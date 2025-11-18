import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/data/repositories/event_repository.dart';
import 'package:khodan/data/repositories/event_template_repository.dart';
import 'package:khodan/data/repositories/food_inventory_repository.dart';
import 'package:khodan/features/account/presentation/cubit/subscription_cubit.dart';
import 'package:khodan/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:khodan/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:khodan/features/events/presentation/screens/add_breeding_record_screen.dart';
import 'package:khodan/features/events/presentation/screens/add_event_screen.dart';

class _MockAuthCubit extends Mock implements AuthCubit {}

class _MockSubscriptionCubit extends Mock implements SubscriptionCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthState());
    registerFallbackValue(const SubscriptionState());
  });

  testWidgets('saillie quick action opens breeding form', (WidgetTester tester) async {
    final _MockAuthCubit authCubit = _buildAuthCubit();
    final _MockSubscriptionCubit subscriptionCubit = _buildSubscriptionCubit();

    await tester.pumpWidget(
      _TestApp(
        authCubit: authCubit,
        subscriptionCubit: subscriptionCubit,
        repositories: const _TestRepositories(),
      ),
    );

    await tester.tap(find.byKey(const Key('dashboard-action-saillie')));
    await tester.pumpAndSettle();

    expect(find.byType(AddBreedingRecordScreen), findsOneWidget);
  });

  testWidgets('pesée quick action opens event form', (WidgetTester tester) async {
    final _MockAuthCubit authCubit = _buildAuthCubit();
    final _MockSubscriptionCubit subscriptionCubit = _buildSubscriptionCubit();

    await tester.pumpWidget(
      _TestApp(
        authCubit: authCubit,
        subscriptionCubit: subscriptionCubit,
        repositories: const _TestRepositories(includeEventDeps: true),
      ),
    );

    await tester.tap(find.byKey(const Key('dashboard-action-pesee')));
    await tester.pumpAndSettle();

    expect(find.byType(AddEventScreen), findsOneWidget);
  });

  testWidgets('abattage quick action opens loss form', (WidgetTester tester) async {
    final _MockAuthCubit authCubit = _buildAuthCubit();
    final _MockSubscriptionCubit subscriptionCubit = _buildSubscriptionCubit();

    await tester.pumpWidget(
      _TestApp(
        authCubit: authCubit,
        subscriptionCubit: subscriptionCubit,
        repositories: const _TestRepositories(includeEventDeps: true),
      ),
    );

    await tester.tap(find.byKey(const Key('dashboard-action-abattage')));
    await tester.pumpAndSettle();

    expect(find.byType(AddEventScreen), findsOneWidget);
  });
}

_MockAuthCubit _buildAuthCubit() {
  final _MockAuthCubit cubit = _MockAuthCubit();
  when(() => cubit.stream).thenAnswer((_) => const Stream<AuthState>.empty());
  when(() => cubit.state).thenReturn(const AuthState());
  when(() => cubit.close()).thenAnswer((_) async {});
  addTearDown(cubit.close);
  return cubit;
}

_MockSubscriptionCubit _buildSubscriptionCubit() {
  final _MockSubscriptionCubit cubit = _MockSubscriptionCubit();
  when(() => cubit.stream)
      .thenAnswer((_) => const Stream<SubscriptionState>.empty());
  when(() => cubit.state).thenReturn(const SubscriptionState());
  when(() => cubit.close()).thenAnswer((_) async {});
  addTearDown(cubit.close);
  return cubit;
}

class _TestRepositories {
  const _TestRepositories({this.includeEventDeps = false});

  final bool includeEventDeps;
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.authCubit,
    required this.subscriptionCubit,
    required this.repositories,
  });

  final AuthCubit authCubit;
  final SubscriptionCubit subscriptionCubit;
  final _TestRepositories repositories;

  @override
  Widget build(BuildContext context) {
    final List<RepositoryProvider<dynamic>> repoProviders =
        <RepositoryProvider<dynamic>>[
      RepositoryProvider<AnimalRepository>(
        create: (_) => InMemoryAnimalRepository(),
      ),
      RepositoryProvider<BreedingRepository>(
        create: (_) => InMemoryBreedingRepository(),
      ),
    ];

    if (repositories.includeEventDeps) {
      repoProviders.addAll(<RepositoryProvider<dynamic>>[
        RepositoryProvider<EventRepository>(
          create: (_) => InMemoryEventRepository(),
        ),
        RepositoryProvider<EventTemplateRepository>(
          create: (_) => InMemoryEventTemplateRepository(),
        ),
        RepositoryProvider<FoodInventoryRepository>(
          create: (_) => InMemoryFoodInventoryRepository(),
        ),
      ]);
    }

    return MultiRepositoryProvider(
      providers: repoProviders,
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<SubscriptionCubit>.value(value: subscriptionCubit),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
  }
}
