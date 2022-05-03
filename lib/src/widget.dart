import 'package:flutter/material.dart';

import 'element.dart';
import 'rendering.dart';

/// Delegate for configuring a [SliverPinnedPersistentHeader].
abstract class SliverPinnedPersistentHeaderDelegate {
  SliverPinnedPersistentHeaderDelegate({
    required this.minExtentProtoType,
    required this.maxExtentProtoType,
  });

  /// The poroto type widget of min extent
  final Widget minExtentProtoType;

  /// The poroto type widget of max extent
  final Widget maxExtentProtoType;

  /// The widget to place inside the [SliverPinnedPersistentHeader].
  ///
  /// The `context` is the [BuildContext] of the sliver.
  ///
  /// The `shrinkOffset` is a distance from [maxExtent] towards [minExtent]
  /// representing the current amount by which the sliver has been shrunk. When
  /// the `shrinkOffset` is zero, the contents will be rendered with a dimension
  /// of [maxExtent] in the main axis. When `shrinkOffset` equals the difference
  /// between [maxExtent] and [minExtent] (a positive number), the contents will
  /// be rendered with a dimension of [minExtent] in the main axis. The
  /// `shrinkOffset` will always be a positive number in that range.
  ///
  /// The `overlapsContent` argument is true if subsequent slivers (if any) will
  /// be rendered beneath this one, and false if the sliver will not have any
  /// contents below it. Typically this is used to decide whether to draw a
  /// shadow to simulate the sliver being above the contents below it. Typically
  /// this is true when `shrinkOffset` is at its greatest value and false
  /// otherwise, but that is not guaranteed. See [NestedScrollView] for an
  /// example of a case where `overlapsContent`'s value can be unrelated to
  /// `shrinkOffset`.
  ///
  /// The 'minExtent'is the smallest size to allow the header to reach, when it shrinks at the
  /// start of the viewport.
  ///
  /// This must return a value equal to or less than [maxExtent].
  ///
  /// This value should not change over the lifetime of the delegate. It should
  /// be based entirely on the constructor arguments passed to the delegate. See
  /// [shouldRebuild], which must return true if a new delegate would return a
  /// different value.
  ///
  ///
  /// The `maxExtent` argument is the size of the header when it is not shrinking at the top of the
  /// viewport.
  ///
  /// This must return a value equal to or greater than [minExtent].
  ///
  /// This value should not change over the lifetime of the delegate. It should
  /// be based entirely on the constructor arguments passed to the delegate. See
  /// [shouldRebuild], which must return true if a new delegate would return a
  /// different value.
  Widget build(BuildContext context, double shrinkOffset, double? minExtent,
      double maxExtent, bool overlapsContent);

  /// Whether this delegate is meaningfully different from the old delegate.
  ///
  /// If this returns false, then the header might not be rebuilt, even though
  /// the instance of the delegate changed.
  ///
  /// This must return true if `oldDelegate` and this object would return
  /// different values for [minExtent], [maxExtent], [snapConfiguration], or
  /// would return a meaningfully different widget tree from [build] for the
  /// same arguments.
  bool shouldRebuild(
      covariant SliverPinnedPersistentHeaderDelegate oldDelegate);
}

/// A sliver whose size varies when the sliver is scrolled to the leading edge
/// of the viewport.
///
/// This is the layout primitive that [ExtendedSliverAppbar] uses for its
/// shrinking/growing effect.
class SliverPinnedPersistentHeader extends StatelessWidget {
  /// Creates a sliver that varies its size when it is scrolled to the start of
  /// a viewport.
  ///
  /// The [delegate] must not be null.
  const SliverPinnedPersistentHeader({required this.delegate});
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

/// A pinned sliver that contains a single box widget.
///
/// Slivers are special-purpose widgets that can be combined using a
/// [CustomScrollView] to create custom scroll effects. A [SliverToBoxAdapter]
/// is a basic sliver that creates a bridge back to one of the usual box-based
/// widgets.
///
/// Rather than using multiple [SliverToBoxAdapter] widgets to display multiple
/// box widgets in a [CustomScrollView], consider using [SliverList],
/// [SliverFixedExtentList], [SliverPrototypeExtentList], or [SliverGrid],
/// which are more efficient because they instantiate only those children that
/// are actually visible through the scroll view's viewport.
class SliverPinnedToBoxAdapter extends SingleChildRenderObjectWidget {
  /// Creates a pinned sliver that contains a single box widget.
  const SliverPinnedToBoxAdapter({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderSliverPinnedToBoxAdapter createRenderObject(BuildContext context) =>
      RenderSliverPinnedToBoxAdapter();
}

/// Sliver BoxAdapter for nested scrollable (like webview)
///
class SliverToNestedScrollBoxAdapter extends SingleChildRenderObjectWidget {
  /// Creates a sliver that contains a single nested scrollable box widget.
  const SliverToNestedScrollBoxAdapter({
    Key? key,
    Widget? child,
    required this.childExtent,
    required this.onScrollOffsetChanged,
  }) : super(key: key, child: child);

  final double childExtent;
  final ScrollOffsetChanged onScrollOffsetChanged;

  @override
  RenderSliverToNestedScrollBoxAdapter createRenderObject(
          BuildContext context) =>
      RenderSliverToNestedScrollBoxAdapter(
        childExtent: childExtent,
        onScrollOffsetChanged: onScrollOffsetChanged,
      );

  @override
  void updateRenderObject(BuildContext context,
      covariant RenderSliverToNestedScrollBoxAdapter renderObject) {
    renderObject.childExtent = childExtent;
    renderObject.onScrollOffsetChanged = onScrollOffsetChanged;
  }
}

/// A material design app bar that integrates with a [CustomScrollView].
/// See more [SliverPinnedPersistentHeader].
class ExtendedSliverAppbar extends StatelessWidget {
  const ExtendedSliverAppbar({
    this.leading,
    this.title,
    this.actions,
    this.background,
    this.toolBarColor,
    this.onBuild,
    this.statusbarHeight,
    this.toolbarHeight,
    this.isOpacityFadeWithToolbar = true,
    this.isOpacityFadeWithTitle = true,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  /// A widget to display before the [title].
  final Widget? leading;

  /// The primary widget displayed in the app bar.
  ///
  /// Typically a [Text] widget containing a description of the current contents
  /// of the app.
  final Widget? title;

  /// Widgets to display after the [title] widget.
  final Widget? actions;

  /// A Widget to display behind [leading],[title],[actions].
  final Widget? background;

  /// Background color for Row(leading,title,background).
  final Color? toolBarColor;

  /// Call when re-build on scroll.
  final OnSliverPinnedPersistentHeaderDelegateBuild? onBuild;

  /// Height of Toolbar. Default value : kToolbarHeight
  final double? toolbarHeight;

  /// Height of Statusbar. Default value : MediaQuery.of(context).padding.top
  final double? statusbarHeight;

  /// Whether do an opacity fade for toolbar.
  ///
  /// By default, the value of isOpacityFadeWithToolbar is true.
  final bool isOpacityFadeWithToolbar;

  /// Whether do an opacity fade for title.
  ///
  /// By default, the value of isOpacityFadeWithTitle is true.
  final bool isOpacityFadeWithTitle;

  /// MainAxisAlignment of toolbar
  ///
  /// By default, the value of mainAxisAlignment is MainAxisAlignment.spaceBetween.
  final MainAxisAlignment mainAxisAlignment;

  /// CrossAxisAlignment of toolbar
  ///
  /// By default, the value of crossAxisAlignment is CrossAxisAlignment.center.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final SafeArea? safeArea =
        context.findAncestorWidgetOfExactType<SafeArea>();
    double? statusbarHeight = this.statusbarHeight;
    final double toolbarHeight = this.toolbarHeight ?? kToolbarHeight;
    if (statusbarHeight == null && (safeArea == null || !safeArea.top)) {
      statusbarHeight = MediaQuery.of(context).padding.top;
    }
    statusbarHeight ??= 0;
    final Widget toolbar = SizedBox(
      height: toolbarHeight + statusbarHeight,
    );

    return SliverPinnedPersistentHeader(
      delegate: _ExtendedSliverAppbarDelegate(
        minExtentProtoType: toolbar,
        maxExtentProtoType: background ?? toolbar,
        title: title,
        leading: leading,
        actions: actions,
        background: background,
        statusbarHeight: statusbarHeight,
        toolbarHeight: toolbarHeight,
        toolBarColor: toolBarColor,
        onBuild: onBuild,
        isOpacityFadeWithToolbar: isOpacityFadeWithToolbar,
        isOpacityFadeWithTitle: isOpacityFadeWithTitle,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
      ),
    );
  }
}

class _ExtendedSliverAppbarDelegate
    extends SliverPinnedPersistentHeaderDelegate {
  _ExtendedSliverAppbarDelegate({
    required Widget minExtentProtoType,
    required Widget maxExtentProtoType,
    this.leading,
    this.title,
    this.actions,
    this.background,
    this.toolBarColor,
    this.onBuild,
    this.statusbarHeight,
    this.toolbarHeight,
    this.isOpacityFadeWithToolbar = true,
    this.isOpacityFadeWithTitle = true,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(
          minExtentProtoType: minExtentProtoType,
          maxExtentProtoType: maxExtentProtoType,
        );

  /// A widget to display before the [title].
  final Widget? leading;

  /// The primary widget displayed in the app bar.
  ///
  /// Typically a [Text] widget containing a description of the current contents
  /// of the app.
  final Widget? title;

  /// Widgets to display after the [title] widget.
  final Widget? actions;

  /// A Widget to display behind [leading],[title],[actions].
  final Widget? background;

  /// Background color for Row(leading,title,background).
  final Color? toolBarColor;

  /// Call when re-build on scroll.
  final OnSliverPinnedPersistentHeaderDelegateBuild? onBuild;

  /// Height of Toolbar. Default value : kToolbarHeight
  final double? toolbarHeight;

  /// Height of Statusbar. Default value : MediaQuery.of(context).padding.top
  final double? statusbarHeight;

  /// Whether do an opacity fade for toolbar.
  ///
  /// By default, the value of isOpacityFadeWithToolbar is true.
  final bool isOpacityFadeWithToolbar;

  /// Whether do an opacity fade for title.
  ///
  /// By default, the value of isOpacityFadeWithTitle is true.
  final bool isOpacityFadeWithTitle;

  /// MainAxisAlignment of toolbar
  ///
  /// By default, the value of mainAxisAlignment is MainAxisAlignment.spaceBetween.
  final MainAxisAlignment mainAxisAlignment;

  /// CrossAxisAlignment of toolbar
  ///
  /// By default, the value of crossAxisAlignment is CrossAxisAlignment.center.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    double? minExtent,
    double maxExtent,
    bool overlapsContent,
  ) {
    onBuild?.call(context, shrinkOffset, minExtent, maxExtent, overlapsContent);
    final double opacity =
        (shrinkOffset / (maxExtent - minExtent!)).clamp(0.0, 1.0);
    Widget? titleWidget = title;
    if (titleWidget != null) {
      if (isOpacityFadeWithTitle) {
        titleWidget = Opacity(
          opacity: opacity,
          child: titleWidget,
        );
      }
    } else {
      titleWidget = Container();
    }
    final ThemeData theme = Theme.of(context);

    Color toolBarColor = this.toolBarColor ?? theme.primaryColor;
    if (isOpacityFadeWithToolbar) {
      toolBarColor = toolBarColor.withOpacity(opacity);
    }

    final Widget toolbar = Container(
      height: toolbarHeight! + statusbarHeight!,
      padding: EdgeInsets.only(top: statusbarHeight!),
      color: toolBarColor,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
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
            oldDelegate.statusbarHeight != statusbarHeight ||
            oldDelegate.toolBarColor != toolBarColor ||
            oldDelegate.toolbarHeight != toolbarHeight ||
            oldDelegate.onBuild != onBuild ||
            oldDelegate.isOpacityFadeWithTitle != isOpacityFadeWithTitle ||
            oldDelegate.isOpacityFadeWithToolbar != isOpacityFadeWithToolbar ||
            oldDelegate.mainAxisAlignment != mainAxisAlignment ||
            oldDelegate.crossAxisAlignment != crossAxisAlignment);
  }
}

/// Call when re-build on scroll
typedef OnSliverPinnedPersistentHeaderDelegateBuild = void Function(
  BuildContext context,
  double shrinkOffset,
  double? minExtent,
  double maxExtent,
  bool overlapsContent,
);
