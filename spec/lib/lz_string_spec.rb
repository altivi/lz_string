describe LZString do
  let(:text)             { "Hello world!" }
  let(:compressed)       { "҅〶惶@✰Ӏ葀" }

  describe ".compress" do
    it "compresses string" do
      expect(described_class.compress(text)).to eq compressed
    end

    it "compresses emoji" do
      expect(described_class.compress("❤")).to eq "覹က"
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
