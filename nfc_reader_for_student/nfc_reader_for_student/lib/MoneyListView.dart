import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget MoneyHistroyCard(width, data){
  var borderRadius = BorderRadius.all(Radius.circular(4.0));
  int money = int.parse(data[8]+data[9]+data[10]);
  String type = (data[7] == "05")?"支払":"チャージ";
  String simbol = (data[7] == "05")?"-":"+";
  String day = "${data[0]}${data[1]}/${data[2]}/${data[3]} ${data[4]}:${data[5]}";
  var color = (data[7] == "05")?Colors.red:Colors.green;

  return Container(
    width: width,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [0.02,0.02],
            colors:[color,Colors.white],
          ),
          borderRadius: borderRadius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                type,
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Text(
                        "$day"
                    ),
                  ),
                  Container(
                    child: Text(
                      "$simbol¥$money",
                      style: TextStyle(
                        fontSize: 25,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

