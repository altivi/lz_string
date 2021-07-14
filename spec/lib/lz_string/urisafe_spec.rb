describe LZString::UriSafe do
  let(:text)       { '{"some": "json", "foo": [{"bar": "baz"}]}' }
  let(:compressed) { "N4Igzg9gtgpiBcACEArSA7EAaZAzCECiA2qAEYCGATkSJQF4gC+Auk0A" }

  describe ".compress" do
    it "compresses string" do
      expect(described_class.compress(text)).to eq compressed
    end
  end

  describe ".decompress" do
    it "decompresses string" do
      expect(described_class.decompress(compressed)).to eq text
    end
  end
end
