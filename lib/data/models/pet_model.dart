import 'package:equatable/equatable.dart';

enum PetType { dog, cat, bird, fish, rabbit, hamster, other }

enum Gender { male, female, unknown }

enum SterilizationStatus { sterilized, notSterilized, unknown }

class PetModel extends Equatable {
  final String id;
  final String name;
  final String? profilePictureUrl;
  final PetType type;
  final String? breed;
  final String? origin;
  final DateTime? dateOfBirth;
  final Gender gender;
  final double? weight;
  final String? microchipNumber;
  final SterilizationStatus sterilizationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String appUserId;

  const PetModel({
    required this.id,
    required this.name,
    this.profilePictureUrl,
    required this.type,
    this.breed,
    this.origin,
    this.dateOfBirth,
    required this.gender,
    this.weight,
    this.microchipNumber,
    required this.sterilizationStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.appUserId,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      type: _parsePetType(json['type']),
      breed: json['breed'] as String?,
      origin: json['origin'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: _parseGender(json['gender']),
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      microchipNumber: json['microchipNumber'] as String?,
      sterilizationStatus: _parseSterilizationStatus(json['sterilizationStatus']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      appUserId: json['appUserId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'type': type.index,
      'breed': breed,
      'origin': origin,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender.index,
      'weight': weight,
      'microchipNumber': microchipNumber,
      'sterilizationStatus': sterilizationStatus.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'appUserId': appUserId,
    };
  }

  static PetType _parsePetType(dynamic value) {
    if (value is int) {
      return PetType.values[value.clamp(0, PetType.values.length - 1)];
    }
    if (value is String) {
      return PetType.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => PetType.other,
      );
    }
    return PetType.other;
  }

  static Gender _parseGender(dynamic value) {
    if (value is int) {
      return Gender.values[value.clamp(0, Gender.values.length - 1)];
    }
    if (value is String) {
      return Gender.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => Gender.unknown,
      );
    }
    return Gender.unknown;
  }

  static SterilizationStatus _parseSterilizationStatus(dynamic value) {
    if (value is int) {
      return SterilizationStatus.values[value.clamp(0, SterilizationStatus.values.length - 1)];
    }
    if (value is String) {
      return SterilizationStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
        orElse: () => SterilizationStatus.unknown,
      );
    }
    return SterilizationStatus.unknown;
  }

  String get typeDisplayName {
    switch (type) {
      case PetType.dog:
        return 'Dog';
      case PetType.cat:
        return 'Cat';
      case PetType.bird:
        return 'Bird';
      case PetType.fish:
        return 'Fish';
      case PetType.rabbit:
        return 'Rabbit';
      case PetType.hamster:
        return 'Hamster';
      case PetType.other:
        return 'Other';
    }
  }

  String get genderDisplayName {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.unknown:
        return 'Unknown';
    }
  }

  String get sterilizationDisplayName {
    switch (sterilizationStatus) {
      case SterilizationStatus.sterilized:
        return 'Sterilized';
      case SterilizationStatus.notSterilized:
        return 'Not Sterilized';
      case SterilizationStatus.unknown:
        return 'Unknown';
    }
  }

  String? get ageString {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    final difference = now.difference(dateOfBirth!);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;

    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''}${months > 0 ? ', $months month${months > 1 ? 's' : ''}' : ''}';
    } else if (months > 0) {
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''}';
    }
  }

  PetModel copyWith({
    String? id,
    String? name,
    String? profilePictureUrl,
    PetType? type,
    String? breed,
    String? origin,
    DateTime? dateOfBirth,
    Gender? gender,
    double? weight,
    String? microchipNumber,
    SterilizationStatus? sterilizationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? appUserId,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      origin: origin ?? this.origin,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      sterilizationStatus: sterilizationStatus ?? this.sterilizationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      appUserId: appUserId ?? this.appUserId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        profilePictureUrl,
        type,
        breed,
        origin,
        dateOfBirth,
        gender,
        weight,
        microchipNumber,
        sterilizationStatus,
        createdAt,
        updatedAt,
        appUserId,
      ];
}
