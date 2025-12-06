/// Preferências de Notificações do Usuário
class NotificationPreferences {
  // Resumo do Portfólio
  final bool portfolioSummaryEnabled;
  final String portfolioFrequency; // 'daily' ou 'weekly'
  final String portfolioTime; // 'morning', 'afternoon', 'evening'
  
  // Variação de Preço
  final bool priceVariationEnabled;
  final double priceThreshold; // 3.0, 5.0, 10.0
  final bool onlyPortfolio;
  
  const NotificationPreferences({
    this.portfolioSummaryEnabled = false,
    this.portfolioFrequency = 'daily',
    this.portfolioTime = 'morning',
    this.priceVariationEnabled = false,
    this.priceThreshold = 5.0,
    this.onlyPortfolio = true,
  });

  /// Cria a partir de um Map (Firestore)
  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      portfolioSummaryEnabled: map['portfolioSummaryEnabled'] as bool? ?? false,
      portfolioFrequency: map['portfolioFrequency'] as String? ?? 'daily',
      portfolioTime: map['portfolioTime'] as String? ?? 'morning',
      priceVariationEnabled: map['priceVariationEnabled'] as bool? ?? false,
      priceThreshold: (map['priceThreshold'] as num?)?.toDouble() ?? 5.0,
      onlyPortfolio: map['onlyPortfolio'] as bool? ?? true,
    );
  }

  /// Converte para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'portfolioSummaryEnabled': portfolioSummaryEnabled,
      'portfolioFrequency': portfolioFrequency,
      'portfolioTime': portfolioTime,
      'priceVariationEnabled': priceVariationEnabled,
      'priceThreshold': priceThreshold,
      'onlyPortfolio': onlyPortfolio,
    };
  }

  /// Cria cópia com alterações
  NotificationPreferences copyWith({
    bool? portfolioSummaryEnabled,
    String? portfolioFrequency,
    String? portfolioTime,
    bool? priceVariationEnabled,
    double? priceThreshold,
    bool? onlyPortfolio,
  }) {
    return NotificationPreferences(
      portfolioSummaryEnabled: portfolioSummaryEnabled ?? this.portfolioSummaryEnabled,
      portfolioFrequency: portfolioFrequency ?? this.portfolioFrequency,
      portfolioTime: portfolioTime ?? this.portfolioTime,
      priceVariationEnabled: priceVariationEnabled ?? this.priceVariationEnabled,
      priceThreshold: priceThreshold ?? this.priceThreshold,
      onlyPortfolio: onlyPortfolio ?? this.onlyPortfolio,
    );
  }

  /// Converte horário para Time
  int getHourForTime() {
    switch (portfolioTime) {
      case 'morning':
        return 9; // 9h
      case 'afternoon':
        return 14; // 14h
      case 'evening':
        return 20; // 20h
      default:
        return 9;
    }
  }
}
