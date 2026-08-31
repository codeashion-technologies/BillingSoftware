import 'package:equatable/equatable.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object?> get props => [];
}

final class LoadAccounts extends AccountEvent {
  const LoadAccounts();
}

final class SearchAccounts extends AccountEvent {
  const SearchAccounts(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}
