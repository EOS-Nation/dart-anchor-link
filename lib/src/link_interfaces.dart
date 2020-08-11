import 'dart:typed_data';

import 'package:dart_anchor_link/src/link_session_interfaces.dart';

import 'package:dart_esr/dart_esr.dart';
import 'package:eosdart/eosdart.dart' as eosDart;

class CancelTransaction {
  Function cancel;

  CancelTransaction(this.cancel);
}

/**
 * Payload accepted by the [[Link.transact]] method.
 * Note that one of `action`, `actions` or `transaction` must be set.
 */
class TransactArgs {
  /** Full transaction to sign. */
  Transaction transaction;
  /** Action to sign. */
  Action action;
  /** Actions to sign. */
  List<Action> actions;
  TransactArgs({this.action, this.actions, this.transaction});
}

/**
 * Options for the [[Link.transact]] method.
 */
class TransactOptions {
  /**
     * Whether to broadcast the transaction or just return the signature.
     * Defaults to true.
     */
  bool broadcast;

  TransactOptions(this.broadcast);
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
      this.transaction, this.serializedTransaction,
      {this.processed});
}

/**
 * The result of a [[Link.identify]] call.
 */
class IdentifyResult implements TransactResult {
  /** The identified account. */
  eosDart.Account account;
  /** The public key that signed the identity proof.  */
  String signerKey;

  IdentifyResult(this.account, this.signerKey, this.request, this.signatures,
      this.payload, this.signer, this.transaction, this.serializedTransaction);

  @override
  CallbackPayload payload;

  //TODO more precise type
  @override
  Map<String, dynamic> processed;

  @override
  SigningRequestManager request;

  @override
  Uint8List serializedTransaction;

  @override
  List<String> signatures;

  @override
  Authorization signer;

  @override
  Transaction transaction;
}

/**
 * The result of a [[Link.login]] call.
 */
class LoginResult implements IdentifyResult {
  /** The session created by the login. */
  LinkSession session;

  LoginResult(
      this.session,
      this.account,
      this.signerKey,
      this.request,
      this.signatures,
      this.payload,
      this.signer,
      this.transaction,
      this.serializedTransaction);

  @override
  eosDart.Account account;

  @override
  CallbackPayload payload;

  @override
  Map<String, dynamic> processed;

  @override
  SigningRequestManager request;

  @override
  Uint8List serializedTransaction;

  @override
  List<String> signatures;

  @override
  Authorization signer;

  @override
  String signerKey;

  @override
  Transaction transaction;
}
