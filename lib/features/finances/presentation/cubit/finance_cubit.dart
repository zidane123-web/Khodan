import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/contact.dart';
import '../../../../data/models/finance_flow.dart';
import '../../../../data/models/financial_transaction.dart';
import '../../../../data/models/transaction_category.dart';
import '../../../../data/repositories/finance_repository.dart';
import '../../services/finance_exporter.dart';
import 'finance_state.dart';

class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit({
    required FinanceRepository repository,
    FinanceExporter? exporter,
  }) : _repository = repository,
       _exporter = exporter ?? createFinanceExporter(),
       super(const FinanceState());

  final FinanceRepository _repository;
  final FinanceExporter _exporter;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat _timestampFormatter = DateFormat('yyyyMMdd-HHmm');

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final List<dynamic> results =
          await Future.wait<dynamic>(<Future<dynamic>>[
            _repository.fetchCategories(),
            _repository.fetchContacts(),
            _repository.fetchTransactions(),
          ]);
      final List<TransactionCategory> categories =
          (results[0] as List<TransactionCategory>).sorted(
            (TransactionCategory a, TransactionCategory b) =>
                a.label.toLowerCase().compareTo(b.label.toLowerCase()),
          );
      final List<Contact> contacts = (results[1] as List<Contact>).sorted(
        (Contact a, Contact b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );
      final List<FinancialTransaction> transactions =
          results[2] as List<FinancialTransaction>;
      final List<FinancialTransaction> filtered = _applyFilters(
        transactions: transactions,
      );
      emit(
        state.copyWith(
          isLoading: false,
          categories: categories,
          contacts: contacts,
          transactions: transactions,
          filteredTransactions: filtered,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  void refreshFilters({
    DateTimeRange? dateRange,
    bool resetDateRange = false,
    String? categoryId,
    bool resetCategory = false,
    String? contactId,
    bool resetContact = false,
    FinanceFlow? flow,
    bool resetFlow = false,
    String? searchQuery,
  }) {
    final FinanceState updated = state.copyWith(
      dateRange: dateRange,
      clearDateRange: resetDateRange,
      categoryId: categoryId,
      clearCategory: resetCategory,
      contactId: contactId,
      clearContact: resetContact,
      flow: flow,
      clearFlow: resetFlow,
      searchQuery: searchQuery ?? state.searchQuery,
    );
    emit(
      updated.copyWith(
        filteredTransactions: _applyFilters(
          transactions: updated.transactions,
          dateRange: updated.dateRange,
          categoryId: updated.categoryId,
          contactId: updated.contactId,
          flow: updated.flow,
          searchQuery: updated.searchQuery,
        ),
      ),
    );
  }

  void updateSearch(String query) {
    refreshFilters(searchQuery: query);
  }

  void clearFilters() {
    refreshFilters(
      resetDateRange: true,
      resetCategory: true,
      resetContact: true,
      resetFlow: true,
      searchQuery: '',
    );
  }

  Future<FinancialTransaction?> saveTransaction(TransactionDraft draft) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final FinancialTransaction? existing = draft.id == null
          ? null
          : state.transactions.firstWhereOrNull(
              (FinancialTransaction tx) => tx.id == draft.id,
            );
      String? attachmentUrl = existing?.attachmentUrl;
      String? attachmentName = existing?.attachmentName;
      if (draft.attachment != null) {
        attachmentUrl = await _repository.uploadReceipt(
          profileId: existing?.profileId ?? draft.profileId ?? 'profile',
          fileName: draft.attachment!.fileName,
          bytes: draft.attachment!.bytes,
          contentType: draft.attachment!.contentType,
        );
        attachmentName = draft.attachment!.fileName;
      } else if (draft.removeExistingAttachment) {
        attachmentUrl = null;
        attachmentName = null;
      }

      final FinancialTransaction payload =
          (existing ??
                  FinancialTransaction(
                    id: '',
                    profileId: draft.profileId ?? '',
                    title: draft.title,
                    flow: draft.flow,
                    amount: draft.amount,
                    currency: draft.currency,
                    occuredOn: draft.occuredOn,
                    categoryId: draft.categoryId,
                    contactId: draft.contactId,
                    paymentMethod: draft.paymentMethod,
                    notes: draft.notes,
                    attachmentUrl: attachmentUrl,
                    attachmentName: attachmentName,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ))
              .copyWith(
                title: draft.title,
                flow: draft.flow,
                amount: draft.amount,
                currency: draft.currency,
                occuredOn: draft.occuredOn,
                categoryId: draft.categoryId,
                contactId: draft.contactId,
                paymentMethod: draft.paymentMethod,
                notes: draft.notes,
                attachmentUrl: attachmentUrl,
                attachmentName: attachmentName,
              );

      final FinancialTransaction saved = existing == null
          ? await _repository.createTransaction(payload)
          : await _repository.updateTransaction(payload);
      final List<FinancialTransaction> transactions = _upsertTransaction(
        state.transactions,
        saved,
      );
      final List<FinancialTransaction> filtered = _applyFilters(
        transactions: transactions,
        dateRange: state.dateRange,
        categoryId: state.categoryId,
        contactId: state.contactId,
        flow: state.flow,
        searchQuery: state.searchQuery,
      );
      emit(
        state.copyWith(
          isSaving: false,
          transactions: transactions,
          filteredTransactions: filtered,
        ),
      );
      return saved;
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.deleteTransaction(id);
      final List<FinancialTransaction> remaining = state.transactions
          .where((FinancialTransaction tx) => tx.id != id)
          .toList(growable: false);
      final List<FinancialTransaction> filtered = _applyFilters(
        transactions: remaining,
        dateRange: state.dateRange,
        categoryId: state.categoryId,
        contactId: state.contactId,
        flow: state.flow,
        searchQuery: state.searchQuery,
      );
      emit(
        state.copyWith(
          isSaving: false,
          transactions: remaining,
          filteredTransactions: filtered,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      rethrow;
    }
  }

  Future<Contact?> saveContact(ContactDraft draft) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final Contact payload = Contact(
        id: draft.id ?? '',
        profileId: draft.profileId ?? '',
        displayName: draft.displayName,
        type: draft.type,
        email: draft.email,
        phone: draft.phone,
        address: draft.address,
        notes: draft.notes,
        createdAt: draft.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final Contact saved = draft.id == null
          ? await _repository.createContact(payload)
          : await _repository.updateContact(payload);
      final List<Contact> contacts = _upsertContact(state.contacts, saved);
      final List<FinancialTransaction> transactions =
          _mapTransactionsForContact(state.transactions, saved);
      emit(
        state.copyWith(
          isSaving: false,
          contacts: contacts,
          transactions: transactions,
          filteredTransactions: _applyFilters(
            transactions: transactions,
            dateRange: state.dateRange,
            categoryId: state.categoryId,
            contactId: state.contactId,
            flow: state.flow,
            searchQuery: state.searchQuery,
          ),
        ),
      );
      return saved;
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      rethrow;
    }
  }

  Future<void> deleteContact(String id) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.deleteContact(id);
      final List<Contact> contacts = state.contacts
          .where((Contact c) => c.id != id)
          .toList(growable: false);
      final List<FinancialTransaction> transactions = state.transactions
          .map(
            (FinancialTransaction tx) => tx.contactId == id
                ? tx.copyWith(contactId: null, contact: null)
                : tx,
          )
          .toList(growable: false);
      emit(
        state.copyWith(
          isSaving: false,
          contacts: contacts,
          transactions: transactions,
          filteredTransactions: _applyFilters(
            transactions: transactions,
            dateRange: state.dateRange,
            categoryId: state.categoryId,
            contactId: state.contactId,
            flow: state.flow,
            searchQuery: state.searchQuery,
          ),
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      rethrow;
    }
  }

  Future<String?> openReceipt(FinancialTransaction transaction) {
    return _repository.getSignedReceiptUrl(transaction.attachmentUrl);
  }

  Future<String?> exportCsv() async {
    emit(state.copyWith(isExporting: true, clearError: true));
    try {
      final List<List<dynamic>> rows = <List<dynamic>>[
        <String>[
          'transaction_id',
          'occured_on',
          'title',
          'flow',
          'amount',
          'currency',
          'category_code',
          'category_label',
          'contact_name',
          'payment_method',
          'notes',
        ],
        ...state.filteredTransactions.map(
          (FinancialTransaction tx) => <dynamic>[
            tx.id,
            _dateFormatter.format(tx.occuredOn),
            tx.title,
            tx.flow.key,
            tx.amount,
            tx.currency,
            tx.category?.code ?? '',
            tx.category?.label ?? '',
            tx.contact?.displayName ?? '',
            tx.paymentMethod ?? '',
            tx.notes ?? '',
          ],
        ),
      ];
      final String csv = const ListToCsvConverter().convert(rows);
      final String profileId = state.transactions.isNotEmpty
          ? state.transactions.first.profileId
          : 'profile';
      final String filename =
          'ledger_${profileId}_${_timestampFormatter.format(DateTime.now())}.csv';
      await _exporter.save(filename, csv);
      emit(state.copyWith(isExporting: false));
      return filename;
    } catch (error) {
      emit(state.copyWith(isExporting: false, errorMessage: error.toString()));
      return null;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  List<FinancialTransaction> _applyFilters({
    required List<FinancialTransaction> transactions,
    DateTimeRange? dateRange,
    String? categoryId,
    String? contactId,
    FinanceFlow? flow,
    String? searchQuery,
  }) {
    final String query = (searchQuery ?? state.searchQuery)
        .trim()
        .toLowerCase();
    return transactions
        .where((FinancialTransaction tx) {
          if (dateRange != null) {
            final DateTime date = tx.occuredOn;
            if (date.isBefore(dateRange.start) || date.isAfter(dateRange.end)) {
              return false;
            }
          }
          if (categoryId != null && categoryId.isNotEmpty) {
            if (tx.categoryId != categoryId) return false;
          }
          if (contactId != null && contactId.isNotEmpty) {
            if (tx.contactId != contactId) return false;
          }
          if (flow != null) {
            if (tx.flow != flow) return false;
          }
          if (query.isNotEmpty) {
            final String haystack = <String?>[
              tx.title,
              tx.notes,
              tx.contact?.displayName,
            ].whereType<String>().join(' ').toLowerCase();
            if (!haystack.contains(query)) {
              return false;
            }
          }
          return true;
        })
        .sorted((FinancialTransaction a, FinancialTransaction b) {
          final int dateCompare = b.occuredOn.compareTo(a.occuredOn);
          if (dateCompare != 0) return dateCompare;
          final DateTime bUpdated = b.updatedAt ?? b.createdAt ?? b.occuredOn;
          final DateTime aUpdated = a.updatedAt ?? a.createdAt ?? a.occuredOn;
          return bUpdated.compareTo(aUpdated);
        })
        .toList(growable: false);
  }

  List<FinancialTransaction> _upsertTransaction(
    List<FinancialTransaction> source,
    FinancialTransaction transaction,
  ) {
    final List<FinancialTransaction> copy = List<FinancialTransaction>.from(
      source,
      growable: true,
    );
    final int index = copy.indexWhere(
      (FinancialTransaction tx) => tx.id == transaction.id,
    );
    if (index >= 0) {
      copy[index] = transaction;
    } else {
      copy.add(transaction);
    }
    copy.sort(
      (FinancialTransaction a, FinancialTransaction b) =>
          b.occuredOn.compareTo(a.occuredOn),
    );
    return copy;
  }

  List<Contact> _upsertContact(List<Contact> source, Contact contact) {
    final List<Contact> copy = List<Contact>.from(source, growable: true);
    final int index = copy.indexWhere((Contact item) => item.id == contact.id);
    if (index >= 0) {
      copy[index] = contact;
    } else {
      copy.add(contact);
    }
    copy.sort(
      (Contact a, Contact b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    return copy;
  }

  List<FinancialTransaction> _mapTransactionsForContact(
    List<FinancialTransaction> transactions,
    Contact contact,
  ) {
    return transactions
        .map(
          (FinancialTransaction tx) =>
              tx.contactId == contact.id ? tx.copyWith(contact: contact) : tx,
        )
        .toList(growable: false);
  }
}

class TransactionDraft {
  const TransactionDraft({
    this.id,
    this.profileId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.occuredOn,
    this.categoryId,
    this.contactId,
    this.flow = FinanceFlow.expense,
    this.paymentMethod,
    this.notes,
    this.attachment,
    this.removeExistingAttachment = false,
  });

  final String? id;
  final String? profileId;
  final String title;
  final double amount;
  final String currency;
  final DateTime occuredOn;
  final String? categoryId;
  final String? contactId;
  final FinanceFlow flow;
  final String? paymentMethod;
  final String? notes;
  final TransactionAttachmentDraft? attachment;
  final bool removeExistingAttachment;
}

class TransactionAttachmentDraft {
  const TransactionAttachmentDraft({
    required this.fileName,
    required this.bytes,
    required this.contentType,
  });

  final String fileName;
  final Uint8List bytes;
  final String contentType;
}

class ContactDraft {
  const ContactDraft({
    this.id,
    this.profileId,
    required this.displayName,
    required this.type,
    this.email,
    this.phone,
    this.address,
    this.notes,
    this.createdAt,
  });

  final String? id;
  final String? profileId;
  final String displayName;
  final ContactType type;
  final String? email;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime? createdAt;
}
