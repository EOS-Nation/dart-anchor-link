//TODO: Move to eosdart
import 'package:eosdart/eosdart.dart' as eosDart;
import 'eosdart-rpc-interface.dart';

class JsonRpc {
  eosDart.EOSClient client;
  JsonRpc(String endpoint, String version, {Object args}) {
    eosDart.EOSClient('https://jungle.greymass.com', 'v1');
  }

  Future<GetAbiResult> getAbi(String accountName) {
    //TODO: get_abi not implemented yet
    throw 'get_abi not implemented yet';
  }

  Future<dynamic> pushTransaction(PushTransactionArgs pushTransactionArgs) {
    //TODO: push_transaction not implemented yet
    throw 'push_transaction not implemented yet';
  }
}
