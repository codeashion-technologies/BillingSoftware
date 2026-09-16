class Account {
  const Account({
    required this.id,
    required this.firmId,
    required this.name,
    required this.group,
    required this.address1,
    required this.address2,
    required this.deliveryAddress1,
    required this.city,
    required this.phone,
    required this.state,
    required this.gstNo,
    required this.gstStatus,
    required this.legalName,
    required this.constitution,
    required this.registrationDate,
    required this.businessNature,
    required this.principalBuilding,
    required this.principalFloor,
    required this.principalLocation,
    required this.principalStreet,
    required this.district,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.tradeNature,
    required this.stateJurisdictionCode,
    required this.stateJurisdiction,
    required this.centralJurisdictionCode,
    required this.centralJurisdiction,
    required this.panNo,
  });

  final int? id;
  final int firmId;
  final String name;
  final String group;
  final String address1;
  final String address2;
  final String deliveryAddress1;
  final String city;
  final String phone;
  final String state;
  final String gstNo;
  final String gstStatus;
  final String legalName;
  final String constitution;
  final String registrationDate;
  final String businessNature;
  final String principalBuilding;
  final String principalFloor;
  final String principalLocation;
  final String principalStreet;
  final String district;
  final String pincode;
  final String latitude;
  final String longitude;
  final String tradeNature;
  final String stateJurisdictionCode;
  final String stateJurisdiction;
  final String centralJurisdictionCode;
  final String centralJurisdiction;
  final String panNo;

  factory Account.fromMap(Map<String, Object?> map) => Account(
    id: map['id'] as int?,
    firmId: map['firm_id'] as int? ?? 0,
    name: map['name'] as String,
    group: map['group_name'] as String,
    address1: map['address1'] as String,
    address2: map['address2'] as String,
    deliveryAddress1: map['delivery_address1'] as String,
    city: map['city'] as String,
    phone: map['phone'] as String,
    state: map['state'] as String,
    gstNo: map['gst_no'] as String,
    gstStatus: map['gst_status'] as String? ?? '',
    legalName: map['taxpayer_legal_name'] as String? ?? '',
    constitution: map['constitution'] as String? ?? '',
    registrationDate: map['registration_date'] as String? ?? '',
    businessNature: map['business_nature'] as String? ?? '',
    principalBuilding: map['principal_building'] as String? ?? '',
    principalFloor: map['principal_floor'] as String? ?? '',
    principalLocation: map['principal_location'] as String? ?? '',
    principalStreet: map['principal_street'] as String? ?? '',
    district: map['district'] as String? ?? '',
    pincode: map['pincode'] as String? ?? '',
    latitude: map['latitude'] as String? ?? '',
    longitude: map['longitude'] as String? ?? '',
    tradeNature: map['trade_nature'] as String? ?? '',
    stateJurisdictionCode: map['state_jurisdiction_code'] as String? ?? '',
    stateJurisdiction: map['state_jurisdiction'] as String? ?? '',
    centralJurisdictionCode: map['central_jurisdiction_code'] as String? ?? '',
    centralJurisdiction: map['central_jurisdiction'] as String? ?? '',
    panNo: map['pan_no'] as String? ?? '',
  );

  Map<String, Object?> toMap() => {
    'firm_id': firmId,
    'name': name,
    'group_name': group,
    'address1': address1,
    'address2': address2,
    'delivery_address1': deliveryAddress1,
    'city': city,
    'phone': phone,
    'state': state,
    'gst_no': gstNo,
    'gst_status': gstStatus,
    'taxpayer_legal_name': legalName,
    'constitution': constitution,
    'registration_date': registrationDate,
    'business_nature': businessNature,
    'principal_building': principalBuilding,
    'principal_floor': principalFloor,
    'principal_location': principalLocation,
    'principal_street': principalStreet,
    'district': district,
    'pincode': pincode,
    'latitude': latitude,
    'longitude': longitude,
    'trade_nature': tradeNature,
    'state_jurisdiction_code': stateJurisdictionCode,
    'state_jurisdiction': stateJurisdiction,
    'central_jurisdiction_code': centralJurisdictionCode,
    'central_jurisdiction': centralJurisdiction,
    'pan_no': panNo,
  };
}
