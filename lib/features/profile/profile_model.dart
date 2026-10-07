/// Profil de l'agent (Dart pur). L'identifiant affiche est derive du compte et n'est jamais modifiable.
class AgentProfile {
  const AgentProfile({
    this.fullName = '',
    this.phone = '',
    this.region = '',
    this.healthPost = '',
    this.role = '',
    this.email = '',
    this.consentAt,
  });

  final String fullName;
  final String phone;
  final String region;
  final String healthPost;
  final String role;
  final String email;
  final String?
      consentAt; // date d'acceptation de l'engagement de confidentialite (ISO)

  static const roles = <String>[
    'Agent de santé communautaire',
    'Infirmier(ère)',
    'Sage-femme',
    'Médecin',
    'Autre',
  ];

  int get filled => [fullName, phone, region, healthPost, role]
      .where((e) => e.trim().isNotEmpty)
      .length;
  double get completion => filled / 5;
  bool get isComplete => filled == 5;

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'phone': phone,
        'region': region,
        'healthPost': healthPost,
        'role': role,
        'email': email,
        'confidentialityAcceptedAt': consentAt,
      };

  static AgentProfile fromMap(Map<String, dynamic> m) => AgentProfile(
        fullName: '${m['fullName'] ?? ''}',
        phone: '${m['phone'] ?? ''}',
        region: '${m['region'] ?? ''}',
        healthPost: '${m['healthPost'] ?? ''}',
        role: '${m['role'] ?? ''}',
        email: '${m['email'] ?? ''}',
        consentAt: m['confidentialityAcceptedAt'] is String
            ? m['confidentialityAcceptedAt'] as String
            : null,
      );
}

/// Identifiant agent affiche : AGT- + 6 premiers caracteres du compte (le uid reste la vraie cle).
String agentCode(String uid) {
  final clean = uid.replaceAll('-', '').toUpperCase();
  return 'AGT-${clean.length > 6 ? clean.substring(0, 6) : clean}';
}
