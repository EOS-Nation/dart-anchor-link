import 'dart:typed_data';

import 'package:dart_anchor_link/src/link_session_interfaces.dart';

import 'package:dart_esr/dart_esr.dart';

class CancelTransaction {
  Function cancel;
  CancelTransaction(this.cancel);
}

/**
 * Payload accepted by the [[Link.transact]] method.
 * Note that one of `action`, `actions` or `transaction` must be set.
 */
abstract class TransactArgs {
  /** Full transaction to sign. */
  Transaction transaction;
  /** Action to sign. */
  Action action;
  /** Actions to sign. */
  List<Action> actions;
}

/**
 * Options for the [[Link.transact]] method.
 */
abstract class TransactOptions {
  /**
     * Whether to broadcast the transaction or just return the signature.
     * Defaults to true.
     */
  bool broadcast;
}

/**
 * The result of a [[Link.transact]] call.
 */
class TransactResult {
  /** The signing request that was sent. */
  SigningRequestManager request;
  /** The transaction signatures. */
  List<String> signatures;
  /** The callback payload. */
  CallbackPayload payload;
  /** The signer authority. */
  Authorization signer;
  /** The resulting transaction. */
  Transaction transaction;
  /** Serialized version of transaction. */
  Uint8List serializedTransaction;
  /** Push transaction response from api node, only present if transaction was broadcast. */
  Map<String, dynamic> processed;

  TransactResult(this.request, this.signatures, this.payload, this.signer,
      this.transaction, this.serializedTransaction, this.processed);
}

/**
 * The result of a [[Link.identify]] call.
 */
abstract class IdentifyResult implements TransactResult {
  /** The identified account. */
  Object account;
  /** The public key that signed the identity proof.  */
  String signerKey;
}

/**
 * The result of a [[Link.login]] call.
 */
abstract class LoginResult implements IdentifyResult {
  /** The session created by the login. */
  LinkSession session;
}
