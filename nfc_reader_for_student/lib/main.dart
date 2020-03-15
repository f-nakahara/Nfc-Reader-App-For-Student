import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import 'MoneyListView.dart';
import 'StudentCardAnalysis.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: '学生証プリペイドリーダー'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  var height;
  var width;
  var money;
  var history_list = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _tagRead();
  }


  _tagRead() {
    NfcManager.instance.startTagSession(onDiscovered: (NfcTag tag) async {
      NfcF nfcf = NfcF.fromTag(tag);
      if(nfcf == null){
        print("typeFではありません！");
      }
      else{
        var balance = await getBalanceData(nfcf);
        var history = await getUsingHistory(nfcf);
        setState(() {
          this.money = balance;
          this.history_list = history;
        });
      }
      NfcManager.instance.stopSession();
    });
  }

  @override
  Widget build(BuildContext context) {
  	_tagRead();
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(
              width: width,
              margin: EdgeInsets.all(10),
              child: Card(
                  color: Colors.amber,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      "学生証にスマホを近づけてください。",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                         fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
              ),
            ),
          ),
          Flexible(
            flex: 7,
            child: FutureBuilder<bool>(
              future: NfcManager.instance.isAvailable(),
              builder: (context,ss){
                if(ss.data != true){
                  return Center(child: Text("NFCが有効になっていません。\n有効後、アプリを再起動してください。"),);
                }
                else{
                  return Column(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: Center(
                          child:Text(
                            (this.money != null)?"¥$money":"",
                            style: TextStyle(
                                fontSize: 50),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 5,
                        child: Container(
                          child: ListView.builder(
                            itemCount: this.history_list.length,
                            itemBuilder: (context,index){
                              return MoneyHistroyCard(width, history_list[index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      )
    );
  }
}
