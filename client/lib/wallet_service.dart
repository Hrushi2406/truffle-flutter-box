import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutterbox/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class WalletService {
  final SharedPreferences _prefs;
  final Web3Client _web3client;

  WalletService(this._prefs, this._web3client);

  ///Send transaction to the network
  ///
  ///with the credentials passed or by
  ///default credentials stored in SharedPrefs
  ///
  ///Returns the transaction Hash
  sendTransaction(Transaction transaction, [Credentials? credentials]) async {
    try {
      final cred = credentials ?? initalizeWallet();

      return await _web3client.sendTransaction(cred, transaction);
    } catch (e) {
      debugPrint('Error at WalletService->sendTransaction: $e');
      rethrow;
    }
  }

  ///Estimate the transaction fee for given [Transaction]
  ///
  ///Gas Info - gas, currentGasPrice, totalTrasactionFee
  ///
  ///It rethrows the error if something goes wrong
  Future<GasInfo> estimateTransactionFee(Transaction transaction) async {
    try {
      //Estimate Gas For Transaction
      final estimatedGas = await _web3client.estimateGas(
        sender: transaction.from,
        to: transaction.to,
        value: transaction.value,
        data: transaction.data,
      );

      //Fetch current gas price
      final currentGasPrice = await _web3client.getGasPrice();

      final totalTransactionFee =
          estimatedGas * currentGasPrice.getInWei / BigInt.from(10).pow(18);

      return GasInfo(
        gas: estimatedGas,
        currentGasPrice: currentGasPrice,
        totalTransactionFee: totalTransactionFee,
      );
    } catch (e) {
      debugPrint('Error at WalletService->estimateTransactionFee: $e');

      rethrow;
    }
  }

  //GENERATE RANDOM WALLET
  Credentials generateRandomAccount() {
    //Generate New Credentials
    final cred = EthPrivateKey.createRandom(Random.secure());
    //Convert private to hex
    final key = bytesToHex(cred.privateKey, padToEvenLength: true);
    //Set private key to shred prefs
    setPrivateKey(key);
    return cred;
  }

  ///Retursn Credentials from given key
  ///
  ///If null then gets private key from shared Prefs
  Credentials initalizeWallet([String? key]) =>
      EthPrivateKey.fromHex(key ?? getPrivateKey());

  ///Stores private key
  ///
  ///in SharedPreferences
  setPrivateKey(String privateKey) async =>
      await _prefs.setString(kPrefsKey, privateKey);

  ///Returns Private Key
  ///
  ///from SharedPrefereces
  String getPrivateKey() => _prefs.getString(kPrefsKey) ?? '';
}

///Gas Info - gas, currentGasPrice, totalTrasactionFee
class GasInfo {
  ///Amount of gas required
  ///
  ///for the transaction
  final BigInt gas;

  ///Current Gas Price is in Wei
  ///
  ///For ETH - 10^-18
  final EtherAmount currentGasPrice;

  ///Total Gas Required in ETH
  ///
  ///totalTransactionFee = gas * currentGasPrice / 10^-18
  final double totalTransactionFee;

  const GasInfo({
    required this.gas,
    required this.currentGasPrice,
    required this.totalTransactionFee,
  });

  @override
  String toString() {
    return 'GasInfo -> gas: $gas, currentGasPrice: $currentGasPrice, totalGasRequired: $totalTransactionFee';
  }
}
