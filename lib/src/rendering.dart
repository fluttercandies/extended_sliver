// ignore_for_file: unnecessary_null_comparison

import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'element.dart';

typedef ScrollOffsetChanged = void Function(double offset);

class RenderSliverPinnedPersistentHeader extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox>, RenderSliverHelpers {
  RenderSliverPinnedPersistentHeader({
    RenderBox? child,
    RenderBox? minProtoType,
    RenderBox? maxProtoType,
  })  : _minProtoType = minProtoType,
        _maxProtoType = maxProtoType {
    this.child = child;
  }

  RenderBox? _minProtoType;
  RenderBox? get minProtoType => _minProtoType;
  set minProtoType(RenderBox? value) {
    if (_minProtoType != null) {
      dropChild(_minProtoType!);
    }
    _minProtoType = value;
    if (_minProtoType != null) {
      adoptChild(_minProtoType!);
    }
    markNeedsLayout();
  }

  RenderBox? _maxProtoType;
  RenderBox? get maxProtoType => _maxProtoType;
  set maxProtoType(RenderBox? value) {
    if (_maxProtoType != null) {
      dropChild(_maxProtoType!);
    }
    _maxProtoType = value;
    if (_maxProtoType != null) {
      adoptChild(_maxProtoType!);
    }
    markNeedsLayout();
  }

  double get minExtent => getChildExtend(minProtoType, constraints);
  double get maxExtent => getChildExtend(maxProtoType, constraints);

  bool _needsUpdateChild = true;
  double _lastShrinkOffset = 0.0;
  bool _lastOverlapsContent = false;

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    minProtoType!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    maxProtoType!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final bool overlapsContent = constraints.overlap > 0.0;
    excludeFromSemanticsScrolling =
        overlapsContent || (constraints.scrollOffset > maxExtent - minExtent);
    layoutChild(constraints.scrollOffset, maxExtent,
        overlapsContent: overlapsContent);
    final double effectiveRemainingPaintExtent =
        math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = (maxExtent - constraints.scrollOffset)
        .clamp(0.0, effectiveRemainingPaintExtent);

    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, effectiveRemainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: maxExtent,
      maxScrollObstructionExtent: minExtent,
      cacheExtent: layoutExtent > 0.0
          ? -constraints.cacheOrigin + layoutExtent
          : layoutExtent,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );
  }

  @override
  void markNeedsLayout() {
    // This is automatically called whenever the child's intrinsic dimensions
    // change, at which point we should remeasure them during the next layout.
    _needsUpdateChild = true;
    super.markNeedsLayout();
  }

  @protected
  double get childExtent {
    return getChildExtend(child, constraints);
  }

  @protected
  void layoutChild(double scrollOffset, double maxExtent,
      {bool overlapsContent = false}) {
    final double shrinkOffset = math.min(scrollOffset, maxExtent);
    if (_needsUpdateChild ||
        _lastShrinkOffset != shrinkOffset ||
        _lastOverlapsContent != overlapsContent) {
      invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
        assert(constraints == this.constraints);
        updateChild(shrinkOffset, minExtent, maxExtent, overlapsContent);
      });
      _lastShrinkOffset = shrinkOffset;
      _lastOverlapsContent = overlapsContent;
      _needsUpdateChild = false;
    }

    assert(() {
      if (minExtent <= maxExtent) {
        return true;
      }
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
            'The maxExtent for this $runtimeType is less than its minExtent.'),
        DoubleProperty('The specified maxExtent was', maxExtent),
        DoubleProperty('The specified minExtent was', minExtent),
      ]);
    }());

    child?.layout(
      constraints.asBoxConstraints(
        maxExtent: math.max(minExtent, maxExtent - shrinkOffset),
      ),
      parentUsesSize: true,
    );
  }

  /// Returns the distance from the leading _visible_ edge of the sliver to the
  /// side of the child closest to that edge, in the scroll axis direction.
  ///
  /// For example, if the [constraints] describe this sliver as having an axis
  /// direction of [AxisDirection.down], then this is the distance from the top
  /// of the visible portion of the sliver to the top of the child. If the child
  /// is scrolled partially off the top of the viewport, then this will be
  /// negative. On the other hand, if the [constraints] describe this sliver as
  /// having an axis direction of [AxisDirection.up], then this is the distance
  /// from the bottom of the visible portion of the sliver to the bottom of the
  /// child. In both cases, this is the direction of increasing
  /// [SliverConstraints.scrollOffset].
  ///
  /// Calling this when the child is not visible is not valid.
  ///
  /// The argument must be the value of the [child] property.
  ///
  /// This must be implemented by [RenderSliverPersistentHeader] subclasses.
  ///
  /// If there is no child, this should return 0.0.
  @override
  double childMainAxisPosition(covariant RenderObject? child) => 0.0;

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    assert(geometry!.hitTestExtent > 0.0);
    if (child != null)
      return hitTestBoxChild(BoxHitTestResult.wrap(result), child!,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition);
    return false;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    if (child != minProtoType && child != maxProtoType) {
      applyPaintTransformForBoxChild(child as RenderBox, transform);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      switch (applyGrowthDirectionToAxisDirection(
          constraints.axisDirection, constraints.growthDirection)) {
        case AxisDirection.up:
          offset += Offset(
              0.0,
              geometry!.paintExtent -
                  childMainAxisPosition(child) -
                  childExtent);
          break;
        case AxisDirection.down:
          offset += Offset(0.0, childMainAxisPosition(child));
          break;
        case AxisDirection.left:
          offset += Offset(
              geometry!.paintExtent -
                  childMainAxisPosition(child) -
                  childExtent,
              0.0);
          break;
        case AxisDirection.right:
          offset += Offset(childMainAxisPosition(child), 0.0);
          break;
      }
      context.paintChild(child!, offset);
    }
  }

  /// Whether the [SemanticsNode]s associated with this [RenderSliver] should
  /// be excluded from the semantic scrolling area.
  ///
  /// [RenderSliver]s that stay on the screen even though the user has scrolled
  /// past them (e.g. a pinned app bar) should set this to true.
  @protected
  bool get excludeFromSemanticsScrolling => _excludeFromSemanticsScrolling;
  bool _excludeFromSemanticsScrolling = false;
  set excludeFromSemanticsScrolling(bool value) {
    if (_excludeFromSemanticsScrolling == value) {
      return;
    }
    _excludeFromSemanticsScrolling = value;
    markNeedsSemanticsUpdate();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    if (_excludeFromSemanticsScrolling)
      config.addTagForChildren(RenderViewport.excludeFromScrolling);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    //properties.add(DoubleProperty.lazy('maxExtent', () => maxExtent));
    properties.add(DoubleProperty.lazy(
        'child position', () => childMainAxisPosition(child)));
  }

  SliverPinnedPersistentHeaderElement? element;

  void updateChild(double shrinkOffset, double? minExtent, double maxExtent,
      bool overlapsContent) {
    assert(element != null);
    element!.build(shrinkOffset, minExtent, maxExtent, overlapsContent);
  }

  void triggerRebuild() {
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_minProtoType != null) {
      _minProtoType!.attach(owner);
    }
    if (_maxProtoType != null) {
      _maxProtoType!.attach(owner);
    }
  }

  @override
  void detach() {
    super.detach();
    if (_minProtoType != null) {
      _minProtoType!.detach();
    }
    if (_maxProtoType != null) {
      _maxProtoType!.detach();
    }
  }

  @override
  void redepthChildren() {
    if (_minProtoType != null) {
      redepthChild(_minProtoType!);
    }
    if (_maxProtoType != null) {
      redepthChild(_maxProtoType!);
    }
    super.redepthChildren();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    super.visitChildren(visitor);
    if (_minProtoType != null) {
      visitor(_minProtoType!);
    }
    if (_maxProtoType != null) {
      visitor(_maxProtoType!);
    }
  }
}

/// A pinned [RenderSliver] that contains a single [RenderBox].
class RenderSliverPinnedToBoxAdapter extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a [RenderBox].
  RenderSliverPinnedToBoxAdapter({
    RenderBox? child,
  }) : super(child: child);

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    assert(childExtent != null);
    final double effectiveRemainingPaintExtent =
        math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = (childExtent! - constraints.scrollOffset)
        .clamp(0.0, effectiveRemainingPaintExtent);

    geometry = SliverGeometry(
      scrollExtent: childExtent!,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent!, effectiveRemainingPaintExtent),
      layoutExtent: layoutExtent,
      maxPaintExtent: childExtent!,
      maxScrollObstructionExtent: childExtent!,
      cacheExtent: layoutExtent > 0.0
          ? -constraints.cacheOrigin + layoutExtent
          : layoutExtent,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );
    setChildParentData(child!, constraints, geometry);
  }

  @override
  void setChildParentData(RenderObject child, SliverConstraints constraints,
      SliverGeometry? geometry) {
    final SliverPhysicalParentData? childParentData =
        child.parentData as SliverPhysicalParentData?;
    Offset offset = Offset.zero;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        offset += Offset(
            0.0,
            geometry!.paintExtent -
                childMainAxisPosition(child as RenderBox) -
                childExtent!);
        break;
      case AxisDirection.down:
        offset += Offset(0.0, childMainAxisPosition(child as RenderBox));
        break;
      case AxisDirection.left:
        offset += Offset(
            geometry!.paintExtent -
                childMainAxisPosition(child as RenderBox) -
                childExtent!,
            0.0);
        break;
      case AxisDirection.right:
        offset += Offset(childMainAxisPosition(child as RenderBox), 0.0);
        break;
    }
    childParentData!.paintOffset = offset;
  }

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;

  double? get childExtent {
    return getChildExtend(child, constraints);
  }
}

double getChildExtend(RenderBox? child, SliverConstraints constraints) {
  if (child == null) {
    return 0.0;
  }
  assert(child.hasSize);
  switch (constraints.axis) {
    case Axis.vertical:
      return child.size.height;
    case Axis.horizontal:
      return child.size.width;
  }
}

/// Sliver BoxAdapter for nested scrollable (like webview)
///
/// come form RenderSliverToBoxAdapter and RenderSliverFixedExtentBoxAdaptor
class RenderSliverToNestedScrollBoxAdapter
    extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a [RenderBox].
  RenderSliverToNestedScrollBoxAdapter({
    RenderBox? child,
    required double childExtent,
    required this.onScrollOffsetChanged,
  })  : _childExtent = childExtent,
        super(child: child);

  double get childExtent => _childExtent;
  double _childExtent;
  set childExtent(double value) {
    assert(value != null);
    if (_childExtent == value) {
      return;
    }
    _childExtent = value;
    markNeedsLayout();
  }

  ScrollOffsetChanged onScrollOffsetChanged;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final double childLayoutExtent =
        min(childExtent, constraints.viewportMainAxisExtent);

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    //final double targetEndScrollOffset = scrollOffset + remainingExtent;

    if (!child!.hasSize || child!.size.height != childLayoutExtent) {
      final BoxConstraints childConstraints = constraints.asBoxConstraints(
        minExtent: childLayoutExtent,
        maxExtent: childLayoutExtent,
      );

      child!.layout(childConstraints, parentUsesSize: true);
    }

    // final double targetEndScrollOffsetForPaint =
    //     constraints.scrollOffset + constraints.remainingPaintExtent;

    const double leadingScrollOffset = 0;
    final double trailingScrollOffset = childExtent;

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: leadingScrollOffset,
      to: trailingScrollOffset,
    );
    final double estimatedMaxScrollOffset = childExtent;
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: constraints.scrollOffset > 0.0,
    );

    setChildParentData(child!, constraints, geometry!);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (childExtent > constraints.viewportMainAxisExtent) {
      // maybe overscroll in ios
      onScrollOffsetChanged(math.min(constraints.scrollOffset,
          childExtent - constraints.viewportMainAxisExtent));
    }
    super.paint(context, offset);
  }

  @override
  @protected
  void setChildParentData(RenderObject child, SliverConstraints constraints,
      SliverGeometry geometry) {
    final SliverPhysicalParentData childParentData =
        child.parentData! as SliverPhysicalParentData;
    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    assert(constraints.axisDirection != null);
    assert(constraints.growthDirection != null);
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        assert(false, 'not support for RenderSliverToScrollableBoxAdapter');
        // childParentData.paintOffset = Offset(
        //     0.0,
        //     -(geometry.scrollExtent -
        //         (geometry.paintExtent + constraints.scrollOffset)));
        break;
      case AxisDirection.right:
        assert(false, 'not support for RenderSliverToScrollableBoxAdapter');
        //childParentData.paintOffset = Offset(-constraints.scrollOffset, 0.0);
        break;
      case AxisDirection.down:
        //childParentData.paintOffset = Offset(0.0, -constraints.scrollOffset);
        // zmtzawqlp

        childParentData.paintOffset = Offset(
            0.0,
            childExtent <= constraints.viewportMainAxisExtent
                ? -constraints.scrollOffset
                : min(childExtent - targetEndScrollOffsetForPaint, 0));
        break;
      case AxisDirection.left:
        assert(false, 'not support for RenderSliverToScrollableBoxAdapter');
        // childParentData.paintOffset = Offset(
        //     -(geometry.scrollExtent -
        //         (geometry.paintExtent + constraints.scrollOffset)),
        //     0.0);
        break;
    }
    assert(childParentData.paintOffset != null);
  }

  @override
  bool hitTestBoxChild(BoxHitTestResult result, RenderBox child,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    final bool rightWayUp = _getRightWayUp(constraints);
    double delta = childMainAxisPosition(child);
    final double crossAxisDelta = childCrossAxisPosition(child);
    double absolutePosition = mainAxisPosition - delta;
    final double absoluteCrossAxisPosition = crossAxisPosition - crossAxisDelta;
    Offset paintOffset, transformedPosition;
    assert(constraints.axis != null);
    switch (constraints.axis) {
      case Axis.horizontal:
        assert(true, 'not support for RenderSliverToScrollableBoxAdapter');
        if (!rightWayUp) {
          absolutePosition = child.size.width - absolutePosition;
          delta = geometry!.paintExtent - child.size.width - delta;
        }
        paintOffset = Offset(delta, crossAxisDelta);
        transformedPosition =
            Offset(absolutePosition, absoluteCrossAxisPosition);
        break;
      case Axis.vertical:
        if (!rightWayUp) {
          absolutePosition = child.size.height - absolutePosition;
          delta = geometry!.paintExtent - child.size.height - delta;
        }
        paintOffset = Offset(crossAxisDelta, delta);
        transformedPosition =
            Offset(absoluteCrossAxisPosition, absolutePosition);
        break;
    }
    assert(paintOffset != null);
    assert(transformedPosition != null);
    return result.addWithOutOfBandPosition(
      paintOffset: paintOffset,
      hitTest: (BoxHitTestResult result) {
        // zmtzawqlp
        return child.hitTest(result,
            position: Offset(transformedPosition.dx,
                transformedPosition.dy - constraints.scrollOffset));
      },
    );
  }

  bool _getRightWayUp(SliverConstraints constraints) {
    assert(constraints != null);
    assert(constraints.axisDirection != null);
    bool rightWayUp;
    switch (constraints.axisDirection) {
      case AxisDirection.up:
      case AxisDirection.left:
        rightWayUp = false;
        break;
      case AxisDirection.down:
      case AxisDirection.right:
        rightWayUp = true;
        break;
    }
    assert(constraints.growthDirection != null);
    switch (constraints.growthDirection) {
      case GrowthDirection.forward:
        break;
      case GrowthDirection.reverse:
        rightWayUp = !rightWayUp;
        break;
    }
    assert(rightWayUp != null);
    return rightWayUp;
  }
}
