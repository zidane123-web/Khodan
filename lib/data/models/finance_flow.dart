enum FinanceFlow {
  income('income'),
  expense('expense'),
  neutral('neutral');

  const FinanceFlow(this.key);

  final String key;

  bool get isIncome => this == FinanceFlow.income;
  bool get isExpense => this == FinanceFlow.expense;
  bool get isNeutral => this == FinanceFlow.neutral;

  static FinanceFlow fromKey(String value) {
    return FinanceFlow.values.firstWhere(
      (FinanceFlow flow) => flow.key == value,
      orElse: () => FinanceFlow.expense,
    );
  }
}
