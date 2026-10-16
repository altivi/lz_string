# lz_string

[![Gem Version](https://img.shields.io/gem/v/lz_string?logo=rubygems&logoColor=white)](https://rubygems.org/gems/lz_string)
[![Downloads](https://img.shields.io/gem/dt/lz_string?logo=rubygems&logoColor=white&label=downloads)](https://rubygems.org/gems/lz_string)
[![Downloads of the latest version](https://img.shields.io/gem/dtv/lz_string?logo=rubygems&logoColor=white&label=downloads%40latest)](https://rubygems.org/gems/lz_string)
[![Tests](https://github.com/altivi/lz_string/actions/workflows/test.yml/badge.svg)](https://github.com/altivi/lz_string/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Ruby port of [lz-string](https://github.com/pieroxy/lz-string), the LZ-based compression for JavaScript.

It gives **the same results as the JavaScript library, for every input**: any text, emoji too, and even broken data.
So you can compress in the browser and decompress in Ruby, or the other way round.

- **Every format of lz-string:** raw, Base64, URI-safe, UTF-16, Uint8Array and your own alphabet.
- **Tested against JavaScript:** it passes [the test suite of lz-string itself](https://github.com/pieroxy/lz-string/tree/master/test)
  (70 of 70 checks), and its specs check it against results of the JavaScript library.
- **The same command line tool** as lz-string 2, with the same options.
- No dependencies. Ruby 2.7 or newer.

## Install

```console
$ gem install lz_string
```

Or add it to your Gemfile:

```ruby
gem "lz_string"
```

## Use

```ruby
require "lz_string"

compressed = LZString.compress_to_base64("Hello, 🎶 world!")
# => "BIUwNmD2A0AEg8G4Nv3YHdICcwBMCEQ="
LZString.decompress_from_base64(compressed)
# => "Hello, 🎶 world!"
```

The methods have the same names as in JavaScript:

| JavaScript                                                            | Ruby                                                                                  | Gives                               |
|-----------------------------------------------------------------------|---------------------------------------------------------------------------------------|-------------------------------------|
| `compressToBase64` / `decompressFromBase64`                           | `LZString.compress_to_base64` / `LZString.decompress_from_base64`                     | Base64                              |
| `compressToEncodedURIComponent` / `decompressFromEncodedURIComponent` | `LZString.compress_to_encoded_uri_component` / `.decompress_from_encoded_uri_component` | text that is safe in a URL          |
| `compressToUTF16` / `decompressFromUTF16`                             | `LZString.compress_to_utf16` / `.decompress_from_utf16`                               | valid UTF-16 text, for localStorage |
| `compressToUint8Array` / `decompressFromUint8Array`                   | `LZString.compress_to_uint8_array` / `.decompress_from_uint8_array`                   | bytes                               |
| `compressToCustom` / `decompressFromCustom`                           | `LZString.compress_to_custom(text, alphabet)` / `.decompress_from_custom(data, alphabet)` | text from your own alphabet         |
| `compress` / `decompress`                                             | `LZString.compress` / `LZString.decompress`                                           | raw: a UTF-16LE string (see below)  |

Each format also has its own class, as in older versions of this gem: `LZString::Base64`, `LZString::UriSafe`,
`LZString::UTF16`, `LZString::Uint8Array` and `LZString::Custom`. Each has `compress` and `decompress`.

```ruby
LZString::UriSafe.compress('{"page": 2, "search": "café ☕"}')
# => "N4IgDghg5gpiBcACATAGkSAzjCAnAxgBYIb4QBmAl4oKhkIAvkA"

LZString.compress_to_uint8_array("🎶")
# => "\x8F\x06\xE3o\xDA\x00"
LZString.decompress_from_uint8_array([143, 6, 227, 111, 218, 0])
# => "🎶"

LZString.compress_to_custom("Hello world!", "0123456789abcdef")
# => "0485303660f60040ee90273004c08440"
```

### Strings in and out

- **In:** any Ruby string. It is read as text in its own encoding (UTF-8, Latin-1, …), like a JavaScript string.
- **Out of `decompress`:** a UTF-8 string, or `nil` when JavaScript gives `null` (broken data).
- **Raw `compress`** gives a UTF-16LE string. Like in JavaScript, this result is often not valid UTF-16
  (it has lone surrogates), and UTF-8 can't hold it. To store or send it, use one of the other formats.
- **Uint8Array** gives a binary string. `decompress_from_uint8_array` takes a binary string or a list of numbers.
- A JavaScript string can hold half of an emoji (a lone surrogate). UTF-8 can't, so `decompress` writes `"�"` for it.
  If you need the result exactly as JavaScript has it, use `decompress_to_utf16le` (every format has it).

## Command line

```console
$ lz_string -h
Usage: lz_string [options] [input-file]

Use lz-string to compress or decompress a file

Arguments:
    input-file                       file to process, if no file then read from stdin

Options:
    -V, --version                    output the version number
    -d, --decompress                 if unset then this will compress
    -e, --encoder TYPE               character encoding to use (choices: base64, custom, encodeduri, raw, uint8array, utf16, default: raw)
    -c, --custom DICTIONARY          dictionary for custom encoder
    -v, --verify                     verify before returning
    -o, --output OUTPUT_FILE         output file, otherwise write to stdout
    -q, --quiet                      don't print any error messages
    -h, --help                       display help for command

$ lz_string -e base64 photo.jpg -o photo.lz
$ lz_string -d -e base64 photo.lz -o photo.jpg
```

Like the lz-string 2 tool, it works on the bytes of a file (2 bytes are one UTF-16 code unit), not on text.
So it can compress any file and give it back the same. It writes the same bytes as the JavaScript tool.

### Check it with the tests of lz-string

```console
$ git clone https://github.com/pieroxy/lz-string && cd lz-string/test
$ cat > profiles/lz_string.sh <<'EOF'
optDescription="The lz_string Ruby gem"
optCommand=lz_string
optDecompress="-d"
optEncoder="-e"
optEncoders="base64,encodeduri,raw,uint8array,utf16"
optOutput="-o"
optQuiet="-q"
EOF
$ ./test.sh lz_string
```

## Upgrade from 0.x

Emoji now work, and all results are the same as in JavaScript. Some things changed, see the [changelog](CHANGELOG.md):

- `LZString.compress` (raw) returns a UTF-16LE string, not UTF-8.
- `LZString.decompress("")` returns `nil`, like in JavaScript.
- Data that starts with code 3 (lz-string never writes that) raises `ArgumentError`, like lz-string 2.
- A binary string with bytes above 127 raises an error. Use `force_encoding` to say what the bytes are.

## Development

```console
$ bundle install
$ rake
```

The specs compare the gem with results of the JavaScript library, kept in `spec/fixtures/js_results.json`.
To make that file again, see `spec/fixtures/js_results.js`.

## License

MIT
