String generateGroupID(List<String> participants) {
  final normalized = participants.map((s) => s.trim().toUpperCase()).toList()
    ..sort();
  final joined = normalized.join('|');

  int hash = 5381;
  for (final codeUnit in joined.codeUnits) {
    hash = ((hash << 5) + hash + codeUnit) & 0xFFFFFFFF;
  }

  return hash.toRadixString(16).padLeft(8, '0').substring(0, 6).toUpperCase();
}

/// +net means they owe the group i.e. the group profits
/// -net means the group owes them i.e. the group loses money
class Balance {
  final String person;
  final String group;
  final double net;
  bool paid;

  Balance({
    required this.person,
    required this.group,
    required this.net,
    this.paid = false,
  });

  bool get isSettled => net.abs() < 0.01;
  bool get isOwed => net < 0.01;
  bool get owes => net > -0.01;
}

class Settlement {
  final String from;
  final String to;
  final double amount;

  const Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });
}
