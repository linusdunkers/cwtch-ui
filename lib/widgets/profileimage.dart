import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cwtch/themes/opaque.dart';
import 'package:provider/provider.dart';

import '../settings.dart';

class ProfileImage extends StatefulWidget {
  ProfileImage(
      {required this.imagePath,
      required this.diameter,
      required this.border,
      this.badgeCount = 0,
      required this.badgeColor,
      required this.badgeTextColor,
      this.maskOut = false,
      this.tooltip = "",
      this.badgeEdit = false});
  final double diameter;
  final String imagePath;
  final Color border;
  final int badgeCount;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool maskOut;
  final bool badgeEdit;
  final String tooltip;

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  @override
  Widget build(BuildContext context) {
    var file = new File(widget.imagePath);
    var image = Image.file(
      file,
      cacheWidth: 512,
      cacheHeight: 512,
      filterQuality: FilterQuality.medium,
      // We need some theme specific blending here...we might want to consider making this a theme level attribute
      colorBlendMode: !widget.maskOut
          ? Provider.of<Settings>(context).theme.mode == mode_dark
              ? BlendMode.softLight
              : BlendMode.darken
          : BlendMode.srcOut,
      color: Provider.of<Settings>(context).theme.portraitBackgroundColor,
      isAntiAlias: true,
      width: widget.diameter,
      height: widget.diameter,
      errorBuilder: (context, error, stackTrace) {
        // on android the above will fail for asset images, in which case try to load them the original way
        return Image.asset(widget.imagePath,
            filterQuality: FilterQuality.medium,
            // We need some theme specific blending here...we might want to consider making this a theme level attribute
            colorBlendMode: !widget.maskOut
                ? Provider.of<Settings>(context).theme.mode == mode_dark
                    ? BlendMode.softLight
                    : BlendMode.darken
                : BlendMode.srcOut,
            color: Provider.of<Settings>(context).theme.portraitBackgroundColor,
            isAntiAlias: true,
            width: widget.diameter,
            height: widget.diameter);
      },
    );

    return RepaintBoundary(
        child: Stack(children: [
      ClipOval(
          clipBehavior: Clip.antiAlias,
          child: Container(
              width: widget.diameter,
              height: widget.diameter,
              color: widget.border,
              child: Padding(
                  padding: const EdgeInsets.all(2.0), //border size
                  child: ClipOval(clipBehavior: Clip.antiAlias, child: widget.tooltip == "" ? image : Tooltip(message: widget.tooltip, child: image))))),
      Visibility(
          visible: widget.badgeEdit || widget.badgeCount > 0,
          child: Positioned(
            bottom: 0.0,
            right: 0.0,
            child: CircleAvatar(
              radius: max(10.0, widget.diameter / 6.0),
              backgroundColor: widget.badgeColor,
              child: widget.badgeEdit
                  ? Icon(
                      Icons.edit,
                      color: widget.badgeTextColor,
                    )
                  : Text(widget.badgeCount > 99 ? "99+" : widget.badgeCount.toString(), style: TextStyle(color: widget.badgeTextColor, fontSize: 8.0)),
            ),
          )),
    ]));
  }
}
