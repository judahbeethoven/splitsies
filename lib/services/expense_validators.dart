/// Input sanitisation for the add-expense form.
///
/// Every method returns `null` when the value is acceptable and an error
/// string otherwise — the exact shape Flutter's `TextFormField.validator`
/// wants, and easy to surface manually for the non-text fields.
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
    if (n <= 0) return 'Amount must be greater than zero';
    if (_decimalPlaces(raw) > 2) return 'Use at most two decimal places';
    if (n > 10000000) return 'That seems too large';
    return null;
  }

  static String? participants(List<String> people) {
    final cleaned = people.map((p) => p.trim()).toList();
    if (cleaned.any((p) => p.isEmpty)) return 'Names can’t be blank';
    if (cleaned.length < 2) {
      return 'Add at least two people to split between';
    }
    final lowered = cleaned.map((p) => p.toLowerCase()).toList();
    if (lowered.toSet().length != lowered.length) {
      return 'Two people have the same name';
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

  /// Loose sanity check for a UPI VPA, e.g. "name@bank" — good enough to
  /// catch empty/garbled input before it gets baked into a QR code.
  static String? upiId(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Add your UPI ID so people can pay you';
    if (!RegExp(r'^[\w.+-]{2,}@[\w.-]{2,}$').hasMatch(raw)) {
      return 'That doesn\'t look like a valid UPI ID';
    }
    return null;
  }

  /// First error across the whole form, or `null` if everything checks out.
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
