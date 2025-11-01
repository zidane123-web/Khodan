import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/contact.dart';
import '../../../../data/models/finance_flow.dart';
import '../../../../data/models/financial_transaction.dart';
import '../../../../data/models/transaction_category.dart';

class FinanceState extends Equatable {
  const FinanceState({
    this.isLoading = false,
    this.isSaving = false,
    this.isExporting = false,
    this.transactions = const <FinancialTransaction>[],
    this.filteredTransactions = const <FinancialTransaction>[],
    this.contacts = const <Contact>[],
    this.categories = const <TransactionCategory>[],
    this.dateRange,
    this.categoryId,
    this.contactId,
    this.flow,
    this.searchQuery = '',
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSaving;
  final bool isExporting;
  final List<FinancialTransaction> transactions;
  final List<FinancialTransaction> filteredTransactions;
  final List<Contact> contacts;
  final List<TransactionCategory> categories;
  final DateTimeRange? dateRange;
  final String? categoryId;
  final String? contactId;
  final FinanceFlow? flow;
  final String searchQuery;
  final String? errorMessage;

  double get totalIncome => filteredTransactions
      .where((FinancialTransaction tx) => tx.flow.isIncome)
      .fold<double>(
        0,
        (double sum, FinancialTransaction tx) => sum + tx.amount,
      );

  double get totalExpense => filteredTransactions
      .where((FinancialTransaction tx) => tx.flow.isExpense)
      .fold<double>(
        0,
        (double sum, FinancialTransaction tx) => sum + tx.amount,
      );

  double get netBalance => totalIncome - totalExpense;

  FinanceState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isExporting,
    List<FinancialTransaction>? transactions,
    List<FinancialTransaction>? filteredTransactions,
    List<Contact>? contacts,
    List<TransactionCategory>? categories,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
    String? categoryId,
    bool clearCategory = false,
    String? contactId,
    bool clearContact = false,
    FinanceFlow? flow,
    bool clearFlow = false,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FinanceState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isExporting: isExporting ?? this.isExporting,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      contacts: contacts ?? this.contacts,
      categories: categories ?? this.categories,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      contactId: clearContact ? null : (contactId ?? this.contactId),
      flow: clearFlow ? null : (flow ?? this.flow),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    isSaving,
    isExporting,
    transactions,
    filteredTransactions,
    contacts,
    categories,
    dateRange,
    categoryId,
    contactId,
    flow,
    searchQuery,
    errorMessage,
  ];
}
