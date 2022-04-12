// Code Originally taken from https://github.com/Cretezy/flutter_linkify/blob/201e147e0b07b7ca5c543da8167d712d81760753/lib/flutter_linkify.dart
//
// Now uses local `linkify`
//
// Original License for this code:
// MIT License
//     Copyright (c) 2020 Charles-William Crete
//
//     Permission is hereby granted, free of charge, to any person obtaining a copy
//     of this software and associated documentation files (the "Software"), to deal
//     in the Software without restriction, including without limitation the rights
//     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//     copies of the Software, and to permit persons to whom the Software is
//     furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice shall be included in all
//     copies or substantial portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//     SOFTWARE.

import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'linkify.dart';

export 'linkify.dart' show LinkifyElement, LinkifyOptions, LinkableElement, TextElement, Linkifier, UrlElement, UrlLinkifier;

/// Callback clicked link
typedef LinkCallback = void Function(LinkableElement link);

/// Turns URLs into links
class Linkify extends StatelessWidget {
  /// Text to be linkified
  final String text;

  /// Linkifiers to be used for linkify
  final List<Linkifier> linkifiers;

  /// Callback for tapping a link
  final LinkCallback? onOpen;

  /// linkify's options.
  final LinkifyOptions options;

  // TextSpan

  /// Style for non-link text
  final TextStyle? style;

  /// Style of link text
  final TextStyle? linkStyle;

  // Text.rich

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// Text direction of the text
  final TextDirection? textDirection;

  /// The maximum number of lines for the text to span, wrapping if necessary
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The number of font pixels for each logical pixel
  final double textScaleFactor;

  /// Whether the text should break at soft line breaks.
  final bool softWrap;

  /// The strut style used for the vertical layout
  final StrutStyle? strutStyle;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale
  final Locale? locale;

  /// Defines how to measure the width of the rendered text.
  final TextWidthBasis textWidthBasis;

  /// Defines how the paragraph will apply TextStyle.height to the ascent of the first line and descent of the last line.
  final TextHeightBehavior? textHeightBehavior;

  const Linkify({
    Key? key,
    required this.text,
    this.linkifiers = defaultLinkifiers,
    this.onOpen,
    this.options = const LinkifyOptions(),
    // TextSpan
    this.style,
    this.linkStyle,
    // RichText
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.softWrap = true,
    this.strutStyle,
    this.locale,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final elements = linkify(
      text,
      options: options,
      linkifiers: linkifiers,
    );

    return Text.rich(
      buildTextSpan(
        elements,
        style: Theme.of(context).textTheme.bodyText2?.merge(style),
        onOpen: onOpen,
        useMouseRegion: true,
        linkStyle: Theme.of(context)
            .textTheme
            .bodyText2
            ?.merge(style)
            .copyWith(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            )
            .merge(linkStyle),
      ),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      softWrap: softWrap,
      strutStyle: strutStyle,
      locale: locale,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// Turns URLs into links
class SelectableLinkify extends StatelessWidget {
  /// Text to be linkified
  final String text;

  /// The number of font pixels for each logical pixel
  final textScaleFactor;

  /// Linkifiers to be used for linkify
  final List<Linkifier> linkifiers;

  /// Callback for tapping a link
  final LinkCallback? onOpen;

  /// linkify's options.
  final LinkifyOptions options;

  // TextSpan

  /// Style for code text
  final TextStyle? codeStyle;

  /// Style for non-link text
  final TextStyle? style;

  /// Style of link text
  final TextStyle? linkStyle;

  // Text.rich

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// Text direction of the text
  final TextDirection? textDirection;

  /// The minimum number of lines to occupy when the content spans fewer lines.
  final int? minLines;

  /// The maximum number of lines for the text to span, wrapping if necessary
  final int? maxLines;

  /// The strut style used for the vertical layout
  final StrutStyle? strutStyle;

  /// Defines how to measure the width of the rendered text.
  final TextWidthBasis? textWidthBasis;

  // SelectableText.rich

  /// Defines the focus for this widget.
  final FocusNode? focusNode;

  /// Whether to show cursor
  final bool showCursor;

  /// Whether this text field should focus itself if nothing else is already focused.
  final bool autofocus;

  /// Configuration of toolbar options
  final ToolbarOptions? toolbarOptions;

  /// How thick the cursor will be
  final double cursorWidth;

  /// How rounded the corners of the cursor should be
  final Radius? cursorRadius;

  /// The color to use when painting the cursor
  final Color? cursorColor;

  /// Determines the way that drag start behavior is handled
  final DragStartBehavior dragStartBehavior;

  /// If true, then long-pressing this TextField will select text and show the cut/copy/paste menu,
  /// and tapping will move the text caret
  final bool enableInteractiveSelection;

  /// Called when the user taps on this selectable text (not link)
  final GestureTapCallback? onTap;

  final ScrollPhysics? scrollPhysics;

  /// Defines how the paragraph will apply TextStyle.height to the ascent of the first line and descent of the last line.
  final TextHeightBehavior? textHeightBehavior;

  /// How tall the cursor will be.
  final double? cursorHeight;

  /// Optional delegate for building the text selection handles and toolbar.
  final TextSelectionControls? selectionControls;

  /// Called when the user changes the selection of text (including the cursor location).
  final SelectionChangedCallback? onSelectionChanged;

  const SelectableLinkify({
    Key? key,
    required this.text,
    this.linkifiers = defaultLinkifiers,
    this.onOpen,
    this.options = const LinkifyOptions(),
    // TextSpan
    this.style,
    this.linkStyle,
    // RichText
    this.textAlign,
    this.codeStyle,
    this.textDirection,
    this.minLines,
    this.maxLines,
    // SelectableText
    this.focusNode,
    this.textScaleFactor = 1.0,
    this.strutStyle,
    this.showCursor = false,
    this.autofocus = false,
    this.toolbarOptions,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.scrollPhysics,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.cursorHeight,
    this.selectionControls,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final elements = linkify(
      text,
      options: options,
      linkifiers: linkifiers,
    );

    return SelectableText.rich(
      buildTextSpan(
        elements,
        style: Theme.of(context).textTheme.bodyText2?.merge(style),
        codeStyle: Theme.of(context).textTheme.bodyText2?.merge(codeStyle),
        onOpen: onOpen,
        linkStyle: Theme.of(context)
            .textTheme
            .bodyText2
            ?.merge(style)
            .copyWith(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            )
            .merge(linkStyle),
      ),
      textAlign: textAlign,
      textDirection: textDirection,
      minLines: minLines,
      maxLines: maxLines,
      focusNode: focusNode,
      strutStyle: strutStyle,
      showCursor: showCursor,
      textScaleFactor: textScaleFactor,
      autofocus: autofocus,
      toolbarOptions: toolbarOptions,
      cursorWidth: cursorWidth,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      dragStartBehavior: dragStartBehavior,
      enableInteractiveSelection: enableInteractiveSelection,
      onTap: onTap,
      scrollPhysics: scrollPhysics,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      cursorHeight: cursorHeight,
      selectionControls: selectionControls,
      onSelectionChanged: onSelectionChanged,
    );
  }
}

class LinkableSpan extends WidgetSpan {
  LinkableSpan({
    required MouseCursor mouseCursor,
    required InlineSpan inlineSpan,
  }) : super(
          child: MouseRegion(
            cursor: mouseCursor,
            child: Text.rich(
              inlineSpan,
            ),
          ),
        );
}

/// Raw TextSpan builder for more control on the RichText
TextSpan buildTextSpan(
  List<LinkifyElement> elements, {
  TextStyle? style,
  TextStyle? linkStyle,
  TextStyle? codeStyle,
  LinkCallback? onOpen,
  bool useMouseRegion = false,
}) {
  return TextSpan(
    children: elements.map<InlineSpan>(
      (element) {
        if (element is LinkableElement) {
          if (useMouseRegion) {
            return TooltipSpan(
                message: element.url,
                inlineSpan: LinkableSpan(
                  mouseCursor: SystemMouseCursors.click,
                  inlineSpan: TextSpan(text: element.text, style: linkStyle, recognizer: onOpen != null ? (TapGestureRecognizer()..onTap = () => onOpen(element)) : null, semanticsLabel: element.text),
                ));
          } else {
            return TooltipSpan(
                message: element.url,
                inlineSpan: TextSpan(
                  text: element.text,
                  style: linkStyle,
                  recognizer: onOpen != null ? (TapGestureRecognizer()..onTap = () => onOpen(element)) : null,
                ));
          }
        } else if (element is BoldElement) {
          return TextSpan(text: element.text.replaceAll("*", ""), style: style?.copyWith(fontWeight: FontWeight.bold), semanticsLabel: element.text);
        } else if (element is ItalicElement) {
          return TextSpan(text: element.text.replaceAll("*", ""), style: style?.copyWith(fontStyle: FontStyle.italic), semanticsLabel: element.text);
        } else if (element is SuperElement) {
          return WidgetSpan(
              child: Transform.translate(
            offset: const Offset(2, -6),
            child: Text(element.text.replaceAll("^", ""),
                //superscript is usually smaller in size
                textScaleFactor: 0.7,
                style: style,
                semanticsLabel: element.text),
          ));
        } else if (element is SubElement) {
          return WidgetSpan(
              child: Transform.translate(
            offset: const Offset(2, 4),
            child: Text(element.text.replaceAll("_", ""),
                //superscript is usually smaller in size
                textScaleFactor: 0.7,
                style: style,
                semanticsLabel: element.text),
          ));
        } else if (element is StrikeElement) {
          return TextSpan(
              text: element.text.replaceAll("~~", ""),
              style: style?.copyWith(decoration: TextDecoration.lineThrough, decorationColor: style.color, decorationStyle: TextDecorationStyle.solid),
              semanticsLabel: element.text);
        } else if (element is CodeElement) {
          return TextSpan(
              text: element.text.replaceAll("\`", ""),
              // monospace fonts at the same size as regular text makes them appear
              // slightly larger, so we compensate by making them slightly smaller...
              style: codeStyle?.copyWith(fontFamily: "RobotoMono", fontSize: codeStyle.fontSize! - 1.5),
              semanticsLabel: element.text);
        } else {
          return TextSpan(
            text: element.text,
            style: style,
          );
        }
      },
    ).toList(),
  );
}

// Show a tooltip over an inlined element in a Rich Text widget.
class TooltipSpan extends WidgetSpan {
  TooltipSpan({
    required String message,
    required InlineSpan inlineSpan,
  }) : super(
          child: Tooltip(
            message: message,
            child: Text.rich(
              inlineSpan,
            ),
          ),
        );
}
