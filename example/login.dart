import 'package:dart_anchor_link/dart_anchor_link.dart';

import 'package:dart_anchor_link/src/json_rpc.dart';
import 'package:dart_esr/dart_esr.dart';

import 'console_transport.dart';

main(List<String> args) => login();

Future<void> login() async {
  // app identifier, should be set to the eosio contract account if applicable
  var identifier = 'pacoeosnatio';

  // initialize the console transport
  var transport = ConsoleTransport();

  var options = LinkOptions(
    transport,
    chainName: ChainName.EOS,
    rpc: JsonRpc('https://eos.eosn.io', 'v1'),
  );

  // initialize the link
  var link = Link(options);

  var res = await link.login(identifier);
  print(res?.session?.identifier);
}
