import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:instagram/core/resources/color_manager.dart';
import 'package:instagram/core/resources/strings_manager.dart';
import 'package:instagram/core/resources/styles_manager.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/core/utility/injector.dart';
import 'package:instagram/domain/entities/registered_user.dart';
import 'package:instagram/presentation/cubit/firestoreUserInfoCubit/searchAboutUser/search_about_user_bloc.dart';
import 'package:instagram/presentation/pages/register/widgets/get_my_user_info.dart';
import 'package:instagram/presentation/pages/register/widgets/register_widgets.dart';
import 'package:instagram/presentation/widgets/global/custom_widgets/custom_elevated_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/functions/toast_show.dart';
import '../../../data/models/parent_classes/without_sub_classes/user_personal_info.dart';
import '../../cubit/firebaseAuthCubit/firebase_auth_cubit.dart';
import '../../cubit/firestoreUserInfoCubit/add_new_user_cubit.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for text input fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();

  // ValueNotifiers for input validation and remembering password option
  final bool validateControllers = false;
  ValueNotifier<bool> validateEmail = ValueNotifier(false);
  ValueNotifier<bool> validatePassword = ValueNotifier(false);
  ValueNotifier<bool> rememberPassword = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    // Building the SignUp page UI using RegisterWidgets
    return RegisterWidgets(
      fullNameController: fullNameController,
      customTextButton: customTextButton(),
      emailController: emailController,
      passwordController: passwordController,
      isThatLogIn: false,
      validateEmail: validateEmail,
      validatePassword: validatePassword,
      rememberPassword: rememberPassword,
    );
  }

  // Custom Text Button widget for handling sign up action
  Widget customTextButton() {
    return ValueListenableBuilder(
      valueListenable: rememberPassword,
      builder: (context, bool rememberPasswordValue, child) =>
          ValueListenableBuilder(
        valueListenable: validateEmail,
        builder: (context, bool validateEmailValue, child) =>
            ValueListenableBuilder(
          valueListenable: validatePassword,
          builder: (context, bool validatePasswordValue, child) {
            bool validate = validatePasswordValue &&
                validateEmailValue &&
                rememberPasswordValue &&
                fullNameController.text.isNotEmpty;
            return CustomElevatedButton(
              isItDone: true,
              isThatSignIn: true,
              nameOfButton: StringsManager.next.tr,
              blueColor: validate ? true : false,
              onPressed: () async {
                if (validate) {
                  // Navigate to UserNamePage upon successful validation
                  Get.to(
                    UserNamePage(
                      emailController: emailController,
                      passwordController: passwordController,
                      fullNameController: fullNameController,
                    ),
                    duration: const Duration(seconds: 0),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class UserNamePage extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController fullNameController;

  const UserNamePage({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.fullNameController,
  }) : super(key: key);

  @override
  State<UserNamePage> createState() => _UserNamePageState();
}

class _UserNamePageState extends State<UserNamePage> {
  // Controller for username input field
  final userNameController = TextEditingController();

  // Boolean flags for various states
  bool isToastShowed = false;
  bool validateEdits = false;
  bool isFieldEmpty = true;
  bool isHeMovedToHome = false;

  @override
  Widget build(BuildContext context) {
    // Building the UserNamePage UI
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: isThatMobile
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: buildColumn(context),
                )
              : buildForWeb(context),
        ),
      ),
    );
  }

  // Building column layout for mobile devices
  Widget buildColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 100),
        Text(
          StringsManager.createUserName.tr,
          style:
              getMediumStyle(color: Theme.of(context).focusColor, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            StringsManager.addUserName.tr,
            style: getNormalStyle(color: ColorManager.grey, fontSize: 13),
          ),
        ),
        Text(
          StringsManager.youCanChangeUserNameLater.tr,
          style: getNormalStyle(color: ColorManager.grey, fontSize: 13),
        ),
        const SizedBox(height: 30),
        userNameTextField(context),
        customTextButton(),
      ],
    );
  }

  // Building layout for web devices
  SizedBox buildForWeb(BuildContext context) {
    return SizedBox(
      width: 352,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 0.2),
            ),
            child: buildColumn(context),
          ),
        ],
      ),
    );
  }

  // Widget for username text field
  Widget userNameTextField(BuildContext context) {
    return BlocBuilder<SearchAboutUserBloc, SearchAboutUserState>(
      bloc: BlocProvider.of<SearchAboutUserBloc>(context)
        ..add(FindSpecificUser(userNameController.text,
            searchForSingleLetter: true)),
      buildWhen: (previous, current) =>
          previous != current && current is SearchAboutUserBlocLoaded,
      builder: (context, state) {
        List<UserPersonalInfo> usersWithSameUserName = [];

        if (state is SearchAboutUserBlocLoaded) {
          usersWithSameUserName = state.users;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
              validateEdits = usersWithSameUserName.isEmpty;
              if (userNameController.text.isEmpty) {
                validateEdits = false;
                isFieldEmpty = true;
              } else {
                isFieldEmpty = false;
              }
            }));
        return customTextField(context);
      },
    );
  }

  // Custom Text Field widget for username
  Padding customTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
      child: SizedBox(
        height: isThatMobile ? null : 37,
        width: double.infinity,
        child: TextField(
          controller: userNameController,
          cursorColor: ColorManager.teal,
          style:
              getNormalStyle(color: Theme.of(context).focusColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: StringsManager.username.tr,
            hintStyle: isThatMobile
                ? getNormalStyle(color: Theme.of(context).indicatorColor)
                : getNormalStyle(color: ColorManager.black54, fontSize: 12),
            fillColor: const Color.fromARGB(48, 232, 232, 232),
            filled: true,
            focusedBorder: outlineInputBorder(),
            suffixIcon: isFieldEmpty
                ? null
                : (validateEdits ? rightIcon() : wrongIcon()),
            enabledBorder: outlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 10, vertical: isThatMobile ? 15 : 5),
            errorText: (isFieldEmpty || validateEdits)
                ? null
                : (isThatMobile ? StringsManager.thisUserNameExist.tr : null),
            errorStyle: getNormalStyle(color: ColorManager.red),
          ),
          onChanged: (value) {
            SearchAboutUserBloc.get(context).add(FindSpecificUser(
                userNameController.text,
                searchForSingleLetter: true));
          },
        ),
      ),
    );
  }

  // Icon widget for indicating a valid username
  Icon rightIcon() {
    return const Icon(Icons.check_rounded, color: ColorManager.green, size: 27);
  }

  // Icon widget for indicating an invalid username
  Widget wrongIcon() {
    return const Icon(
      Icons.close_rounded,
      color: ColorManager.red,
      size: 27,
    );
  }

  // Method for defining outline input border
  OutlineInputBorder outlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(isThatMobile ? 5.0 : 1.0),
      borderSide: BorderSide(
          color: ColorManager.lightGrey, width: isThatMobile ? 1.0 : 0.8),
    );
  }

  // Widget for custom text button handling sign-up action
  Widget customTextButton() {
    return Builder(builder: (context) {
      FireStoreAddNewUserCubit userCubit =
          FireStoreAddNewUserCubit.get(context);
      return BlocConsumer<FirebaseAuthCubit, FirebaseAuthCubitState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is CubitAuthConfirmed) {
            addNewUser(state, userCubit);
            moveToMain(state);
          } else if (state is CubitAuthFailed && !isToastShowed) {
            ToastShow.toastStateError(state.error);
          }
        },
        buildWhen: (previous, current) => previous != current,
        builder: (context, authState) {
          return CustomElevatedButton(
            isItDone: authState is! CubitAuthConfirming,
            nameOfButton: StringsManager.signUp.tr,
            blueColor: validateEdits,
            onPressed: () async {
              FirebaseAuthCubit authCubit = FirebaseAuthCubit.get(context);

              if (validateEdits) {
                setState(() => isToastShowed = false);

                await authCubit.signUp(RegisteredUser(
                  email: widget.emailController.text,
                  password: widget.passwordController.text,
                ));
              }
            },
          );
        },
      );
    });
  }

  // Method for navigating to the main screen after successful signup
  moveToMain(CubitAuthConfirmed authState) async {
    myPersonalId = authState.user.uid;

    final SharedPreferences sharePrefs = injector<SharedPreferences>();
    if (!isHeMovedToHome) {
      setState(() => isHeMovedToHome = true);

      if (myPersonalId.isNotEmpty) {
        await sharePrefs.setString("myPersonalId", myPersonalId);
        Get.offAll(GetMyPersonalInfo(myPersonalId: myPersonalId));
      } else {
        ToastShow.toast(StringsManager.somethingWrong.tr);
      }
    }
  }

  // Method for adding a new user after signup
  addNewUser(CubitAuthConfirmed authState, FireStoreAddNewUserCubit userCubit) {
    String fullName = widget.fullNameController.text;
    List<dynamic> charactersOfName = [];
    String nameOfLower = fullName.toLowerCase();

    for (int i = 0; i < nameOfLower.length; i++) {
      charactersOfName = charactersOfName + [nameOfLower.substring(0, i + 1)];
    }
    String userName = userNameController.text;
    UserPersonalInfo newUserInfo = UserPersonalInfo(
      name: fullName,
      charactersOfName: charactersOfName,
      email: authState.user.email!,
      userName: userName,
      bio: "",
      profileImageUrl: "",
      userId: authState.user.uid,
      followerPeople: const [], // Initial values
      followedPeople: const [], // Initial values
      posts: const [], // Initial values
      chatsOfGroups: const [], // Initial values
      stories: const [], // Initial values
      lastThreePostUrls: const [], // Initial values
    );
    userCubit.addNewUser(newUserInfo);
  }
}
