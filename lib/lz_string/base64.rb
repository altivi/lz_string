module LZString
  # Base64 compressing algorithm.
  class Base64
    # Base64 alphabet.
    KEY_STR_BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="

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
    def self.decompress(compressed)
      return "" if compressed.nil?
      return nil if compressed == ""

      LZString::Base.decompress(
        compressed.length,
        32,
        lambda { |index| get_base_value(KEY_STR_BASE64, compressed[index]) }
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
