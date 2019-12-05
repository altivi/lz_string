# lz-string
Ruby implementation of [LZ-String](https://github.com/pieroxy/lz-string) compression algorithm.

Supports:
 * Raw compression
 * UTF-16 compression
 * Base64 compression

### Installation

Install the latest release:

```
$ gem install lz_string
```

In Rails, add it to your Gemfile:

```ruby
gem 'lz_string'
```

### How to use

#### Normal Compression and Decompression:

``` ruby
  # Compress
  compressed = LZString.compress("Hello world!")
  => "҅〶惶@✰Ӏ葀"
  
  # Decompress
  LZString.decompress(compressed)
  => "Hello world!"
```

#### UTF-16 Compression and Decompression:

``` ruby
  some_string = '{"some": "json", "foo": [{"bar": "؋", "key": "؄"}], "ঞᕠ": "൱ඵቜ"}'
  
  # Compress
  compressed = LZString::UTF16.compress(some_string)
  => "ᯡࡓ䈌\u0B80匰ᜠр\u0AF2Ǹ䀺㈦イ\u0530්C¦¼䒨ᨬිǌ〩痐࠸С㸢璑Ч䲤U⋴ҕ䈥㛢ĉ႙  "
  
  # Decompress
  LZString::UTF16.decompress(compressed)
  => "{\"some\": \"json\", \"foo\": [{\"bar\": \"؋\", \"key\": \"؄\"}], \"ঞᕠ\": \"൱ඵቜ\"}"
```

#### Base64 Compression and Decompression:

``` ruby		
  # Compress
  compressed = LZString::Base64.compress("Hello world!")
  => "BIUwNmD2AEDukCcwBMCEQ==="
  
  # Decompress
  LZString::Base64.decompress(compressed)
  => "Hello world!"
```
 
### Tests

``` bash
$ rake
```
