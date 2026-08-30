enum ExpenseCategory { travel, food, outing, supplies, subscription, other }

enum SettleStatus { none, partial, all }

class Expense {
  final String id;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final List<String> participants;
  final String payer;
  final DateTime createdAt;

  final Map<String, bool> paidStatus;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.participants,
    required this.payer,
    required this.createdAt,
    Map<String, bool>? paidStatus,
  }) : paidStatus = paidStatus ?? _defaultPaidStatus(participants, payer),
       assert(participants.isNotEmpty, 'an expense needs participants'),
       assert(participants.contains(payer), 'payer must be a participant');

  static Map<String, bool> _defaultPaidStatus(
    List<String> participants,
    String payer,
  ) => {for (final p in participants) p: p == payer};

  double get nominalShare => amount / participants.length;

  List<String> get owers =>
      participants.where((p) => p != payer).toList(growable: false);

  bool isPaidBy(String person) => paidStatus[person] ?? (person == payer);

  int get paidOwerCount => owers.where(isPaidBy).length;

  bool get allSettled => owers.every(isPaidBy);

  bool get nonePaid => owers.every((p) => !isPaidBy(p));

  SettleStatus get settleStatus {
    if (owers.isEmpty || allSettled) return SettleStatus.all;
    if (nonePaid) return SettleStatus.none;
    return SettleStatus.partial;
  }

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    ExpenseCategory? category,
    List<String>? participants,
    String? payer,
    DateTime? createdAt,
    Map<String, bool>? paidStatus,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      participants: participants ?? this.participants,
      payer: payer ?? this.payer,
      createdAt: createdAt ?? this.createdAt,
      paidStatus: paidStatus ?? this.paidStatus,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'category': category.name,
    'participants': participants,
    'payer': payer,
    'createdAt': createdAt.toIso8601String(),
    'paidStatus': paidStatus,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    final rawPaidStatus = json['paidStatus'] as Map<String, dynamic>?;
    return Expense(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.byName(json['category'] as String),
      participants: (json['participants'] as List<dynamic>).cast<String>(),
      payer: json['payer'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidStatus: rawPaidStatus?.map((k, v) => MapEntry(k, v as bool)),
    );
  }

  @override
  bool operator ==(Object other) => other is Expense && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
