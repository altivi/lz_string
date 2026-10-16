# Changelog

## 1.0.0 (2026-10-16)

Now it gives the same results as JavaScript lz-string for every input, emoji too
([#3](https://github.com/altivi/lz_string/issues/3)), and it passes the test suite of lz-string itself.

### Fixed

- Emoji and all other characters. Like JS, compress and decompress now work on UTF-16 code units.
  Before, emoji gave wrong results, `nil` or a `RangeError`.
- `decompress` always returns UTF-8. Before, it could return a binary string (`"\xF6"` for `"ö"`).
- Text with `__proto__` in it compresses like in JS.
- `compress("")` gives what JS gives (`"Q==="` in Base64), not `""`.
- `LZString.decompress("")` returns `nil`, like JS.
- `UriSafe.decompress` no longer changes the string you give it, and works with frozen strings.
- Faster: on 100 KB of text, Base64 compress takes 0.03 s instead of 0.10 s, and decompress 0.008 s instead of 0.12 s.

### Added

- `LZString::Uint8Array`: compress to bytes and back (`compressToUint8Array` in JS).
- `LZString::Custom`: compress with your own alphabet (`compressToCustom`, new in lz-string 2).
- The JS function names: `LZString.compress_to_base64`, `LZString.decompress_from_base64` and all the others.
- `decompress_to_utf16le` for every format: the exact JS result, which can hold a lone surrogate.
- The `lz_string` command line tool, with the same options as the one of lz-string 2.

### Changed (this can break your code)

- `LZString.compress` (raw) returns a UTF-16LE string. Like in JS, its result often has lone surrogates,
  and UTF-8 can't hold them. Before, it returned UTF-8 with `"�"` in it, which could not be decompressed.
  The Base64, URI-safe and UTF-16 results are UTF-8, as before.
- Data that starts with code 3 (lz-string never writes that) raises `ArgumentError`, like lz-string 2.
- A binary (ASCII-8BIT) string with bytes above 127 raises `Encoding::UndefinedConversionError`.
  Before, its bytes were read as Latin-1. Use `force_encoding` to say what the bytes are.
- It needs Ruby 2.7 or newer.

## 0.3.0 (2025-04-14)

- Better Unicode handling. Emoji still did not work (fixed in 1.0.0).

## 0.2.0 (2023-06-13)

- URI-safe compression: `LZString::UriSafe` ([#2](https://github.com/altivi/lz_string/pull/2)).

## 0.1.2 (2020-01-27)

- Updated dependencies.

## 0.1.1 (2019-12-05)

- UTF-16 and Base64 compression.

## 0.1.0 (2019-12-05)

- First release: raw compression.
