module LZString
  # Base compression class.
  class Base
    # @param uncompressed      [String]
    # @param bits_per_char     [Integer]
    # @param get_char_from_int [Integer]
    def self.compress(uncompressed, bits_per_char, get_char_from_int)
      return "" if uncompressed.nil?

      i, value, ii = nil
      context_dictionary = {}
      context_dictionary_to_create = {}
      context_c = ""
      context_wc = ""
      context_w = ""
      # Compensate for the first entry which should not count
      context_enlarge_in = 2
      context_dict_size = 3
      context_num_bits = 2
      context_data = []
      context_data_val = 0
      context_data_position = 0

      for ii in 0...uncompressed.length do
        context_c = uncompressed[ii]

        if (!context_dictionary.has_key?(context_c))
          context_dictionary[context_c] = context_dict_size
          context_dictionary_to_create[context_c] = true
          context_dict_size += 1
        end

        context_wc = context_w + context_c
        if (context_dictionary.has_key?(context_wc))
          context_w = context_wc
        else
          if (context_dictionary_to_create.has_key?(context_w))
            if (context_w[0].ord < 256)
              for i in 0...context_num_bits do
                context_data_val = (context_data_val << 1)
                if (context_data_position == bits_per_char - 1)
                  context_data_position = 0
                  context_data.push(get_char_from_int[context_data_val])
                  context_data_val = 0
                else
                  context_data_position += 1
                end
              end

              value = context_w[0].ord
              for i in 0...8 do
                context_data_val = (context_data_val << 1) | (value & 1)
                if (context_data_position == bits_per_char - 1)
                  context_data_position = 0
                  context_data.push(get_char_from_int[context_data_val])
                  context_data_val = 0
                else
                  context_data_position += 1
                end
                value = value >> 1
              end
            else
              value = 1
              for i in 0...context_num_bits do
                context_data_val = (context_data_val << 1) | value
                if (context_data_position == bits_per_char-1)
                  context_data_position = 0
                  context_data.push(get_char_from_int[context_data_val])
                  context_data_val = 0
                else
                  context_data_position += 1
                end
                value = 0
              end
              value = context_w[0].ord
              for i in 0...16 do
                context_data_val = (context_data_val << 1) | (value & 1)
                if (context_data_position == bits_per_char - 1)
                  context_data_position = 0
                  context_data.push(get_char_from_int[context_data_val])
                  context_data_val = 0
                else
                  context_data_position += 1
                end
                value = value >> 1
              end
            end
            context_enlarge_in -= 1
            if (context_enlarge_in == 0)
              context_enlarge_in = 2**context_num_bits
              context_num_bits += 1
            end
            context_dictionary_to_create.delete(context_w)
          else
            value = context_dictionary[context_w]
            for i in 0...context_num_bits do
              context_data_val = (context_data_val << 1) | (value & 1)
              if (context_data_position == bits_per_char - 1)
                context_data_position = 0
                context_data.push(get_char_from_int[context_data_val])
                context_data_val = 0
              else
                context_data_position += 1
              end
              value = value >> 1
            end
          end

          context_enlarge_in -= 1

          if (context_enlarge_in == 0)
            context_enlarge_in = 2**context_num_bits
            context_num_bits += 1
          end

          # Add wc to the dictionary.
          context_dictionary[context_wc] = context_dict_size
          context_dict_size += 1
          context_w = context_c.to_s
        end
      end

      # Output the code for w.
      if (context_w != "")
        if (context_dictionary_to_create.has_key?(context_w))
          if (context_w[0].ord < 256)
            for i in 0...context_num_bits do
              context_data_val = (context_data_val << 1)
              if (context_data_position == bits_per_char-1)
                context_data_position = 0
                context_data.push(get_char_from_int[context_data_val])
                context_data_val = 0
              else
                context_data_position += 1
              end
            end
            value = context_w[0].ord
            for i in 0...8 do
              context_data_val = (context_data_val << 1) | (value & 1)
              if (context_data_position == bits_per_char-1)
                context_data_position = 0
                context_data.push(get_char_from_int[context_data_val])
                context_data_val = 0
              else
                context_data_position += 1
              end
              value = value >> 1
            end
          else
            value = 1
            for i in 0...context_num_bits do
              context_data_val = (context_data_val << 1) | value
              if (context_data_position == bits_per_char-1)
                context_data_position = 0
                context_data.push(get_char_from_int[context_data_val])
                context_data_val = 0
              else
                context_data_position += 1
              end
              value = 0
            end
            value = context_w[0].ord
            for i in 0...16 do
              context_data_val = (context_data_val << 1) | (value & 1)
              if (context_data_position == bits_per_char-1)
                context_data_position = 0
                context_data.push(get_char_from_int[context_data_val])
                context_data_val = 0
              else
                context_data_position += 1
              end
              value = value >> 1
            end
          end
          context_enlarge_in -= 1
          if (context_enlarge_in == 0)
            context_enlarge_in = 2**context_num_bits
            context_num_bits += 1
          end
          context_dictionary_to_create.delete(context_w)
        else
          value = context_dictionary[context_w]
          for i in 0...context_num_bits
            context_data_val = (context_data_val << 1) | (value & 1)
            if (context_data_position == bits_per_char-1)
              context_data_position = 0
              context_data.push(get_char_from_int[context_data_val])
              context_data_val = 0
            else
              context_data_position += 1
            end
            value = value >> 1
          end
        end

        context_enlarge_in -= 1
        if (context_enlarge_in == 0)
          context_enlarge_in = 2**context_num_bits
          context_num_bits += 1
        end
      end

      # Mark the end of the stream
      value = 2
      for i in 0...context_num_bits do
        context_data_val = (context_data_val << 1) | (value & 1)
        if (context_data_position == bits_per_char - 1)
          context_data_position = 0
          context_data.push(get_char_from_int[context_data_val])
          context_data_val = 0
        else
          context_data_position += 1
        end
        value = value >> 1
      end

      # Flush the last char
      while (true)
        context_data_val = (context_data_val << 1)
        if (context_data_position == bits_per_char-1)
          context_data.push(get_char_from_int[context_data_val])
          break
        else
          context_data_position += 1
        end
      end

      return context_data.join("")
    end

    # @param length         [Integer]
    # @param reset_value    [Integer]
    # @param get_next_value [Proc]
    def self.decompress(length, reset_value, get_next_value, encoding = "ASCII-8BIT")
      dictionary = [0, 1, 2]
      enlarge_in = 4
      dict_size = 4
      num_bits = 3
      entry = ""
      result = []
      data = {
        val: get_next_value[(0)],
        position: reset_value,
        index: 1
      }
      bits = 0
      maxpower = 2**2
      power = 1
      i, w, resb, c = nil

      while (power != maxpower)
        resb = data[:val] & data[:position]
        data[:position] >>= 1
        if (data[:position] == 0)
          data[:position] = reset_value
          data[:val] = get_next_value[data[:index]]
          data[:index] += 1
        end
        bits |= (resb > 0 ? 1 : 0) * power
        power <<= 1
      end

      case(n = bits)
      when 0
        bits = 0
        maxpower = 2**8
        power = 1
        while power != maxpower
          resb = data[:val] & data[:position]
          data[:position] >>= 1
          if (data[:position] == 0)
            data[:position] = reset_value
            data[:val] = get_next_value[data[:index]]
            data[:index] += 1
          end
          bits |= (resb > 0 ? 1 : 0) * power
          power <<= 1
        end
        c = bits.chr(encoding)
      when 1
        bits = 0
        maxpower = 2*16
        power = 1
        while (power != maxpower)
          resb = data[:val] & data[:position]
          data[:position] >>= 1
          if (data[:position] == 0)
              data[:position] = reset_value
              data[:val] = get_next_value[data[:index]]
              data[:index] += 1
          end
          bits |= (resb > 0 ? 1 : 0) * power
          power <<= 1
        end
        c = bits.chr(encoding)
      when 2
        ""
      end

      dictionary[3] = c
      w = c
      result << c

      while(true)
        return "" if (data[:index] > length)

        bits = 0
        maxpower = 2**num_bits
        power = 1
        while (power != maxpower)
          resb = data[:val] & data[:position]
          data[:position] >>= 1
          if (data[:position] == 0)
            data[:position] = reset_value
            data[:val] = get_next_value[data[:index]]
            data[:index] += 1
          end
          bits |= (resb > 0 ? 1 : 0) * power
          power <<= 1
        end

        case(c = bits)
        when 0
          bits = 0
          maxpower = 2**8
          power = 1
          while (power != maxpower)
            resb = data[:val] & data[:position]
            data[:position] >>= 1
            if (data[:position] == 0)
              data[:position] = reset_value
              data[:val] = get_next_value[data[:index]]
              data[:index] += 1
            end
            bits |= (resb > 0 ? 1 : 0) * power
            power <<= 1
          end

          dictionary[dict_size] = bits.chr(encoding)
          dict_size += 1
          c = dict_size - 1
          enlarge_in -= 1
        when 1
          bits = 0
          maxpower = 2**16
          power = 1
          while (power != maxpower)
            resb = data[:val] & data[:position]
            data[:position] >>= 1
            if (data[:position] == 0)
              data[:position] = reset_value
              data[:val] = get_next_value[data[:index]]
              data[:index] += 1
            end
            bits |= (resb > 0 ? 1 : 0) * power
            power <<= 1
          end
          dictionary[dict_size] = bits.chr(encoding)
          dict_size += 1
          c = dict_size - 1
          enlarge_in -= 1
        when 2
          return result.join("")
        end

        if (enlarge_in == 0)
          enlarge_in = 2**num_bits
          num_bits += 1
        end

        if (dictionary[c])
          entry = dictionary[c]
        else
          if (c === dict_size)
              entry = w + w[0]
          else
            return nil
          end
        end

        result << entry

        # Add w+entry[0] to the dictionary.
        dictionary[dict_size] = w + entry[0]
        dict_size += 1
        enlarge_in -= 1

        w = entry

        if (enlarge_in == 0)
          enlarge_in = 2**num_bits
          num_bits += 1
        end
      end
    end
  end
end
