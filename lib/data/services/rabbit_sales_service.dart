import 'dart:async';

import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/finance_flow.dart';
import '../models/financial_transaction.dart';
import '../models/marketplace_listing.dart';
import '../models/rabbit_sale.dart';
import '../models/rabbit_transfer.dart';
import '../models/transaction_category.dart';
import '../repositories/finance_repository.dart';
import 'api_client.dart';
import 'notification_hooks.dart';

class RabbitSalesService {
  RabbitSalesService({
    ApiExecutor? apiClient,
    required FinanceRepository financeRepository,
    List<NotificationHook>? notificationHooks,
    this.profileIdOverride,
  })  : _api = apiClient ?? ApiClient(),
        _financeRepository = financeRepository,
        _explicitHooks = notificationHooks;

  final ApiExecutor _api;
  final FinanceRepository _financeRepository;
  final List<NotificationHook>? _explicitHooks;
  final String? profileIdOverride;

  static const String _salesSelect = '''
    *,
    animal:animal_id(tag_id,name),
    contact:contact_id(display_name,phone,email)
  ''';
  static const String _transferSelect = '''
    *,
    contact:contact_id(display_name,phone,email),
    animal:animal_id(tag_id)
  ''';

  List<NotificationHook> get _hooks =>
      _explicitHooks ?? NotificationServiceRegistry.instance.hooks;

  SupabaseClient get _client => _api.client;

  Future<List<RabbitSale>> fetchSales({
    RabbitSaleStatus? status,
    DateTime? start,
    DateTime? end,
    bool includeArchived = false,
  }) async {
    final List<dynamic> rows = await _api.run((SupabaseClient client) {
      final PostgrestFilterBuilder<PostgrestList> query =
          client.from('rabbit_sales').select(_salesSelect);
      query.order('created_at', ascending: false);
      if (!includeArchived) {
        query.filter('archived_at', 'is', null);
      }
      if (status != null) {
        query.eq('status', status.key);
      }
      if (start != null) {
        query.gte('created_at', start.toIso8601String());
      }
      if (end != null) {
        query.lte('created_at', end.toIso8601String());
      }
      return query;
    }, label: 'sales.fetch');

    return rows
        .map((dynamic row) => RabbitSale.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<RabbitSale> createLocalSale(RabbitSaleDraft draft) async {
    final String profileId = _requireProfileId();
    final String categoryId = await _resolveCategoryId(code: 'sales');
    final FinancialTransaction ledger = FinancialTransaction(
      id: '',
      profileId: profileId,
      title: 'Vente lapin ${draft.animalId}',
      flow: FinanceFlow.income,
      amount: draft.price,
      currency: draft.currency,
      occuredOn: DateTime.now(),
      categoryId: categoryId,
      contactId: draft.contactId,
      paymentMethod: draft.paymentMethod,
      notes: draft.notes,
      attachmentUrl: draft.proofUrl,
      attachmentName: draft.proofName,
    );
    final FinancialTransaction recorded =
        await _financeRepository.createTransaction(ledger);

    final Map<String, dynamic> row =
        await _api.run((SupabaseClient client) async {
          return client
              .from('rabbit_sales')
              .insert(<String, dynamic>{
                'profile_id': profileId,
                'animal_id': draft.animalId,
                'contact_id': draft.contactId,
                'sale_type': draft.saleType.key,
                'status': RabbitSaleStatus.pending.key,
                'price': draft.price,
                'currency': draft.currency,
                'payment_method': draft.paymentMethod,
                'proof_url': draft.proofUrl,
                'proof_name': draft.proofName,
                'expected_close_date': draft.expectedCloseDate?.toIso8601String(),
                'notes': draft.notes,
                'financial_transaction_id': recorded.id,
              })
              .select(_salesSelect)
              .single();
        }, label: 'sales.create');

    final RabbitSale sale = RabbitSale.fromJson(row);
    await _dispatchNotification(
      id: 'sale:${sale.id}',
      event: 'sale.created',
      profileId: sale.profileId,
      title: 'Nouvelle vente',
      body: 'Lapin ${sale.animalTag ?? sale.animalId} - ${sale.price} ${sale.currency}',
      email: sale.contactEmail,
      phone: sale.contactPhone,
    );
    return sale;
  }

  Future<RabbitSale> completeSale(String saleId) async {
    final Map<String, dynamic> row =
        await _api.run((SupabaseClient client) async {
          return client
              .from('rabbit_sales')
              .update(<String, dynamic>{
                'status': RabbitSaleStatus.completed.key,
                'closed_at': DateTime.now().toIso8601String(),
              })
              .eq('id', saleId)
              .select(_salesSelect)
              .single();
        }, label: 'sales.complete');
    final RabbitSale sale = RabbitSale.fromJson(row);
    await _archiveAnimal(sale.animalId, archive: true);
    await _dispatchNotification(
      id: 'sale:${sale.id}',
      event: 'sale.completed',
      profileId: sale.profileId,
      title: 'Vente confirmée',
      body: 'Paiement validé pour ${sale.animalTag ?? sale.animalId}.',
      email: sale.contactEmail,
      phone: sale.contactPhone,
    );
    return sale;
  }

  Future<RabbitSale> cancelSale(String saleId) async {
    final RabbitSale before = await _fetchSale(saleId);
    if (before.financialTransactionId != null) {
      await _financeRepository.deleteTransaction(before.financialTransactionId!);
    }
    final Map<String, dynamic> row =
        await _api.run((SupabaseClient client) async {
          return client
              .from('rabbit_sales')
              .update(<String, dynamic>{
                'status': RabbitSaleStatus.cancelled.key,
                'closed_at': DateTime.now().toIso8601String(),
              })
              .eq('id', saleId)
              .select(_salesSelect)
              .single();
        }, label: 'sales.cancel');
    await _archiveAnimal(before.animalId, archive: false);
    return RabbitSale.fromJson(row);
  }

  Future<List<RabbitTransfer>> fetchTransfers({
    bool includeArchived = false,
    RabbitTransferStatus? status,
  }) async {
    final List<dynamic> rows = await _api.run((SupabaseClient client) {
      final PostgrestFilterBuilder<PostgrestList> query =
          client.from('rabbit_transfers').select(_transferSelect);
      query.order('created_at', ascending: false);
      if (!includeArchived) {
        query.filter('archived_at', 'is', null);
      }
      if (status != null) {
        query.eq('status', status.key);
      }
      final String profileId = _requireProfileId();
      query.or(
        'profile_id.eq.$profileId,recipient_profile_id.eq.$profileId',
      );
      return query;
    }, label: 'sales.transfers.fetch');

    return rows
        .map(
          (dynamic row) => RabbitTransfer.fromJson(row as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<RabbitTransfer> initiateTransfer(RabbitTransferRequest request) async {
    final String profileId = _requireProfileId();
    String? transactionId;
    if (request.transferFee > 0) {
      final String categoryId = await _resolveCategoryId(code: 'transfer');
      final FinancialTransaction fee = FinancialTransaction(
        id: '',
        profileId: profileId,
        title: 'Transfert lapin ${request.animalId}',
        flow: FinanceFlow.neutral,
        amount: request.transferFee,
        currency: 'XOF',
        occuredOn: DateTime.now(),
        categoryId: categoryId,
        contactId: request.contactId,
        notes: request.notes,
      );
      final FinancialTransaction recorded =
          await _financeRepository.createTransaction(fee);
      transactionId = recorded.id;
    }

    final DateTime expires =
        request.expiresAt ?? DateTime.now().add(const Duration(days: 2));
    final Map<String, dynamic> row =
        await _api.run((SupabaseClient client) async {
          return client
              .from('rabbit_transfers')
              .insert(<String, dynamic>{
                'profile_id': profileId,
                'recipient_profile_id': request.recipientProfileId,
                'animal_id': request.animalId,
                'contact_id': request.contactId,
                'status': RabbitTransferStatus.pending.key,
                'transfer_fee': request.transferFee,
                'expires_at': expires.toIso8601String(),
                'notes': request.notes,
                'financial_transaction_id': transactionId,
              })
              .select(_transferSelect)
              .single();
        }, label: 'sales.transfers.create');

    final RabbitTransfer transfer = RabbitTransfer.fromJson(row);
    await _dispatchNotification(
      id: 'transfer:${transfer.id}',
      event: 'transfer.pending',
      profileId: profileId,
      title: 'Transfert en attente',
      body:
          'Lapin ${transfer.animalTag ?? transfer.animalId} vers ${transfer.recipientProfileId}.',
      email: transfer.contactEmail,
      phone: transfer.contactPhone,
      extra: <String, dynamic>{
        'recipient_profile_id': transfer.recipientProfileId,
      },
    );
    return transfer;
  }

  Future<RabbitTransfer> acceptTransfer(String transferId) async {
    final Map<String, dynamic> row =
        await _api.run((SupabaseClient client) async {
          return client
              .from('rabbit_transfers')
              .update(<String, dynamic>{
                'status': RabbitTransferStatus.completed.key,
                'processed_at': DateTime.now().toIso8601String(),
              })
              .eq('id', transferId)
              .select(_transferSelect)
              .single();
        }, label: 'sales.transfers.complete');
    final RabbitTransfer transfer = RabbitTransfer.fromJson(row);
    await _archiveAnimal(transfer.animalId, archive: true);
    return transfer;
  }

  Future<RabbitTransfer> rejectTransfer(String transferId) async {
    final Map<String, dynamic> row =
        await _api.run((SupabaseClient client) async {
          return client
              .from('rabbit_transfers')
              .update(<String, dynamic>{
                'status': RabbitTransferStatus.rejected.key,
                'processed_at': DateTime.now().toIso8601String(),
              })
              .eq('id', transferId)
              .select(_transferSelect)
              .single();
        }, label: 'sales.transfers.reject');
    final RabbitTransfer transfer = RabbitTransfer.fromJson(row);
    await _archiveAnimal(transfer.animalId, archive: false);
    return transfer;
  }

  Future<MarketplaceListing> publishListing(MarketplaceListingDraft draft) async {
    final String profileId = _requireProfileId();
    final Map<String, dynamic> row =
        await _api.run((SupabaseClient client) async {
          return client
              .from('marketplace_listings')
              .insert(<String, dynamic>{
                'profile_id': profileId,
                'animal_id': draft.animalId,
                'contact_id': draft.contactId,
                'title': draft.title,
                'description': draft.description,
                'price': draft.price,
                'currency': draft.currency,
                'is_negotiable': draft.isNegotiable,
                'media_urls': draft.mediaUrls,
                'tags': draft.tags,
                'status': MarketplaceListingStatus.published.key,
                'visibility': draft.visibility,
                'published_at': DateTime.now().toIso8601String(),
                'expires_at': draft.expiresAt?.toIso8601String(),
                'fee_transaction_id': draft.feeTransactionId,
              })
              .select()
              .single();
        }, label: 'sales.marketplace.publish');
    return MarketplaceListing.fromJson(row);
  }

  Future<MarketplaceListing> updateListingStatus(
    String listingId,
    MarketplaceListingStatus status,
  ) async {
    final Map<String, dynamic> row =
        await _api.run((SupabaseClient client) async {
          return client
              .from('marketplace_listings')
              .update(<String, dynamic>{
                'status': status.key,
              })
              .eq('id', listingId)
              .select()
              .single();
        }, label: 'sales.marketplace.update');
    return MarketplaceListing.fromJson(row);
  }

  Future<List<MarketplaceListing>> fetchListings({
    MarketplaceListingStatus? status,
    bool includeArchived = false,
  }) async {
    final List<dynamic> rows = await _api.run((SupabaseClient client) {
      final PostgrestFilterBuilder<PostgrestList> query =
          client.from('marketplace_listings').select();
      query.order('created_at', ascending: false);
      if (status != null) {
        query.eq('status', status.key);
      }
      if (!includeArchived) {
        query.filter('archived_at', 'is', null);
      }
      return query;
    }, label: 'sales.marketplace.fetch');

    return rows
        .map(
          (dynamic row) =>
              MarketplaceListing.fromJson(row as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<RabbitSale> _fetchSale(String saleId) async {
    final Map<String, dynamic> row =
        await _api.run((SupabaseClient client) async {
          return client
              .from('rabbit_sales')
              .select(_salesSelect)
              .eq('id', saleId)
              .single();
        }, label: 'sales.fetch.single');
    return RabbitSale.fromJson(row);
  }

  Future<void> _archiveAnimal(String animalId, {required bool archive}) async {
    await _api.run((SupabaseClient client) async {
      return client
          .from('animals')
          .update(<String, dynamic>{
            'status': archive ? 'sold' : 'active',
            'deleted_at': archive ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', animalId)
          .select('id')
          .single();
    }, label: 'sales.animals.archive');
  }

  Future<String> _resolveCategoryId({required String code}) async {
    final List<TransactionCategory> categories =
        await _financeRepository.fetchCategories(includeInactive: false);
    final TransactionCategory? match = categories.firstWhereOrNull(
      (TransactionCategory category) => category.code == code,
    );
    if (match != null) {
      return match.id;
    }
    throw DataLayerException(
      'Aucune catégorie "$code" disponible pour le ledger.',
    );
  }

  Future<void> _dispatchNotification({
    required String id,
    required String event,
    required String profileId,
    String? title,
    String? body,
    String? email,
    String? phone,
    Map<String, dynamic>? extra,
  }) async {
    if (_hooks.isEmpty) {
      return;
    }
    final NotificationPayload payload = NotificationPayload(
      taskId: id,
      triggerAt: DateTime.now(),
      profileId: profileId,
      title: title,
      body: body,
      email: email,
      phone: phone,
      metadata: <String, dynamic>{
        'event': event,
        ...?extra,
      },
    );
    for (final NotificationHook hook in _hooks) {
      try {
        await hook.dispatch(payload);
      } catch (_) {
        // Ignored: notification hooks are best-effort.
      }
    }
  }

  String _requireProfileId() {
    if (profileIdOverride != null && profileIdOverride!.isNotEmpty) {
      return profileIdOverride!;
    }
    final String? profileId = _client.auth.currentUser?.id;
    if (profileId == null || profileId.isEmpty) {
      throw DataLayerException('Aucune session Supabase active.');
    }
    return profileId;
  }
}
