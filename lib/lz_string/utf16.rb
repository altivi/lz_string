module LZString
  # UTF16 compressing algorithm.
  class UTF16
    # @param input [String]
    def self.compress(input)
      return "" if (input == nil)

      LZString::Base.compress(input, 15, lambda { |a| (a + 32).chr("UTF-8") }) + " "
    end

    # @param compressed [String]
    # @return [String, nil] UTF-8
    def self.decompress(compressed)
      LZString::Base.to_utf8(decompress_to_utf16le(compressed))
    end

    # @param compressed [String]
    # @return [String, nil] UTF-16LE, see LZString.decompress_to_utf16le
    def self.decompress_to_utf16le(compressed)
      return "" if (compressed == nil)
      return nil if compressed.empty?

      values = LZString::Base.code_units(compressed)
      LZString::Base.decompress(values.length, 16384, lambda { |index| values[index] ? values[index] - 32 : 0 })
    end
  end
end
