describe LZString do
  let(:text)             { "Hello world!" }
  let(:compressed)       { "҅〶惶@✰Ӏ葀".encode(Encoding::UTF_16LE) }

  describe ".compress" do
    it "compresses string" do
      expect(described_class.compress(text)).to eq compressed
    end

    it "returns UTF-16LE, because the result can have lone surrogates" do
      expect(described_class.compress(text).encoding).to eq Encoding::UTF_16LE
    end

    it "compresses Basic Multilingual Plane (BMP) emoji" do
      expect(described_class.compress("⛩️")).to eq "ꗙ➃切".encode(Encoding::UTF_16LE)
    end

    it "compresses Supplementary Planes emoji" do
      # The last code unit is a lone surrogate, as in JS.
      expect(described_class.compress("🀄").unpack("v*")).to eq [0x8F06, 0xE101, 0xDA00]
    end

    it "compresses empty string like JS" do
      expect(described_class.compress("")).to eq "䀀".encode(Encoding::UTF_16LE)
    end
  end

  describe ".decompress" do
    it "decompresses string" do
      expect(described_class.decompress(compressed)).to eq text
    end

    it "decompresses UTF-8 string" do
      expect(described_class.decompress(compressed.encode(Encoding::UTF_8))).to eq text
    end

    it "decompresses Unicode" do
      expect(described_class.decompress(described_class.compress("❤"))).to eq "❤"
    end

    it "decompresses Supplementary Planes emoji" do
      expect(described_class.decompress(described_class.compress("🀄"))).to eq "🀄"
    end

    it "returns nil for empty string, like JS" do
      expect(described_class.decompress("")).to be_nil
    end

    it "raises like lz-string 2 when the data starts with code 3, which compress never writes" do
      expect { described_class.decompress("쀀") }.to raise_error(ArgumentError, "No character found")
    end

    it "gives the exact JS result with decompress_to_utf16le, also a lone surrogate" do
      half_emoji = [0xD83C].pack("v").force_encoding(Encoding::UTF_16LE)
      result = described_class.decompress_to_utf16le(described_class.compress(half_emoji))
      expect(result.unpack("v*")).to eq [0xD83C]
      expect(described_class.decompress(described_class.compress(result))).to eq "�"
    end
  end
end
