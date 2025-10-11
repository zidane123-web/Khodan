import '../../common/failure.dart';
import '../../common/use_case.dart';
import '../entities/animal_entity.dart';
import '../repositories/animal_repository_interface.dart';

class FetchAnimalsParams {
  const FetchAnimalsParams({this.farmId, this.status});

  final String? farmId;
  final String? status;
}

class FetchAnimalsUseCase extends UseCase<List<AnimalEntity>, FetchAnimalsParams> {
  FetchAnimalsUseCase(this.repository);

  final AnimalRepositoryInterface repository;

  @override
  Future<List<AnimalEntity>> call(FetchAnimalsParams params) async {
    try {
      return repository.fetchAnimals(
        farmId: params.farmId,
        status: params.status,
      );
    } catch (error) {
      throw UnknownFailure(message: 'Unable to fetch animals', cause: error);
    }
  }
}
