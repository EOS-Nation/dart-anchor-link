import 'dart:math';
import 'dart:typed_data';

import "package:pointycastle/export.dart";

Uint8List aesCbcEncrypt(
    Uint8List key, Uint8List iv, Uint8List paddedPlaintext) {
  // Create a CBC block cipher with AES, and initialize with key and IV

  final cbc = CBCBlockCipher(AESFastEngine())
    ..init(true, ParametersWithIV(KeyParameter(key), iv)); // true=encrypt

  // Encrypt the plaintext block-by-block

  final cipherText = Uint8List(paddedPlaintext.length); // allocate space

  var offset = 0;
  while (offset < paddedPlaintext.length) {
    offset += cbc.processBlock(paddedPlaintext, offset, cipherText, offset);
  }
  assert(offset == paddedPlaintext.length);

  return cipherText;
}

Uint8List aesCbcDecrypt(Uint8List key, Uint8List iv, Uint8List cipherText) {
  // Create a CBC block cipher with AES, and initialize with key and IV

  final cbc = CBCBlockCipher(AESFastEngine())
    ..init(false, ParametersWithIV(KeyParameter(key), iv)); // false=decrypt

  // Decrypt the cipherText block-by-block

  final paddedPlainText = Uint8List(cipherText.length); // allocate space

  var offset = 0;
  while (offset < cipherText.length) {
    offset += cbc.processBlock(cipherText, offset, paddedPlainText, offset);
  }
  assert(offset == cipherText.length);

  return paddedPlainText;
}

FortunaRandom _secureRandom;

Uint8List generateRandomBytes(int numBytes) {
  if (_secureRandom == null) {
    // First invocation: create _secureRandom and seed it

    _secureRandom = FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    _secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  }

  // Use it to generate the random bytes

  final iv = _secureRandom.nextBytes(numBytes);
  return iv;
}
