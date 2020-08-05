import 'package:dart_anchor_link/src/link_storage.dart';
import 'package:dart_anchor_link/src/link_transport.dart';
import 'package:dart_esr/dart_esr.dart';

import 'toMoveTo/eosdart/eosdart_jsonrpc.dart';

/**
 * Available options when creating a new [[Link]] instance.
 * Set either chainName or chainId, if both have values, chainName is use
 */
class LinkOptions {
  LinkOptions(this.transport,
      {ChainName chainName,
      this.chainId,
      this.rpc,
      this.service,
      this.storage,
      this.textEncoder,
      this.textDecoder}) {
    if (chainName != null) {
      this.chainId = ESRConstants.ChainIdLookup[chainName];
    }
  }
  /**
   * Link transport responsible for presenting signing requests to user, required.
   */
  LinkTransport transport;
  /**
   * ChainID or esr chain name alias for which the link is valid.
   * Defaults to EOS (aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906).
   */
  String chainId;
  /**
   * URL to EOSIO node to communicate with or e eosjs JsonRpc instance.
   * Defaults to https://eos.greymass.com
   */
  JsonRpc rpc;
  /**
   * URL to link callback service.
   * Defaults to https://cb.anchor.link.
   */
  String service;
  /**
   * Optional storage adapter that will be used to persist sessions if set.
   * If not storage adapter is set but the given transport provides a storage, that will be used.
   * Explicitly set this to `null` to force no storage.
   */
  LinkStorage storage;
  /**
     * Text encoder, only needed in old browsers or if used in node.js versions prior to v13.
     */
  TextEncoder textEncoder;
  /**
     * Text decoder, only needed in old browsers or if used in node.js versions prior to v13.
     */
  TextDecoder textDecoder;
}

/**
 * TODO: Change Jungle for EOS mainnet 
 * 
 * 'chainId':  'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906',
 * 'rpc':  'https://eos.greymass.com',
 */
final defaults = LinkOptions(null,
    chainId: ESRConstants.ChainIdLookup[ChainName.EOS_JUNGLE2],
    rpc: JsonRpc('https://jungle.greymass.com', 'v1'),
    service: 'https://cb.anchor.link');
