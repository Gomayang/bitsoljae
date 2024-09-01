import 'dart:convert';

import 'package:http/http.dart' as http;

class NoticeThumbnail {
  String id = "";
  String title = "";
  String date = "";
  String author = "";
  String views = "";

  NoticeThumbnail({
    required this.id,
    required this.title,
    required this.date,
    required this.author,
    required this.views,
  });

  NoticeThumbnail.fromJson(Map<String, dynamic> json)
      : id = json["seq"].toString(),
        title = json["subject"],
        date = json["regdate"],
        author = json["regname"],
        views = json["visitcnt"].toString();

  NoticeThumbnail.empty()
      : id = "",
        title = "",
        date = "",
        author = "",
        views = "";
}

class Notice {
  String id = "";
  String title = "";
  String date = "";
  String author = "";
  String views = "";
  String content = "";
  List<String> attachments = [];
  bool isTop = false;

  Notice({
    required this.id,
    required this.title,
    required this.date,
    required this.author,
    required this.views,
    required this.content,
    required this.attachments,
    required this.isTop,
  });

  Notice.empty()
      : id = "",
        title = "",
        date = "",
        author = "",
        views = "",
        content = "",
        attachments = [],
        isTop = false;
}

Future<(List<NoticeThumbnail> topList, List<NoticeThumbnail> list, int count)>
    getNoticeList(int page, int row) async {
  String url = "https://kw.happydorm.or.kr/bbs/getBbsList.kmc";
  Map<String, String> body = {
    "cPage": page.toString(),
    "rows": row.toString(),
    "bbs_locgbn": "KW",
    "bbs_id": "notice",
    "sType": "",
    "sWord": "",
  };
  http.Response response = await http.post(
    Uri.parse(url),
    body: body,
  );
  if (response.statusCode != 200) {
    return Future.error(Exception("Failed to load notice thumbnails"));
  }

  List<NoticeThumbnail> topList = [];
  List<NoticeThumbnail> list = [];

  Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));

  /*
  {
    "root": [
        {
        "topList": [],
        "list": [],
        "totalCount": [{
            "cnt": 0
        }]        
        }
    ]
  }
  */

  List<dynamic> topListJson = jsonData["root"][0]["topList"];
  List<dynamic> listJson = jsonData["root"][0]["list"];
  int count = jsonData["root"][0]["totalCount"][0]["cnt"];
  for (var item in topListJson) {
    topList.add(NoticeThumbnail.fromJson(item));
  }
  for (var item in listJson) {
    list.add(NoticeThumbnail.fromJson(item));
  }

  // logger.d("writing file to lib/notice/notice.json");
  // final File file = File("lib/notice/notice.json");
  // file.writeAsStringSync(response.body);
  // logger.d("file written to lib/notice/notice.json");
  return (topList, list, count);
}

Future<Notice> getNotice(String id) async {
  String url = "https://kw.happydorm.or.kr/bbs/getBbsView.kmc";
  Map<String, String> body = {
    "bbs_locgbn": "KW",
    "bbs_id": "notice",
    "seq": id,
  };

  http.Response response = await http.post(
    Uri.parse(url),
    body: body,
  );

  if (response.statusCode != 200) {
    return Future.error(Exception("Failed to load notice"));
  }

  Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
  Notice notice = Notice(
    id: jsonData["root"][0]["seq"].toString(),
    title: jsonData["root"][0]["subject"],
    date: jsonData["root"][0]["regdate"],
    author: jsonData["root"][0]["regname"],
    views: jsonData["root"][0]["visit_cnt"].toString(),
    content: jsonData["root"][0]["contents"],
    attachments: [],
    isTop: jsonData["root"][0]["top_flag"] == "Y",
  );

  for (int i = 1; jsonData["root"][0]["file_name$i"] != null; i++) {
    String fileUrl =
        "https://kw.happydorm.or.kr/bbs/file_Download.kmc?fileseq=$i&seq=${notice.id}&bbs_locgbn=KW&bbs_id=notice";
    notice.attachments.add(fileUrl);
  }
  return notice;
}
