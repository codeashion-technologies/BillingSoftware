import 'package:flutter/material.dart';

import 'credit_note_page.dart';

class DebitNotePage extends StatelessWidget {
  const DebitNotePage({super.key});

  @override
  Widget build(BuildContext context) => const CreditNotePage(isDebit: true);
}
