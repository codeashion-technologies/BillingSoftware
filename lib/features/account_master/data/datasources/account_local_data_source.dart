import '../../domain/entities/account.dart';

abstract interface class AccountLocalDataSource {
  Future<List<Account>> getAccounts();
}
