import 'package:app/app/core/utils/colors/colors_utils.dart';
import 'package:app/app/core/utils/constants/widgets_utils.dart';
import 'package:app/app/modules/splash/presentation/controllers/splash_bloc.dart';
import 'package:app/app/modules/splash/presentation/controllers/splash_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/presentation/controller/app_state.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _splashBloc = Modular.get<SplashBloc>();

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5), () {
      _splashBloc.add(LoggedUserEvent());
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashBloc, AppState>(
      bloc: _splashBloc,
      listener: (context, state) {
        if (state is ErrorState) {
          WidgetUtils.showSnackBar(context, state.message!,
              actionText: 'Ok', onTap: () {});
          return;
        }
        if (state is UserNotLoggedState) {
          Modular.to.pushReplacementNamed('/auth/');
          return;
        }
        Modular.to.pushReplacementNamed('/home/');
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: SvgPicture.asset(
              'assets/images/splash_icon.svg',
              color: ColorUtils.whiteColor,
            ),
          ),
        );
      },
    );
  }
}
