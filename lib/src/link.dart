import 'dart:typed_data';

import 'package:dart_anchor_link/src/link_session.dart';
import 'package:dart_esr/dart_esr.dart' as esr;
import 'esr.dart' as esr;

/** EOSIO permission level with actor and signer, a.k.a. 'auth', 'authority' or 'account auth' */
class PermissionLevel {
  final String _actor;
  String get actor => _actor;

  final String _permission;
  String get permission => _permission;

  PermissionLevel(this._actor, this._permission);
}

/**
 * Payload accepted by the [[Link.transact]] method.
 * Note that one of `action`, `actions` or `transaction` must be set.
 */
abstract class TransactArgs {
  /** Full transaction to sign. */
  esr.Transaction transaction;
  /** Action to sign. */
  esr.Action action;
  /** Actions to sign. */
  List<esr.Action> actions;
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
abstract class TransactResult {
  /** The signing request that was sent. */
  esr.SigningRequest request;
  /** The transaction signatures. */
  List<String> signatures;
  /** The callback payload. */
  esr.CallbackPayload payload;
  /** The signer authority. */
  PermissionLevel signer;
  /** The resulting transaction. */
  esr.Transaction transaction;
  /** Serialized version of transaction. */
  Uint8List serializedTransaction;
  /** Push transaction response from api node, only present if transaction was broadcast. */
  Map<String, dynamic> processed;
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
