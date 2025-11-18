import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:khodan/data/repositories/animal_repository.dart';
import 'package:khodan/data/repositories/breeding_repository.dart';
import 'package:khodan/features/account/presentation/cubit/subscription_cubit.dart';
import 'package:khodan/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:khodan/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:khodan/features/events/presentation/screens/add_breeding_record_screen.dart';

class _MockAuthCubit extends Mock implements AuthCubit {}

class _MockSubscriptionCubit extends Mock implements SubscriptionCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(const AuthState());
    registerFallbackValue(const SubscriptionState());
  });

  testWidgets('saillie quick action opens breeding form', (WidgetTester tester) async {
    final _MockAuthCubit authCubit = _MockAuthCubit();
    final _MockSubscriptionCubit subscriptionCubit = _MockSubscriptionCubit();
    when(() => authCubit.stream).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => authCubit.state).thenReturn(const AuthState());
    when(() => authCubit.close()).thenAnswer((_) async {});
    when(() => subscriptionCubit.stream)
        .thenAnswer((_) => const Stream<SubscriptionState>.empty());
    when(() => subscriptionCubit.state).thenReturn(const SubscriptionState());
    when(() => subscriptionCubit.close()).thenAnswer((_) async {});

    addTearDown(authCubit.close);
    addTearDown(subscriptionCubit.close);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: <RepositoryProvider<dynamic>>[
          RepositoryProvider<AnimalRepository>(
            create: (_) => InMemoryAnimalRepository(),
          ),
          RepositoryProvider<BreedingRepository>(
            create: (_) => InMemoryBreedingRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<SubscriptionCubit>.value(value: subscriptionCubit),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('dashboard-action-saillie')));
    await tester.pumpAndSettle();

    expect(find.byType(AddBreedingRecordScreen), findsOneWidget);
  });
}

