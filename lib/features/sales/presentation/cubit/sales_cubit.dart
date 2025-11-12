import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/contact.dart';
import '../../../../data/models/marketplace_listing.dart';
import '../../../../data/models/rabbit_sale.dart';
import '../../../../data/models/rabbit_transfer.dart';
import '../../../../data/repositories/animal_repository.dart';
import '../../../../data/repositories/finance_repository.dart';
import '../../../../data/services/rabbit_sales_service.dart';
import '../../../finances/services/finance_exporter.dart';
import 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  SalesCubit({
    required RabbitSalesService salesService,
    required AnimalRepository animalRepository,
    required FinanceRepository financeRepository,
    FinanceExporter? exporter,
  })  : _service = salesService,
        _animalRepository = animalRepository,
        _financeRepository = financeRepository,
        _exporter = exporter ?? createFinanceExporter(),
        super(const SalesState());

  final RabbitSalesService _service;
  final AnimalRepository _animalRepository;
  final FinanceRepository _financeRepository;
  final FinanceExporter _exporter;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  final DateFormat _timestampFormatter = DateFormat('yyyyMMdd_HHmm');

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final List<dynamic> results = await Future.wait(<Future<dynamic>>[
        _service.fetchSales(),
        _service.fetchTransfers(),
        _service.fetchListings(),
        _financeRepository.fetchContacts(),
        _animalRepository.fetchAnimals(),
      ]);
      emit(
        state.copyWith(
          isLoading: false,
          sales: results[0] as List<RabbitSale>,
          transfers: results[1] as List<RabbitTransfer>,
          listings: results[2] as List<MarketplaceListing>,
          contacts: results[3] as List<Contact>,
          animals: results[4] as List<Animal>,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refreshSales() async {
    try {
      final List<RabbitSale> sales = await _service.fetchSales();
      emit(state.copyWith(sales: sales));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  void updateStatusFilter(RabbitSaleStatus? status) {
    emit(state.copyWith(statusFilter: status));
  }

  void updatePeriodFilter(DateTimeRange? range) {
    if (range == null) {
      emit(state.copyWith(clearPeriodFilter: true));
    } else {
      emit(state.copyWith(periodFilter: range));
    }
  }

  Future<void> createSale(RabbitSaleDraft draft) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final RabbitSale sale = await _service.createLocalSale(draft);
      final List<RabbitSale> updated = <RabbitSale>[sale, ...state.sales];
      emit(state.copyWith(isSaving: false, sales: updated));
    } catch (error) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> completeSale(String saleId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final RabbitSale sale = await _service.completeSale(saleId);
      final List<RabbitSale> updated = state.sales
          .map((RabbitSale existing) =>
              existing.id == sale.id ? sale : existing)
          .toList(growable: false);
      emit(state.copyWith(isSaving: false, sales: updated));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
    }
  }

  Future<void> cancelSale(String saleId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final RabbitSale sale = await _service.cancelSale(saleId);
      final List<RabbitSale> updated = state.sales
          .map((RabbitSale existing) =>
              existing.id == sale.id ? sale : existing)
          .toList(growable: false);
      emit(state.copyWith(isSaving: false, sales: updated));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
    }
  }

  Future<void> initiateTransfer(RabbitTransferRequest request) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final RabbitTransfer transfer = await _service.initiateTransfer(request);
      emit(
        state.copyWith(
          isSaving: false,
          transfers: <RabbitTransfer>[transfer, ...state.transfers],
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
    }
  }

  Future<void> acceptTransfer(String transferId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final RabbitTransfer transfer = await _service.acceptTransfer(transferId);
      final List<RabbitTransfer> updated = state.transfers
          .map((RabbitTransfer item) =>
              item.id == transfer.id ? transfer : item)
          .toList(growable: false);
      emit(state.copyWith(isSaving: false, transfers: updated));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
    }
  }

  Future<void> rejectTransfer(String transferId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final RabbitTransfer transfer = await _service.rejectTransfer(transferId);
      final List<RabbitTransfer> updated = state.transfers
          .map((RabbitTransfer item) =>
              item.id == transfer.id ? transfer : item)
          .toList(growable: false);
      emit(state.copyWith(isSaving: false, transfers: updated));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
    }
  }

  Future<void> publishListing(MarketplaceListingDraft draft) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final MarketplaceListing listing =
          await _service.publishListing(draft);
      emit(
        state.copyWith(
          isSaving: false,
          listings: <MarketplaceListing>[listing, ...state.listings],
        ),
      );
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
    }
  }

  Future<void> updateListingStatus(
    String listingId,
    MarketplaceListingStatus status,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final MarketplaceListing listing =
          await _service.updateListingStatus(listingId, status);
      final List<MarketplaceListing> updated = state.listings
          .map((MarketplaceListing item) =>
              item.id == listing.id ? listing : item)
          .toList(growable: false);
      emit(state.copyWith(isSaving: false, listings: updated));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
    }
  }

  Future<String?> exportSalesCsv() async {
    emit(state.copyWith(isExporting: true, clearError: true));
    try {
      final List<List<dynamic>> rows = <List<dynamic>>[
        <String>[
          'sale_id',
          'animal_tag',
          'contact_name',
          'status',
          'price',
          'currency',
          'payment_method',
          'created_at',
        ],
        ...state.filteredSales.map(
          (RabbitSale sale) => <dynamic>[
            sale.id,
            sale.animalTag ?? sale.animalId,
            sale.contactName ?? '',
            sale.status.key,
            sale.price,
            sale.currency,
            sale.paymentMethod ?? '',
            _dateFormatter.format(sale.createdAt),
          ],
        ),
      ];
      final String csv = const ListToCsvConverter().convert(rows);
      final String filename =
          'sales_${_timestampFormatter.format(DateTime.now())}.csv';
      await _exporter.save(filename, csv);
      emit(state.copyWith(isExporting: false));
      return filename;
    } catch (error) {
      emit(
        state.copyWith(
          isExporting: false,
          errorMessage: error.toString(),
        ),
      );
      return null;
    }
  }
}
