import '../../domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({required super.id, required super.name});

  factory AccountModel.fromMap(Map<String, Object?> map) =>
      AccountModel(id: map['id'] as String, name: map['name'] as String);

  Map<String, Object?> toMap() => {'id': id, 'name': name};
}
