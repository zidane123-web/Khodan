import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/contact.dart';
import '../models/finance_flow.dart';
import '../models/financial_transaction.dart';
import '../models/transaction_category.dart';
import '../services/api_client.dart';

abstract class FinanceRepository {
  Future<List<TransactionCategory>> fetchCategories({
    bool includeInactive = false,
  });

  Future<List<Contact>> fetchContacts();

  Future<Contact> createContact(Contact contact);

  Future<Contact> updateContact(Contact contact);

  Future<void> deleteContact(String id);

  Future<List<FinancialTransaction>> fetchTransactions();

  Future<FinancialTransaction> createTransaction(
    FinancialTransaction transaction,
  );

  Future<FinancialTransaction> updateTransaction(
    FinancialTransaction transaction,
  );

  Future<void> deleteTransaction(String id);

  Future<String> uploadReceipt({
    required String profileId,
    required String fileName,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  });

  Future<String?> getSignedReceiptUrl(String? storagePath);
}

class SupabaseFinanceRepository implements FinanceRepository {
  SupabaseFinanceRepository({ApiExecutor? apiClient})
    : _api = apiClient ?? ApiClient(),
      _uuid = const Uuid();

  final ApiExecutor _api;
  final Uuid _uuid;
  static const String _bucket = 'receipts';

  SupabaseClient get _client => _api.client;

  @override
  Future<List<TransactionCategory>> fetchCategories({
    bool includeInactive = false,
  }) async {
    final List<dynamic> rows = await _api.run((SupabaseClient client) {
      final PostgrestFilterBuilder<PostgrestList> query = client
          .from('transaction_categories')
          .select(
            'id, profile_id, code, label, default_flow, '
            'is_active, is_custom, created_at, updated_at',
          );
      if (!includeInactive) {
        query.eq('is_active', true);
      }
      query.order('label');
      return query;
    }, label: 'finance.fetchCategories');
    return rows
        .map(
          (dynamic row) =>
              TransactionCategory.fromJson(row as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<List<Contact>> fetchContacts() async {
    final List<dynamic> rows = await _api.run(
      (SupabaseClient client) => client
          .from('contacts')
          .select()
          .order('display_name', ascending: true),
      label: 'finance.fetchContacts',
    );
    return rows
        .map((dynamic row) => Contact.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Contact> createContact(Contact contact) async {
    final Contact payload =
        (contact.id.isEmpty ? contact : contact.copyWith(id: '')).copyWith(
          profileId: _requireProfileId(),
        );
    final Map<String, dynamic> row =
        await _api.run(
              (SupabaseClient client) => client
                  .from('contacts')
                  .insert(payload.toInsertPayload())
                  .select()
                  .single(),
              label: 'finance.createContact',
            );
    return Contact.fromJson(row);
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    final Contact payload = contact.profileId.isEmpty
        ? contact.copyWith(profileId: _requireProfileId())
        : contact;
    final Map<String, dynamic> row =
        await _api.run(
              (SupabaseClient client) => client
                  .from('contacts')
                  .update(payload.toUpdatePayload())
                  .eq('id', payload.id)
                  .select()
                  .single(),
              label: 'finance.updateContact',
            );
    return Contact.fromJson(row);
  }

  @override
  Future<void> deleteContact(String id) async {
    await _api.run(
      (SupabaseClient client) => client.from('contacts').delete().eq('id', id),
      label: 'finance.deleteContact',
    );
  }

  @override
  Future<List<FinancialTransaction>> fetchTransactions() async {
    final List<dynamic> rows = await _api.run(
      (SupabaseClient client) => client
          .from('financial_transactions')
          .select('''
id,
profile_id,
category_id,
contact_id,
title,
flow,
amount,
currency,
occured_on,
payment_method,
notes,
attachment_url,
attachment_name,
created_at,
updated_at,
category:transaction_categories(
  id,
  profile_id,
  code,
  label,
  default_flow,
  is_active,
  is_custom,
  created_at,
  updated_at
),
contact:contacts(
  id,
  profile_id,
  display_name,
  type,
  email,
  phone,
  address,
  notes,
  created_at,
  updated_at
)
''')
          .order('occured_on', ascending: false)
          .order('created_at', ascending: false),
      label: 'finance.fetchTransactions',
    );
    return rows
        .map(
          (dynamic row) =>
              FinancialTransaction.fromJson(row as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<FinancialTransaction> createTransaction(
    FinancialTransaction transaction,
  ) async {
    final FinancialTransaction payload =
        (transaction.id.isEmpty ? transaction : transaction.copyWith(id: ''))
            .copyWith(profileId: _requireProfileId());
    final Map<String, dynamic> row =
        await _api.run(
              (SupabaseClient client) => client
                  .from('financial_transactions')
                  .insert(payload.toInsertPayload())
                  .select('''
*,
category:transaction_categories(*),
contact:contacts(*)
''')
                  .single(),
              label: 'finance.createTransaction',
            );
    return FinancialTransaction.fromJson(row);
  }

  @override
  Future<FinancialTransaction> updateTransaction(
    FinancialTransaction transaction,
  ) async {
    final FinancialTransaction payload = transaction.profileId.isEmpty
        ? transaction.copyWith(profileId: _requireProfileId())
        : transaction;
    final Map<String, dynamic> row =
        await _api.run(
              (SupabaseClient client) => client
                  .from('financial_transactions')
                  .update(payload.toUpdatePayload())
                  .eq('id', payload.id)
                  .select('''
*,
category:transaction_categories(*),
contact:contacts(*)
''')
                  .single(),
              label: 'finance.updateTransaction',
            );
    return FinancialTransaction.fromJson(row);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _api.run(
      (SupabaseClient client) =>
          client.from('financial_transactions').delete().eq('id', id),
      label: 'finance.deleteTransaction',
    );
  }

  @override
  Future<String> uploadReceipt({
    required String profileId,
    required String fileName,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final String sanitized = fileName.replaceAll(
      RegExp(r'[^A-Za-z0-9\.\-_]'),
      '_',
    );
    final String path = '$profileId/${_uuid.v4()}-$sanitized'.replaceAll(
      '//',
      '/',
    );
    await _api.run(
      (SupabaseClient client) => client.storage
          .from(_bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          ),
      label: 'finance.uploadReceipt',
    );
    return path;
  }

  String _requireProfileId() {
    final String? profileId = _client.auth.currentUser?.id;
    if (profileId == null || profileId.isEmpty) {
      throw DataLayerException('Missing Supabase session for finance actions.');
    }
    return profileId;
  }

  @override
  Future<String?> getSignedReceiptUrl(String? storagePath) async {
    if (storagePath == null || storagePath.isEmpty) {
      return null;
    }
    return _api.run(
      (SupabaseClient client) =>
          client.storage.from(_bucket).createSignedUrl(storagePath, 60 * 15),
      label: 'finance.getReceiptUrl',
    );
  }
}

class InMemoryFinanceRepository implements FinanceRepository {
  InMemoryFinanceRepository({String profileId = 'local-profile'})
    : _profileId = profileId {
    _seedDefaultCategories();
  }

  final String _profileId;
  final Uuid _uuid = const Uuid();
  final List<TransactionCategory> _categories = <TransactionCategory>[];
  final List<Contact> _contacts = <Contact>[];
  final List<FinancialTransaction> _transactions = <FinancialTransaction>[];
  final Map<String, String> _attachments = <String, String>{};

  @override
  Future<List<TransactionCategory>> fetchCategories({
    bool includeInactive = false,
  }) async {
    final Iterable<TransactionCategory> items = includeInactive
        ? _categories
        : _categories.where((TransactionCategory cat) => cat.isActive);
    return List<TransactionCategory>.from(items);
  }

  @override
  Future<List<Contact>> fetchContacts() async {
    final List<Contact> sorted = List<Contact>.from(_contacts)
      ..sort(
        (Contact a, Contact b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );
    return sorted;
  }

  @override
  Future<Contact> createContact(Contact contact) async {
    final Contact created = contact.copyWith(
      id: _uuid.v4(),
      profileId: _profileId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _contacts.add(created);
    return created;
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    final int index = _contacts.indexWhere((Contact c) => c.id == contact.id);
    if (index == -1) {
      throw StateError('Contact not found: ${contact.id}');
    }
    final Contact updated = contact.copyWith(
      updatedAt: DateTime.now(),
      profileId: _profileId,
    );
    _contacts[index] = updated;
    _updateTransactionsWithContact(updated);
    return updated;
  }

  void _updateTransactionsWithContact(Contact contact) {
    for (int i = 0; i < _transactions.length; i += 1) {
      final FinancialTransaction tx = _transactions[i];
      if (tx.contactId == contact.id) {
        _transactions[i] = tx.copyWith(contact: contact);
      }
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    final bool hasTransaction = _transactions.any(
      (FinancialTransaction tx) => tx.contactId == id,
    );
    if (hasTransaction) {
      throw StateError('Contact $id is linked to existing transactions.');
    }
    _contacts.removeWhere((Contact contact) => contact.id == id);
  }

  @override
  Future<List<FinancialTransaction>> fetchTransactions() async {
    final List<FinancialTransaction> copy =
        List<FinancialTransaction>.from(_transactions)..sort(
          (FinancialTransaction a, FinancialTransaction b) =>
              b.occuredOn.compareTo(a.occuredOn),
        );
    return copy;
  }

  @override
  Future<FinancialTransaction> createTransaction(
    FinancialTransaction transaction,
  ) async {
    final TransactionCategory? category = _categories.firstWhereOrNull(
      (TransactionCategory cat) => cat.id == transaction.categoryId,
    );
    final Contact? contact = _contacts.firstWhereOrNull(
      (Contact c) => c.id == transaction.contactId,
    );
    final FinancialTransaction created = transaction.copyWith(
      id: _uuid.v4(),
      profileId: _profileId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      category: category,
      contact: contact,
    );
    _transactions.add(created);
    return created;
  }

  @override
  Future<FinancialTransaction> updateTransaction(
    FinancialTransaction transaction,
  ) async {
    final int index = _transactions.indexWhere(
      (FinancialTransaction tx) => tx.id == transaction.id,
    );
    if (index == -1) {
      throw StateError('Transaction not found: ${transaction.id}');
    }
    final TransactionCategory? category = _categories.firstWhereOrNull(
      (TransactionCategory cat) => cat.id == transaction.categoryId,
    );
    final Contact? contact = _contacts.firstWhereOrNull(
      (Contact c) => c.id == transaction.contactId,
    );
    final FinancialTransaction updated = transaction.copyWith(
      profileId: _profileId,
      updatedAt: DateTime.now(),
      category: category,
      contact: contact,
    );
    _transactions[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((FinancialTransaction tx) => tx.id == id);
  }

  @override
  Future<String> uploadReceipt({
    required String profileId,
    required String fileName,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final String key = 'memory-${_uuid.v4()}';
    final String dataUrl = 'data:$contentType;base64,${base64Encode(bytes)}';
    _attachments[key] = dataUrl;
    return key;
  }

  @override
  Future<String?> getSignedReceiptUrl(String? storagePath) async {
    if (storagePath == null) {
      return null;
    }
    return _attachments[storagePath];
  }

  void _seedDefaultCategories() {
    if (_categories.isNotEmpty) {
      return;
    }
    final DateTime now = DateTime.now();
    final List<Map<String, dynamic>> defaults = <Map<String, dynamic>>[
      <String, dynamic>{
        'code': 'feed',
        'label': 'Alimentation',
        'flow': FinanceFlow.expense,
      },
      <String, dynamic>{
        'code': 'health',
        'label': 'Soins',
        'flow': FinanceFlow.expense,
      },
      <String, dynamic>{
        'code': 'supplies',
        'label': 'Materiel',
        'flow': FinanceFlow.expense,
      },
      <String, dynamic>{
        'code': 'transport',
        'label': 'Transport',
        'flow': FinanceFlow.expense,
      },
      <String, dynamic>{
        'code': 'breeding',
        'label': 'Reproduction',
        'flow': FinanceFlow.expense,
      },
      <String, dynamic>{
        'code': 'housing',
        'label': 'Infrastructure',
        'flow': FinanceFlow.expense,
      },
      <String, dynamic>{
        'code': 'sales',
        'label': 'Ventes',
        'flow': FinanceFlow.income,
      },
      <String, dynamic>{
        'code': 'subsidy',
        'label': 'Subvention',
        'flow': FinanceFlow.income,
      },
      <String, dynamic>{
        'code': 'transfer',
        'label': 'Transfert interne',
        'flow': FinanceFlow.neutral,
      },
      <String, dynamic>{
        'code': 'other',
        'label': 'Autre',
        'flow': FinanceFlow.neutral,
      },
    ];

    for (final Map<String, dynamic> item in defaults) {
      _categories.add(
        TransactionCategory(
          id: _uuid.v4(),
          profileId: null,
          code: item['code'] as String,
          label: item['label'] as String,
          defaultFlow: item['flow'] as FinanceFlow,
          isActive: true,
          isCustom: false,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }
}
