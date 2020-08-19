import 'package:dart_anchor_link/dart_anchor_link.dart';

import 'package:dart_anchor_link_console_transport/dart_anchor_link_console_transport.dart';

import 'package:dart_anchor_link/src/json_rpc.dart';
import 'package:dart_esr/dart_esr.dart';

main(List<String> args) => login();

Future<void> login() async {
  try {
    // app identifier, should be set to the eosio contract account if applicable
    var identifier = 'pacoeosnatio';

    // initialize the console transport
    var transport = ConsoleTransport();

    var options = LinkOptions(
      transport,
      chainName: ChainName.JUNGLE,
      rpc: JsonRpc('https://jungle.greymass.com', 'v1'),
    );

    // initialize the link
    var link = Link(options);

    var res = await link.login(identifier);
    print(res?.session?.identifier);
  } catch (e) {
    print(e.toString());
  }
}
