import 'package:flutter/material.dart';
/**
 * 媒体卡片组件-base
 */

abstract class MediaCard extends StatelessWidget {
  String imageUrl, title;
  num scope;

  MediaCard({@required this.imageUrl, this.scope, this.title});
}

class MediaCardVertical extends MediaCard {
  MediaCardVertical({String imageUrl, String title, num scope = 0, bool this.limitedTimeFree = false}) : super(imageUrl: imageUrl, title: title, scope: scope);

  bool limitedTimeFree;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AspectRatio(
              aspectRatio: 113.0 / 158.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(imageUrl),
              )),
          Positioned(
            bottom: 4,
            right: 6,
            child: scope == 0
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(scope.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 0),
                                blurRadius: 8.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              )
                            ],
                            fontSize: 12)),
                  ),
          )
        ],
      ),
      if (title != null)
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(top: 6),
            child: Text(title, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1),
          ),
        )
    ]));
  }
}
