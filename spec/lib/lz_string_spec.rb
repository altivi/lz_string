describe LZString do
  let(:text)             { "Hello world!" }
  let(:compressed)       { "҅〶惶@✰Ӏ葀" }

  describe ".compress" do
    it "compresses string" do
      expect(described_class.compress(text)).to eq compressed
    end

    it "compresses Basic Multilingual Plane (BMP) emoji" do
      expect(described_class.compress("⛩️")).to eq "ꗙ➃切"
    end

    it "compresses Supplementary Planes emoji" do
      expect(described_class.compress("🀄")).to eq "輆�"
    end
  end

  describe ".decompress" do
    it "decompresses string" do
      expect(described_class.decompress(compressed)).to eq text
    end

    it "decompresses Unicode" do
      expect(described_class.decompress(described_class.compress("❤"))).to eq "❤"
    end
  end
end
