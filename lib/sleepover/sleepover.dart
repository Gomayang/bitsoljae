import 'dart:convert';

import 'package:bitsoljae/logger.dart';
import 'package:http/http.dart' as http;

class Degree {
  String code = '';
  String name = '';
  bool passed = false;

  Degree({required this.code, required this.name, required this.passed});

  Degree.empty() {
    code = '';
    name = '';
    passed = false;
  }

  Degree.fromJson(Map<String, dynamic> json) {
    code = json["de_code"];
    name = json["list_kor_name"];
    passed = json["passdate_yn"] == 'Y';
  }
}

Future<List<Degree>> getDegreeList(String id, String birth) async {
  String loginUrl = 'https://kw.happydorm.or.kr/00/0000.kmc';
  var response = await http
      .get(
    Uri.parse(loginUrl),
  )
      .onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  var cookie = response.headers['set-cookie'];
  logger.d('cookie: $cookie');

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return [];
  }

  String selectUserUrl = 'https://kw.happydorm.or.kr/student/getPassList.kmc';
  response = await http.post(
    Uri.parse(selectUserUrl),
    headers: {
      'cookie': cookie!,
    },
    body: {
      'locgbn': 'KW',
      'hakbun': id,
      'birth': birth,
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return [];
  }

  logger.d('response: ${response.body}');

  List<Degree> degreeList = [];
  var json = jsonDecode(utf8.decode(response.bodyBytes));
  var degreeJsonList = json['root'] as List;
  for (var degreeJson in degreeJsonList) {
    degreeList.add(Degree.fromJson(degreeJson));
  }
  return degreeList;
}

class Sleepover {
  String id = '';
  String date = '';
  String reason = '';
  String requestDate = '';

  Sleepover(
      {required this.id,
      required this.date,
      required this.reason,
      required this.requestDate});

  Sleepover.empty() {
    id = '';
    date = '';
    reason = '';
    requestDate = '';
  }

  Sleepover.fromJson(Map<String, dynamic> json) {
    id = json['seq'];
    date = json['sl_sdate'];
    reason = json['sl_content'];
    requestDate = json['regdate'];
  }
}

Future<List<Sleepover>> getSleepoverList(
    String id, String birth, String degreeCode, int page, int row) async {
  String loginUrl = 'https://kw.happydorm.or.kr/00/0000.kmc';
  var response = await http
      .get(
    Uri.parse(loginUrl),
  )
      .onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  var cookie = response.headers['set-cookie'];
  logger.d('cookie: $cookie');

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return [];
  }

  String selectUserUrl = 'https://kw.happydorm.or.kr/student/getPassList.kmc';
  response = await http.post(
    Uri.parse(selectUserUrl),
    headers: {
      'cookie': cookie!,
    },
    body: {
      'locgbn': 'KW',
      'hakbun': id,
      'birth': birth,
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return [];
  }

  logger.d('response: ${response.body}');

  String getLoginUrl =
      'https://kw.happydorm.or.kr/00/login_list_sel.kmc?hakbun=$id&birth=$birth&de_code=$degreeCode&locgbn=KW';
  response = await http.get(
    Uri.parse(getLoginUrl),
    headers: {
      'cookie': cookie,
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 302) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return [];
  }

  String getSleepoverListUrl =
      'https://kw.happydorm.or.kr/stayout/getStayoutList.kmc';

  DateTime now = DateTime.now();
  response = await http.post(
    Uri.parse(getSleepoverListUrl),
    headers: {
      'cookie': cookie,
    },
    body: {
      'cPage': page.toString(),
      'rows': row.toString(),
      'stayout_locgbn': 'KW',
      'list_type': "mypage",
      'month': dateTimeToString(now),
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return [];
  }

  var json = jsonDecode(utf8.decode(response.bodyBytes));

  List<Sleepover> sleepoverList = [];

  var sleepoverJsonList = json['root'][0] as List;
  for (var sleepoverJson in sleepoverJsonList) {
    sleepoverList.add(Sleepover.fromJson(sleepoverJson));
  }

  return sleepoverList;
}

Future<int> addNormalSleepover(String id, String birth, String degreeCode,
    DateTime date, String reason) async {
  String loginUrl = 'https://kw.happydorm.or.kr/00/0000.kmc';
  var response = await http
      .get(
    Uri.parse(loginUrl),
  )
      .onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  var cookie = response.headers['set-cookie'];
  logger.d('cookie: $cookie');

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return response.statusCode;
  }

  String selectUserUrl = 'https://kw.happydorm.or.kr/student/getPassList.kmc';
  response = await http.post(
    Uri.parse(selectUserUrl),
    headers: {
      'cookie': cookie!,
    },
    body: {
      'locgbn': 'KW',
      'hakbun': id,
      'birth': birth,
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return response.statusCode;
  }

  logger.d('response: ${response.body}');

  String getLoginUrl =
      'https://kw.happydorm.or.kr/00/login_list_sel.kmc?hakbun=$id&birth=$birth&de_code=$degreeCode&locgbn=KW';
  response = await http.get(
    Uri.parse(getLoginUrl),
    headers: {
      'cookie': cookie,
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 302) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return response.statusCode;
  }

  String addSleepoverUrl = "https://kw.happydorm.or.kr/stayout/setStayout.kmc";

  response = await http.post(
    Uri.parse(addSleepoverUrl),
    headers: {
      'cookie': cookie,
    },
    body: {
      'list_type': 'mypage',
      'seq': '',
      'stayout_locgbn': 'KW',
      'sl_hakbun': id,
      'sl_univ': '',
      'sl_gubun': 'NORMAL',
      'sl_sdate1': dateTimeToString(date),
      'sl_sdate2': '',
      'sl_sdate3': '',
      'sl_sdate4': '',
      'sl_sdate5': '',
      'sl_sdate6': '',
      'sl_content': reason,
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return response.statusCode;
  }

  return 200;
}

// TODO: addLongSleepover

Future<int> deleteSleepover(
    String id, String birth, String degreeCode, String sleepoverCode) async {
  String loginUrl = 'https://kw.happydorm.or.kr/00/0000.kmc';
  var response = await http
      .get(
    Uri.parse(loginUrl),
  )
      .onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  var cookie = response.headers['set-cookie'];
  logger.d('cookie: $cookie');

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return response.statusCode;
  }

  String selectUserUrl = 'https://kw.happydorm.or.kr/student/getPassList.kmc';
  response = await http.post(
    Uri.parse(selectUserUrl),
    headers: {
      'cookie': cookie!,
    },
    body: {
      'locgbn': 'KW',
      'hakbun': id,
      'birth': birth,
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return response.statusCode;
  }

  logger.d('response: ${response.body}');

  String getLoginUrl =
      'https://kw.happydorm.or.kr/00/login_list_sel.kmc?hakbun=$id&birth=$birth&de_code=$degreeCode&locgbn=KW';
  response = await http.get(
    Uri.parse(getLoginUrl),
    headers: {
      'cookie': cookie,
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 302) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return response.statusCode;
  }

  String deleteSleepoverUrl =
      "https://kw.happydorm.or.kr/stayout/deleteStayout.kmc";

  response = await http.post(
    Uri.parse(deleteSleepoverUrl),
    headers: {
      'cookie': cookie,
    },
    body: {
      'seq': sleepoverCode,
      'stayout_locgbn': 'KW',
    },
  ).onError((error, stackTrace) {
    logger.e('Failed to get sleepover list: $error');
    return http.Response('', 404);
  });

  if (response.statusCode != 200) {
    logger.e('Failed to get sleepover list: ${response.statusCode}');
    return response.statusCode;
  }

  return 200;
}

String dateTimeToString(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
