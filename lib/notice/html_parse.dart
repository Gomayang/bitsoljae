import 'package:bitsoljae/ui_manager.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

class HtmlElement {
  String? tag;
  String? text;
  String? src;
  List<HtmlElement> children = [];
  HtmlStyle? style;

  HtmlElement({this.tag, this.text, required this.children, this.style});

  HtmlElement.empty() {
    tag = null;
    text = null;
    src = null;
    children = [];
    style = null;
  }

  HtmlElement getAllElementFromHtml(dom.Element element) {
    HtmlElement htmlElement = HtmlElement.empty();
    htmlElement.tag = element.localName;
    htmlElement.text = element.text;
    if (element.localName == 'img') {
      htmlElement.src = element.attributes['src'];
    }
    String? style = element.attributes['style'];
    if (style != null) {
      htmlElement.style = HtmlStyle.fromElement(element);
    }
    for (dom.Element child in element.children) {
      htmlElement.children.add(getAllElementFromHtml(child));
    }

    return htmlElement;
  }

  Widget toWidget(BuildContext context) {
    const exp = 2.5;
    if (children.isEmpty) {
      if (tag == 'img') {
        return Image.network(
          src!
              .replaceAll('file:///', '')
              .replaceAll('/%22', '')
              .replaceAll(r'\"', ''),
        );
      } else {
        return Text(
          text ?? "",
          style: TextStyle(
            fontSize: (style?.fontSize?.toDouble() ?? 12) *
                getScaleWidth(context) *
                exp,
            color: style?.color,
          ),
        );
      }
    } else if (children.length == 1) {
      return children[0].toWidget(context);
    } else if (tag == 'p') {
      return Column(
        children: [
          for (HtmlElement child in children)
            if (child.tag == 'img')
              Image.network(
                child.src!
                    .replaceAll('file:///', '')
                    .replaceAll('/%22', '')
                    .replaceAll(r'\"', ''),
              )
            else
              Row(
                children: [
                  if (text != null)
                    Text(
                      text ?? "",
                      style: TextStyle(
                        fontSize: (style?.fontSize?.toDouble() ?? 12) *
                            getScaleWidth(context) *
                            exp,
                        color: style?.color,
                      ),
                    ),
                  child.toWidget(context),
                ],
              ),
        ],
      );
    } else {
      return Row(
        children: children.map((e) => e.toWidget(context)).toList(),
      );
    }
  }
}

class HtmlStyle {
  double? fontSize;
  String? textAlign;
  Color? color;

  HtmlStyle({this.fontSize, this.textAlign, this.color});

  HtmlStyle.fromElement(dom.Element element) {
    String? style = element.attributes['style'];
    if (style != null) {
      List<String> styleList = style.split(';');
      for (String styleItem in styleList) {
        if (styleItem.contains('font-size')) {
          String fontSizeString = styleItem.split(': ')[1];
          fontSize = double.parse(
              fontSizeString.substring(0, fontSizeString.length - 2));
        }
        if (styleItem.contains('text-align')) {
          textAlign = styleItem.split(': ')[1];
        }
        if (styleItem.contains('color')) {
          String colorString = styleItem.split(': ')[1];
          // rgb(119, 119, 119)
          List<String> colorList = colorString
              .substring(4, colorString.length - 1)
              .split(', ')
              .toList();
          color = Color.fromRGBO(
            int.parse(colorList[0]),
            int.parse(colorList[1]),
            int.parse(colorList[2]),
            1.0,
          );
        }
      }
    }
  }
}
