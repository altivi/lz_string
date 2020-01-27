require "lz_string/base"
require "lz_string/base64"
require "lz_string/utf16"
require "lz_string/version"

# LZ-based compression algorithm.
module LZString
  # @param input [String]
  def self.compress(input)
    return "" if input.nil?

    LZString::Base.compress(input, 16, lambda { |a| a.chr("UTF-8") })
  end

  # @param compressed [String]
  def self.decompress(compressed)
    return "" if compressed.nil?
    return nil if compressed == ""

    LZString::Base.decompress(compressed.length, 32768, lambda { |index| compressed[index].ord })
  end
end
