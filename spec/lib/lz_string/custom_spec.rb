describe LZString::Custom do
  let(:hex) { "0123456789abcdef" }
  let(:compressed) { "0485303660f60040ee90273004c08440" }

  describe ".compress" do
    it "writes each code unit with the characters of the dictionary, like JS" do
      expect(described_class.compress("Hello world!", hex)).to eq compressed
    end

    it "needs at least 2 characters in the dictionary" do
      expect { described_class.compress("Hello world!", "a") }.to raise_error(ArgumentError)
    end

    it "gives an empty string for nil, like JS" do
      expect(described_class.compress(nil, hex)).to eq ""
    end
  end

  describe ".decompress" do
    it "decompresses string" do
      expect(described_class.decompress(compressed, hex)).to eq "Hello world!"
    end

    it "returns nil like JS for a short dictionary or a wrong length" do
      expect(described_class.decompress(compressed, "a")).to be_nil
      expect(described_class.decompress(compressed.chop, hex)).to be_nil
      expect(described_class.decompress("", hex)).to be_nil
    end

    it "gives an empty string for nil, like JS" do
      expect(described_class.decompress(nil, hex)).to eq ""
    end
  end
end
