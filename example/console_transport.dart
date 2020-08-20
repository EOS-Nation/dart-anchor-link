import 'package:dart_esr/dart_esr.dart';
import 'package:dart_anchor_link/dart_anchor_link.dart';

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
  }

  @override
  LinkStorage storage;

  @override
  void onFailure(SigningRequestManager request, Exception exception) {
    // Called if the request failed. Not used in console transport
  }

  @override
  void onSessionRequest(LinkSession session, SigningRequestManager request,
      void Function({Exception exception, String reason}) cancel) {
    // Called when a session request is initiated. Not used in console transport
  }

  @override
  void onSuccess(SigningRequestManager request, TransactResult result) {
    // Called if the request was successful.  Not used in console transport
  }

  @override
  Future<SigningRequestManager> prepare(SigningRequestManager request,
      {LinkSession session}) async {
    return request;
  }

  @override
  void showLoading() {
    print('loading');
  }
}
