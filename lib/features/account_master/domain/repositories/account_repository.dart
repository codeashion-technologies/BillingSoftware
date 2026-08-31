import '../entities/account.dart';

abstract interface class AccountRepository {
  Future<List<Account>> getAccounts();
}
