import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/config/routes/app_routes.dart';
import 'package:instagram/core/resources/color_manager.dart';
import 'package:instagram/core/resources/styles_manager.dart';
import 'package:instagram/data/models/user_personal_info.dart';
import 'package:instagram/domain/entities/calling_status.dart';
import 'package:instagram/presentation/cubit/callingRooms/calling_rooms_cubit.dart';
import 'package:instagram/presentation/cubit/firestoreUserInfoCubit/user_info_cubit.dart';
import 'package:instagram/presentation/pages/messages/video_call_page.dart';

class CallingRingingPage extends StatefulWidget {
  final String channelId;
  final VoidCallback clearMoving;
  const CallingRingingPage(
      {Key? key, required this.channelId, required this.clearMoving})
      : super(key: key);

  @override
  State<CallingRingingPage> createState() => _CallingRingingPageState();
}

class _CallingRingingPageState extends State<CallingRingingPage> {
  bool pop = false;
  @override
  void dispose() {
    widget.clearMoving();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.grey,
      body: SafeArea(
        child: BlocBuilder<CallingRoomsCubit, CallingRoomsState>(
          bloc: CallingRoomsCubit.get(context)
            ..getUsersInfoInThisRoom(channelId: widget.channelId),
          builder: (context, state) {
            if (pop) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => pop = false);
                Navigator.of(context).maybePop();
              });
            }
            if (state is UsersInfoInRoomLoaded) {
              return callingLoadingPage(state.usersInfo[0], context);
            } else {
              return Center(
                  child: Text(
                "Waiting...",
                style: getNormalStyle(color: ColorManager.white),
              ));
            }
          },
        ),
      ),
    );
  }

  Widget callingLoadingPage(
      UserInfoInCallingRoom userInfo, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(height: 100),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userInfo.profileImageUrl),
            ),
            const SizedBox(height: 30),
            Text(userInfo.name,
                style: getNormalStyle(color: ColorManager.white, fontSize: 25)),
            const SizedBox(height: 10),
            Text('Calling...',
                style:
                    getNormalStyle(color: ColorManager.white, fontSize: 16.5)),
          ],
        ),
        const Spacer(),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              onTap: () async {
                UserPersonalInfo myPersonalInfo =
                    UserInfoCubit.getMyPersonalInfo(context);
                await CallingRoomsCubit.get(context)
                    .cancelJoiningToRoom(userId: myPersonalInfo.userId);
                if (!mounted) return;
                Navigator.of(context).maybePop();
              },
              child: const CircleAvatar(
                radius: 32,
                backgroundColor: ColorManager.red,
                child: Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                UserPersonalInfo myPersonalInfo =
                    UserInfoCubit.getMyPersonalInfo(context);
                await CallingRoomsCubit.get(context).joinToRoom(
                    channelId: widget.channelId, userInfo: myPersonalInfo);
                if (!mounted) return;

                await pushToPage(
                  context,
                  page: CallPage(
                    channelName: widget.channelId,
                    role: ClientRole.Broadcaster,
                    userInfo: userInfo,
                    userCallingType: UserCallingType.receiver,
                  ),
                  withoutRoot: false,
                );
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => setState(() => pop = true));
              },
              child: const CircleAvatar(
                radius: 32,
                backgroundColor: ColorManager.green,
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 35.0,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}