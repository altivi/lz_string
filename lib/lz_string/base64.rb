module LZString
  # Base64 compressing algorithm.
  class Base64
    # Base64 alphabet.
    KEY_STR_BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
    # Code unit of each alphabet character => its value.
    VALUES = KEY_STR_BASE64.each_char.with_index.map { |char, i| [char.ord, i] }.to_h

    # @param input [String]
    def self.compress(input)
      return "" if input.nil?

      res = LZString::Base.compress(input, 6, lambda { |a| KEY_STR_BASE64[a] })

      # To produce valid Base64
      case (res.length % 4)
      when 0 then res
      when 1 then res + "==="
      when 2 then res + "=="
      when 3 then res + "="
      end
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

      # Like in JS, a character outside the alphabet counts as 0.
      values = LZString::Base.code_units(compressed).map { |unit| VALUES.fetch(unit, 0) }
      LZString::Base.decompress(values.length, 32, lambda { |index| values[index] || 0 })
    end
  end
end
