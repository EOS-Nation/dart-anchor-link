import 'package:dart_anchor_link/src/link.dart';
import 'package:dart_anchor_link/src/link_interfaces.dart';
import 'package:dart_anchor_link/src/link_session.dart';
import 'package:dart_anchor_link/src/toMoveTo/eosdart/eosdart-api-interface.dart'
    as eosDart;
import 'package:dart_esr/dart_esr.dart';

/**
 * Type describing a link session that can create a eosjs compatible
 * signature provider and transact for a specific auth.
 */
abstract class LinkSession {
  /** The underlying link instance used by the session. */
  Link link;
  /** App identifier that owns the session. */
  String identifier;
  /** The public key the session can sign for. */
  String publicKey;
  /** The EOSIO auth (a.k.a. permission level) the session can sign for. */
  Authorization auth;
  /** Session type, e.g. 'channel'.  */
  String type;
  /** Arbitrary metadata that will be serialized with the session. */
  Map<String, dynamic> metadata;

  /** Creates a eosjs compatible authority provider. */
  eosDart.AuthorityProvider makeAuthorityProvider();
  /** Creates a eosjs compatible signature provider that can sign for the session public key. */
  SignatureProvider makeSignatureProvider();
  /**
     * Transact using this session. See [[Link.transact]].
     */
  Future<TransactResult> transact(TransactArgs args, {TransactOptions options});
  /** Returns a JSON-encodable object that can be used recreate the session. */
  SerializedLinkSession serialize();
  /**
     * Convenience, remove this session from associated [[Link]] storage if set.
     * Equivalent to:
     * ```ts
     * session.link.removeSession(session.identifier, session.auth)
     * ```
     */
  Future<void> remove() async {
    if (this.link.storage != null) {
      await this.link.removeSession(this.identifier, this.auth);
    }
  }

  /** Restore a previously serialized session. */
  static LinkSession restore(Link link, SerializedLinkSession data) {
    switch (data.type) {
      case 'channel':
        return LinkChannelSession(link, data.data, data.metadata);
      case 'fallback':
        return LinkFallbackSession(link, data.data, data.metadata);
      default:
        throw 'Unable to restore, session data invalid';
    }
  }
}

class SerializedLinkSession {
  String type;
  Map<String, dynamic> metadata;
  LinkSessionData data;

  SerializedLinkSession(this.type, this.data, this.metadata);
}

class ChannelInfo {
  String key;
  String name;
  String url;

  ChannelInfo(this.key, this.name, this.url);
}

abstract class LinkSessionData {}

class LinkChannelSessionData implements LinkSessionData {
  Authorization auth;
  String identifier;
  String publicKey;
  ChannelInfo channel;
  String requestKey;

  LinkChannelSessionData(this.identifier, this.auth, this.publicKey,
      this.channel, this.requestKey);
}

class LinkFallbackSessionData implements LinkSessionData {
  Authorization auth;
  String identifier;
  String publicKey;

  LinkFallbackSessionData(this.identifier, this.auth, this.publicKey);
}
