import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_local_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._localDataSource);
  final AccountLocalDataSource _localDataSource;

  @override
  Future<List<Account>> getAccounts() => _localDataSource.getAccounts();
}
