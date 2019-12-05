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
  end

  describe ".decompress" do
    it "decompresses string" do
      expect(described_class.decompress(compressed)).to eq text
    end
  end
end
