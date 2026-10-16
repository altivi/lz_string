require "lz_string/base"
require "lz_string/base64"
require "lz_string/custom"
require "lz_string/uint8_array"
require "lz_string/urisafe"
require "lz_string/utf16"
require "lz_string/version"

# LZ-based compression algorithm.
module LZString
  # Returns the same UTF-16 code units as LZString.compress in JS. Like in JS, they are often not
  # valid UTF-16 (a lone surrogate), and UTF-8 can't hold them, so the result is a UTF-16LE string.
  #
  # @param input [String]
  # @return [String] UTF-16LE
  def self.compress(input)
    return "" if input.nil?

    LZString::Base.compress(input, 16, lambda { |a| [a].pack("v") }).force_encoding(Encoding::UTF_16LE)
  end

  # @param compressed [String] the UTF-16LE string from .compress (other encodings work too)
  # @return [String, nil] UTF-8
  def self.decompress(compressed)
    LZString::Base.to_utf8(decompress_to_utf16le(compressed))
  end

  # Like .decompress, but gives the result exactly as JS has it: a UTF-16LE string, which can
  # also hold a lone surrogate (half of an emoji). Every format has this method.
  #
  # @param compressed [String]
  # @return [String, nil] UTF-16LE
  def self.decompress_to_utf16le(compressed)
    return "" if compressed.nil?
    return nil if compressed.empty?

    values = LZString::Base.code_units(compressed)
    LZString::Base.decompress(values.length, 32768, lambda { |index| values[index] || 0 })
  end
end
