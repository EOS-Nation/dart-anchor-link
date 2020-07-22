import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

import 'package:eosdart/eosdart.dart';

part 'link_info.g.dart';

@JsonSerializable(explicitToJson: true)
class LinkInfo {
  //type = time_point_sec
  @JsonKey(name: 'expiration')
  String expiration;

  LinkInfo();

  factory LinkInfo.fromJson(Map<String, dynamic> json) =>
      _$LinkInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LinkInfoToJson(this);

  @override
  String toString() => this.toJson().toString();

  Uint8List toBinary(Type type) {
    var buffer = SerialBuffer(Uint8List(0));
    type.serialize(type, buffer, this.toJson());
    return buffer.asUint8List();
  }
}
