require "json"

# js_results.json holds what JavaScript lz-string returned (see spec/fixtures/js_results.js).
describe "Same results as JavaScript lz-string" do
  results = JSON.parse(File.read(File.expand_path("../../fixtures/js_results.json", __dir__)))
  formats = {
    "raw" => LZString, "base64" => LZString::Base64, "uri" => LZString::UriSafe,
    "utf16" => LZString::UTF16, "uint8array" => LZString::Uint8Array,
  }

  # Bytes come as hex. A list of numbers is a string of UTF-16 code units,
  # because JSON can't hold a lone surrogate.
  def from_json(value, format = nil)
    return [value].pack("H*") if format == "uint8array"

    value.is_a?(Array) ? value.pack("v*").force_encoding(Encoding::UTF_16LE) : value
  end

  # What came out, in the shape of the JSON: the text, or the error message.
  def outcome
    { "output" => yield }
  rescue ArgumentError => e
    { "error" => e.message }
  end

  formats.each do |name, format|
    describe format do
      it "compresses #{results["compress"].size} strings like JS #{results["lz_string"]}" do
        wrong = results["compress"].reject do |result|
          format.compress(from_json(result["input"])) == from_json(result[name], name)
        end
        expect(wrong.map { |result| result["input"] }).to eq []
      end

      it "decompresses what JS compressed" do
        wrong = results["compress"].reject do |result|
          format.decompress(from_json(result[name], name)) == result.fetch("text", result["input"])
        end
        expect(wrong.map { |result| result["input"] }).to eq []
      end

      it "decompresses #{results["decompress"][name].size} broken strings like JS" do
        wrong = results["decompress"][name].reject do |result|
          outcome { format.decompress(from_json(result["input"], name)) } == result.slice("output", "error")
        end
        expect(wrong.map { |result| result["input"] }).to eq []
      end
    end
  end

  describe LZString::Custom do
    it "compresses #{results["custom"].size} strings like JS" do
      wrong = results["custom"].reject do |result|
        LZString::Custom.compress(from_json(result["input"]), result["dictionary"]) == result["output"]
      end
      expect(wrong.map { |result| result["input"] }).to eq []
    end

    it "decompresses what JS compressed" do
      wrong = results["custom"].reject do |result|
        outcome { LZString::Custom.decompress(result["output"], result["dictionary"]) } == result["decompressed"]
      end
      expect(wrong.map { |result| result["input"] }).to eq []
    end

    it "decompresses #{results["decompress"]["custom"].size} broken strings like JS" do
      wrong = results["decompress"]["custom"].reject do |result|
        outcome { LZString::Custom.decompress(result["input"], result["dictionary"]) } == result.slice("output", "error")
      end
      expect(wrong.map { |result| result["input"] }).to eq []
    end
  end
end
