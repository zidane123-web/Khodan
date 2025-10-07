import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/event.dart';
import '../../../../data/repositories/event_repository.dart';

enum EventsStatus { initial, loading, success, failure }

class EventsState extends Equatable {
  const EventsState({
    this.status = EventsStatus.initial,
    this.healthEvents = const <LivestockEvent>[],
    this.otherEvents = const <LivestockEvent>[],
    this.errorMessage,
  });

  final EventsStatus status;
  final List<LivestockEvent> healthEvents;
  final List<LivestockEvent> otherEvents;
  final String? errorMessage;

  EventsState copyWith({
    EventsStatus? status,
    List<LivestockEvent>? healthEvents,
    List<LivestockEvent>? otherEvents,
    String? errorMessage,
  }) {
    return EventsState(
      status: status ?? this.status,
      healthEvents: healthEvents ?? this.healthEvents,
      otherEvents: otherEvents ?? this.otherEvents,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    healthEvents,
    otherEvents,
    errorMessage,
  ];
}

class EventsCubit extends Cubit<EventsState> {
  EventsCubit(EventRepository repository)
    : _repository = repository,
      super(const EventsState());

  final EventRepository _repository;

  static const Set<String> _healthEventTypes = <String>{
    'weight',
    'vaccination',
    'treatment',
    'health_check',
  };

  static const Set<String> _reproductionEventTypes = <String>{
    'mating',
    'palpation',
    'kindling',
    'weaning',
    'breeding',
  };

  Future<void> loadEvents() async {
    emit(state.copyWith(status: EventsStatus.loading));
    try {
      final List<LivestockEvent> events = await _repository.fetchEvents();
      final List<LivestockEvent> healthEvents = <LivestockEvent>[];
      final List<LivestockEvent> otherEvents = <LivestockEvent>[];

      for (final LivestockEvent event in events) {
        if (_healthEventTypes.contains(event.eventType)) {
          healthEvents.add(event);
          continue;
        }

        if (_reproductionEventTypes.contains(event.eventType)) {
          continue;
        }

        otherEvents.add(event);
      }

      emit(
        state.copyWith(
          status: EventsStatus.success,
          healthEvents: List<LivestockEvent>.unmodifiable(healthEvents),
          otherEvents: List<LivestockEvent>.unmodifiable(otherEvents),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: EventsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
