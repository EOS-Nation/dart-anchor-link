import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:dart_anchor_link/src/link.dart';
import 'package:dart_anchor_link/src/exceptions.dart';
import 'package:dart_anchor_link/src/link_interfaces.dart';
import 'package:dart_anchor_link/src/link_session_interfaces.dart';
import 'package:dart_anchor_link/src/link_storage.dart';
import 'package:dart_anchor_link/src/link_transport.dart';
import 'package:dart_anchor_link/src/utils/utils.dart';

import 'package:dart_esr/dart_esr.dart';

import 'toMoveTo/eosdart/eosdart-api-interface.dart' as eosDart;

class LinkChannelSession extends LinkSession implements LinkTransport {
  LinkChannelSession(
      Link link, LinkChannelSessionData data, Map<String, dynamic> metadata)
      : super() {
    this.type = 'channel';
    this._timeout = 2 * 60 * 1000; // ms
    this.link = link;
    this.auth = data.auth;
    this.publicKey = data.publicKey;
    this._channel = data.channel;
    this.identifier = data.identifier;

    var tempMetadata = metadata != null ? metadata : <String, dynamic>{};
    tempMetadata['timeout'] = this._timeout;
    tempMetadata['name'] = this._channel.name;
    this.metadata = tempMetadata;
  }

  int _timeout;
  ChannelInfo _channel;
  LinkChannelSessionData _data;

  Uint8List encrypt(request) => sealMessage(request.encode(true, false),
      this._data?.requestKey, this._data?.channel?.key);

  /**
   * From LinkTransport 
   */
  @override
  LinkStorage storage;

  @override
  void onSessionRequest(LinkSession session, SigningRequestManager request,
      Function({Exception exception, String reason}) cancel) {
    // Not implemented in LinkChannelSession
  }

  @override
  void onSuccess(SigningRequestManager request, TransactResult result) {
    if (this.link.transport.onSuccess is Function) {
      this.link.transport.onSuccess(request, result);
    }
  }

  @override
  void onFailure(SigningRequestManager request, Exception exception) {
    if (this.link.transport.onFailure is Function) {
      this.link.transport.onFailure(request, exception);
    }
  }

  @override
  Future<void> onRequest(SigningRequestManager request,
      Function({Exception exception, String reason}) cancel) async {
    var now = DateTime.now().add(Duration(milliseconds: this._timeout));
    var info = InfoPair()
      ..key = 'expiration'
      ..key = 'expiration'
      ..value = now.toIso8601String();

    if (this.link.transport.onSessionRequest is Function) {
      this.link.transport.onSessionRequest(this, request, cancel);
    }

    // TODO: check if need to cancel timer when response received or error
    Timer(
        Duration(milliseconds: this._timeout + 500),
        () => cancel(
            exception: SessionException('Wallet did not respond in time',
                LinkExceptionCode.E_TIMEOUT)));

    request.data.info.add(info);

    try {
      var xBuoyWait = (this._timeout / 1000).round();
      var headers = <String, String>{'X-Buoy-Wait': xBuoyWait.toString()};
      http.Response response = await http.post(this._channel.url,
          headers: headers, body: this.encrypt(request));
      if (response.statusCode >= 300) {
        cancel(
            exception: SessionException(
                'Unable to push message', LinkExceptionCode.E_DELIVERY));
      } else {
        // request delivered
      }
    } catch (e) {
      cancel(
          exception: SessionException(
              'Unable to reach link service (${e.toString()})',
              LinkExceptionCode.E_DELIVERY));
    }
  }

  @override
  Future<SigningRequestManager> prepare(SigningRequestManager request,
      {LinkSession session}) async {
    if (this.link.transport.prepare is Function) {
      return this.link.transport.prepare(request, session: this);
    }
    return request;
  }

  @override
  void showLoading() {
    if (this.link.transport.showLoading is Function) {
      return this.link.transport.showLoading();
    }
  }

  /**
   * From LinkSession 
   */
  @override
  eosDart.AuthorityProvider makeAuthorityProvider() =>
      this.link.makeAuthorityProvider();

  @override
  SignatureProvider makeSignatureProvider() =>
      this.link.makeSignatureProvider([this.publicKey], transport: this);

  @override
  Future<TransactResult> transact(TransactArgs args,
          {TransactOptions options}) =>
      this.link.transact(args, options: options, transport: this);

  @override
  SerializedLinkSession serialize() =>
      SerializedLinkSession(this.type, this._data, this.metadata);
}

class LinkFallbackSession extends LinkSession implements LinkTransport {
  LinkFallbackSession(
      Link link, LinkFallbackSessionData data, Map<String, dynamic> metadata)
      : super() {
    this.type = 'fallback';
    this.link = link;
    this._data = data;
    this.auth = data.auth;
    this.publicKey = data.publicKey;
    this.metadata = metadata != null ? metadata : <String, dynamic>{};
    this.identifier = data.identifier;
  }

  LinkFallbackSessionData _data;

  /**
   * From LinkTransport 
   */
  @override
  LinkStorage storage;

  @override
  void onSessionRequest(LinkSession session, SigningRequestManager request,
      void Function({Exception exception, String reason}) cancel) {
    // TODO: implement onSessionRequest
  }

  @override
  void onSuccess(SigningRequestManager request, TransactResult result) {
    if (this.link.transport.onSuccess is Function) {
      this.link.transport.onSuccess(request, result);
    }
  }

  @override
  void onFailure(SigningRequestManager request, Exception exception) {
    if (this.link.transport.onFailure is Function) {
      this.link.transport.onFailure(request, exception);
    }
  }

  @override
  void onRequest(SigningRequestManager request,
      void Function({Exception exception, String reason}) cancel) {
    if (this.link.transport.onSessionRequest is Function) {
      this.link.transport.onSessionRequest(this, request, cancel);
    } else {
      this.link.transport.onRequest(request, cancel);
    }
  }

  @override
  Future<SigningRequestManager> prepare(SigningRequestManager request,
      {LinkSession session}) async {
    if (this.link.transport.prepare is Function) {
      return this.link.transport.prepare(request, session: this);
    }
    return request;
  }

  @override
  void showLoading() {
    if (this.link.transport.showLoading is Function) {
      return this.link.transport.showLoading();
    }
  }

  /**
   * From LinkSession 
   */
  @override
  SignatureProvider makeSignatureProvider() =>
      this.link.makeSignatureProvider([this.publicKey], transport: this);

  @override
  eosDart.AuthorityProvider makeAuthorityProvider() =>
      this.link.makeAuthorityProvider();

  @override
  Future<TransactResult> transact(TransactArgs args,
          {TransactOptions options}) =>
      this.link.transact(args, options: options, transport: this);

  @override
  SerializedLinkSession serialize() =>
      SerializedLinkSession(this.type, this._data, this.metadata);
}
