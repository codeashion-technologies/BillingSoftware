class Account {
  const Account({
    required this.id,
    required this.name,
    required this.group,
    required this.address1,
    required this.address2,
    required this.deliveryAddress1,
    required this.city,
    required this.phone,
    required this.state,
    required this.gstNo,
  });

  final int? id;
  final String name;
  final String group;
  final String address1;
  final String address2;
  final String deliveryAddress1;
  final String city;
  final String phone;
  final String state;
  final String gstNo;

  factory Account.fromMap(Map<String, Object?> map) => Account(
    id: map['id'] as int?,
    name: map['name'] as String,
    group: map['group_name'] as String,
    address1: map['address1'] as String,
    address2: map['address2'] as String,
    deliveryAddress1: map['delivery_address1'] as String,
    city: map['city'] as String,
    phone: map['phone'] as String,
    state: map['state'] as String,
    gstNo: map['gst_no'] as String,
  );

  Map<String, Object?> toMap() => {
    'name': name,
    'group_name': group,
    'address1': address1,
    'address2': address2,
    'delivery_address1': deliveryAddress1,
    'city': city,
    'phone': phone,
    'state': state,
    'gst_no': gstNo,
  };
}
