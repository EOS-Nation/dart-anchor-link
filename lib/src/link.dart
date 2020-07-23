import 'dart:math';

import 'package:dart_anchor_link/src/link_interfaces.dart';
import 'package:dart_esr/dart_esr.dart' as esr;

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
class Link {}

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
String formatAuth(PermissionLevel auth) {
  if (auth.actor == esr.ESRConstants.PlaceholderName) {
    auth.actor = '<any>';
  }
  if (auth.permission == esr.ESRConstants.PlaceholderName ||
      auth.permission == esr.ESRConstants.PlaceholderPermission) {
    auth.permission = '<any>';
  }
  return '${auth.actor}@${auth.permission}';
}
