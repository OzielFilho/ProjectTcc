import 'package:app/app/modules/auth/domain/entities/user_create.dart';
import 'package:app/app/modules/auth/infra/models/user_create_model.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/create_account_repository.dart';
import '../datasources/create_account_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';

class CreateAccountRepositoryImpl extends CreateAccountRepository {
  final CreateAccountDatasource datasource;

  CreateAccountRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, AuthResult>> createAccountWithEmailAndPassword(
      UserCreate user) async {
    try {
      final result = await datasource.createAccountWithEmailAndPassword(
          UserCreateModel.fromUserCreate(user));
      return right(result);
    } on CreateUserException {
      return left(CreateUserFailure());
    } catch (e) {
      return left(CreateUserFailure());
    }
  }
}
