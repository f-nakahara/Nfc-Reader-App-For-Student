import 'dart:typed_data';
import 'package:nfc_manager/platform_tags.dart';

getBalanceData(NfcF nfcf) async {
  List<int> SYSTEM_CODE = [0xFE,0x00];
  List<int> SERVICE_CODE = [0x50,0xD7];
  int SIZE = 1;

  var poll = await _polling(SYSTEM_CODE);
  var pollingRes = await nfcf.transceive(poll);
  var targetIDm = await pollingRes.sublist(2,10);
  var req = await _readWithoutEncryption(targetIDm, SIZE, SERVICE_CODE);
  var res = await nfcf.transceive(req);
  var data = _parse(res);
  var balanceData = Uint8List.fromList([data[0][3],data[0][2],data[0][1],data[0][0]]);
  var balance = balanceData.buffer.asByteData().getInt32(0);
  return balance;
}

getUsingHistory(NfcF nfcf) async {
  List<int> SYSTEM_CODE = [0xFE,0x00];
  List<int> SERVICE_CODE = [0x50,0xCF];
  int SIZE = 10;

  var poll = await _polling(SYSTEM_CODE);
  var pollingRes = await nfcf.transceive(poll);
  var targetIDm = await pollingRes.sublist(2,10);
  var req = await _readWithoutEncryption(targetIDm, SIZE, SERVICE_CODE);
  var res = await nfcf.transceive(req);
  var data = _parse(res);
  var history = [];
  for(var i=0;i<data.length;i++){
    history.add([]);
    for(var j=0;j<data[i].length;j++){
      int val = data[i][j];
      history[i].add((val.toRadixString(16)).padLeft(2,"0"));
    }
  }
  return history;
}

getMeeaUsingHistory(NfcF nfcf) async {
  List<int> SYSTEM_CODE = [0xFE,0x00];
  List<int> SERVICE_CODE = [0x50,0xCB];
  int SIZE = 2;

  var poll = await _polling(SYSTEM_CODE);
  var pollingRes = await nfcf.transceive(poll);
  var targetIDm = await pollingRes.sublist(2,10);
  var req = await _readWithoutEncryption(targetIDm, SIZE, SERVICE_CODE);
  var res = await nfcf.transceive(req);
  var data = _parse(res);
  var history = [];
  for(var i=0;i<data.length;i++){
    history.add([]);
    for(var j=0;j<data[i].length;j++){
      int val = data[i][j];
      history[i].add(val.toRadixString(16));
    }
  }
  return history;
}

_polling (systemCode) {
  List<int> bout = [];

  bout.add(0x00);
  bout.add(0x00);
  bout.add(systemCode[0]);
  bout.add(systemCode[1]);
  bout.add(0x01);
  bout.add(0x0f);

  Uint8List msg = Uint8List.fromList(bout);
  msg[0] = msg.length;
  return msg;
}

_readWithoutEncryption(targetIDm,size,targetServiceCode) {
  List<int> bout = [];
  bout.add(0);
  bout.add(0X06);
  bout.addAll(targetIDm);
  bout.add(1);

  bout.add(targetServiceCode[1]);
  bout.add(targetServiceCode[0]);
  bout.add(size);

  for(var i=0;i<size;i++){
    bout.add(0X80);
    bout.add(i);
  }

  var msg = Uint8List.fromList(bout);
  msg[0] = msg.length;
  return msg;
}

_parse(res){
  if(res[10] != 0x00){
  }

  int size = res[12];
  var data = List.generate(size, (_) => Uint8List.fromList(List.generate(16, (_) => 0)));
  for(var i=0;i<size;i++){
    var tmp = Uint8List.fromList(List.generate(16,(_)=>0));
    int offset = 13+i*16;
    for(int j=0;j<16;j++){
      tmp[j] = res[offset+j];
    }
    data[i] = tmp;
  }
  return data;
}