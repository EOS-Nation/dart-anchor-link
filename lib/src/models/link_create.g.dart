// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinkCreate _$LinkCreateFromJson(Map<String, dynamic> json) {
  return LinkCreate()
    ..sessionName = json['session_name'] as String
    ..requestKey = json['request_key'] as String;
}

Map<String, dynamic> _$LinkCreateToJson(LinkCreate instance) =>
    <String, dynamic>{
      'session_name': instance.sessionName,
      'request_key': instance.requestKey,
    };
