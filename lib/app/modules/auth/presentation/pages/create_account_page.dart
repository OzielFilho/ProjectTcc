import 'package:app/app/modules/auth/presentation/controllers/create_account_controller/create_account_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../core/presentation/controller/app_state.dart';
import '../../../../core/presentation/widgets/buttons_design.dart';
import '../../../../core/presentation/widgets/form_desing.dart';
import '../../../../core/presentation/widgets/loading_desing.dart';
import '../../../../core/theme/theme_app.dart';
import '../controllers/create_account_controller/create_account_event.dart';

class CreateAccountPage extends StatefulWidget {
  CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _emailControllerNew = TextEditingController();
  final _nameControllerNew = TextEditingController();
  final _confirmPasswordControllerNew = TextEditingController();
  final _phoneControllerNew = TextEditingController();
  final _passwordControllerNew = TextEditingController();

  final _createAccount = Modular.get<CreateAccountBloc>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateAccountBloc, AppState>(
      bloc: _createAccount,
      listener: (context, state) {
        if (state is SuccessState) {
          Modular.to.pushReplacementNamed('/home/');
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
                leading: IconButton(
                    onPressed: () => Modular.to.pop(),
                    icon: Icon(Icons.arrow_back_ios_new_outlined))),
            body: SingleChildScrollView(
                child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Crie sua conta',
                          style: ThemeApp.theme.textTheme.headline1),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Insira suas credenciais',
                          style: ThemeApp.theme.textTheme.subtitle1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Insira Seu Nome',
                                style: ThemeApp.theme.textTheme.subtitle1),
                          ),
                          FormsDesign(
                            prefixIcon: null,
                            suffixIcon: null,
                            title: 'Nome',
                            visibility: false,
                            controller: _nameControllerNew,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Insira Seu Email',
                                style: ThemeApp.theme.textTheme.subtitle1),
                          ),
                          FormsDesign(
                            prefixIcon: null,
                            suffixIcon: null,
                            title: 'Email',
                            visibility: false,
                            controller: _emailControllerNew,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Insira Sua Senha',
                                style: ThemeApp.theme.textTheme.subtitle1),
                          ),
                          FormsDesign(
                            prefixIcon: null,
                            suffixIcon: null,
                            title: 'Senha',
                            visibility: false,
                            controller: _passwordControllerNew,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Repita a Senha',
                                style: ThemeApp.theme.textTheme.subtitle1),
                          ),
                          FormsDesign(
                            prefixIcon: null,
                            suffixIcon: null,
                            title: 'Confirme a Senha',
                            visibility: false,
                            controller: _confirmPasswordControllerNew,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Insira Seu Telefone',
                                style: ThemeApp.theme.textTheme.subtitle1),
                          ),
                          FormsDesign(
                            prefixIcon: null,
                            suffixIcon: null,
                            title: '(xx) xxxxx.xxxx',
                            visibility: false,
                            controller: _phoneControllerNew,
                          ),
                          if (state is ErrorState) ...[
                            AnimatedContainer(
                              duration: Duration(seconds: 5),
                              curve: Curves.ease,
                              child: Text(
                                state.message!,
                                style: ThemeApp.theme.textTheme.subtitle1,
                              ),
                            )
                          ],
                          ButtonDesign(
                              text: 'Criar Conta',
                              action: () {
                                if (!(state is ProcessingState)) {
                                  _createAccount.add(
                                      CreateAccountWithEmailAndPasswordEvent(
                                          contacts: [],
                                          phone: _phoneControllerNew.text,
                                          confirmePassword:
                                              _confirmPasswordControllerNew
                                                  .text,
                                          email: _emailControllerNew.text,
                                          name: _nameControllerNew.text,
                                          password:
                                              _passwordControllerNew.text));
                                }
                              }),
                          if (state is ProcessingState) ...[
                            LoadingDesign(),
                          ],
                        ],
                      ),
                    )
                  ]),
            )));
      },
    );
  }
}
