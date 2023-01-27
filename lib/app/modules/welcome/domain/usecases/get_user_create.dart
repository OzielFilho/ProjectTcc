import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../authentication/utils/entities/auth_result.dart';
import '../repositories/welcome_repository.dart';

class GetUserCreate implements Usecase<AuthResult, NoParams> {
  final WelcomeRepository repository;

  GetUserCreate(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(NoParams? params) async {
    return await repository.getUserCreate();
  }
}
