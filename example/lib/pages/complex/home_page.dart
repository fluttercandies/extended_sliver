import 'dart:async';
import 'dart:math';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

@FFRoute(
  name: 'fluttercandies://homePage',
  routeName: 'HomePage',
  description: 'A complex demo with extended_sliver.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 0,
  },
)
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<PullToRefreshNotificationState> refreshKey =
      GlobalKey<PullToRefreshNotificationState>();

  StreamController<void> onBuildController = StreamController<void>.broadcast();
  StreamController<bool> followButtonController = StreamController<bool>();
  int listlength = 100;
  double maxDragOffset = 100;
  final String description =
      'This text can be short or long. It affects the final height.' *
          (Random().nextInt(3) + 1);
  bool showFollowButton = false;
  @override
  void dispose() {
    onBuildController.close();
    followButtonController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: PullToRefreshNotification(
          pullBackOnRefresh: true,
          onRefresh: onRefresh,
          key: refreshKey,
          maxDragOffset: maxDragOffset,
          child: CustomScrollView(
            ///in case,list is not full screen and remove ios Bouncing
            physics: const AlwaysScrollableClampingScrollPhysics(),
            slivers: <Widget>[
              PullToRefreshContainer(
                  (PullToRefreshScrollNotificationInfo? info) {
                final double offset = info?.dragOffset ?? 0.0;
                Widget actions = const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                );
                if (info?.refreshWidget != null) {
                  actions = const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  );
                }

                actions = Row(
                  children: <Widget>[
                    StreamBuilder<bool>(
                      stream: followButtonController.stream,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> data) {
                        //hide FollowButton
                        if (!data.data!) {
                          return Container();
                        }
                        return OutlinedButton(
                          child: const Text('Follow'),
                          style: ButtonStyle(
                            textStyle: MaterialStateProperty.all(
                              const TextStyle(color: Colors.white),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            side: MaterialStateProperty.all(
                              const BorderSide(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          onPressed: () {},
                        );
                      },
                      initialData: showFollowButton,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    actions,
                  ],
                );
                return ExtendedSliverAppbar(
                  onBuild: (
                    BuildContext context,
                    double shrinkOffset,
                    double? minExtent,
                    double maxExtent,
                    bool overlapsContent,
                  ) {
                    if (shrinkOffset > 0) {
                      onBuildController.sink.add(null);
                    }
                  },
                  title: const Text(
                    'ExtendedSliverAppbar',
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: const BackButton(
                    onPressed: null,
                    color: Colors.white,
                  ),
                  background: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                            child: Image.asset(
                          'assets/cypridina.jpeg',
                          fit: BoxFit.cover,
                        )),
                        Padding(
                          padding: EdgeInsets.only(
                            top: kToolbarHeight + statusBarHeight,
                            bottom: 20,
                          ),
                          child: Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  height: offset,
                                ),
                                Image.asset(
                                  'assets/flutter_candies_logo.png',
                                  height: 100,
                                  width: 100,
                                ),
                                const Text(
                                  'ExtendedSliverAppbar',
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, bottom: 5),
                                  child: FollowButton(
                                    onBuildController,
                                    followButtonController,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  actions: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: actions,
                  ),
                );
              }),
              //pinned box
              SliverPinnedToBoxAdapter(
                child: Container(
                  color: Colors.yellow,
                  height: 200.0,
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
                            '${listlength - index}',
                          ),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(50),
                        ),
                      ),
                    );
                  },
                  childCount: listlength,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
          refreshKey.currentState!.show(
            notificationDragOffset: maxDragOffset,
          );
        },
      ),
    );
  }

  Future<bool> onRefresh() {
    return Future<bool>.delayed(const Duration(seconds: 2), () {
      setState(() {
        listlength += 10;
      });
      return true;
    });
  }
}

class FollowButton extends StatefulWidget {
  const FollowButton(this.onBuildController, this.followButtonController);
  final StreamController<void> onBuildController;
  final StreamController<bool> followButtonController;
  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool showFollowButton = false;
  @override
  void initState() {
    super.initState();
    widget.onBuildController.stream.listen((_) {
      if (mounted) {
        final double statusBarHeight = MediaQuery.of(context).padding.top;
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset position = renderBox.localToGlobal(Offset.zero);
        final bool show = position.dy + renderBox.size.height <
            statusBarHeight + kToolbarHeight;
        if (showFollowButton != show) {
          showFollowButton = show;
          widget.followButtonController.sink.add(showFollowButton);
        }
        //print('${position.dy + renderBox.size.height} ----- ${statusBarHeight + kToolbarHeight}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      //MaterialTapTargetSize.padded min 48
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: OutlinedButton(
        child: const Text('Follow'),
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          side: MaterialStateProperty.all(
            const BorderSide(
              color: Colors.orange,
            ),
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}
