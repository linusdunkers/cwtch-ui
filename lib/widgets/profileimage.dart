import 'package:flutter/material.dart';
import 'package:cwtch/opaque.dart';
import 'package:provider/provider.dart';

import '../settings.dart';

class ProfileImage extends StatefulWidget {
  ProfileImage({required this.imagePath, required this.diameter, required this.border, this.badgeCount = 0, required this.badgeColor, required this.badgeTextColor, this.maskOut = false, this.tooltip = ""});
  final double diameter;
  final String imagePath;
  final Color border;
  final int badgeCount;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool maskOut;
  final String tooltip;

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  @override
  Widget build(BuildContext context) {
    var image = Image(
      image: AssetImage("assets/" + widget.imagePath),
      filterQuality: FilterQuality.medium,
      // We need some theme specific blending here...we might want to consider making this a theme level attribute
      colorBlendMode: !widget.maskOut
          ? Provider.of<Settings>(context).theme.identifier() == "dark"
          ? BlendMode.softLight
          : BlendMode.darken
          : BlendMode.srcOut,
      color: Provider.of<Settings>(context).theme.backgroundHilightElementColor(),
      isAntiAlias: true,
      width: widget.diameter,
      height: widget.diameter,
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
                  child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: widget.tooltip == "" ? image : Tooltip(
                        message: widget.tooltip,
                        child: image))))),
      Visibility(
          visible: widget.badgeCount > 0,
          child: Positioned(
            bottom: 0.0,
            right: 0.0,
            child: CircleAvatar(
              radius: 10.0,
              backgroundColor: widget.badgeColor,
              child: Text(widget.badgeCount > 99 ? "99+" : widget.badgeCount.toString(), style: TextStyle(color: widget.badgeTextColor, fontSize: 8.0)),
            ),
          )),
    ]));
  }
}
