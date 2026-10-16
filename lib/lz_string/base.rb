module LZString
  # Base compression class.
  #
  # A port of lz-string (JavaScript) that gives the same results as lz-string 2, and as 1.5.0 for
  # all real data. JS strings are made of UTF-16 code units, so the work here is done on code units
  # too: an emoji like "🎶" is two units.
  class Base
    # JS keeps the dictionary in a plain object, and an object can't store the key "__proto__".
    # So JS never finds that word in its dictionary, and we must not find it either.
    PROTO = "__proto__".encode(Encoding::UTF_16LE).b.freeze

    # @param string [String]
    # @return [Array<Integer>] the UTF-16 code units, like charCodeAt in JS
    def self.code_units(string)
      string.encode(Encoding::UTF_16LE).unpack("v*")
    end

    # UTF-8 can't hold a lone surrogate. Like JS TextEncoder, we write "�" for it.
    #
    # @param string [String, nil] UTF-16LE
    # @return [String, nil] UTF-8
    def self.to_utf8(string)
      string && string.encode(Encoding::UTF_8, invalid: :replace)
    end

    # @param uncompressed      [String]
    # @param bits_per_char     [Integer]
    # @param get_char_from_int [Proc]
    def self.compress(uncompressed, bits_per_char, get_char_from_int)
      return "" if uncompressed.nil?

      dictionary = {}
      dictionary_to_create = {}
      w = "".b
      # Compensate for the first entry which should not count
      enlarge_in = 2
      dict_size = 3
      num_bits = 2
      data = []
      data_val = 0
      data_position = 0

      # Writes the lowest `count` bits of `value`, lowest bit first.
      write_bits = lambda do |value, count|
        count.times do
          data_val = (data_val << 1) | (value & 1)
          if data_position == bits_per_char - 1
            data_position = 0
            data << get_char_from_int.call(data_val)
            data_val = 0
          else
            data_position += 1
          end
          value >>= 1
        end
      end

      # Writes the code for w: a new character, or its place in the dictionary.
      write_w = lambda do
        if dictionary_to_create.key?(w)
          code_unit = w.unpack1("v")
          if code_unit < 256
            write_bits.call(0, num_bits)
            write_bits.call(code_unit, 8)
          else
            write_bits.call(1, num_bits)
            write_bits.call(code_unit, 16)
          end
          enlarge_in -= 1
          if enlarge_in == 0
            enlarge_in = 2**num_bits
            num_bits += 1
          end
          dictionary_to_create.delete(w)
        else
          write_bits.call(dictionary[w], num_bits)
        end
        enlarge_in -= 1
        if enlarge_in == 0
          enlarge_in = 2**num_bits
          num_bits += 1
        end
      end

      # Each character is one UTF-16 code unit: 2 bytes, little endian.
      input = uncompressed.encode(Encoding::UTF_16LE).b
      0.step(input.bytesize - 1, 2) do |i|
        c = input.byteslice(i, 2)
        unless dictionary.key?(c)
          dictionary[c] = dict_size
          dict_size += 1
          dictionary_to_create[c] = true
        end

        wc = w + c
        if dictionary.key?(wc)
          w = wc
        else
          write_w.call
          # Add wc to the dictionary.
          dictionary[wc] = dict_size unless wc == PROTO
          dict_size += 1
          w = c
        end
      end

      # Output the code for w.
      write_w.call unless w.empty?

      # Mark the end of the stream
      write_bits.call(2, num_bits)

      # Flush the last char
      loop do
        data_val <<= 1
        if data_position == bits_per_char - 1
          data << get_char_from_int.call(data_val)
          break
        end
        data_position += 1
      end

      data.join
    end

    # @param length         [Integer]
    # @param reset_value    [Integer]
    # @param get_next_value [Proc]
    # @return [String, nil] UTF-16LE, exactly as JS has it (it can hold lone surrogates)
    def self.decompress(length, reset_value, get_next_value)
      dictionary = [0, 1, 2]
      enlarge_in = 4
      dict_size = 4
      num_bits = 3
      result = []
      data_val = get_next_value.call(0)
      data_position = reset_value
      data_index = 1

      # Reads `count` bits, lowest bit first.
      read_bits = lambda do |count|
        bits = 0
        count.times do |i|
          resb = data_val & data_position
          data_position >>= 1
          if data_position == 0
            data_position = reset_value
            data_val = get_next_value.call(data_index)
            data_index += 1
          end
          bits |= 1 << i if resb > 0
        end
        bits
      end

      # Each character is one UTF-16 code unit: 2 bytes, little endian.
      c = case read_bits.call(2)
          when 0 then [read_bits.call(8)].pack("v")
          when 1 then [read_bits.call(16)].pack("v")
          when 2 then return "".encode(Encoding::UTF_16LE)
          # Real data never starts with 3. lz-string 2 throws here, so we raise too
          # (1.5.0 went on with an undefined value and gave junk, null or a TypeError).
          else raise ArgumentError, "No character found"
          end
      dictionary[3] = c
      w = c
      result << c

      loop do
        return "".encode(Encoding::UTF_16LE) if data_index > length

        case (c = read_bits.call(num_bits))
        when 0, 1
          dictionary[dict_size] = [read_bits.call(c == 0 ? 8 : 16)].pack("v")
          c = dict_size
          dict_size += 1
          enlarge_in -= 1
        when 2
          return result.join.force_encoding(Encoding::UTF_16LE)
        end

        if enlarge_in == 0
          enlarge_in = 2**num_bits
          num_bits += 1
        end

        if dictionary[c]
          entry = dictionary[c]
        elsif c == dict_size
          entry = w + w.byteslice(0, 2)
        else
          return nil
        end
        result << entry

        # Add w+entry[0] to the dictionary.
        dictionary[dict_size] = w + entry.byteslice(0, 2)
        dict_size += 1
        enlarge_in -= 1

        w = entry

        if enlarge_in == 0
          enlarge_in = 2**num_bits
          num_bits += 1
        end
      end
    end
  end
end
