import 'package:dart_anchor_link/src/link_interfaces.dart';
import 'package:dart_anchor_link/src/link_session_interfaces.dart';
import 'package:dart_anchor_link/src/link_storage.dart';

import 'package:dart_esr/dart_esr.dart';

/**
 * Protocol link transports need to implement.
 * A transport is responsible for getting the request to the
 * user, e.g. by opening request URIs or displaying QR codes.
 */
abstract class LinkTransport {
  /**
     * Present a signing request to the user.
     * @param request The signing request.
     * @param cancel Can be called to abort the request.
     */
  void onRequest(SigningRequestManager request,
      Function({String reason, Exception exception}) cancel);
  /** Called if the request was successful. */
  void onSuccess(SigningRequestManager request, TransactResult result);
  /** Called if the request failed. */
  void onFailure(SigningRequestManager request, Exception exception);
  /**
     * Called when a session request is initiated.
     * @param session Session where the request originated.
     * @param request Signing request that will be sent over the session.
     */
  void onSessionRequest(LinkSession session, SigningRequestManager request,
      void Function({String reason, Exception exception}) cancel);

  /** Can be implemented if transport provides a storage as well. */
  LinkStorage storage;
  /** Can be implemented to modify request just after it has been created. */
  Future<SigningRequestManager> prepare(SigningRequestManager request,
      {LinkSession session}) async {
    return request;
  }

  /** Called immediately when the transaction starts */
  void showLoading();
}
