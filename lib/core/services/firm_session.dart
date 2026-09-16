import 'package:flutter/foundation.dart';

import '../../shared/models/firm.dart';

class FirmSession extends ChangeNotifier {
  FirmSession._();

  static final instance = FirmSession._();

  Firm _current = const Firm(
    id: 0,
    code: '3723',
    name: 'SHREE BALKRISHNA FASHION',
    financialYear: '2026-27',
    area: 'SACHIN',
  );

  Firm get current => _current;

  void select(Firm firm) {
    _current = firm;
    notifyListeners();
  }
}
