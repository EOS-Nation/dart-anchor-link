# dart-anchor-link
Persistent sessions that allows applications to setup a persistent and secure channel for pushing signature requests (ESR/EEP-7) to a wallet.

dart-anchor-link is based on the javascript library anchor-link -> https://github.com/greymass/anchor-link

## Examples

https://github.com/EOS-Nation/dart-anchor-link/master/example

## Usage

#### Import
```dart
import 'package:dart_esr/dart_esr.dart';
```

#### Login
```dart
    // app identifier, should be set to the eosio contract account if applicable
    var identifier = 'pacoeosnatio';

    // initialize the console transport
    var transport = ConsoleTransport();

    var options = LinkOptions(
      transport,
      chainName: ChainName.EOS_JUNGLE2,
      rpc: JsonRpc('https://jungle.greymass.com', 'v1'),
    );

    // initialize the link
    var link = Link(options);

    var res = await link.login(identifier);
    print(res?.session?.identifier);
```

#### Transact
```dart
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
```

## Installing
The package is available in pub dev repository => https://pub.dev/packages/dart_anchor_link
or in github => https://github.com/EOS-Nation/dart-anchor-link

1 - Resolve dependencies
```console
pub get
```
2 - Execute examples
```console
pub run example/example.dart
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/EOS-Nation/dart-anchor-link/issues
