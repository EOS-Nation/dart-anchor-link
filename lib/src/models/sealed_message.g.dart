// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sealed_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SealedMessage _$SealedMessageFromJson(Map<String, dynamic> json) {
  return SealedMessage()
    ..from = json['from'] as String
    ..nonce = json['nonce'] as String
    ..ciphertext = json['ciphertext']
    ..checksum = json['checksum'] as int;
}

Map<String, dynamic> _$SealedMessageToJson(SealedMessage instance) =>
    <String, dynamic>{
      'from': instance.from,
      'nonce': instance.nonce,
      'ciphertext': instance.ciphertext,
      'checksum': instance.checksum,
    };
