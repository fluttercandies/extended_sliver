import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'element.dart';

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
