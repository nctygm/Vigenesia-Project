import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:vigenesiaproject/screens/EditPage.dart';
import 'package:vigenesiaproject/screens/Login.dart';
import 'package:vigenesiaproject/screens/Login.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'dart:convert';
import 'package:vigenesiaproject/Models/Motivasi_Model.dart';
import 'package:dio/dio.dart';
import 'package:vigenesiaproject/constant/const.dart';

class mainscreen extends StatefulWidget {
  final String iduser;
  final String nama;
  const mainscreen({Key? key, required this.iduser, required this.nama})
      : super(key: key);

  @override
  State<mainscreen> createState() => _mainscreenState();
}

class _mainscreenState extends State<mainscreen> {
  String baseurl = url;
  String? id;
  var dio = Dio();
  List<MotivasiModel> ass = [];
  TextEditingController titleController = TextEditingController();

  Future<dynamic> sendMotivasi(String isi) async {
    Map<String, dynamic> data = {
      "isi_motivasi": isi,
      "iduser": widget.iduser
    }; //MENAMBAHKAN ATAU MENAMPILKAN ID DAN USER DI WIDGET HOMESCREEN
    try {
      Response response = await dio.post("$baseurl/api/dev/POSTmotivasi",
          data: data,
          options: Options(contentType: Headers.formUrlEncodedContentType));
      print("Respon -> ${response.data} + ${response.statusCode}");

      return response;
    } catch (e) {
      print("Error di -> $e");
    }
  }

  List<MotivasiModel> listproduk = [];
  Future<List<MotivasiModel>> getData() async {
    var response =
        await dio.get('$baseurl/api/Get_motivasi?iduser=${widget.iduser}');

    print(" ${response.data}");
    if (response.statusCode == 200) {
      var getUsersData = response.data as List;
      var listUsers =
          getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<dynamic> deletePost(String id) async {
    dynamic data = {
      "id": id,
    };
    var response = await dio.delete('$baseurl/api/dev/DELETEmotivasi',
        data: data,
        options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {"Content-type": "application/json"}));
    print(" ${response.data}");

    var resbody = (response.data);
    return resbody;
  }

  Future<List<MotivasiModel>> getData2() async {
    var response = await dio
        .get('$baseurl/api/Get_motivasi'); //untuk mengambil data by user
    print(" ${response.data}");
    if (response.statusCode == 200) {
      var getUsersData = response.data as List;
      var listUsers =
          getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> _getData() async {
    setState(() {
      getData();
      listproduk.clear();
      showIndicator(BuildContext context) {
        return const Dialog(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    });
  }

  TextEditingController isicontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    getData();
    getData2();
    _getData();
  }

  @override
  String? trigger;
  String? triggeruser;

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Container(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: 40,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'Hallo ${widget.nama}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              TextButton(
                  child: Icon(Icons.logout),
                  onPressed: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new Login()));
                  }),
            ]),
            SizedBox(
              height: 30,
            ),
            FormBuilderTextField(
              controller: isicontroller,
              name: 'isi_motivasi',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.only(left: 10),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () async {
                  if (isicontroller.text.toString().isEmpty) {
                    Flushbar(
                      message: "Data Tidak boleh kosong",
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.redAccent,
                      flushbarPosition: FlushbarPosition.TOP,
                    ).show(context);
                  } else if (isicontroller.text.toString().isNotEmpty) {
                    await sendMotivasi(
                      isicontroller.text.toString(),
                    ).then((value) => {
                          if (value != null)
                            {
                              Flushbar(
                                message: 'Berhasil Submit',
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.greenAccent,
                                flushbarPosition: FlushbarPosition.TOP,
                              ).show(context)
                            }
                        });
                  }
                  ;
                  print("Sukses!");
                },
                child: Text('Submit'),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            TextButton(
              child: Icon(Icons.refresh),
              onPressed: () {
                _getData();
              },
            ),
            FormBuilderRadioGroup(
                onChanged: (value) {
                  setState(() {
                    trigger = value as String;
                    print("Hasilnya --> ${trigger}");
                  });
                },
                name: "_",
                options: ['Motivasi By All', 'Motivasi By User']
                    .map((e) =>
                        FormBuilderFieldOption(value: e, child: Text("${e}")))
                    .toList()),
            trigger == "Motivasi By All"
                ? FutureBuilder(
                    future: getData2(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<MotivasiModel>> snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          child: Column(
                            children: [
                              for (var item in snapshot.data!)
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      Container(child: Text(item.isiMotivasi)),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return Text("No Data");
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
                : Container(),
            trigger == 'Motivasi By User'
                ? FutureBuilder(
                    future: getData(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<MotivasiModel>> snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            for (var item in snapshot.data!)
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    Expanded(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.isiMotivasi),
                                        Row(
                                          children: [
                                            TextButton(
                                              child: Icon(Icons.settings),
                                              onPressed: () {
                                                String id;
                                                String isi_motivasi;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          EditPage(
                                                            id = item.id,
                                                            isi_motivasi: item
                                                                .isiMotivasi,
                                                            id: '${item.id}',
                                                          )),
                                                );
                                              },
                                            ),
                                            TextButton(
                                              child: Icon(Icons.delete),
                                              onPressed: () {
                                                deletePost(item.id)
                                                    .then((value) => {
                                                          if (value != null)
                                                            {
                                                              Flushbar(
                                                                message:
                                                                    "berhasil Delete",
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            2),
                                                                backgroundColor:
                                                                    Colors
                                                                        .redAccent,
                                                                flushbarPosition:
                                                                    FlushbarPosition
                                                                        .TOP,
                                                              ).show(context)
                                                            }
                                                        });
                                                _getData();
                                              },
                                            )
                                          ],
                                        )
                                      ],
                                    ))
                                  ],
                                ),
                              )
                          ],
                        );
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return Text('No Data');
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
                : Container(),
          ]),
        )),
      ),
    );
  }
}
