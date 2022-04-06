// Originally from linkify: https://github.com/Cretezy/linkify/blob/dfb3e43b0e56452bad584ddb0bf9b73d8db0589f/lib/src/url.dart
//
// Removed handling of `removeWWW` and `humanize`.
// Removed auto-appending of `http(s)://` to the readable url
//
// MIT License
//
// Copyright (c) 2019 Charles-William Crete
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:cwtch/config.dart';

import 'linkify.dart';

final _urlRegex = RegExp(
  r'^(.*?)((?:https?:\/\/|www\.)[^\s/$.?#].[^\s]*)',
  caseSensitive: false,
  dotAll: true,
);

final _looseUrlRegex = RegExp(
  r'^(.*?)((https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*))',
  caseSensitive: false,
  dotAll: true,
);

final _protocolIdentifierRegex = RegExp(
  r'^(https?:\/\/)',
  caseSensitive: false,
);

class Formatter {
  final RegExp expression;
  final LinkifyElement Function(String) element;

  Formatter(this.expression, this.element);
}

// regex to match **bold**
final _boldRegex = RegExp(
  r'^(.*?)(\*\*([^*]*)\*\*)',
  caseSensitive: false,
  dotAll: true,
);

// regex to match *italic*
final _italicRegex = RegExp(
  r'^(.*?)(\*([^*]*)\*)',
  caseSensitive: false,
  dotAll: true,
);

// regex to match ^superscript^
final _superRegex = RegExp(
  r'^(.*?)(\^([^\^]*)\^)',
  caseSensitive: false,
  dotAll: true,
);

// regex to match ^subscript^
final _subRegex = RegExp(
  r'^(.*?)(\_([^\_]*)\_)',
  caseSensitive: false,
  dotAll: true,
);

// regex to match ~~strikethrough~~
final _strikeRegex = RegExp(
  r'^(.*?)(\~\~([^\~]*)\~\~)',
  caseSensitive: false,
  dotAll: true,
);

// regex to match `code`
final _codeRegex = RegExp(
  r'^(.*?)(\`([^\`]*)\`)',
  caseSensitive: false,
  dotAll: true,
);

class UrlLinkifier extends Linkifier {
  const UrlLinkifier();

  List<LinkifyElement> replaceAndParse(tle, TextElement element, RegExpMatch match, List<LinkifyElement> list, options) {
    final text = element.text.replaceFirst(match.group(0)!, '');

    if (match.group(1)?.isNotEmpty == true) {
      list.addAll(parse([TextElement(match.group(1)!)], options));
    }

    if (match.group(2)?.isNotEmpty == true) {
      list.add(tle(match.group(2)!));
    }

    if (text.isNotEmpty) {
      list.addAll(parse([TextElement(text)], options));
    }
    return list;
  }

  List<LinkifyElement> parseFormatting(element, options) {
    var list = <LinkifyElement>[];

    // code -> bold -> italic -> super -> sub -> strike
    // not we don't currently allow combinations of these elements the first
    // one to match a given set will be the only style applied - this will be fixed
    final formattingPrecedence = [
      Formatter(_codeRegex, CodeElement.new),
      Formatter(_boldRegex, BoldElement.new),
      Formatter(_italicRegex, ItalicElement.new),
      Formatter(_superRegex, SuperElement.new),
      Formatter(_subRegex, SubElement.new),
      Formatter(_strikeRegex, StrikeElement.new)
    ];

    // Loop through the formatters in with precedence and break when something is found...
    for (var formatter in formattingPrecedence) {
      var formattingMatch = formatter.expression.firstMatch(element.text);
      if (formattingMatch != null) {
        list = replaceAndParse(formatter.element, element, formattingMatch, list, options);
        break;
      }
    }

    // catch all case where we didn't match anything and so need to return back
    // the unformatted text
    // conceptually this is Formatter((.*), TextElement.new)
    if (list.isEmpty) {
      list.add(element);
    }

    return list;
  }

  @override
  List<LinkifyElement> parse(elements, options) {
    var list = <LinkifyElement>[];

    elements.forEach((element) {
      if (element is TextElement) {
        if (options.parseLinks == false && options.messageFormatting == false) {
          list.add(element);
        } else if (options.parseLinks == true) {
          // check if there is a link...
          var match = options.looseUrl ? _looseUrlRegex.firstMatch(element.text) : _urlRegex.firstMatch(element.text);

          // if not then we only have to consider formatting...
          if (match == null) {
            // only do formatting if message formatting is enabled
            if (options.messageFormatting == false) {
              list.add(element);
            } else {
              // add all the formatting elements contained in this text
              list.addAll(parseFormatting(element, options));
            }
          } else {
            final text = element.text.replaceFirst(match.group(0)!, '');

            if (match.group(1)?.isNotEmpty == true) {
              // we match links first and the feed everything before the link
              // back through the parser
              list.addAll(parse([TextElement(match.group(1)!)], options));
            }

            if (match.group(2)?.isNotEmpty == true) {
              var originalUrl = match.group(2)!;
              String? end;

              if ((options.excludeLastPeriod) && originalUrl[originalUrl.length - 1] == ".") {
                end = ".";
                originalUrl = originalUrl.substring(0, originalUrl.length - 1);
              }

              var url = originalUrl;

              // If protocol has not been specified then append a protocol
              // to the start of the URL so that it can be opened...
              if (!url.startsWith("https://") && !url.startsWith("http://")) {
                url = "https://" + url;
              }

              list.add(UrlElement(url, originalUrl));

              if (end != null) {
                list.add(TextElement(end));
              }
            }

            if (text.isNotEmpty) {
              list.addAll(parse([TextElement(text)], options));
            }
          }
        } else if (options.messageFormatting == true) {
          // we can jump straight to message formatting...
          list.addAll(parseFormatting(element, options));
        } else {
          // unreachable - if we get here then there is something wrong in the above logic since every combination of
          // formatting options should have already been accounted for.
          EnvironmentConfig.debugLog("'unreachable' code path in formatting has been triggered. this is very likely a bug - please report $options");
        }
      }
    });

    return list;
  }
}

/// Represents an element containing a link
class UrlElement extends LinkableElement {
  UrlElement(String url, [String? text]) : super(text, url);

  @override
  String toString() {
    return "LinkElement: '$url' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) => other is UrlElement && super.equals(other);
}
