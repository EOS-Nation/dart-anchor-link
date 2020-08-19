import 'package:dart_esr/dart_esr.dart';

/** Arguments to `getRequiredKeys` */
abstract class AuthorityProviderArgs {
  /** Transaction that needs to be signed */
  Transaction transaction;
  /** Public keys associated with the private keys that the `SignatureProvider` holds */
  List<String> availableKeys;

  AuthorityProviderArgs(this.transaction, this.availableKeys);
}

/** Get subset of `availableKeys` needed to meet authorities in `transaction` */
abstract class AuthorityProvider {
  /** Get subset of `availableKeys` needed to meet authorities in `transaction` */
  Future<String> getRequiredKeys(AuthorityProviderArgs args);
}
