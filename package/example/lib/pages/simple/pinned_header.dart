import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:extended_sliver/extended_sliver.dart';

@FFRoute(
  name: 'fluttercandies://PinnedHeader',
  routeName: 'PinnedHeader',
  description: 'pinned header without minExtent and maxExtent.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class PinnedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Container(
            color: Colors.yellow,
            height: 200.0,
          ),
        ),
        SliverPinnedPersistentHeader(
          delegate: MySliverPinnedPersistentHeaderDelegate(
            minExtentProtoType: Container(
              height: 120.0,
              color: Colors.red.withOpacity(0.5),
              child: FlatButton(
                child: const Text('minProtoType'),
                onPressed: () {
                  print('minProtoType');
                },
              ),
              alignment: Alignment.topCenter,
            ),
            maxExtentProtoType: Container(
              height: 200.0,
              color: Colors.blue,
              child: FlatButton(
                child: const Text('maxProtoType'),
                onPressed: () {
                  print('maxProtoType');
                },
              ),
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1)),
                child: MaterialButton(
                  onPressed: () => debugPrint('$index'),
                  child: Container(
                    child: Text(
                      '$index',
                    ),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(50),
                  ),
                ),
              );
            },
            childCount: 100,
          ),
        ),
      ],
    );
  }
}

class MySliverPinnedPersistentHeaderDelegate
    extends SliverPinnedPersistentHeaderDelegate {
  MySliverPinnedPersistentHeaderDelegate({
    @required Widget minExtentProtoType,
    @required Widget maxExtentProtoType,
  }) : super(
          minExtentProtoType: minExtentProtoType,
          maxExtentProtoType: maxExtentProtoType,
        );
  @override
  Widget build(BuildContext context, double shrinkOffset, double minExtent,
      double maxExtent, bool overlapsContent) {
    print(shrinkOffset);
    return Stack(
      children: <Widget>[
        Positioned(
          child: maxExtentProtoType,
          top: -shrinkOffset,
          bottom: 0,
          left: 0,
          right: 0,
        ),
        Positioned(
          child: minExtentProtoType,
          top: 0,
          left: 0,
          right: 0,
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(SliverPinnedPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
