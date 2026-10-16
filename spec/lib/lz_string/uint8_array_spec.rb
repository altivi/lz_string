describe LZString::Uint8Array do
  let(:bytes) { "\x8F\x06\xE3\x6F\xDA\x00".b }

  describe ".compress" do
    it "compresses emoji to the same bytes as JS" do
      expect(described_class.compress("🎶")).to eq bytes
    end

    it "gives no bytes for nil, like JS" do
      expect(described_class.compress(nil)).to eq ""
    end
  end

  describe ".decompress" do
    it "decompresses a binary string" do
      expect(described_class.decompress(bytes)).to eq "🎶"
    end

    it "decompresses a list of numbers" do
      expect(described_class.decompress(bytes.bytes)).to eq "🎶"
    end

    it "decompresses an odd count of bytes, like lz-string 2" do
      expect(described_class.decompress(bytes.byteslice(0, 5))).to eq "🎶"
    end

    it "returns nil for no bytes and an empty string for nil, like JS" do
      expect(described_class.decompress("")).to be_nil
      expect(described_class.decompress(nil)).to eq ""
    end
  end
end
