import 'package:bitsoljae/logger.dart';
import 'package:bitsoljae/notice/notice.dart';
import 'package:bitsoljae/ui_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final ScrollController _scrollController = ScrollController();
  List<Notice> _noticeList = <Notice>[];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;

  void _getNoticeList() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    List<NoticeThumbnail> newNoticeThumbnailsTopList = [];
    List<NoticeThumbnail> newNoticeThumbnailsList = [];
    (newNoticeThumbnailsTopList, newNoticeThumbnailsList, _) =
        await getNoticeList(_currentPage + 1, _pageSize)
            .onError((error, stackTrace) {
      logger.e('Failed to get notice list: $error');
      if (!mounted) {
        return (<NoticeThumbnail>[], <NoticeThumbnail>[], 0);
      }
      showDialog(
          context: context,
          builder: (context) {
            return infoDialog(
              title: '오류',
              body: '공지사항을 불러오는 중 오류가 발생했습니다. 나중에 다시 시도해주세요.',
              context: context,
            );
          });
      return (<NoticeThumbnail>[], <NoticeThumbnail>[], 0);
    });
    List<Notice> newNoticeList = [];
    if (_currentPage == 0) {
      newNoticeThumbnailsList.addAll(newNoticeThumbnailsTopList);
      newNoticeThumbnailsList.sort((a, b) => b.date.compareTo(a.date));
    }
    for (NoticeThumbnail noticeThumbnail in newNoticeThumbnailsList) {
      Notice newNotice =
          await getNotice(noticeThumbnail.id).onError((error, stackTrace) {
        logger.e('Failed to get notice: $error');
        if (!mounted) {
          return Notice.empty();
        }
        showDialog(
            context: context,
            builder: (context) {
              return infoDialog(
                title: '오류',
                body: '공지사항을 불러오는 중 오류가 발생했습니다. 나중에 다시 시도해주세요.',
                context: context,
              );
            });
        return Notice.empty();
      });
      newNoticeList.add(newNotice);
    }
    setState(() {
      _noticeList.addAll(newNoticeList);
      _currentPage++;
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _getNoticeList();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _noticeList = [];
    _currentPage = 0;
    _isLoading = false;
    _getNoticeList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _noticeList = [];
      _currentPage = 0;
      _isLoading = false;
      _getNoticeList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          '공지사항',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        )),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refresh();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              if (_noticeList.isEmpty)
                Center(
                  child: Text(
                    '공지사항을 불러오는 중입니다...',
                    style: TextStyle(
                      fontSize: 32 * getScaleWidth(context),
                    ),
                  ),
                ),
              for (Notice notice in _noticeList)
                Center(child: NoticeCard(notice: notice)),
            ],
          ),
        ),
      ),
    );
  }
}

String _getFormattedBeforeDate(String date) {
  DateTime currentDate = DateTime.now();
  List<String> splitDate =
      date.replaceAll('-', ' ').replaceAll(':', ' ').split(' ');
  int hour = int.parse(splitDate[4]);
  if (splitDate[3] == 'PM' && hour < 12) {
    hour += 12;
  }
  DateTime targetDate = DateTime(
    int.parse(splitDate[0]),
    int.parse(splitDate[1]),
    int.parse(splitDate[2]),
    hour,
    int.parse(splitDate[5]),
  );
  Duration difference = currentDate.difference(targetDate);
  if (difference.inMinutes < 1) {
    return "${difference.inSeconds}초 전";
  }
  if (difference.inHours < 1) {
    return "${difference.inMinutes}분 전";
  }
  if (difference.inDays < 1) {
    return "${difference.inHours}시간 전";
  }
  if (difference.inDays < 7) {
    return "${difference.inDays}일 전";
  }
  if (difference.inDays < 30) {
    return "${difference.inDays ~/ 7}주 전";
  }
  if (difference.inDays < 365) {
    return "${difference.inDays ~/ 30}달 전";
  }
  return "${difference.inDays ~/ 365}년 전";
}

Widget _getFormattedHtml(String html, BuildContext context,
    {List<String> attachment = const <String>[]}) {
  // dom.Element emptyElement = dom.Element.tag('div');
  String replacedString = html
      .replaceAll(r'\"', '"')
      .replaceAll('file:///', '')
      .replaceAll('/%22', '')
      .replaceAll(r'\n', '')
      .replaceAll(RegExp(r'\n+'), '\n');
  dom.Document document = parser.parse(replacedString);
  dom.Element body = document.body!;
  if (body.innerHtml == '<p><br></p>') {
    logger.d("empty html");
    if (attachment.isNotEmpty) {
      logger.d("attachment: $attachment");
      return Column(
        children: [
          for (String attach in attachment)
            Image.network(
              attach,
              fit: BoxFit.fitWidth,
            ),
        ],
      );
    } else {
      return Container();
    }
  }
  // delete all line-height style
  body.querySelectorAll('*').forEach((element) {
    element.attributes.remove('style');
  });
  // HtmlElement htmlElement = HtmlElement.empty().getAllElementFromHtml(body);
  return InkWell(
    onTap: () {
      logger.d("html: ${html.replaceAll(r'\"', '"')}");
    },
    child: Html.fromElement(documentElement: body),
    // child: htmlElement.toWidget(context),
  );
}

class NoticeCard extends StatefulWidget {
  final Notice notice;
  const NoticeCard({super.key, required this.notice});

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  // bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // _isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16.0 * getScaleWidth(context),
        bottom: 16.0 * getScaleWidth(context),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black12,
            width: 1.0 * getScaleWidth(context),
          ),
        ),
        width: 1040 * getScaleWidth(context),
        child: Column(
          children: [
            yMargin(16, context),
            SizedBox(
              height: 55 * getScaleWidth(context),
              child: Container(
                width: 1000 * getScaleWidth(context),
                padding: EdgeInsets.all(8.0 * getScaleWidth(context)),
                child: Text(
                  widget.notice.title,
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            SizedBox(
              height: 55 * getScaleWidth(context),
              child: Container(
                width: 1000 * getScaleWidth(context),
                padding: EdgeInsets.all(8.0 * getScaleWidth(context)),
                child: Text(
                  "${widget.notice.author} · ${_getFormattedBeforeDate(widget.notice.date)} · 조회수 ${widget.notice.views}",
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.black87,
                      ),
                ),
              ),
            ),
            yMargin(32, context),
            Padding(
              padding: EdgeInsets.all(40 * getScaleWidth(context)),
              child: _getFormattedHtml(
                widget.notice.content,
                context,
                attachment: widget.notice.attachments,
              ),
            ),
            yMargin(16, context),
            // TextButton(
            //     onPressed: () {
            //       setState(() {
            //         _isExpanded = !_isExpanded;
            //       });
            //     },
            //     child: Text(_isExpanded ? '접기' : '펼치기')),
          ],
        ),
      ),
    );
  }
}
