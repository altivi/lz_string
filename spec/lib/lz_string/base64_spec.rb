describe LZString::Base64 do
  let(:text)       { "Hello world!!!!!!!" }
  let(:compressed) { "BIUwNmD2AEDukCcwBMCE6OqA" }

  describe ".compress" do
    context "when res.length == 0" do
      it "compresses string" do
        expect(described_class.compress(text)).to eq compressed
      end
    end

    context "when res.length == 1" do
      let(:text)       { "Hello world!" }
      let(:compressed) { "BIUwNmD2AEDukCcwBMCEQ===" }

      it "compresses string" do
        expect(described_class.compress(text)).to eq compressed
      end
    end

    context "when res.length == 2" do
      let(:text)       { "Hello world!!" }
      let(:compressed) { "BIUwNmD2AEDukCcwBMCEqg==" }

      it "compresses string" do
        expect(described_class.compress(text)).to eq compressed
      end
    end

    context "when res.length == 3" do
      let(:text)       { "Hello world!!!!" }
      let(:compressed) { "BIUwNmD2AEDukCcwBMCE7VA=" }

      it "compresses string" do
        expect(described_class.compress(text)).to eq compressed
      end
    end

    # The examples from https://github.com/altivi/lz_string/issues/3
    it "compresses Unicode like JS" do
      expect(described_class.compress("ö")).to eq "G9A="
      expect(described_class.compress("❤")).to eq "ibkQ"
      expect(described_class.compress("🎶")).to eq "jwbjb9o="
    end
  end

  describe ".decompress" do
    it "decompresses string" do
      expect(described_class.decompress(compressed)).to eq text
    end

    it "decompresses Unicode" do
      expect(described_class.decompress("G9A=")).to eq "ö"
      expect(described_class.decompress("ibkQ")).to eq "❤"
      expect(described_class.decompress("jwbjb9o=")).to eq "🎶"
    end

    it "returns UTF-8" do
      expect(described_class.decompress(compressed).encoding).to eq Encoding::UTF_8
    end
  end
end
