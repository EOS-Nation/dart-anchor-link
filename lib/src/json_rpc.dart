import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:dart_esr/dart_esr.dart';
import 'package:eosdart/eosdart.dart' as eosDart;

class JsonRpc extends AbiProvider {
  EOSNode node;
  JsonRpc(String endpoint, String version, {Object args}) {
    node = EOSNode(endpoint, version);
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

class EOSNode {
  String _nodeURL;
  get url => this._nodeURL;
  set url(String url) => this._nodeURL = url;

  String _nodeVersion;
  get version => this._nodeVersion;
  set version(String url) => this._nodeVersion = version;

  EOSNode(this._nodeURL, this._nodeVersion);

  Future<dynamic> _post(String path, Object body) async {
    var response = await http.post('${this.url}/${this.version}${path}',
        body: json.encode(body));
    if (response.statusCode >= 300) {
      throw response.body;
    } else {
      return json.decode(response.body);
    }
  }

  /// Get EOS Node Info
  Future<eosDart.NodeInfo> getInfo() async {
    var nodeInfo = await this._post('/chain/get_info', {});
    return eosDart.NodeInfo.fromJson(nodeInfo);
  }

  /// Get EOS Block Info
  Future<eosDart.Block> getBlock(String blockNumOrId) async {
    var block =
        await this._post('/chain/get_block', {'block_num_or_id': blockNumOrId});
    return eosDart.Block.fromJson(block);
  }

  /// Get EOS account info form the given account name
  Future<eosDart.Account> getAccount(String accountName) async {
    var account =
        await this._post('/chain/get_account', {'account_name': accountName});
    return eosDart.Account.fromJson(account);
  }

  /// Get EOS raw abi from account name
  Future<eosDart.AbiResp> getRawAbi(String accountName) async {
    var rawAbi =
        await this._post('/chain/get_raw_abi', {'account_name': accountName});
    return eosDart.AbiResp.fromJson(rawAbi);
  }

  /// Get EOS abi from account name
  Future<eosDart.AbiResp> getAbi(String accountName) async {
    var abi = await this._post('/chain/get_abi', {'account_name': accountName});
    return eosDart.AbiResp.fromJson(abi);
  }

  /// Push transaction to EOS chain
  Future<dynamic> pushTransaction(
      eosDart.PushTransactionArgs pushTransactionArgs) async {
    return this._post('/chain/push_transaction', {
      'signatures': pushTransactionArgs.signatures,
      'compression': 0,
      'packed_context_free_data': '',
      'packed_trx':
          eosDart.arrayToHex(pushTransactionArgs.serializedTransaction),
    });
  }
}
