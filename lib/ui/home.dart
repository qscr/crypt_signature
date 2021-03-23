import 'package:api_event/api_event.dart';
import 'package:crypt_signature/bloc/native.dart';
import 'package:flutter/material.dart';

import 'certificates.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Event<bool> csp = new Event<bool>();

  @override
  void initState() {
    _initCSP();
    super.initState();
  }

  _initCSP() async {
    bool result = await Native.initCSP();
    csp.publish(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Подпись",
            style: TextStyle(color: Colors.black),
          ),
          leading: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "Назад",
                  maxLines: 1,
                  style: TextStyle(color: Colors.redAccent),
                )),
          ),
        ),
      ),
      body: StreamBuilder<bool>(
          stream: csp.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              );

            return snapshot.data
                ? Certificates()
                : Center(child: Text("Не удалось инициализировать провайдер"));
          }),
    );
  }
}
