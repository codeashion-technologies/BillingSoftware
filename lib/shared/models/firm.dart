class Firm {
  const Firm({
    required this.id,
    required this.code,
    required this.name,
    required this.financialYear,
    required this.area,
  });

  final int id;
  final String code;
  final String name;
  final String financialYear;
  final String area;

  factory Firm.fromMap(Map<String, Object?> map) => Firm(
    id: map['id'] as int,
    code: map['firm_code'] as String,
    name: map['firm_name'] as String,
    financialYear: map['financial_year'] as String,
    area: map['area'] as String,
  );
}
