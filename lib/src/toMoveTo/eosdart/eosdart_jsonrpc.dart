//TODO: Move to eosdart
import 'package:dart_anchor_link/src/toMoveTo/eosdart/eosdart-rpc-interface.dart';
import 'package:dart_esr/dart_esr.dart';
import 'package:eosdart/eosdart.dart' as eosDart;

class JsonRpc extends AbiProvider {
  eosDart.EOSClient client;
  JsonRpc(String endpoint, String version, {Object args}) {
    client = eosDart.EOSClient('https://jungle.greymass.com', 'v1');
  }

  @override
  Future<dynamic> getAbi(String accountName) async {
    var abiResp = await client.getAbi(accountName);
    return GetAbiResult(abiResp.accountName, abiResp.abi);
  }

  Future<dynamic> pushTransaction(
      eosDart.PushTransactionArgs pushTransactionArgs) {
    //TODO: push_transaction not implemented yet
    throw 'push_transaction not implemented yet';
  }

  Future<eosDart.Account> getAccount(String accountName) async {
    return await client.getAccount(accountName);
  }
}
