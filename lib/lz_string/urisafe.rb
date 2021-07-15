module LZString
  class UriSafe
    # Base64 alphabet.
    KEY_STR_URISAFE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-$"

    # @param input [String]
    def self.compress(input)
      return "" if input.nil?

      LZString::Base.compress(input, 6, lambda { |a| KEY_STR_URISAFE[a] })
    end

    # @param compressed [String]
    def self.decompress(compressed)
      return "" if compressed.nil?
      return nil if compressed == ""
      compressed.gsub!(" ","+")
      LZString::Base.decompress(
        compressed.length,
        32,
        lambda { |index| get_base_value(KEY_STR_URISAFE, compressed[index]) }
      )
    end

    # @param alphabet  [String]
    # @param character [String]
    def self.get_base_value(alphabet, character)
      base_reverse_dic = {}

      if (!base_reverse_dic[alphabet])
        base_reverse_dic[alphabet] = {}
        for i in 0...alphabet.length do
          base_reverse_dic[alphabet][alphabet[i]] = i
        end
      end

      base_reverse_dic[alphabet][character]
    end

    private_class_method :get_base_value
  end
end
