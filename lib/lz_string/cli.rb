require "optparse"
require "lz_string"

module LZString
  # The command line tool. It has the same options as the one of lz-string 2 (JS), so
  # lz-string's own test suite (test/test.sh in its repository) can check this gem too.
  #
  # Like the JS tool it is binary safe: a file is read and written as UTF-16 code units,
  # 2 bytes each, big endian.
  module CLI
    FORMATS = {
      "base64" => LZString::Base64,
      "custom" => LZString::Custom,
      "encodeduri" => LZString::UriSafe,
      "raw" => LZString,
      # The JS tool writes the same bytes for raw and uint8array.
      "uint8array" => LZString,
      "utf16" => LZString::UTF16,
    }.freeze

    # @param argv [Array<String>]
    # @return [Integer] the exit code
    def self.run(argv, stdin: $stdin, stdout: $stdout, stderr: $stderr)
      options = { encoder: "raw" }
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: lz_string [options] [input-file]\n\nUse lz-string to compress or decompress a file"
        opts.separator ""
        opts.separator "Arguments:"
        opts.separator "    input-file                       file to process, if no file then read from stdin"
        opts.separator ""
        opts.separator "Options:"
        opts.on("-V", "--version", "output the version number") { options[:version] = true }
        opts.on("-d", "--decompress", "if unset then this will compress") { options[:decompress] = true }
        opts.on("-e", "--encoder TYPE", FORMATS.keys,
                "character encoding to use (choices: #{FORMATS.keys.join(", ")}, default: raw)") { |type| options[:encoder] = type }
        opts.on("-c", "--custom DICTIONARY", "dictionary for custom encoder") { |dictionary| options[:dictionary] = dictionary }
        opts.on("-v", "--verify", "verify before returning") { options[:verify] = true }
        opts.on("-o", "--output OUTPUT_FILE", "output file, otherwise write to stdout") { |file| options[:output] = file }
        opts.on("-q", "--quiet", "don't print any error messages") { options[:quiet] = true }
        opts.on("-h", "--help", "display help for command") { options[:help] = true }
      end

      begin
        file, = parser.parse(argv)
      rescue OptionParser::ParseError => e
        stderr.puts("error: #{e.message}", parser.help)
        return 1
      end
      return stdout.puts(parser.help) || 0 if options[:help]
      return stdout.puts(LZString::VERSION) || 0 if options[:version]

      error = lambda do |message|
        stderr.puts(message) unless options[:quiet]
        1
      end
      return error.call("Unable to find #{file}") if file && !File.exist?(file)
      return error.call("Unable to access #{file}") if file && !File.readable?(file)

      format = FORMATS.fetch(options[:encoder])
      dictionary = []
      if format == LZString::Custom
        return error.call("The custom encoder needs a dictionary (-c)") unless options[:dictionary]

        dictionary = [options[:dictionary]]
      end

      input = to_string(file ? File.binread(file) : stdin.binmode.read)
      begin
        result = if options[:decompress]
                   format.decompress_to_utf16le(input, *dictionary)
                 else
                   format.compress(input, *dictionary)
                 end
        return error.call("Unable to process #{file || "stdin"}") if result.nil?

        if options[:verify]
          back = options[:decompress] ? format.compress(result, *dictionary) : format.decompress_to_utf16le(result, *dictionary)
          return error.call("Unable to validate #{file || "stdin"}") unless back && Base.code_units(back) == Base.code_units(input)
        end
      rescue ArgumentError, EncodingError
        return error.call("Unable to process #{file || "stdin"}")
      end

      if options[:output]
        File.binwrite(options[:output], to_bytes(result))
      else
        stdout.binmode.write(to_bytes(result))
      end
      0
    end

    # Bytes to a string of UTF-16 code units, 2 bytes each, big endian. A last odd byte is the
    # high byte of a code unit.
    def self.to_string(bytes)
      units = bytes.unpack("C*").each_slice(2).map { |high, low| (high << 8) | low.to_i }
      units.pack("v*").force_encoding(Encoding::UTF_16LE)
    end

    # The other way. Like the JS tool, a last 0 byte is left out, so a file with an odd count
    # of bytes comes back the same.
    def self.to_bytes(string)
      units = Base.code_units(string)
      bytes = units.pack("n*")
      !units.empty? && units.last % 256 == 0 ? bytes.byteslice(0, bytes.bytesize - 1) : bytes
    end
  end
end
