import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

import 'package:eosdart/eosdart.dart';

part 'link_create.g.dart';

@JsonSerializable(explicitToJson: true)
class LinkCreate {
  //type = name
  @JsonKey(name: 'session_name')
  String sessionName;

  //type = public_key
  @JsonKey(name: 'request_key')
  String requestKey;

  LinkCreate();

  factory LinkCreate.fromJson(Map<String, dynamic> json) =>
      _$LinkCreateFromJson(json);

  Map<String, dynamic> toJson() => _$LinkCreateToJson(this);

  @override
  String toString() => this.toJson().toString();

  Uint8List toBinary(Type type) {
    var buffer = SerialBuffer(Uint8List(0));
    type.serialize(type, buffer, this.toJson());
    return buffer.asUint8List();
  }
}
