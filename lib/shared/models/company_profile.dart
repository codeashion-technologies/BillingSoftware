class CompanyProfile {
  const CompanyProfile({
    required this.financialYear,
    required this.softwareCompanyName,
    required this.millBaseId,
    required this.clientName,
    required this.area,
  });

  final String financialYear;
  final String softwareCompanyName;
  final String millBaseId;
  final String clientName;
  final String area;

  static const defaults = CompanyProfile(
    financialYear: '2026-27',
    softwareCompanyName: 'CODEASHION TECHNOLOGIES',
    millBaseId: '3723',
    clientName: 'SHREE BALKRISHNA FASHION',
    area: 'SACHIN',
  );
}
