import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/animal.dart';
import '../../../../data/models/contact.dart';
import '../../../../data/models/marketplace_listing.dart';
import '../../../../data/models/rabbit_sale.dart';
import '../../../../data/models/rabbit_transfer.dart';

class SalesState extends Equatable {
  const SalesState({
    this.isLoading = false,
    this.isSaving = false,
    this.isExporting = false,
    this.sales = const <RabbitSale>[],
    this.transfers = const <RabbitTransfer>[],
    this.listings = const <MarketplaceListing>[],
    this.contacts = const <Contact>[],
    this.animals = const <Animal>[],
    this.statusFilter,
    this.periodFilter,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSaving;
  final bool isExporting;
  final List<RabbitSale> sales;
  final List<RabbitTransfer> transfers;
  final List<MarketplaceListing> listings;
  final List<Contact> contacts;
  final List<Animal> animals;
  final RabbitSaleStatus? statusFilter;
  final DateTimeRange? periodFilter;
  final String? errorMessage;

  List<RabbitSale> get filteredSales {
    return sales.where((RabbitSale sale) {
      if (statusFilter != null && sale.status != statusFilter) {
        return false;
      }
      if (periodFilter != null) {
        if (sale.createdAt.isBefore(periodFilter!.start) ||
            sale.createdAt.isAfter(periodFilter!.end)) {
          return false;
        }
      }
      return true;
    }).toList(growable: false);
  }

  List<RabbitTransfer> get activeTransfers => transfers
      .where(
        (RabbitTransfer transfer) =>
            transfer.status == RabbitTransferStatus.pending ||
            transfer.status == RabbitTransferStatus.accepted,
      )
      .toList(growable: false);

  List<Animal> get sellableAnimals => animals
      .where(
        (Animal animal) {
          final String status = animal.status.toLowerCase();
          return status != 'sold' && status != 'transferred';
        },
      )
      .toList(growable: false);

  SalesState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isExporting,
    List<RabbitSale>? sales,
    List<RabbitTransfer>? transfers,
    List<MarketplaceListing>? listings,
    List<Contact>? contacts,
    List<Animal>? animals,
    RabbitSaleStatus? statusFilter,
    DateTimeRange? periodFilter,
    bool clearPeriodFilter = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SalesState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isExporting: isExporting ?? this.isExporting,
      sales: sales ?? this.sales,
      transfers: transfers ?? this.transfers,
      listings: listings ?? this.listings,
      contacts: contacts ?? this.contacts,
      animals: animals ?? this.animals,
      statusFilter: statusFilter ?? this.statusFilter,
      periodFilter: clearPeriodFilter ? null : (periodFilter ?? this.periodFilter),
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        isLoading,
        isSaving,
        isExporting,
        sales,
        transfers,
        listings,
        contacts,
        animals,
        statusFilter,
        periodFilter,
        errorMessage,
      ];
}
