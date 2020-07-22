import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

import 'package:eosdart/eosdart.dart';

part 'sealed_message.g.dart';

@JsonSerializable(explicitToJson: true)
class SealedMessage {
  //type = public_key
  @JsonKey(name: 'from')
  String from;

  //type = uint64
  @JsonKey(name: 'nonce')
  String nonce;

  //type = bytes
  @JsonKey(name: 'ciphertext')
  Object ciphertext;

  //type = uint32
  @JsonKey(name: 'checksum')
  int checksum;

  SealedMessage();

  factory SealedMessage.fromJson(Map<String, dynamic> json) =>
      _$SealedMessageFromJson(json);

  Map<String, dynamic> toJson() => _$SealedMessageToJson(this);

  @override
  String toString() => this.toJson().toString();

  Uint8List toBinary(Type type) {
    var buffer = SerialBuffer(Uint8List(0));
    type.serialize(type, buffer, this.toJson());
    return buffer.asUint8List();
  }
}
