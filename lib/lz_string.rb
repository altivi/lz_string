require "lz_string/base"
require "lz_string/base64"
require "lz_string/utf16"
require "lz_string/urisafe"
require "lz_string/version"

# LZ-based compression algorithm.
module LZString
  # @param input [String]
  def self.compress(input)
    return "" if input.nil?

    result = LZString::Base.compress(input, 16, lambda { |a| [a].pack('v') })
    # Convert to binary string first, then to UTF-8
    result.b.force_encoding('UTF-16LE').encode('UTF-8', invalid: :replace, undef: :replace)
  end

  # @param compressed [String]
  def self.decompress(compressed)
    return "" if compressed.nil? || compressed.empty?
    return nil if compressed == ""

    LZString::Base.decompress(compressed.length, 32768, lambda { |index| compressed[index].ord })
  end
end
