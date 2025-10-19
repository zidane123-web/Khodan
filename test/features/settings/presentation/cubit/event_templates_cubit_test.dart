import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/models/event_template.dart';
import 'package:khodan/data/repositories/event_template_repository.dart';
import 'package:khodan/features/settings/presentation/cubit/event_templates_cubit.dart';

class _MockEventTemplateRepository extends Mock
    implements EventTemplateRepository {}

EventTemplate _buildTemplate({int id = 1, String name = 'Vaccination'}) {
  final DateTime now = DateTime(2025, 1, 1);
  return EventTemplate(
    id: id,
    userId: 'profile',
    templateName: name,
    eventType: 'sante',
    defaultDetails: const <String, dynamic>{'produit': 'Vitamine'},
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late _MockEventTemplateRepository repository;
  late EventTemplatesCubit cubit;

  setUpAll(() {
    registerFallbackValue(_buildTemplate());
  });

  setUp(() {
    repository = _MockEventTemplateRepository();
    when(() => repository.fetchTemplates('profile'))
        .thenAnswer((_) async => <EventTemplate>[]);
    cubit = EventTemplatesCubit(repository, profileId: 'profile');
  });

  test('initialize loads templates', () async {
    await cubit.initialize();

    expect(cubit.state.templates, isEmpty);
    verify(() => repository.fetchTemplates('profile')).called(1);
  });

  test('saveTemplate creates template and refreshes list', () async {
    await cubit.initialize();

    final EventTemplate created = _buildTemplate(id: 7);
    when(() => repository.createTemplate(any())).thenAnswer((_) async => created);
    when(() => repository.fetchTemplates('profile'))
        .thenAnswer((_) async => <EventTemplate>[created]);

    await cubit.saveTemplate(
      name: 'Vaccination',
      eventType: 'sante',
      defaultDetails: const <String, dynamic>{'produit': 'Vitamine'},
    );

    expect(cubit.state.templates, <EventTemplate>[created]);
    expect(cubit.state.successMessage, isNotNull);
    verify(() => repository.createTemplate(any())).called(1);
  });

  test('saveTemplate updates template', () async {
    final EventTemplate existing = _buildTemplate(id: 2);
    when(() => repository.fetchTemplates('profile'))
        .thenAnswer((_) async => <EventTemplate>[existing]);
    await cubit.initialize();

    final EventTemplate updated = existing.copyWith(templateName: 'Pesage');
    when(() => repository.updateTemplate(any())).thenAnswer((_) async => updated);
    when(() => repository.fetchTemplates('profile'))
        .thenAnswer((_) async => <EventTemplate>[updated]);

    await cubit.saveTemplate(
      id: existing.id,
      name: 'Pesage',
      eventType: existing.eventType,
      defaultDetails: existing.defaultDetails,
    );

    expect(cubit.state.templates.first.templateName, 'Pesage');
    verify(() => repository.updateTemplate(any())).called(1);
  });

  test('deleteTemplate removes template and refreshes list', () async {
    final EventTemplate existing = _buildTemplate(id: 3);
    when(() => repository.fetchTemplates('profile'))
        .thenAnswer((_) async => <EventTemplate>[existing]);
    await cubit.initialize();

    when(() => repository.fetchTemplates('profile'))
        .thenAnswer((_) async => <EventTemplate>[]);
    when(() => repository.deleteTemplate(existing.id))
        .thenAnswer((_) async {});

    await cubit.deleteTemplate(existing.id);

    expect(cubit.state.templates, isEmpty);
    verify(() => repository.deleteTemplate(existing.id)).called(1);
  });
}

