module LZString
  class UriSafe
    # Base64 alphabet.
    KEY_STR_URISAFE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-$"
    # Code unit of each alphabet character => its value.
    VALUES = KEY_STR_URISAFE.each_char.with_index.map { |char, i| [char.ord, i] }.to_h

    # @param input [String]
    def self.compress(input)
      return "" if input.nil?

      LZString::Base.compress(input, 6, lambda { |a| KEY_STR_URISAFE[a] })
    end

    # @param compressed [String]
    # @return [String, nil] UTF-8
    def self.decompress(compressed)
      LZString::Base.to_utf8(decompress_to_utf16le(compressed))
    end

    # @param compressed [String]
    # @return [String, nil] UTF-16LE, see LZString.decompress_to_utf16le
    def self.decompress_to_utf16le(compressed)
      return "" if compressed.nil?
      return nil if compressed.empty?

      # Like in JS, a space is read as "+" (a URL can turn "+" into a space),
      # and any other character outside the alphabet counts as 0.
      values = LZString::Base.code_units(compressed).map { |unit| VALUES.fetch(unit == " ".ord ? "+".ord : unit, 0) }
      LZString::Base.decompress(values.length, 32, lambda { |index| values[index] || 0 })
    end
  end
end
