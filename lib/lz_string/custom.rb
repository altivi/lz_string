module LZString
  # Custom compressing algorithm: writes each code unit of the raw result as a number,
  # with a fixed count of digits from your own alphabet (from lz-string 2).
  class Custom
    # @param input      [String]
    # @param dictionary [String] the alphabet: at least 2 characters
    # @return [String] UTF-8
    def self.compress(input, dictionary)
      return "" if input.nil?

      alphabet = LZString::Base.code_units(dictionary)
      # JS never ends with a 1-character alphabet.
      raise ArgumentError, "The dictionary needs at least 2 characters" if alphabet.size < 2

      digits = digits_per_code_unit(alphabet.size)
      units = LZString.compress(input).unpack("v*").flat_map do |unit|
        (digits - 1).downto(0).map { |j| alphabet[unit / alphabet.size**j % alphabet.size] }
      end
      units.pack("v*").force_encoding(Encoding::UTF_16LE).encode(Encoding::UTF_8)
    end

    # @param compressed [String]
    # @param dictionary [String]
    # @return [String, nil] UTF-8
    def self.decompress(compressed, dictionary)
      LZString::Base.to_utf8(decompress_to_utf16le(compressed, dictionary))
    end

    # @param compressed [String]
    # @param dictionary [String]
    # @return [String, nil] UTF-16LE, see LZString.decompress_to_utf16le
    def self.decompress_to_utf16le(compressed, dictionary)
      return "" if compressed.nil?
      return nil if compressed.empty?

      alphabet = LZString::Base.code_units(dictionary)
      return nil if alphabet.size < 2

      digits = digits_per_code_unit(alphabet.size)
      units = LZString::Base.code_units(compressed)
      return nil if units.size % digits != 0

      # The first place of each character, like indexOf in JS.
      places = {}
      alphabet.each_with_index { |unit, place| places[unit] ||= place }
      values = units.each_slice(digits).map do |number|
        # Like JS: a character outside the alphabet counts as -1, and String.fromCharCode keeps 16 bits.
        number.reduce(0) { |value, unit| value * alphabet.size + places.fetch(unit, -1) } & 0xFFFF
      end
      LZString.decompress_to_utf16le(values.pack("v*").force_encoding(Encoding::UTF_16LE))
    end

    # Digits needed for 65536 values. Same float math as JS (checked for every size up to 70000).
    def self.digits_per_code_unit(base)
      (Math.log(65536) / Math.log(base)).ceil
    end

    private_class_method :digits_per_code_unit
  end
end
