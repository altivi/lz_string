describe LZString do
  let(:text)         { "Hello world!" }
  let(:compressed)   { "҅〶惶@✰Ӏ葀" }

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
