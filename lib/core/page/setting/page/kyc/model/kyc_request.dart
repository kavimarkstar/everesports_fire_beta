class KycRequest {
  final String? id;
  final String userId;
  final String? fullName;
  final String firstName;
  final String surname;
  final String address;
  final String? country;
  final String idType;
  final String idNumber;
  final String? idCardNumber;
  final String idDocumentFrontPath;
  final String? idDocumentBackPath;
  final String addressProofPath;
  final String status;
  final String createdAt;
  final String? updatedAt;

  const KycRequest({
    this.id,
    required this.userId,
    this.fullName,
    required this.firstName,
    required this.surname,
    required this.address,
    this.country,
    required this.idType,
    required this.idNumber,
    this.idCardNumber,
    required this.idDocumentFrontPath,
    this.idDocumentBackPath,
    required this.addressProofPath,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      if (fullName != null) 'fullName': fullName,
      'firstName': firstName,
      'surname': surname,
      'address': address,
      if (country != null) 'country': country,
      'idType': idType,
      'idNumber': idNumber,
      if (idCardNumber != null) 'idCardNumber': idCardNumber,
      'idDocumentFrontPath': idDocumentFrontPath,
      if (idDocumentBackPath != null) 'idDocumentBackPath': idDocumentBackPath,
      'addressProofPath': addressProofPath,
      'status': status,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  factory KycRequest.fromMap(Map<String, dynamic> map) {
    return KycRequest(
      id: map['_id']?.toString(),
      userId: map['userId'] ?? '',
      fullName: map['fullName']?.toString(),
      firstName: map['firstName'] ?? '',
      surname: map['surname'] ?? '',
      address: map['address'] ?? '',
      country: map['country']?.toString(),
      idType: map['idType'] ?? '',
      idNumber: map['idNumber'] ?? '',
      idCardNumber: map['idCardNumber']?.toString(),
      idDocumentFrontPath: map['idDocumentFrontPath'] ?? '',
      idDocumentBackPath: map['idDocumentBackPath']?.toString(),
      addressProofPath: map['addressProofPath'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt']?.toString(),
    );
  }

  KycRequest copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? firstName,
    String? surname,
    String? address,
    String? country,
    String? idType,
    String? idNumber,
    String? idCardNumber,
    String? idDocumentFrontPath,
    String? idDocumentBackPath,
    String? addressProofPath,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return KycRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      address: address ?? this.address,
      country: country ?? this.country,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      idCardNumber: idCardNumber ?? this.idCardNumber,
      idDocumentFrontPath: idDocumentFrontPath ?? this.idDocumentFrontPath,
      idDocumentBackPath: idDocumentBackPath ?? this.idDocumentBackPath,
      addressProofPath: addressProofPath ?? this.addressProofPath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum KycStatus {
  pending,
  approved,
  rejected,
  underReview;

  @override
  String toString() => name;

  static KycStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return KycStatus.approved;
      case 'rejected':
        return KycStatus.rejected;
      case 'underreview':
      case 'under_review':
        return KycStatus.underReview;
      default:
        return KycStatus.pending;
    }
  }
}

enum IdDocumentType {
  passport,
  nationalId,
  drivingLicense;

  String get displayName {
    switch (this) {
      case IdDocumentType.passport:
        return 'Passport';
      case IdDocumentType.nationalId:
        return 'National ID';
      case IdDocumentType.drivingLicense:
        return 'Driving License';
    }
  }

  String get value {
    switch (this) {
      case IdDocumentType.passport:
        return 'Passport';
      case IdDocumentType.nationalId:
        return 'National ID Card';
      case IdDocumentType.drivingLicense:
        return 'Driving License';
    }
  }

  static IdDocumentType fromString(String type) {
    switch (type) {
      case 'National ID Card':
        return IdDocumentType.nationalId;
      case 'Driving License':
        return IdDocumentType.drivingLicense;
      default:
        return IdDocumentType.passport;
    }
  }

  bool get requiresBothSides => true; // All documents can have front and back
}
