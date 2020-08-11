import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_anchor_link/src/exceptions.dart';
import 'package:dart_anchor_link/src/models/link_create.dart';
import 'package:dart_anchor_link/src/utils/utils.dart';
import 'package:uuid/uuid.dart';

import 'package:dart_anchor_link/src/link_interfaces.dart';
import 'package:dart_anchor_link/src/link_options.dart';
import 'package:dart_anchor_link/src/link_session.dart';
import 'package:dart_anchor_link/src/link_storage.dart';
import 'package:dart_anchor_link/src/link_transport.dart';
import 'package:dart_anchor_link/src/link_session_interfaces.dart';

import 'package:dart_esr/dart_esr.dart';
import 'package:eosdart/eosdart.dart' as eosDart;
import 'package:eosdart_ecc/eosdart_ecc.dart' as ecc;

import 'package:dart_anchor_link/src/toMoveTo/eosdart/eosdart-api-interface.dart'
    as eosDart;
import 'package:web_socket_channel/io.dart';

import 'toMoveTo/eosdart/eosdart-rpc-interface.dart';
import 'toMoveTo/eosdart/eosdart_jsonrpc.dart' as eosDart;

/**
 * Main class, also exposed as the default export of the library.
 *
 * Example:
 *
 * ```ts
 * import AnchorLink from 'anchor-link'
 * import ConsoleTransport from 'anchor-link-console-transport'
 *
 * const link = new AnchorLink({
 *     transport: new ConsoleTransport()
 * })
 *
 * const result = await link.transact({actions: myActions})
 * ```
 */
class Link extends AbiProvider {
  /** The eosjs RPC instance used to communicate with the EOSIO node. */
  eosDart.JsonRpc _rpc;
  eosDart.JsonRpc get rpc => _rpc;

  /** Transportto deliver requests to the user wallet. */
  LinkTransport _transport;
  LinkTransport get transport => _transport;

  /** EOSIO ChainID for which requests are valid. */
  String _chainId;
  String get chainId => _chainId;

  /** Storage adapter used to persist sessions. */
  LinkStorage _storage;
  LinkStorage get storage => _storage;

  String _serviceAddress;
  String get serviceAddress => _serviceAddress;

  SigningRequestEncodingOptions _requestOptions;
  SigningRequestEncodingOptions get requestOptions => _requestOptions;

  Map<String, eosDart.Abi> _abiCache = {};
  Map<String, eosDart.Abi> get abiCache => _abiCache;

  Map<String, Future<GetAbiResult>> _pendingAbis = {};
  Map<String, Future<GetAbiResult>> get pendingAbis => _pendingAbis;

  /** Create a new link instance. */
  Link(LinkOptions options) {
    if (options == null) {
      throw 'Missing options object';
    }
    if (options.transport == null) {
      throw 'options.transport is required, see https://github.com/greymass/anchor-link#transports';
    }

    if (options.rpc == null) {
      this._rpc = defaults.rpc;
    } else {
      this._rpc = options.rpc;
    }

    if (options.chainId != null) {
      this._chainId = options.chainId;
    } else {
      this._chainId = defaults.chainId;
    }

    var serviceAddr =
        (options.service != null ? options.service : defaults.service).trim();
    if (serviceAddr.endsWith('/')) {
      this._serviceAddress = serviceAddr.substring(serviceAddr.length - 1);
    } else {
      this._serviceAddress = serviceAddr;
    }

    this._transport = options.transport;

    if (options.storage != null) {
      this._storage = options.storage;
    } else {
      this._storage = this.transport.storage;
    }

    var textEncoder =
        options.textEncoder ?? defaultSigningRequestEncodingOptions.textEncoder;
    var textDecoder =
        options.textDecoder ?? defaultSigningRequestEncodingOptions.textDecoder;
    this._requestOptions = SigningRequestEncodingOptions(
        abiProvider: this.rpc,
        textEncoder: textEncoder,
        textDecoder: textDecoder,
        zlib: defaultSigningRequestEncodingOptions.zlib);
  }

  /**
   * Create a new unique buoy callback url.
   * @internal
   */
  String createCallbackUrl() {
    var uuid = Uuid().v4();
    return '${this.serviceAddress}/${uuid}';
  }

  /**
   * Create a SigningRequestManager instance configured for this link.
   * @internal
   */
  Future<SigningRequestManager> createRequest(
      SigningRequestCreateArguments args,
      {LinkTransport transport}) async {
    var t = transport != null ? transport : this.transport;
    // generate unique callback url
    args.chainId = this.chainId;
    args.broadcast = false;
    args.callback = CallbackType(
      this.createCallbackUrl(),
      true,
    );
    var request =
        await SigningRequestManager.create(args, options: this.requestOptions);

    return await t.prepare(request);
  }

  /**
     * Send a SigningRequest instance using this link.
     * @internal
     */
  Future<TransactResult> sendRequest(SigningRequestManager request,
      {LinkTransport transport, bool broadcast = false}) async {
    var t = transport != null ? transport : this.transport;
    try {
      var linkUrl = request?.data?.callback;
      if (linkUrl == null || !linkUrl.startsWith(this.serviceAddress)) {
        throw 'Request must have a link callback';
      }
      if (request.data.flags != 2) {
        throw 'Invalid request flags';
      }

      var ctx = CancelTransaction(() => {});

      // // wait for callback or user cancel
      // var socket = waitForCallback(linkUrl, ctx: ctx)
      //     .then((data) => data)
      //     .catchError((onError) {
      //   throw CancelException('Rejected by wallet: ${onError.toString()}');
      // });

      // var cancel = Future(() async {
      //   // var completer = new Completer();
      //   await t.onRequest(request, ({exception, reason}) {
      //     if (ctx.cancel != null) {
      //       ctx.cancel();
      //     }
      //     // completer.completeError(reason);
      //     throw CancelException(reason);
      //   });
      // });
      //TODO make ws work
      // CallbackPayload payloads = await Future.any([socket, cancel]);

      var decodedRes = json.decode(
          '''{"sig":"SIG_K1_KAiMKTevRUKWxJmN2eLsKL2G76k4VdiAVsCDesE1gSWCgSJCzB3rcuP9Faq9VJaB7LUGV8Ad9Y5Y8W1cogQE9W1GY3Y3gJ",
          "tx":"52C33424F74DDCC42EC9FFD780CBE5D8FE6F7A55E559BC1F6E1A691F2BD912DC",
          "rbn":"0",
          "rid":"0",
          "ex":"1970-01-01T00:00:00.000",
          "req":"esr://gmN8zrVqx8w62T9P-_evaTi9u__Nm-qZ52doTXFRt9mTckSkmJmByTqjpKSg2EpfPzlJLzEvOSO_SC8nMy9bP9Uk2TjJMsVE18jQJEnXxCDNUtcyNdVcN9HYPC3ZMtXA0CAplZkFpFSLgYHhCiNPpg0D8z0XxryGVXdEq7vjOYSeTPqyOb_NgLMpnn31zZV3Cl-qbOEuTsxNjU9JLctMTmVk5C5KLSktyosvSCzJaGGEuSOrNC89J1UvKSc_u1gvM18_MTk5vzSvRD81vzivIDMvvSA_L90-Jz8xxTk_r6QoMbnEtqSoNFWtJDHJNiQxKSe1WA2qwxZZh1pxcn5BKqpQTmZuZomtoYGBsmlaXo5PVnEBAA",
          "sa":"pacoeosnatio",
          "sp":"active"}''');

      CallbackPayload payload = CallbackPayload(
        bn: decodedRes['bn'],
        ex: decodedRes['ex'],
        sig: decodedRes['sig'],
        rbn: decodedRes['rbn'],
        req: decodedRes['req'],
        rid: decodedRes['rid'],
        sa: decodedRes['sa'],
        sp: decodedRes['sp'],
        tx: decodedRes['tx'],
        signatures:
            decodedRes['sigX'] ?? <String, String>{'sig0': decodedRes['sig']},
      );

      var signer = Authorization()
        ..actor = payload.sa
        ..permission = payload.sp;

      List<String> signatures =
          payload.signatures.entries.map((entry) => entry.value).toList();
      var resolved = await ResolvedSigningRequest.fromPayload(
          payload, this.requestOptions);

      var info = resolved.request.getInfo();
      if (info.containsKey(['fuel_sig'])) {
        signatures.insert(0, info['fuel_sig']);
      }

      TransactResult result = TransactResult(
        resolved.request,
        signatures,
        payload,
        signer,
        resolved.transaction,
        resolved.serializedTransaction,
      );

      if (broadcast) {
        var res = await this.rpc.pushTransaction(eosDart.PushTransactionArgs(
              result.signatures,
              result.serializedTransaction,
            ));
        result.processed = res.processed;
      }
      if (t.onSuccess != null) {
        t.onSuccess(request, result);
      }
      return result;
    } catch (e) {
      if (t.onFailure != null && e is Exception) {
        t.onFailure(request, e);
      }
      throw e;
    }
  }

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
      {TransactOptions options, LinkTransport transport}) async {
    LinkTransport t = transport ?? this.transport;
    var broadcast = options != null ? options.broadcast : true;

    // Initialize the loading state of the transport
    if (t != null && t.showLoading is Function) {
      t.showLoading();
    }

    SigningRequestCreateArguments requestArgs;
    if (args.action != null) {
      requestArgs = SigningRequestCreateArguments(action: args.action);
    } else if (args.actions != null) {
      requestArgs = SigningRequestCreateArguments(actions: args.actions);
    } else if (args.transaction != null) {
      requestArgs =
          SigningRequestCreateArguments(transaction: args.transaction);
    }
    //TODO add code eosjs transact compat: upgrade to transaction if args have any header fields

    var request = await this.createRequest(requestArgs, transport: t);
    var result =
        await this.sendRequest(request, transport: t, broadcast: broadcast);
    return result;
  }

  /**
     * Send an identity request and verify the identity proof.
     * @param requestPermission Optional request permission if the request is for a specific account or permission.
     * @param info Metadata to add to the request.
     * @note This is for advanced use-cases, you probably want to use [[Link.login]] instead.
     */
  Future<IdentifyResult> identify(
      {Authorization requestPermission, Map<String, dynamic> info}) async {
    var identity = Identity()
      ..authorization = requestPermission ?? ESRConstants.PlaceholderAuth;
    var identifyRequest =
        SigningRequestCreateArguments(identity: identity, info: info);

    var request = await this.createRequest(identifyRequest);

    var res = await this.sendRequest(request);
    if (!res.request.isIdentity()) {
      throw IdentityException('Unexpected response');
    }

    var mess = <int>[];
    mess.addAll(eosDart.stringToHex(request.getChainId()));
    mess.addAll(res.serializedTransaction);

    var message = Uint8List.fromList(mess);
    var signature = ecc.EOSSignature.fromString(res.signatures[0]);
    var eosPubKey = signature.recover(message);
    //TODO get good key from ecc
    var signerKey =
        'EOS4vNRQnPLXVLtdAbCrffKDd2UZ6vX6unEQSGxhjvjCrPRtFVDgC'; //eosPubKey.toString();

    var account = await this.rpc.getAccount(res.signer.actor);
    if (account == null) {
      throw IdentityException(
          'Signature from unknown account: ${res.signer.actor}');
    }

    var permission = account.permissions.firstWhere(
        (permission) => permission.permName == res.signer.permission);
    if (permission == null) {
      throw IdentityException(
          '${res.signer.actor} signed for unknown permission: ${res.signer.permission}');
    }

    var auth = permission.requiredAuth;
    var keyAuth =
        auth.keys.firstWhere((key) => publicKeyEqual(key.key, signerKey));
    if (keyAuth == null) {
      throw IdentityException(
          '${formatAuth(res.signer)} has no key matching id signature');
    }
    if (auth.threshold > keyAuth.weight) {
      throw IdentityException(
          '${formatAuth(res.signer)} signature does not reach auth threshold');
    }
    if (requestPermission != null) {
      if ((requestPermission.actor != ESRConstants.PlaceholderName &&
              requestPermission.actor != res.signer.actor) ||
          (requestPermission.permission != ESRConstants.PlaceholderPermission &&
              requestPermission.permission != res.signer.permission)) {
        throw new IdentityException(
            'Unexpected identity proof from ${formatAuth(res.signer)}, expected ${formatAuth(requestPermission)} ');
      }
    }

    return IdentifyResult(account, signerKey, res.request, res.signatures,
        res.payload, res.signer, res.transaction, res.serializedTransaction);
  }

  /**
     * Login and create a persistent session.
     * @param identifier The session identifier, an EOSIO name (`[a-z1-5]{1,12}`).
     *                   Should be set to the contract account if applicable.
     */
  Future<LoginResult> login(String identifier) async {
    var privateKey = await generatePrivateKey();
    var requestKey = privateKey.toEOSPublicKey();
    var createInfo = LinkCreate()
      ..sessionName = identifier
      ..requestKey = requestKey.toString();

    var encodedData = abiEncode(createInfo, 'link_create');
    var res = await this.identify(
      info: {'link': encodedData},
    );

    var rawInfo = res.request.getRawInfo();

    var metadata = <String, bool>{
      'sameDevice': rawInfo != null && rawInfo['return_path'] != null
    };

    LinkSession session;
    if (res.payload.linkCh != null &&
        res.payload.linkKey != null &&
        res.payload.linkName != null) {
      session = new LinkChannelSession(
          this,
          LinkChannelSessionData(
            identifier,
            res.signer,
            res.signerKey,
            ChannelInfo(
              res.payload.linkKey,
              res.payload.linkName,
              res.payload.linkCh,
            ),
            privateKey.toString(),
          ),
          metadata);
    } else {
      session = LinkFallbackSession(
          this,
          LinkFallbackSessionData(
            identifier,
            res.signer,
            res.signerKey,
          ),
          metadata);
    }
    if (this.storage != null) {
      await this._storeSession(identifier, session);
    }
    return LoginResult(
        session,
        res.account,
        res.signerKey,
        res.request,
        res.signatures,
        res.payload,
        res.signer,
        res.transaction,
        res.serializedTransaction);
  }

  /**
     * Restore previous session, see [[Link.login]] to create a new session.
     * @param identifier The session identifier, should be same as what was used when creating the session with [[Link.login]].
     * @param auth A specific session auth to restore, if omitted the most recently used session will be restored.
     * @returns A [[LinkSession]] instance or null if no session can be found.
     * @throws If no [[LinkStorage]] adapter is configured or there was an error retrieving the session data.
     **/
  Future<LinkSession> restoreSession(String identifier,
      {Authorization auth}) async {
    if (this.storage == null) {
      throw 'Unable to restore session: No storage adapter configured';
    }
    String key;
    if (auth != null) {
      key = this._sessionKey(identifier, formatAuth(auth));
    } else {
      var latest = (await this.listSessions(identifier))[0];
      if (latest == null) {
        return null;
      }
      key = this._sessionKey(identifier, formatAuth(latest));
    }
    var data = await this.storage.read(key);
    if (data == null) {
      return null;
    }
    var sessionData;
    try {
      //TODO check json encoding
      sessionData = jsonDecode(data);
    } catch (error) {
      throw 'Unable to restore session: Stored JSON invalid (${error.toString})';
    }
    var session = LinkSession.restore(this, sessionData);
    if (auth != null) {
      // update latest used
      await this._touchSession(identifier, auth);
    }
    return session;
  }

  /**
     * List stored session auths for given identifier.
     * The most recently used session is at the top (index 0).
     * @throws If no [[LinkStorage]] adapter is configured or there was an error retrieving the session list.
     **/
  Future<List<Authorization>> listSessions(String identifier) async {
    if (this.storage == null) {
      throw 'Unable to list sessions: No storage adapter configured';
    }
    var key = this._sessionKey(identifier, 'list');
    List<Authorization> list;
    try {
      var data = await this._storage.read(key);
      //TODO check json encoding
      list = jsonDecode(data);
    } catch (error) {
      throw 'Unable to list sessions: Stored JSON invalid (${error.toString()})';
    }
    return list;
  }

  /**
     * Remove stored session for given identifier and auth.
     * @throws If no [[LinkStorage]] adapter is configured or there was an error removing the session data.
     */
  Future<void> removeSession(String identifier, Authorization auth) async {
    if (this.storage == null) {
      throw 'Unable to remove session: No storage adapter configured';
    }
    var key = this._sessionKey(identifier, formatAuth(auth));
    await this.storage.remove(key);
    await this._touchSession(identifier, auth, remove: true);
  }

  /**
     * Remove all stored sessions for given identifier.
     * @throws If no [[LinkStorage]] adapter is configured or there was an error removing the session data.
     */
  Future<void> clearSessions(String identifier) async {
    if (this.storage == null) {
      throw 'Unable to clear sessions: No storage adapter configured';
    }
    var sessions = await this.listSessions(identifier);
    for (var auth in sessions) {
      await this.removeSession(identifier, auth);
    }
  }

  /**
     * Create an eosjs compatible signature provider using this link.
     * @param availableKeys Keys the created provider will claim to be able to sign for.
     * @param transport (internal) Transport override for this call.
     * @note We don't know what keys are available so those have to be provided,
     *       to avoid this use [[LinkSession.makeSignatureProvider]] instead. Sessions can be created with [[Link.login]].
     */
  SignatureProvider makeSignatureProvider(List<String> availableKeys,
      {LinkTransport transport}) {
    //TODO makeSignatureProvider()
    throw 'not implemented yet';
  }

  /**
     * Create an eosjs authority provider using this link.
     * @note Uses the configured RPC Node's `/v1/chain/get_required_keys` API to resolve keys.
     */
  eosDart.AuthorityProvider makeAuthorityProvider() {
    //TODO makeAuthorityProvider()
    throw 'not implemented yet';
  }

  /** Makes sure session is in storage list of sessions and moves it to top (most recently used). */
  Future<void> _touchSession(String identifier, Authorization auth,
      {bool remove = false}) async {
    var auths = await this.listSessions(identifier);
    var formattedAuth = formatAuth(auth);
    var existing = auths.indexWhere((a) => formatAuth(a) == formattedAuth);
    if (existing >= 0) {
      auths.removeAt(existing);
    }
    if (remove == false) {
      auths.insert(0, auth);
    }
    var key = this._sessionKey(identifier, 'list');
    if (this.storage != null) {
      //TODO fromjson tojson
      await this.storage.write(key, jsonEncode(auths));
    }
  }

  /** Makes sure session is in storage list of sessions and moves it to top (most recently used). */
  Future<void> _storeSession(
      String identifier, LinkChannelSession session) async {
    var key = this._sessionKey(identifier, formatAuth(session.auth));
    //TODO fromjson tojson
    var data = jsonEncode(session.serialize());
    if (this.storage != null) {
      await this.storage.write(key, data);
    }
    await this._touchSession(identifier, session.auth);
  }

  /** Session storage key for identifier and suffix. */
  String _sessionKey(String identifier, String suffix) =>
      '${this.chainId}-${identifier}-${suffix}';

  @override
  Future getAbi(String account) async {
    return this._rpc.getAbi(account);
  }
}

/**
 * Connect to a WebSocket channel and wait for a message.
 * @internal
 */
Future<CallbackPayload> waitForCallback(String url,
    {CancelTransaction ctx}) async {
  //TODO check if completer is same as resove reject
  var completer = Completer<CallbackPayload>();

  var active = true;
  var retries = 0;
  var socketUrl = url.replaceFirst('http', 'ws');

  void handleResponse(String response) {
    //TODO return Callnackpayload instead of json decode
    try {
      //check decode
      completer.complete(json.decode(response));
    } catch (e) {
      completer.completeError('Unable to parse callback JSON: ${e.toString()}');
    }
  }

  void connect() {
    final socket = IOWebSocketChannel.connect(socketUrl);

    ctx.cancel = () {
      active = false;
      try {
        socket.sink.close();
      } catch (e) {
        print(e.toString());
      }
    };

    onData(event) {
      active = false;
      try {
        socket.sink.close();
      } catch (e) {
        print(e.toString());
      }

      // if (event.data is Blob) {
      //   var reader = FileReader();
      //   reader.onLoad
      //       .listen((event) => handleResponse(reader.result as String));
      //   reader.onError.listen((event) => throw Error);

      //   reader.readAsText(event.data);
      // } else {
      if (event.data is String) {
        handleResponse(event.data);
      } else {
        handleResponse(event.data.toString());
      }
      // }
    }

    ;
    // socket.onOpen.listen((event) => retries = 0);
    // socket.onError.listen((event) {});

    socket.stream.listen((event) {
      print('data');
      onData(event);
    }, onDone: () {
      if (active) {
        Timer(Duration(milliseconds: backoff(retries++)), connect);
      }
    });
  }

  connect();
  return completer.future;
}

/**
 * Exponential backoff function that caps off at 10s after 10 tries.
 * https://i.imgur.com/IrUDcJp.png
 * @internal
 */
int backoff(tries) {
  return min(pow(tries * 10, 2), 10 * 1000);
}

/**
 * Format a EOSIO permission level in the format `actor@permission` taking placeholders into consideration.
 * @internal
 */
String formatAuth(Authorization auth) {
  if (auth.actor == ESRConstants.PlaceholderName) {
    auth.actor = '<any>';
  }
  if (auth.permission == ESRConstants.PlaceholderName ||
      auth.permission == ESRConstants.PlaceholderPermission) {
    auth.permission = '<any>';
  }
  return '${auth.actor}@${auth.permission}';
}
