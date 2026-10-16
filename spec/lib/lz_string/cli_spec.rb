require "lz_string/cli"
require "stringio"
require "tmpdir"

describe LZString::CLI do
  # Files from the test data of JS lz-string (github.com/pieroxy/lz-string, test/data, MIT),
  # written by its own command line tool.
  data = File.expand_path("../../fixtures/cli", __dir__)

  def run(*argv, stdin: "")
    stdout = StringIO.new
    stderr = StringIO.new
    code = described_class.run(argv, stdin: StringIO.new(stdin.b), stdout: stdout, stderr: stderr)
    [code, stdout.string.b, stderr.string]
  end

  %w[hello_world repeated].each do |name|
    %w[base64 encodeduri raw uint8array utf16].each do |encoder|
      it "compresses #{name} with #{encoder} to the same bytes as the JS tool" do
        expect(run("-e", encoder, "#{data}/#{name}/data.bin")).to eq [0, File.binread("#{data}/#{name}/#{encoder}.bin"), ""]
      end

      it "decompresses #{name} with #{encoder} like the JS tool" do
        expect(run("-d", "-e", encoder, "#{data}/#{name}/#{encoder}.bin")).to eq [0, File.binread("#{data}/#{name}/data.bin"), ""]
      end
    end
  end

  it "keeps any bytes, also halves of emoji and an odd count of bytes" do
    bytes = "\xD8\x3C\x00\x41\xDF\xB6\xDC\x00\x12".b
    Dir.mktmpdir do |dir|
      File.binwrite("#{dir}/input", bytes)
      %w[base64 custom encodeduri raw uint8array utf16].each do |encoder|
        expect(run("-v", "-e", encoder, "-c", "0123456789", "#{dir}/input", "-o", "#{dir}/compressed")).to eq [0, "", ""]
        expect(run("-v", "-d", "-e", encoder, "-c", "0123456789", "#{dir}/compressed", "-o", "#{dir}/output")).to eq [0, "", ""]
        expect(File.binread("#{dir}/output")).to eq bytes
      end
    end
  end

  it "reads stdin and writes stdout" do
    expect(run(stdin: File.binread("#{data}/hello_world/data.bin"))).to eq [0, File.binread("#{data}/hello_world/raw.bin"), ""]
  end

  it "fails for a file that is not there" do
    expect(run("missing.txt")).to eq [1, "", "Unable to find missing.txt\n"]
  end

  it "fails quietly with -q" do
    expect(run("-q", "missing.txt")).to eq [1, "", ""]
  end

  it "fails for a file it can't read" do
    Dir.mktmpdir do |dir|
      File.write("#{dir}/locked", "x")
      File.chmod(0o000, "#{dir}/locked")
      expect(run("#{dir}/locked")).to eq [1, "", "Unable to access #{dir}/locked\n"]
    end
  end

  it "fails for data it can't decompress" do
    # "/" is 3 in the first 2 bits, which real data never has (JS throws).
    expect(run("-d", "-e", "base64", stdin: "/".encode("UTF-16BE"))).to eq [1, "", "Unable to process stdin\n"]
    # JS returns null for this one.
    expect(run("-d", "-e", "base64", stdin: "NWyU".encode("UTF-16BE"))).to eq [1, "", "Unable to process stdin\n"]
  end

  it "fails to verify data that compresses to something else" do
    # Valid, but with a character more than JS writes.
    expect(run("-v", "-d", "-e", "base64", stdin: "BIUwNmD2AEDukCcwBMCEQ===A".encode("UTF-16BE")))
      .to eq [1, "", "Unable to validate stdin\n"]
  end

  it "needs a dictionary for the custom encoder" do
    expect(run("-e", "custom", stdin: "")).to eq [1, "", "The custom encoder needs a dictionary (-c)\n"]
  end

  it "fails for an unknown encoder" do
    code, output, error = run("-e", "zip")
    expect([code, output, error.lines.first]).to eq [1, "", "error: invalid argument: -e zip\n"]
  end

  it "prints the help and the version" do
    expect(run("-h")[1]).to include "Usage: lz_string [options] [input-file]"
    expect(run("-V")).to eq [0, "#{LZString::VERSION}\n", ""]
  end
end
