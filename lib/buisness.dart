import 'dart:math';

Random random = new Random(); //전역으로 사용된다. 다른 dart 파일에서도 참조 된다.

String get6RandNum() {
  String ret = "";
  for (var i = 6; i > 0; i--) {
    ret += " " + (random.nextInt(45) + 1).toString();
  }
  return ret;
}
