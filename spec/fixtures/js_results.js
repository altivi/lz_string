// Makes js_results.json: what the JavaScript lz-string returns for many inputs.
// The specs check that this gem returns exactly the same. To make the file again (Node 22.13+):
//
//   git clone https://github.com/pieroxy/lz-string /tmp/lz-string
//   node spec/fixtures/js_results.js /tmp/lz-string > spec/fixtures/js_results.json
//
// It runs lz-string 2 from its TypeScript source, with Node's own type stripping. lz-string 1.5.0
// (npm) gives the same results, but has no custom encoder, throws on an odd count of bytes in
// decompressFromUint8Array, and gives junk instead of an error for data that starts with code 3.
//
// JSON can't hold a lone surrogate (half of an emoji), so a string that may have one is written
// as a list of UTF-16 code units, and bytes are written as hex.
"use strict";
const fs = require("fs");
const os = require("os");
const path = require("path");
const { stripTypeScriptTypes } = require("module");

function loadLzString(repository) {
  const src = path.join(repository, "src");
  const out = fs.mkdtempSync(path.join(os.tmpdir(), "lz-string-"));
  for (const file of fs.readdirSync(src, { recursive: true })) {
    if (!file.endsWith(".ts") || file.includes("__tests__") || file === "cli.ts") continue;
    let code = stripTypeScriptTypes(fs.readFileSync(path.join(src, file), "utf8"));
    code = code.replace("PathOrFileDescriptor, ", ""); // a type, imported like a value
    // ESM needs full paths: "./raw" is a folder, "./_compress" a file.
    code = code.replace(/from "(\.{1,2}\/[^"]*)"/g, (_, name) => {
      const target = path.resolve(path.dirname(path.join(src, file)), name);
      return `from "${fs.existsSync(target + ".ts") ? name + ".mjs" : name + "/index.mjs"}"`;
    });
    fs.mkdirSync(path.dirname(path.join(out, file)), { recursive: true });
    fs.writeFileSync(path.join(out, file.replace(/\.ts$/, ".mjs")), code);
  }
  return require(path.join(out, "index.mjs")).default;
}

const LZ = loadLzString(process.argv[2]);
const version = JSON.parse(fs.readFileSync(path.join(process.argv[2], "package.json"), "utf8")).version;

// Same random numbers on every run (mulberry32), so the file only changes when the code does.
let seed = 1;
function rand() {
  seed = (seed + 0x6d2b79f5) | 0;
  let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
}
const int = (n) => Math.floor(rand() * n);
const pick = (list) => list[int(list.length)];
const units = (s) => Array.from({ length: s.length }, (_, i) => s.charCodeAt(i));
const fromUnits = (list) => list.map((u) => String.fromCharCode(u)).join("");
const hex = (bytes) => Buffer.from(bytes).toString("hex");
const asJson = (s) => (s.isWellFormed() ? s : units(s));

function randomCharacter(allowLoneSurrogate) {
  switch (int(allowLoneSurrogate ? 8 : 7)) {
    case 0: return String.fromCodePoint(32 + int(95));             // ASCII
    case 1: return String.fromCodePoint(int(32));                  // control characters
    case 2: return String.fromCodePoint(128 + int(128));           // Latin-1: JS writes these with 8 bits
    case 3: return String.fromCodePoint(256 + int(0xd800 - 256));  // rest of the BMP
    case 4: return String.fromCodePoint(0xe000 + int(0x2000));     // BMP after the surrogates
    case 5: return String.fromCodePoint(0x1f300 + int(0x700));     // emoji: two code units each
    case 6: return String.fromCodePoint(0x10000 + int(0x100000));  // any supplementary plane
    case 7: return String.fromCharCode(0xd800 + int(0x800));       // lone surrogate
  }
}

function randomText(length, allowLoneSurrogate) {
  const characters = Array.from({ length: 1 + int(pick([3, 12, 60])) }, () => randomCharacter(allowLoneSurrogate));
  if (rand() < 0.15) characters.push("__proto__");
  let text = "";
  while (text.length < length) text += pick(characters);
  return text;
}

const inputs = [
  "", "a", "ö", "❤", "🎶", "🀄", "⛩️", "👨‍👩‍👧‍👦", "🇺🇦", "👍🏽", "😀😁😂🤣",
  "Hello world!", "Hello world!!", "Hello world!!!!", "Hello world!!!!!!!",
  '{"some": "json", "foo": [{"bar": "baz"}]}',
  '{"some": "json", "foo": [{"bar": "؋", "key": "؄"}], "ঞᕠ": "൱ඵቜ"}',
  "Привет, мир! 你好，世界！ こんにちは世界 안녕하세요 مرحبا بالعالم नमस्ते दुनिया",
  "__proto__", "__proto____proto__", "__proto__".repeat(20), "a__proto__".repeat(10), "__proto__🎶".repeat(6),
  "\u0000", "ÿ", "Ā", "￿", "\u{10000}\u{10ffff}", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "🎶".repeat(100), "😀😁😂".repeat(50), "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ".repeat(30),
  Array.from({ length: 256 }, (_, i) => String.fromCharCode(i)).join(""),
  "\ud83c", "\udfb6", "a\ud83cb", "\udfb6\ud83c",
];
for (let i = 0; i < 100; i++) inputs.push(randomText(Math.floor(Math.exp(rand() * Math.log(2000))), rand() < 0.1));
// A long one makes the dictionary big, so codes grow to 14 bits.
inputs.push(randomText(15000, false));

const compress = inputs.map((input) => {
  const result = { input: asJson(input) };
  // JS gives back the lone surrogate itself; in UTF-8 it can only be "�".
  if (!input.isWellFormed()) result.text = input.toWellFormed();
  result.raw = units(LZ.compress(input));
  result.base64 = LZ.compressToBase64(input);
  result.uri = LZ.compressToEncodedURIComponent(input);
  result.utf16 = LZ.compressToUTF16(input);
  result.uint8array = hex(LZ.compressToUint8Array(input));
  return result;
});

const dictionaries = [
  "0123456789abcdef", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "01",
  "äöüßÄÖÜ€", "aab", Array.from({ length: 300 }, (_, i) => String.fromCharCode(0x4e00 + i)).join(""),
];
// Broken data that starts with code 3 (real data starts with 0, 1 or 2) makes lz-string 2 throw.
function decompressOrError(decompress, ...args) {
  try {
    const output = decompress(...args);
    return { output: output === null ? null : output.toWellFormed() };
  } catch (e) {
    return { error: e.message };
  }
}

// "aab" has a letter twice, so even JS doesn't get the text back: keep what it gives.
const custom = inputs.slice(0, 60).filter((input) => input.length < 400).map((input, i) => {
  const dictionary = dictionaries[i % dictionaries.length];
  const output = LZ.compressToCustom(input, dictionary);
  return { input: asJson(input), dictionary, output, decompressed: decompressOrError(LZ.decompressFromCustom, output, dictionary) };
});

// Broken data: random characters, and good data with a few changes.
const B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
const URI = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-$";
const textFormats = {
  raw: { decompress: LZ.decompress, character: () => int(0x10000) },
  base64: { decompress: LZ.decompressFromBase64, character: () => (rand() < 0.9 ? B64[int(65)] : pick([" ", "!", "é"])).charCodeAt(0) },
  uri: { decompress: LZ.decompressFromEncodedURIComponent, character: () => (rand() < 0.9 ? URI[int(65)] : pick([" ", "!", "é"])).charCodeAt(0) },
  utf16: { decompress: LZ.decompressFromUTF16, character: () => 32 + int(32768) },
};
function damaged(good, character) {
  let input = good.slice();
  for (let n = 1 + int(3); n > 0; n--) input[int(input.length)] = character();
  if (rand() < 0.5) input = input.slice(0, 1 + int(input.length));
  return input;
}
const decompress = {};
for (const [name, format] of Object.entries(textFormats)) {
  decompress[name] = Array.from({ length: 60 }, () => {
    const good = pick(compress)[name];
    const input = rand() < 0.5 ? Array.from({ length: 1 + int(40) }, format.character) : damaged(typeof good === "string" ? units(good) : good, format.character);
    return { input, ...decompressOrError(format.decompress, fromUnits(input)) };
  });
}
decompress.uint8array = Array.from({ length: 60 }, () => {
  const good = [...Buffer.from(pick(compress).uint8array, "hex")];
  const input = rand() < 0.5 ? Array.from({ length: 1 + int(40) }, () => int(256)) : damaged(good, () => int(256));
  return { input: hex(input), ...decompressOrError(LZ.decompressFromUint8Array, Uint8Array.from(input)) };
});
decompress.custom = Array.from({ length: 60 }, () => {
  const dictionary = pick(dictionaries);
  const characters = units(dictionary + "!é");
  const good = pick(custom.filter((c) => c.dictionary === dictionary)).output;
  const input = rand() < 0.5 ? Array.from({ length: 1 + int(40) }, () => pick(characters)) : damaged(units(good), () => pick(characters));
  return { input: fromUnits(input), dictionary, ...decompressOrError(LZ.decompressFromCustom, fromUnits(input), dictionary) };
});

const lines = (list) => list.map((item) => JSON.stringify(item)).join(",\n");
process.stdout.write(
  `{"lz_string": ${JSON.stringify(version)},\n"compress": [\n${lines(compress)}\n],\n"custom": [\n${lines(custom)}\n],\n` +
  `"decompress": {\n${Object.keys(decompress).map((name) => `${JSON.stringify(name)}: [\n${lines(decompress[name])}\n]`).join(",\n")}\n}}\n`
);
