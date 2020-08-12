import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'element.dart';
import 'render.dart';

abstract class SliverPinnedPersistentHeaderDelegate {
  SliverPinnedPersistentHeaderDelegate({
    @required this.minExtentProtoType,
    @required this.maxExtentProtoType,
  })  : assert(minExtentProtoType != null),
        assert(maxExtentProtoType != null);
  final Widget minExtentProtoType;
  final Widget maxExtentProtoType;

  Widget build(BuildContext context, double shrinkOffset, double minExtent,
      double maxExtent, bool overlapsContent);

  bool shouldRebuild(
      covariant SliverPinnedPersistentHeaderDelegate oldDelegate);
}

class SliverPinnedPersistentHeader extends StatelessWidget {
  const SliverPinnedPersistentHeader({@required this.delegate});
  final SliverPinnedPersistentHeaderDelegate delegate;
  @override
  Widget build(BuildContext context) {
    return SliverPinnedPersistentHeaderRenderObjectWidget(delegate);
  }
}

class SliverPinnedPersistentHeaderRenderObjectWidget
    extends RenderObjectWidget {
  const SliverPinnedPersistentHeaderRenderObjectWidget(this.delegate);
  final SliverPinnedPersistentHeaderDelegate delegate;

  @override
  RenderObjectElement createElement() {
    return SliverPinnedPersistentHeaderElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverPinnedPersistentHeader();
  }
}

class SliverPinnedToBoxAdapter extends SingleChildRenderObjectWidget {
  /// Creates a pinned sliver that contains a single box widget.
  const SliverPinnedToBoxAdapter({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  RenderSliverPinnedToBoxAdapter createRenderObject(BuildContext context) =>
      RenderSliverPinnedToBoxAdapter();
}

class ExtendedSliverAppbar extends StatelessWidget {
  const ExtendedSliverAppbar({
    this.actions,
    this.leading,
    this.title,
    this.background,
    this.toolBarColor,
    this.onBuild,
  });
  final Widget actions;
  final Widget leading;
  final Widget title;
  final Widget background;
  final Color toolBarColor;
  final OnSliverPinnedPersistentHeaderDelegateBuild onBuild;
  @override
  Widget build(BuildContext context) {
    final SafeArea safeArea = context.findAncestorWidgetOfExactType<SafeArea>();
    double statusBarHeight = 0;
    if (safeArea == null || !safeArea.top) {
      statusBarHeight = MediaQuery.of(context).padding.top;
    }
    final Widget toolbar = SizedBox(
      height: kToolbarHeight + statusBarHeight,
    );

    return SliverPinnedPersistentHeader(
      delegate: _ExtendedSliverAppbarDelegate(
        minExtentProtoType: toolbar,
        maxExtentProtoType: background ?? toolbar,
        title: title,
        leading: leading,
        actions: actions,
        background: background,
        statusBarHeight: statusBarHeight,
      ),
    );
  }
}

class _ExtendedSliverAppbarDelegate
    extends SliverPinnedPersistentHeaderDelegate {
  _ExtendedSliverAppbarDelegate({
    @required Widget minExtentProtoType,
    @required Widget maxExtentProtoType,
    this.actions,
    this.leading,
    this.title,
    this.background,
    this.statusBarHeight,
    this.toolBarColor,
    this.onBuild,
  }) : super(
          minExtentProtoType: minExtentProtoType,
          maxExtentProtoType: maxExtentProtoType,
        );
  final Widget actions;
  final Widget leading;
  final Widget title;
  final Widget background;
  final double statusBarHeight;
  final Color toolBarColor;
  final OnSliverPinnedPersistentHeaderDelegateBuild onBuild;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    double minExtent,
    double maxExtent,
    bool overlapsContent,
  ) {
    onBuild?.call(context, shrinkOffset, minExtent, maxExtent, overlapsContent);
    final double opacity =
        (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0) as double;
    Widget titleWidget = title;
    if (titleWidget != null) {
      titleWidget = Opacity(
        opacity: opacity,
        child: titleWidget,
      );
    } else {
      titleWidget = Container();
    }
    final ThemeData theme = Theme.of(context);
    final Widget toolbar = Container(
      height: kToolbarHeight + statusBarHeight,
      padding: EdgeInsets.only(top: statusBarHeight),
      color: (toolBarColor ?? theme.primaryColor).withOpacity(opacity),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          leading ??
              const BackButton(
                onPressed: null,
              ),
          titleWidget,
          actions ?? Container(),
        ],
      ),
    );

    return Material(
      child: ClipRect(
        child: Stack(
          children: <Widget>[
            Positioned(
              child: maxExtentProtoType,
              top: -shrinkOffset,
              bottom: 0,
              left: 0,
              right: 0,
            ),
            Positioned(
              child: toolbar,
              top: 0,
              left: 0,
              right: 0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPinnedPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate.runtimeType != runtimeType) {
      return true;
    }

    return oldDelegate is _ExtendedSliverAppbarDelegate &&
        (oldDelegate.minExtentProtoType != minExtentProtoType ||
            oldDelegate.maxExtentProtoType != maxExtentProtoType ||
            oldDelegate.leading != leading ||
            oldDelegate.title != title ||
            oldDelegate.actions != actions ||
            oldDelegate.background != background ||
            oldDelegate.statusBarHeight != statusBarHeight ||
            oldDelegate.toolBarColor != toolBarColor);
  }
}

///call when shrinkOffset is changed.
typedef OnSliverPinnedPersistentHeaderDelegateBuild = void Function(
  BuildContext context,
  double shrinkOffset,
  double minExtent,
  double maxExtent,
  bool overlapsContent,
);
