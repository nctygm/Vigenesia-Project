import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vigenesiaproject/constant/const.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vigenesiaproject/screens/mainscreen.dart';
import 'Register.dart';
import 'mainscreen.dart';
import 'package:vigenesiaproject/Models/Login_Model.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? nama;
  String? iduser;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  Future<LoginModels?> postLogin(String email, String password) async {
    var dio = Dio();
    String baseurl = url;

    Map<String, dynamic> data = {"email": email, "password": password};
    try {
      final response = await dio.post("$baseurl/api/login/",
          data: data,
          options: Options(headers: {'Content-type': 'application/json'}));

      print("Respon -> ${response.data} + ${response.statusCode}");

      if (response.statusCode == 200) {
        final loginModel = LoginModels.fromJson(response.data);

        return loginModel;
      }
    } catch (e) {
      print("Failed To Load $e");
    }
  }

  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passworcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text('Login Area',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                  SizedBox(height: 50),
                  Center(
                    child: Form(
                      // key: _fbKey,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: Column(
                          children: [
                            FormBuilderTextField(
                              name: 'email',
                              controller: emailcontroller,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10),
                                  border: OutlineInputBorder(),
                                  labelText: "E mail"),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            FormBuilderTextField(
                              obscureText: true,
                              name: 'password',
                              controller: passworcontroller,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10),
                                  border: OutlineInputBorder(),
                                  labelText: "Password"),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: 'Dont Have Account?',
                                  style: TextStyle(color: Colors.black54)),
                              TextSpan(
                                  text: 'Sign Up',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  new Register()));
                                    },
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueAccent,
                                  )),
                            ])),
                            SizedBox(
                              height: 40,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await postLogin(emailcontroller.text,
                                          passworcontroller.text)
                                      .then((value) => {
                                            if (value != null)
                                              {
                                                setState(() {
                                                  nama = value.data.nama;
                                                  iduser = value.data.iduser;
                                                  print(
                                                      'ini data id ----->${iduser}');
                                                  Navigator.pushReplacement(
                                                      context,
                                                      new MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  comtext) =>
                                                              new mainscreen(
                                                                iduser:
                                                                    '${iduser}',
                                                                nama: '${nama}',
                                                              )));
                                                })
                                              }
                                            else if (value == null)
                                              {
                                                Flushbar(
                                                  message:
                                                      "Check yout Email/Paswword",
                                                  duration:
                                                      Duration(seconds: 5),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  flushbarPosition:
                                                      FlushbarPosition.TOP,
                                                ).show(context)
                                              }
                                          });
                                },
                                child: Text('Sin In'),
                              ),
                            )

                            ///disini belum
                          ],
                        ),
                      ),
                    ),
                  )
                ])),
          ),
        ),
      ),
    );
  }
}
