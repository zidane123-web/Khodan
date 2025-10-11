abstract class UseCase<Output, Input> {
  const UseCase();

  Future<Output> call(Input params);
}

class NoParams {
  const NoParams();
}
