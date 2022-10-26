import 'package:app/app/core/utils/colors/colors_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../core/utils/constants/encrypt_data.dart';
import 'widgets/header_chat_user.dart';

import '../../../../../core/utils/widgets_utils.dart';
import '../../controllers/events/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../core/presentation/controller/app_state.dart';
import '../../../../../core/presentation/widgets/loading_desing.dart';
import '../../../../../core/theme/theme_app.dart';
import '../../controllers/bloc/chat/get_list_details_contact_from_phone_chat_bloc.dart';

class ChatListHomePage extends StatefulWidget {
  final List<String> contacts;
  final String tokenId;
  final String photo;
  final String nameUser;
  const ChatListHomePage(
      {Key? key,
      required this.contacts,
      required this.tokenId,
      required this.photo,
      required this.nameUser})
      : super(key: key);

  @override
  State<ChatListHomePage> createState() => _ChatListHomePageState();
}

class _ChatListHomePageState extends State<ChatListHomePage> {
  final _blocGetContacts =
      Modular.get<GetListDetailsContactFromPhoneChatBloc>();

  @override
  void initState() {
    _blocGetContacts.add(
        GetListDetailsContactFromPhoneChatEvent(contacts: widget.contacts));
    super.initState();
  }

  final ScrollController _scrollController = ScrollController();

  List<String> _getListContactWithoutApp() {
    final copyContacts = [...widget.contacts.toList()];
    final contactsWithChatPhone =
        _blocGetContacts.contacts!.map((e) => e.phone).toList();
    copyContacts
        .removeWhere((element) => contactsWithChatPhone.contains(element));

    return copyContacts.map((e) => EncryptData().decrypty(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<GetListDetailsContactFromPhoneChatBloc, AppState>(
          listener: (context, state) {
            if (state is NetworkErrorState) {
              WidgetUtils.showOkDialog(
                  context, 'Internet Indisponível', state.message!, 'Reload',
                  () {
                Modular.to.pop(context);
                _blocGetContacts.add(GetListDetailsContactFromPhoneChatEvent(
                    contacts: widget.contacts));
              }, permanentDialog: false);
            }
          },
          bloc: _blocGetContacts,
          builder: (context, state) {
            if (state is ProcessingState) {
              return Center(child: LoadingDesign());
            }
            if (state is ErrorState) {
              return AnimatedContainer(
                duration: Duration(seconds: 5),
                alignment: Alignment.center,
                curve: Curves.ease,
                child: Text(
                  state.message!,
                  style: ThemeApp.theme.textTheme.subtitle1,
                ),
              );
            }
            if (state is SuccessGetListDetailsContactFromPhoneChatState) {
              return SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, index) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => Modular.to.pushNamed(
                                    'chat_with_contact_home',
                                    arguments: {
                                      'tokenIdContact': _blocGetContacts
                                          .contacts![index].tokenId,
                                      'photoContact': _blocGetContacts
                                          .contacts![index].photo,
                                      'photoUser': widget.photo,
                                      'tokenIdUser': widget.tokenId,
                                      'nameContact': _blocGetContacts
                                          .contacts![index].name,
                                      'nameUser': widget.nameUser,
                                    }),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: HeaderChatUser(
                                    body:
                                        '${_blocGetContacts.contacts![index].email}',
                                    title:
                                        '${_blocGetContacts.contacts![index].name}',
                                    image: _blocGetContacts
                                        .contacts![index].photo!,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await launchUrlString(
                                      "tel://${EncryptData().decrypty(_blocGetContacts.contacts![index].phone)}");
                                },
                                child: Icon(
                                  Icons.call,
                                  color: ColorUtils.whiteColor,
                                ),
                              )
                            ],
                          ),
                          itemCount: _blocGetContacts.contacts!.length,
                          shrinkWrap: true,
                        ),
                        ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            final phoneConvert =
                                _getListContactWithoutApp()[index];
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: HeaderChatUser(
                                      body: 'Usuário não disponível',
                                      title: phoneConvert,
                                      image: null,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    await launchUrlString(
                                        "tel://$phoneConvert");
                                  },
                                  child: Icon(
                                    Icons.call,
                                    color: ColorUtils.whiteColor,
                                  ),
                                )
                              ],
                            );
                          },
                          itemCount: _getListContactWithoutApp().length,
                          shrinkWrap: true,
                        ),
                      ],
                    )),
              );
            }
            return Center(child: LoadingDesign());
          }),
    );
  }
}
