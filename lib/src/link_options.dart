import 'package:dart_anchor_link/src/link_storage.dart';
import 'package:dart_anchor_link/src/link_transport.dart';
import 'package:dart_esr/dart_esr.dart';

/**
 * Available options when creating a new [[Link]] instance.
 */
abstract class LinkOptions {
  /**
   * Link transport responsible for presenting signing requests to user, required.
   */
  LinkTransport transport;
  /**
   * ChainID or esr chain name alias for which the link is valid.
   * Defaults to EOS (aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906).
   */
  ChainName chainId;
  /**
   * URL to EOSIO node to communicate with or e eosjs JsonRpc instance.
   * Defaults to https://eos.greymass.com
   */
  EOSClient rpc;
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
}

/**
 * TODO: Change Jungle for EOS mainnet 
 * 
 * 'chainId':  'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906',
 * 'rpc':  'https://eos.greymass.com',
 */
const defaults = {
  'chainId': 'e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473',
  'rpc': 'https://jungle.greymass.com',
  'service': 'https://cb.anchor.link',
};
