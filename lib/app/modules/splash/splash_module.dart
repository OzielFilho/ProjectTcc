import 'package:app/app/modules/splash/domain/usecases/logged_user.dart';
import 'package:app/app/modules/splash/external/firebase_refresh_account.dart';
import 'package:app/app/modules/splash/infra/repositories/refresh_account_repository_impl.dart';
import 'package:app/app/modules/splash/presentation/controllers/splash_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'presentation/splash_page.dart';

class SplashModule extends Module {
  @override
  List<Bind> get binds => [
        Bind((i) => FirebaseRefreshAccount(FirebaseAuth.instance)),
        Bind((i) => RefreshAccountRepositoryImpl(i())),
        Bind((i) => LoggedUser(i())),
        Bind((i) => SplashBloc(i())),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          Modular.initialRoute,
          child: (context, args) => SplashPage(),
        )
      ];
}
