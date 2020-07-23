import 'dart:typed_data';

import 'package:dart_anchor_link/src/link_options.dart';
import 'package:dart_anchor_link/src/link_session.dart';
import 'package:dart_anchor_link/src/link_session_interfaces.dart';
import 'package:dart_anchor_link/src/link_storage.dart';
import 'package:dart_anchor_link/src/link_transport.dart';
import 'package:dart_anchor_link/src/toMoveTo/dart-esr/esr.dart';
import 'package:dart_anchor_link/src/toMoveTo/eosdart/eosdart-api-interface.dart';
import 'package:dart_anchor_link/src/toMoveTo/eosdart/eosdart_jsonrpc.dart';
import 'package:dart_esr/dart_esr.dart' as esr;
import 'package:dart_esr/dart_esr.dart';
import 'toMoveTo/dart-esr/esr.dart' as esr;

/** EOSIO permission level with actor and signer, a.k.a. 'auth', 'authority' or 'account auth' */
class PermissionLevel {
  String actor;

  String permission;

  PermissionLevel(this.actor, this.permission);
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

/**
 * Main class, also exposed as the default export of the library.
 *
 */
abstract class Link {
  /** The eosjs RPC instance used to communicate with the EOSIO node. */
  JsonRpc _rpc;
  get rpc => _rpc;
  /** Transport used to deliver requests to the user wallet. */
  LinkTransport _transport;
  get transport => _transport;
  /** EOSIO ChainID for which requests are valid. */
  String _chainId;
  get chainId => _chainId;
  /** Storage adapter used to persist sessions. */
  LinkStorage _storage;
  get storage => _storage;

  String _serviceAddress;
  SigningRequestEncodingOptions _requestOptions;
  Map<dynamic, dynamic> _abiCache;
  Map<dynamic, dynamic> _pendingAbis;

  /** Create a new link instance. */
  Link(LinkOptions options);
  /**
     * Fetch the ABI for given account, cached.
     * @internal
     */
  Future<dynamic> getAbi(String account);
  /**
     * Create a new unique buoy callback url.
     * @internal
     */
  String createCallbackUrl();
  /**
     * Create a SigningRequest instance configured for this link.
     * @internal
     */
  Future<esr.SigningRequest> createRequest(
      esr.SigningRequestCreateArguments args,
      {LinkTransport transport});
  /**
     * Send a SigningRequest instance using this link.
     * @internal
     */
  Future<TransactResult> sendRequest(esr.SigningRequest request,
      {LinkTransport transport, bool broadcast});
  /**
     * Sign and optionally broadcast a EOSIO transaction, action or actions.
     *
     * Example:
     *
     * ```ts
     * let result = await myLink.transact({transaction: myTx})
     * ```
     *
     * @param args The action, actions or transaction to use.
     * @param options Options for this transact call.
     * @param transport Transport override, for internal use.
     */
  Future<TransactResult> transact(TransactArgs args,
      {TransactOptions options, LinkTransport transport});
  /**
     * Send an identity request and verify the identity proof.
     * @param requestPermission Optional request permission if the request is for a specific account or permission.
     * @param info Metadata to add to the request.
     * @note This is for advanced use-cases, you probably want to use [[Link.login]] instead.
     */
  Future<IdentifyResult> identify(
      {PermissionLevel requestPermission,
      dynamic info}); // info Map<String,String > || Uint8List
  /**
     * Login and create a persistent session.
     * @param identifier The session identifier, an EOSIO name (`[a-z1-5]{1,12}`).
     *                   Should be set to the contract account if applicable.
     */
  Future<LoginResult> login(String identifier);
  /**
     * Restore previous session, see [[Link.login]] to create a new session.
     * @param identifier The session identifier, should be same as what was used when creating the session with [[Link.login]].
     * @param auth A specific session auth to restore, if omitted the most recently used session will be restored.
     * @returns A [[LinkSession]] instance or null if no session can be found.
     * @throws If no [[LinkStorage]] adapter is configured or there was an error retrieving the session data.
     **/
  Future<LinkSession> restoreSession(String identifier, {PermissionLevel auth});
  /**
     * List stored session auths for given identifier.
     * The most recently used session is at the top (index 0).
     * @throws If no [[LinkStorage]] adapter is configured or there was an error retrieving the session list.
     **/
  Future<List<PermissionLevel>> listSessions(String identifier);
  /**
     * Remove stored session for given identifier and auth.
     * @throws If no [[LinkStorage]] adapter is configured or there was an error removing the session data.
     */
  Future<void> removeSession(String identifier, PermissionLevel auth);
  /**
     * Remove all stored sessions for given identifier.
     * @throws If no [[LinkStorage]] adapter is configured or there was an error removing the session data.
     */
  Future<void> clearSessions(String identifier);
  /**
     * Create an eosjs compatible signature provider using this link.
     * @param availableKeys Keys the created provider will claim to be able to sign for.
     * @param transport (internal) Transport override for this call.
     * @note We don't know what keys are available so those have to be provided,
     *       to avoid this use [[LinkSession.makeSignatureProvider]] instead. Sessions can be created with [[Link.login]].
     */
  SignatureProvider makeSignatureProvider(List<String> availableKeys,
      {LinkTransport transport});
  /**
     * Create an eosjs authority provider using this link.
     * @note Uses the configured RPC Node's `/v1/chain/get_required_keys` API to resolve keys.
     */
  AuthorityProvider makeAuthorityProvider();
  /** Makes sure session is in storage list of sessions and moves it to top (most recently used). */
  void _touchSession(String identifier, RequiredAuth auth,
      {bool remove = false});
  /** Makes sure session is in storage list of sessions and moves it to top (most recently used). */
  void _storeSession(String identifier, LinkChannelSession session);
  /** Session storage key for identifier and suffix. */
  void _sessionKey(String identifier, String suffix);
}
