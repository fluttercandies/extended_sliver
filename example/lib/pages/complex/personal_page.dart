import 'dart:math';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

@FFRoute(
  name: 'fluttercandies://personalPage',
  routeName: 'personal',
  description: 'how to use extended_sliver in ',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 0,
  },
)
class PersonalPage extends StatefulWidget {
  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final GlobalKey<PullToRefreshNotificationState> refreshKey =
      GlobalKey<PullToRefreshNotificationState>();
  final GlobalKey<State> followButtonKey = GlobalKey<State>();
  int listlength = 100;
  double maxDragOffset = 100;
  final String description =
      'This text maybe short or long. It will affect the actual max height.' *
          (Random().nextInt(2) + 1);
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
                  (PullToRefreshScrollNotificationInfo info) {
                final double offset = info?.dragOffset ?? 0.0;
                Widget refreshWiget = Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                );
                if (info?.refreshWiget != null) {
                  refreshWiget = SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  );
                }
                return ExtendedSliverAppbar(
                  onBuild: (
                    BuildContext context,
                    double shrinkOffset,
                    double minExtent,
                    double maxExtent,
                    bool overlapsContent,
                  ) {
                    try {
                      final RenderBox renderBox = followButtonKey.currentContext
                          .findRenderObject() as RenderBox;
                      final Offset position =
                          renderBox.localToGlobal(Offset.zero);
                      print(position.dy + renderBox.size.height <
                          statusBarHeight + kToolbarHeight);
                    } catch (e) {}
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    OutlineButton(
                                      child: const Text('Follow'),
                                      textColor: Colors.white,
                                      borderSide:
                                          BorderSide(color: Colors.orange),
                                      onPressed: () {},
                                    ),
                                    OutlineButton(
                                      child: const Text('Follow'),
                                      textColor: Colors.white,
                                      borderSide:
                                          BorderSide(color: Colors.orange),
                                      onPressed: () {},
                                    )
                                  ],
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
                    child: refreshWiget,
                  ),
                );
              }),
              SliverToBoxAdapter(
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
        child: Icon(Icons.refresh),
        onPressed: () {
          refreshKey.currentState.show(
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
