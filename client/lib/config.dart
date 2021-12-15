import 'package:flutterbox/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

const kPrefsKey = 'user-private-key';

//Change your URL here
const rpcURL = 'https://rpc-mumbai.maticvigil.com';

Future<void> init() async {
  final SharedPreferences _prefs = await SharedPreferences.getInstance();

  final Web3Client _web3Client = Web3Client(
    rpcURL,
    http.Client(),
  );

  final WalletService walletService = WalletService(_prefs, _web3Client);
}
