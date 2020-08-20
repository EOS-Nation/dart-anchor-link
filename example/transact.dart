import 'package:dart_anchor_link/dart_anchor_link.dart';

import 'package:dart_anchor_link/src/json_rpc.dart';
import 'package:dart_esr/dart_esr.dart';

import 'console_transport.dart';

main(List<String> args) => transact();

Future<void> transact() async {
  // initialize the console transport
  var transport = ConsoleTransport();

  var options = LinkOptions(
    transport,
    chainName: ChainName.EOS,
    rpc: JsonRpc('https://eos.eosn.io', 'v1'),
  );

  // initialize the link
  var link = Link(options);

  var auth = <Authorization>[ESRConstants.PlaceholderAuth];

  var data = <String, dynamic>{
    'voter': ESRConstants.PlaceholderName,
    'proxy': 'eosnationftw',
    'producers': [],
  };

  var action = Action()
    ..account = 'eosio'
    ..name = 'voteproducer'
    ..authorization = auth
    ..data = data;

  var args = TransactArgs(action: action);

  var res = await link.transact(args);
  print(res?.processed);
}
