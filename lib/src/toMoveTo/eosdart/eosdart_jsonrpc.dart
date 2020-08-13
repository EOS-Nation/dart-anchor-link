//TODO: Move to eosdart
import 'package:dart_esr/dart_esr.dart';
import 'package:eosdart/eosdart.dart' as eosDart;

class JsonRpc extends AbiProvider {
  EOSNode node;
  JsonRpc(String endpoint, String version, {Object args}) {
    node = EOSNode('https://jungle.greymass.com', 'v1');
  }

  @override
  Future<eosDart.Abi> getAbi(String accountName) async {
    var abiResp = await node.getAbi(accountName);
    return abiResp.abi;
  }

  Future<dynamic> pushTransaction(
      eosDart.PushTransactionArgs pushTransactionArgs) async {
    return await node.pushTransaction(pushTransactionArgs);
  }

  Future<eosDart.Account> getAccount(String accountName) async {
    return await node.getAccount(accountName);
  }
}
