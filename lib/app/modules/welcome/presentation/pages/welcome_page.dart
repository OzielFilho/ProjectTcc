import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/presentation/controller/app_state.dart';
import '../../../../core/presentation/widgets/buttons_design.dart';
import '../../../../core/presentation/widgets/form_desing.dart';
import '../../../../core/presentation/widgets/loading_desing.dart';
import '../../../../core/theme/theme_app.dart';
import '../../../../core/utils/colors/colors_utils.dart';
import '../../../../core/utils/widgets_utils.dart';
import '../controllers/bloc/get_user_welcome_bloc.dart';
import '../controllers/bloc/update_user_create_bloc.dart';
import '../controllers/bloc/user_phone_is_empty_bloc.dart';
import '../controllers/event/welcome_event.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _getUserBloc = Modular.get<GetUserWelcomeBloc>();
  final _userPhoneEmptyBloc = Modular.get<UserPhoneIsEmptyBloc>();
  final _updateUserCreateBloc = Modular.get<UpdateUserCreateBloc>();
  List<String> _contactsText = [];
  _createNewForm() {
    _formsContacts.add(FormsDesign(
        controller: TextEditingController(),
        title: 'Insira um número',
        formatter: [_maskFormatter],
        suffixIcon: IconButton(
            onPressed: _createNewForm,
            icon: Icon(
              Icons.add,
              color: ColorUtils.whiteColor,
            ))));
    setState(() {});
  }

  List<FormsDesign> _formsContacts = [];

  final _controllerPhone = TextEditingController();
  PageController? _controllerPage;

  var _maskFormatter = new MaskTextInputFormatter(
      mask: '(##)#####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  void initState() {
    _createNewForm();
    _controllerPage = PageController(initialPage: 0);
    _getUserBloc.add(GetUserEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetUserWelcomeBloc, AppState>(
      bloc: _getUserBloc,
      listener: (context, state) {
        if (state is NetworkErrorState) {
          WidgetUtils.showOkDialog(
              context, 'Internet Indisponível', state.message!, 'Reload', () {
            Modular.to.pop(context);
            _getUserBloc.add(GetUserEvent());
          }, permanentDialog: false);
        }
        if (state is SuccessGetUserState) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (_controllerPage!.hasClients) {
              if (_getUserBloc.user!.phone.isEmpty) {
                _controllerPage!.jumpToPage(2);
              } else {
                _controllerPage!.jumpToPage(1);
              }
            }
          });
        }
      },
      builder: (context, state) {
        if (state is ProcessingState) {
          return Scaffold(body: Center(child: LoadingDesign()));
        }

        if (state is ErrorState) {
          return Scaffold(
            body: AnimatedContainer(
              alignment: Alignment.center,
              duration: Duration(seconds: 5),
              curve: Curves.ease,
              child: Text(
                state.message!,
                style: ThemeApp.theme.textTheme.subtitle1,
              ),
            ),
          );
        }
        if (state is SuccessGetUserState) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-Vindo ao Shh!',
                      style: ThemeApp.theme.textTheme.headline1,
                    ),
                    Text(
                      'Você acaba de entrar no Shh! Preciso de ajuda!',
                      style: ThemeApp.theme.textTheme.subtitle1,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Expanded(
                        flex: 1,
                        child: PageView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _controllerPage,
                          children: [
                            Center(child: LoadingDesign()),
                            BlocConsumer<UpdateUserCreateBloc, AppState>(
                                listener: (context, state) {
                                  if (state is NetworkErrorState) {
                                    WidgetUtils.showOkDialog(
                                        context,
                                        'Internet Indisponível',
                                        state.message!,
                                        'Reload', () {
                                      Modular.to.pop(context);
                                    }, permanentDialog: false);
                                  }
                                  if (state is SuccessUpdateUserCreateState) {
                                    Modular.to
                                        .pushReplacementNamed('/tutorial');
                                  }
                                },
                                bloc: _updateUserCreateBloc,
                                builder: (context, stateUpdate) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Para continuar, insira seus telefones de confiança que serão utilizados para contato',
                                          style: ThemeApp
                                              .theme.textTheme.subtitle1,
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: _formsContacts.length,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.all(12.0),
                                            itemBuilder: (context, index) {
                                              return _formsContacts[index];
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: ButtonDesign(
                                              text: 'Finalizar Conta',
                                              action: () {
                                                FocusScope.of(context)
                                                    .unfocus();

                                                _contactsText = _formsContacts
                                                    .map((e) =>
                                                        e.controller.text)
                                                    .toList();
                                                print(_contactsText);
                                                _updateUserCreateBloc.add(
                                                    UpdateUserCreateEvent(
                                                        contacts: _contactsText,
                                                        email:
                                                            _getUserBloc
                                                                .user!.email,
                                                        photo: _getUserBloc
                                                                .user!.photo ??
                                                            '',
                                                        name: _getUserBloc
                                                            .user!.name,
                                                        phone: _getUserBloc
                                                            .user!.phone,
                                                        welcomePage:
                                                            !_getUserBloc.user!
                                                                .welcomePage));
                                              }),
                                        ),
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        if (stateUpdate is ErrorState) ...[
                                          AnimatedContainer(
                                            duration: Duration(seconds: 5),
                                            curve: Curves.ease,
                                            child: Text(
                                              stateUpdate.message!,
                                              style: ThemeApp
                                                  .theme.textTheme.subtitle1,
                                            ),
                                          )
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                            BlocConsumer<UserPhoneIsEmptyBloc, AppState>(
                                listener: (context, state) {
                                  if (state is SuccessState) {
                                    _getUserBloc.user!.phone =
                                        _controllerPhone.text;
                                    _controllerPage!.jumpToPage(1);
                                  }
                                },
                                bloc: _userPhoneEmptyBloc,
                                builder: (context, eventPhoneEmpty) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Insira seu telefone',
                                        style:
                                            ThemeApp.theme.textTheme.subtitle1,
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      FormsDesign(
                                          controller: _controllerPhone,
                                          formatter: [_maskFormatter],
                                          suffixIcon: Icon(
                                            Icons.phone_android,
                                            color: Colors.white,
                                          )),
                                      if (eventPhoneEmpty
                                          is ProcessingState) ...[
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        Align(
                                            alignment: Alignment.center,
                                            child: LoadingDesign()),
                                      ],
                                      if (eventPhoneEmpty is ErrorState) ...[
                                        const SizedBox(
                                          height: 20.0,
                                        ),
                                        AnimatedContainer(
                                          alignment: Alignment.center,
                                          duration: Duration(seconds: 5),
                                          curve: Curves.ease,
                                          child: Text(
                                            eventPhoneEmpty.message!,
                                            style: ThemeApp
                                                .theme.textTheme.subtitle1,
                                          ),
                                        )
                                      ],
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: ButtonDesign(
                                            text: 'Continuar',
                                            action: () {
                                              FocusScope.of(context).unfocus();
                                              if (!(eventPhoneEmpty
                                                  is ProcessingState)) {
                                                _userPhoneEmptyBloc.add(
                                                    PhoneIsEmptyEvent(
                                                        phone: _controllerPhone
                                                            .text));
                                              }
                                            }),
                                      ),
                                    ],
                                  );
                                }),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          body: Container(),
        );
      },
    );
  }
}
