import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

// http://www.nlotto.co.kr/common.do?method=getLottoNumber&drwNo=825

/*
{
  "totSellamnt": 82890578000,
  "returnValue": "success",
  "drwNoDate": "2018-09-22",
  "firstWinamnt": 1658710563,
  "drwtNo6": 38,
  "drwtNo4": 31,
  "firstPrzwnerCo": 12,
  "drwtNo5": 33,
  "bnusNo": 42,
  "firstAccumamnt": 19904526756,
  "drwNo": 825,
  "drwtNo2": 15,
  "drwtNo3": 21,
  "drwtNo1": 8
}
*/

const baseUrl = "http://www.nlotto.co.kr/common.do";

class LottoInfo {
 DateTime lotteryDate;
 int drwtNo1;
 int drwtNo2;
 int drwtNo3;
 int drwtNo4;
 int drwtNo5;
 int drwtNo6;
 int round;

  LottoInfo([this.lotteryDate, this.drwtNo1, this.drwtNo2, this.drwtNo3, this.drwtNo4, this.drwtNo5, this.drwtNo6, this.round ]);
  
  LottoInfo.origin(){
lotteryDate=DateTime.parse("1000-01-01");
drwtNo1=0;
drwtNo2=0;
drwtNo3=0;
drwtNo4=0;
drwtNo5=0;
drwtNo6=0;
round=0;
  }

  LottoInfo.fromJson(Map<String, dynamic> json) :
          lotteryDate = json['drwNoDate'],
          drwtNo1 = json['drwtNo1'],
          drwtNo2 = json['drwtNo2'],
          drwtNo3 = json['drwtNo3'],
          drwtNo4 = json['drwtNo4'],
          drwtNo5 = json['drwtNo5'],
          drwtNo6 = json['drwtNo6'],
          round = json['drwNo'] {
              print('In LottoInfo.fromJson(): ($lotteryDate, $round)' );
          }
}

class LottoAPI {
  static Future getLottoNumber(int round) {
    var url = baseUrl + "/users";
    return http.get(url);
  }
}