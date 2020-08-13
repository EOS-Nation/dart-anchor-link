import 'dart:async';
import 'dart:io';

import 'package:dart_anchor_link/dart_anchor_link.dart';
import 'package:dart_anchor_link/src/toMoveTo/eosdart/eosdart_jsonrpc.dart';
import 'package:dart_esr/dart_esr.dart';
import 'package:dart_esr/src/signing_request_manager.dart';

const timeout = Duration(seconds: 300);

Future<void> main(List<String> arguments) {
  transact();
  // login();
}

Future<void> transact() async {
  try {
    // initialize the console transport
    var transport = ConsoleTransport();

    var options = LinkOptions(
      transport,
      chainName: ChainName.JUNGLE,
      rpc: JsonRpc('https://jungle.greymass.com', 'v1'),
    );

    // initialize the link
    var link = Link(options);

    var auth = <Authorization>[ESRConstants.PlaceholderAuth];
    var data = <String, String>{'name': 'test'};
    var action = Action()
      ..account = 'eosnpingpong'
      ..name = 'ping'
      ..authorization = auth
      ..data = data;

    var args = TransactArgs(action: action);

    var res = await link.transact(args);
    print(res?.processed);
  } catch (e) {
    print(e.toString());
  }
}

Future<void> login() async {
  // app identifier, should be set to the eosio contract account if applicable
  try {
    var identifier = 'pacoeosnatio';

    // initialize the console transport
    var transport = ConsoleTransport();

    var options = LinkOptions(
      transport,
      chainName: ChainName.JUNGLE,
      rpc: JsonRpc('https://jungle.greymass.com', 'v1'),
    );
    // initialize the link
    var link = Link(options);

    var res = await link.login(identifier);
    print(res?.session?.identifier);
  } catch (e) {
    print(e.toString());
  }
}

/**
 * A signing request presenter that writes requests
 * as URI strings and ASCII qr codes to print.
 */
class ConsoleTransport implements LinkTransport {
  @override
  void onRequest(SigningRequestManager request,
      Function({Exception exception, String reason}) cancel) {
    var uri = request.encode();
    print('Signing request\n${uri}');

    var onCancel = () async {
      //TODO verify that it cancel when login done
      await Future.delayed(timeout, () {});
      cancel();
    };
    onCancel();
  }

  @override
  LinkStorage storage;

  @override
  void onFailure(SigningRequestManager request, Exception exception) {
    // TODO: implement onFailure
  }

  @override
  void onSessionRequest(LinkSession session, SigningRequestManager request,
      void Function({Exception exception, String reason}) cancel) {
    // TODO: implement onSessionRequest
  }

  @override
  void onSuccess(SigningRequestManager request, TransactResult result) {
    // TODO: implement onSuccess
  }

  @override
  Future<SigningRequestManager> prepare(SigningRequestManager request,
          {LinkSession session}) async =>
      request;

  @override
  void showLoading() {
    // TODO: implement showLoading
  }
}
