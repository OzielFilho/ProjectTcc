import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

abstract class AuthUserRepository {
  Future<Either<Failure, bool>> loginUser(String email, String password);
}
