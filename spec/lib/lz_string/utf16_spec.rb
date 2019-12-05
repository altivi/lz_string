describe LZString::UTF16 do
  let(:text)       { '{"some": "json", "foo": [{"bar": "؋", "key": "؄"}], "ঞᕠ": "൱ඵቜ"}' }
  let(:compressed) { "ᯡࡓ䈌\u0B80匰ᜠр\u0AF2Ǹ䀺㈦イ\u0530්C¦¼䒨ᨬිǌ〩痐࠸С㸢璑Ч䲤U⋴ҕ䈥㛢ĉ႙  " }

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
