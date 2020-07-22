import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_anchor_link/src/link_abi_data_json.dart';

import 'package:dart_anchor_link/src/models/sealed_message.dart';
import 'package:dart_anchor_link/src/utils/aes_cbc.dart';

import 'package:eosdart_ecc/eosdart_ecc.dart' as ecc;
import 'package:eosdart/eosdart.dart' as eosDart;

import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/block/modes/ecb.dart';

Map<String, eosDart.Type> types = eosDart.getTypesFromAbi(
    eosDart.createInitialTypes(),
    eosDart.Abi.fromJson(json.decode(linkAbiData)));

/**
 * Helper to ABI encode value.
 */
Uint8List abiEncode(dynamic value, String typeName) {
  if (!types.containsKey(typeName)) {
    throw 'No such type: ${typeName}';
  }
  var type = types[typeName];
  var buffer = eosDart.SerialBuffer(Uint8List(0));
  type.serialize(buffer, value);
  return buffer.asUint8List();
}

/**
 * Helper to ABI decode data.
 */
dynamic abiDecode(dynamic data, String typeName) {
  if (!types.containsKey(typeName)) {
    throw 'No such type: ${typeName}';
  }
  var type = types[typeName];
  if (data.runtimeType == String) {
    data = eosDart.hexToUint8List(data);
  } else if (data.runtimeType == List<int>().runtimeType) {
    data = Uint8List.fromList(data);
  }

  var buffer = eosDart.SerialBuffer(data);
  return type.deserialize(buffer);
}

/**
 * Encrypt a message using AES and shared secret derived from given keys.
 */
Uint8List sealMessage(String message, String privateKey, String publicKey) {
// export function sealMessage(message: string, privateKey: string, publicKey: string) {
//     const res = ecc.Aes.encrypt(privateKey, publicKey, message)
//     const data: SealedMessage = {
//         from: ecc.privateToPublic(privateKey),
//         nonce: res.nonce.toString(),
//         ciphertext: res.message,
//         checksum: res.checksum,
//     }
//     return abiEncode(data, 'sealed_message')
// }
  var nonce = generateRandomBytes(128 ~/ 8);

  var cipherText = aesCbcEncrypt(Uint8List.fromList(privateKey.codeUnits),
      nonce, Uint8List.fromList(message.codeUnits));

  //TODO: filled with good data (look into checksum)
  Map<String, dynamic> dataJson = {
    'from': '',
    'nonce': '',
    'ciphertext': '',
    'checksum': '',
  };
  var data = SealedMessage.fromJson(dataJson);
  return abiEncode(data, 'sealed_message');
}

/**
 * Ensure public key is in new PUB_ format.
 * @internal
 */
String normalizePublicKey(String key) {
  if (key.startsWith('PUB_')) {
    return key;
  }
  var formatedKey = 'EOS' + key.substring(key.length - 50);
  return eosDart.publicKeyToString(eosDart.stringToPublicKey(formatedKey));
}

/**
 * Return true if given public keys are equal.
 * @internal
 */
bool publicKeyEqual(String keyA, String keyB) {
  return normalizePublicKey(keyA) == normalizePublicKey(keyB);
}

/**
 * Generate a random private key using eosdart-ecc.
 */
ecc.EOSPrivateKey generatePrivateKey() {
  return ecc.EOSPrivateKey.fromRandom();
}
