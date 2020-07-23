//TODO: Move to eosdart
import 'dart:typed_data';

import 'package:eosdart/eosdart.dart';

/** Arguments to `getRequiredKeys` */
abstract class AuthorityProviderArgs {
  /** Transaction that needs to be signed */
  dynamic transaction;
  /** Public keys associated with the private keys that the `SignatureProvider` holds */
  List<String> availableKeys;

  AuthorityProviderArgs(this.transaction, this.availableKeys);
}

/** Get subset of `availableKeys` needed to meet authorities in `transaction` */
abstract class AuthorityProvider {
  /** Get subset of `availableKeys` needed to meet authorities in `transaction` */
  Future<String> getRequiredKeys(AuthorityProviderArgs args);
}

/** Retrieves raw ABIs for a specified accountName */
abstract class AbiProvider {
  /** Retrieve the BinaryAbi */
  Future<BinaryAbi> getRawAbi(String accountName);
}

/** Structure for the raw form of ABIs */
abstract class BinaryAbi {
  /** account which has deployed the ABI */
  String accountName;
  /** abi in binary form */
  Uint8List abi;

  BinaryAbi(this.accountName, this.abi);
}

/** Holds a fetched abi */
abstract class CachedAbi {
  /** abi in binary form */
  Uint8List rawAbi;
  /** abi in structured form */
  String abi;

  CachedAbi(this.rawAbi, this.abi); //TODO final Abi abi;
}

/** Arguments to `sign` */
abstract class SignatureProviderArgs {
  /** Chain transaction is for */
  String chainId;
  /** Public keys associated with the private keys needed to sign the transaction */
  List<String> requiredKeys;
  /** Transaction to sign */
  Uint8List serializedTransaction;
  /** ABIs for all contracts with actions included in `serializedTransaction` */
  List<BinaryAbi> abis;

  SignatureProviderArgs(
      this.chainId, this.requiredKeys, this.serializedTransaction);
}

/** Signs transactions */
abstract class SignatureProvider {
  /** Public keys associated with the private keys that the `SignatureProvider` holds */
  Future<String> getAvailableKeys;
  /** Sign a transaction */
  Future<PushTransactionArgs> sign(SignatureProviderArgs args);
}
