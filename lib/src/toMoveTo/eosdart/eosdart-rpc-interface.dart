//TODO: Move to eosdart
import 'dart:typed_data';

import 'package:eosdart/eosdart.dart';

/** Return value of `/v1/chain/get_abi` */
class GetAbiResult {
  String account_name;
  Abi abi;

  GetAbiResult(this.account_name, this.abi);
}

/** Subset of `GetBlockResult` needed to calculate TAPoS fields in transactions */
abstract class BlockTaposInfo {
  String timestamp;
  int block_num;
  int ref_block_prefix;
}

/** Return value of `/v1/chain/get_block` */
abstract class GetBlockResult {
  String timestamp;
  String producer;
  int confirmed;
  String previous;
  String transaction_mroot;
  String action_mroot;
  int schedule_version;
  String producer_signature;
  String id;
  int block_num;
  int ref_block_prefix;
}

/** Return value of `/v1/chain/get_code` */
abstract class GetCodeResult {
  String account_name;
  String code_hash;
  String wast;
  String wasm;
  Abi abi;
}

/** Return value of `/v1/chain/get_info` */
abstract class GetInfoResult {
  String server_version;
  String chain_id;
  int head_block_num;
  int last_irreversible_block_num;
  String last_irreversible_block_id;
  String head_block_id;
  String head_block_time;
  String head_block_producer;
  int virtual_block_cpu_limit;
  int virtual_block_net_limit;
  int block_cpu_limit;
  int block_net_limit;
}

/** Return value of `/v1/chain/get_raw_code_and_abi` */
abstract class GetRawCodeAndAbiResult {
  String account_name;
  String wasm;
  String abi;
}

/** Arguments for `push_transaction` */
class PushTransactionArgs {
  List<String> signatures;
  Uint8List serializedTransaction;
  PushTransactionArgs(this.signatures, this.serializedTransaction);
}
