/// Modelo de Perfil do Usuário
/// 
/// Armazena informações adicionais coletadas no onboarding
class UserProfile {
  final String userId;
  final String fullName;
  final String phone;
  final DateTime birthDate;
  final String state;
  final String occupation;
  final String accountId;
  final bool profileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.birthDate,
    required this.state,
    required this.occupation,
    required this.accountId,
    this.profileComplete = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria um UserProfile a partir de um Map (Firestore)
  factory UserProfile.fromMap(Map<String, dynamic> map, String userId) {
    return UserProfile(
      userId: userId,
      fullName: map['fullName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'] as String)
          : DateTime.now(),
      state: map['state'] as String? ?? '',
      occupation: map['occupation'] as String? ?? '',
      accountId: map['accountId'] as String? ?? '',
      profileComplete: map['profileComplete'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converte o UserProfile para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'birthDate': birthDate.toIso8601String(),
      'state': state,
      'occupation': occupation,
      'accountId': accountId,
      'profileComplete': profileComplete,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia com campos atualizados
  UserProfile copyWith({
    String? fullName,
    String? phone,
    DateTime? birthDate,
    String? state,
    String? occupation,
    String? accountId,
    bool? profileComplete,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      state: state ?? this.state,
      occupation: occupation ?? this.occupation,
      accountId: accountId ?? this.accountId,
      profileComplete: profileComplete ?? this.profileComplete,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
