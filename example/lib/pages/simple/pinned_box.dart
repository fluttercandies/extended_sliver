import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:extended_sliver/extended_sliver.dart';

@FFRoute(
  name: 'fluttercandies://PinnedBox',
  routeName: 'PinnedBox',
  description: 'simple pinned box.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 1,
  },
)
class PinnedBox extends StatelessWidget {
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
        SliverPinnedToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.withOpacity(0.5),
            child: Column(
              children: <Widget>[
                const Text(
                    '[love]Extended text help you to build rich text quickly. any special text you will have with extended text. '
                    '\n\nIt\'s my pleasure to invite you to join \$FlutterCandies\$ if you want to improve flutter .[love]'
                    '\n\nif you meet any problem, please let me konw @zmtzawqlp .[sun_glasses]'),
                TextButton(
                  child: const Text('I\'m button. click me!'),
                  onPressed: () {
                    debugPrint('click');
                  },
                ),
              ],
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
