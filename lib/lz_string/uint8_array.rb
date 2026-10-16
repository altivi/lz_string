module LZString
  # Uint8Array compressing algorithm: the raw result as bytes, 2 per code unit, big endian.
  class Uint8Array
    # @param input [String]
    # @return [String] binary (ASCII-8BIT)
    def self.compress(input)
      LZString.compress(input).unpack("v*").pack("n*")
    end

    # @param compressed [String, Array<Integer>] the bytes, as a binary string or a list of numbers
    # @return [String, nil] UTF-8
    def self.decompress(compressed)
      LZString::Base.to_utf8(decompress_to_utf16le(compressed))
    end

    # @param compressed [String, Array<Integer>]
    # @return [String, nil] UTF-16LE, see LZString.decompress_to_utf16le
    def self.decompress_to_utf16le(compressed)
      return "" if compressed.nil?

      bytes = compressed.is_a?(String) ? compressed.bytes : compressed
      # Like lz-string 2, a last odd byte is the high byte of the last code unit.
      units = bytes.each_slice(2).map { |high, low| (high << 8) | low.to_i }
      LZString.decompress_to_utf16le(units.pack("v*").force_encoding(Encoding::UTF_16LE))
    end
  end
end
