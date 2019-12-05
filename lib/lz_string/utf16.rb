module LZString
  # UTF16 compressing algorithm.
  class UTF16
    # @param input [String]
    def self.compress(input)
      return "" if (input == nil)

      LZString::Base.compress(input, 15, lambda { |a| (a + 32).chr("UTF-8") }) + " "
    end

    # @param compressed [String]
    def self.decompress(compressed)
      return "" if (compressed == nil)
      return nil if (compressed == "")

      LZString::Base.decompress(
        compressed.length,
        16384,
        lambda { |index| compressed[index].ord - 32 },
        "UTF-8"
      )
    end
  end
end
