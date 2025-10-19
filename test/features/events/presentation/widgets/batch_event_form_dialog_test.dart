import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:khodan/data/models/animal.dart';
import 'package:khodan/data/models/animal_event.dart';
import 'package:khodan/data/models/event.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/features/events/presentation/widgets/batch_event_form_dialog.dart';
import 'package:khodan/features/events/presentation/cubit/events_cubit.dart';

class _RecordingEventRepository implements EventRepository {
  final List<LivestockEvent> created = <LivestockEvent>[];

  @override
  Future<LivestockEvent> createEvent(
    LivestockEvent event, {
    List<AnimalEventLink> links = const <AnimalEventLink>[],
  }) async {
    created.add(event);
    return event;
  }

  @override
  Future<List<LivestockEvent>> fetchEvents({DateTime? start, DateTime? end}) async =>
      <LivestockEvent>[];

  @override
  Future<List<AnimalEventLink>> fetchEventLinks() async => <AnimalEventLink>[];
}

class _TestEventsCubit extends EventsCubit {
  _TestEventsCubit(EventRepository repository) : super(repository);

  int refreshCalls = 0;

  @override
  Future<void> refresh() async {
    refreshCalls += 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Animal animal = Animal(
    id: 'animal-1',
    profileId: 'profile',
    speciesId: 1,
    tagId: 'A-01',
    birthDate: DateTime(2024, 1, 1),
    sex: 'Male',
    status: 'active',
  );

  testWidgets('enqueues batch events and refreshes list', (WidgetTester tester) async {
    final _RecordingEventRepository repository = _RecordingEventRepository();
    final _TestEventsCubit eventsCubit = _TestEventsCubit(repository);

    await tester.pumpWidget(
      RepositoryProvider<EventRepository>.value(
        value: repository,
        child: BlocProvider<EventsCubit>.value(
          value: eventsCubit,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        BatchEventFormDialog.show(
                          context,
                          animals: <Animal>[animal],
                        );
                      },
                      child: const Text('ouvrir'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Pes').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Poids (kg)'), '2');

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(repository.created, hasLength(1));
    expect(repository.created.first.eventType, 'weight');
    expect(eventsCubit.refreshCalls, 1);
    expect(find.byType(AlertDialog), findsNothing);

    await eventsCubit.close();
  });
}
