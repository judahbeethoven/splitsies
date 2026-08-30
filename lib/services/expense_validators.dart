class ExpenseValidators {
  const ExpenseValidators._();

  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Add a short description';
    }
    if (value.trim().length > 80) {
      return 'Keep it under 80 characters';
    }
    return null;
  }

  static String? amount(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Enter an amount';

    final n = double.tryParse(raw);
    if (n == null || n.isNaN || n.isInfinite) return 'Enter a valid number';
    if (n <= 0) return 'ITS FREE???!';
    if (_decimalPlaces(raw) > 2) return '2 decimals is enough vro';
    if (n > 10000000) return 'Calm down Elon';
    return null;
  }

  static String? participants(List<String> people) {
    final cleaned = people.map((p) => p.trim()).toList();
    if (cleaned.any((p) => p.isEmpty)) return '"I have an imaginary friend"';
    if (cleaned.length < 2) {
      return 'Get some friends bro please';
    }
    final lowered = cleaned.map((p) => p.toLowerCase()).toList();
    if (lowered.toSet().length != lowered.length) {
      return 'Put in your nicknames please, two people have a name clash';
    }
    return null;
  }

  static String? payer(
    String? payer,
    List<String> participants, {
    String selfName = 'You',
  }) {
    if (payer == null || payer.trim().isEmpty) return 'Pick who paid';
    if (!participants.contains(payer)) {
      return 'Whoever paid has to be in the split';
    }
    if (payer != selfName) {
      return 'Only you can be marked as the payer';
    }
    return null;
  }

  static String? upiId(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Add your UPI ID so people can pay you';
    if (!RegExp(r'^[\w.+-]{2,}@[\w.-]{2,}$').hasMatch(raw)) {
      return 'That doesn\'t look like a valid UPI ID';
    }
    return null;
  }

  static String? firstError({
    required String? description,
    required String? amount,
    required List<String> participants,
    required String? payer,
  }) {
    return ExpenseValidators.description(description) ??
        ExpenseValidators.amount(amount) ??
        ExpenseValidators.participants(participants) ??
        ExpenseValidators.payer(payer, participants);
  }

  static int _decimalPlaces(String raw) {
    final dot = raw.indexOf('.');
    return dot == -1 ? 0 : raw.length - dot - 1;
  }
}
