import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/constant/routes.dart';

import 'package:mynotes/firebase_options.dart';

import '../utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Enter you're email here",
                      ),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: "Enter you're password here",
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        try {
                           await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: email, password: password);
                           final user = FirebaseAuth.instance.currentUser;
                           await user?.sendEmailVerification();
                          Navigator.of(context).pushNamed(verifyEmailRoute);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                              await showErrorDialog(context,"Password is too weak");
                          } else if (e.code == 'email-already-in-use') {
                              await showErrorDialog(context,"Email is already in use");
                          } else if (e.code == 'invalid-email') {
                              await showErrorDialog(context,"Invalid email");
                          } else {
                              await showErrorDialog(context,"Something went wrong");
                          }
                        }catch(e){
                          await showErrorDialog(context,'${e.toString()}');
                        }
                      },
                      child: const Text('Register'),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute, (route) => false);
                        },
                        child: Text("Already registered? Login here"))
                  ],
                );
              default:
                return Text("Loading");
            }
          },
        ));
  }
}
