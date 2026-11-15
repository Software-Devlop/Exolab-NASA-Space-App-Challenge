import 'dart:math' as math;

import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

// ===========================================================================
// COLORS
// ===========================================================================

/// Hover: bright green.
final vm.Vector4 _kHoverColor = _srgb(0, 230, 118);

/// Selected: blue.
final vm.Vector4 _kSelectedColor = _srgb(30, 107, 255);

/// Suspected injury: orange.
final vm.Vector4 _kSuspectedColor = _srgb(255, 152, 0);

/// Mild injury: yellow.
final vm.Vector4 _kMildInjuryColor = _srgb(255, 214, 10);

/// Moderate injury: deep orange.
final vm.Vector4 _kModerateColor = _srgb(255, 100, 0);

/// Severe injury: red.
final vm.Vector4 _kSevereInjuryColor = _srgb(255, 48, 48);

/// Convert sRGB to linear RGB.
vm.Vector4 _srgb(int r, int g, int b) {
  double lin(int v) {
    final c = v / 255.0;

    return c <= 0.04045
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  return vm.Vector4(lin(r), lin(g), lin(b), 1.0);
}

// ===========================================================================
// INJURY SEVERITY
// ===========================================================================

enum InjurySeverity { suspected, mild, moderate, severe }

/// "upper_back_left" -> "Left Upper Back"
String prettyPartName(String id) {
  var side = '';
  var base = id;

  for (final s in const ['left', 'right']) {
    if (id.endsWith('_$s')) {
      side = '${s[0].toUpperCase()}${s.substring(1)} ';
      base = id.substring(0, id.length - s.length - 1);
    }
  }

  final words = base
      .split('_')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  return '$side$words';
}

/// Stores an existing material and its original RGB color.
class _PartMaterialSnapshot {
  final PhysicallyBasedMaterial material;
  final vm.Vector4 originalColor;

  const _PartMaterialSnapshot({
    required this.material,
    required this.originalColor,
  });
}

// ===========================================================================
// ANATOMY VIEWER
// ===========================================================================

class AnatomyViewerTest extends StatefulWidget {
  const AnatomyViewerTest({
    super.key,
    this.onPartSelected,
    this.injuredParts = const {},
  });

  /// Called when a part is selected or deselected, returning the part ID and injury severity.
  final void Function(String? part, InjurySeverity? severity)? onPartSelected;

  /// Anatomical mesh names and their injury severity.
  ///
  /// Example:
  /// {
  ///   'chest_left': InjurySeverity.mild,
  ///   'abdomen_upper_left': InjurySeverity.severe,
  /// }
  final Map<String, InjurySeverity> injuredParts;

  @override
  State<AnatomyViewerTest> createState() => _AnatomyViewerTestState();
}

class _AnatomyViewerTestState extends State<AnatomyViewerTest>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final Scene scene;
  late final OrbitCameraController orbitController;

  bool ready = false;
  String? error;

  static const double minZoom = 0.4;
  static const double maxZoom = 12;
  static const double zoomStep = 0.4;

  double cameraDistance = 2.4;

  // -----------------------------------------------------------------------
  // Anatomical parts
  // -----------------------------------------------------------------------

  final Map<String, Node> _parts = {};

  final Map<String, List<_PartMaterialSnapshot>> _partMaterials = {};

  final ValueNotifier<String?> _hoveredId = ValueNotifier<String?>(null);

  final ValueNotifier<String?> _selectedId = ValueNotifier<String?>(null);

  // -----------------------------------------------------------------------
  // Initialization
  // -----------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    scene = Scene();

    // SMAA anti-aliasing.
    scene.antiAliasingMode = AntiAliasingMode.smaa;

    scene.smaa.threshold = 0.05;
    scene.smaa.maxSearchSteps = 24;
    scene.smaa.maxDiagonalSearchSteps = 16;
    scene.smaa.cornerRounding = 0;

    orbitController = OrbitCameraController(
      target: vm.Vector3.zero(),
      distance: cameraDistance,
      minDistance: minZoom,
      maxDistance: maxZoom,
      rotateSpeed: -3.0,
      dollySpeed: 0.15,
      minPolar: -1.5,
      maxPolar: 1.5,
      panSpeed: 0.0,
    );

    _initializeScene();
  }

  // -----------------------------------------------------------------------
  // Update injuries
  // -----------------------------------------------------------------------

  @override
  void didUpdateWidget(covariant AnatomyViewerTest oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.injuredParts != widget.injuredParts) {
      for (final id in _parts.keys) {
        _applyMaterials(id);
      }
    }
  }

  // -----------------------------------------------------------------------
  // Initialize scene
  // -----------------------------------------------------------------------

  Future<void> _initializeScene() async {
    try {
      await Scene.initializeStaticResources();

      final model = await Node.fromGlbAsset(
        'assets/glb/human_body_segmented_smooth.glb',
      );

      // Rotate 20 degrees to the left.
      // Rotate the model 20 degrees around the vertical Y axis.
      model.rotation = vm.Quaternion.axisAngle(
        vm.Vector3(0, 1, 0),
        -168 * math.pi / 180,
      );

      scene.add(model);

      _indexParts(model);

      // Center camera on the model.
      final bounds = model.combinedWorldBounds;

      if (bounds != null) {
        final center = bounds.center;

        orbitController.target = vm.Vector3(center.x, center.y, center.z);
      }

      final cameraNode = Node();

      cameraNode.addComponent(CameraComponent(activateOnMount: true));

      cameraNode.addComponent(orbitController);

      scene.add(cameraNode);

      if (mounted) {
        setState(() {
          ready = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Anatomy initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          error = e.toString();
        });
      }
    }
  }

  // -----------------------------------------------------------------------
  // Index model parts and fix original transparency
  // -----------------------------------------------------------------------

  void _indexParts(Node model) {
    for (final node in model.meshNodes) {
      final mesh = node.mesh;

      if (mesh == null || node.name.isEmpty) {
        continue;
      }

      _parts[node.name] = node;

      final snapshots = <_PartMaterialSnapshot>[];

      for (final primitive in mesh.primitives) {
        final material = primitive.material;

        if (material is! PhysicallyBasedMaterial) {
          debugPrint('Skipping unsupported material: ${node.name}');
          continue;
        }

        // Preserve the original RGB color.
        final original = material.baseColorFactor;

        final originalColor = vm.Vector4(
          original.x,
          original.y,
          original.z,
          1.0,
        );

        snapshots.add(
          _PartMaterialSnapshot(
            material: material,
            originalColor: originalColor,
          ),
        );

        // Make original materials completely opaque.
        material
          ..baseColorFactor = originalColor.clone()
          ..alphaMode = AlphaMode.opaque;
      }

      _partMaterials[node.name] = snapshots;
    }

    if (_parts.isEmpty) {
      throw StateError('No named anatomical mesh nodes were found.');
    }

    // Apply injuries supplied through the constructor.
    for (final id in _parts.keys) {
      _applyMaterials(id);
    }
  }

  // -----------------------------------------------------------------------
  // Material coloring
  // -----------------------------------------------------------------------

  /// Color priority:
  ///
  /// 1. Severe injury -> red
  /// 2. Bad injury -> deep orange
  /// 3. Mild injury -> yellow
  /// 4. Possible injury -> orange
  /// 5. Selected -> blue
  /// 6. Hovered -> bright green
  /// 7. Normal -> original GLB color
  void _applyMaterials(String id) {
    final snapshots = _partMaterials[id];

    if (snapshots == null || snapshots.isEmpty) {
      return;
    }

    final injury = widget.injuredParts[id];

    final vm.Vector4 color;

    if (injury == InjurySeverity.severe) {
      color = _kSevereInjuryColor;
    } else if (injury == InjurySeverity.moderate) {
      color = _kModerateColor;
    } else if (injury == InjurySeverity.mild) {
      color = _kMildInjuryColor;
    } else if (injury == InjurySeverity.suspected) {
      color = _kSuspectedColor;
    } else if (id == _selectedId.value) {
      color = _kSelectedColor;
    } else if (id == _hoveredId.value) {
      color = _kHoverColor;
    } else {
      color = snapshots.first.originalColor;
    }

    for (final snapshot in snapshots) {
      snapshot.material
        ..baseColorFactor = color.clone()
        ..alphaMode = AlphaMode.opaque;
    }
  }

  // -----------------------------------------------------------------------
  // Picking
  // -----------------------------------------------------------------------

  String? _pickPart(Offset position, Size viewSize) {
    final camera = scene.camera;

    if (camera == null || viewSize.isEmpty) {
      return null;
    }

    final ray = camera.screenPointToRay(position, viewSize);

    final hit = scene.raycast(ray);

    if (hit == null) return null;

    // Walk upward until finding the actual anatomical mesh.
    Node? node = hit.node;

    while (node != null) {
      if (_parts.containsKey(node.name)) {
        return node.name;
      }

      node = node.parent;
    }

    return null;
  }

  // -----------------------------------------------------------------------
  // Hover
  // -----------------------------------------------------------------------

  void _setHovered(String? id) {
    final previous = _hoveredId.value;

    if (previous == id) return;

    _hoveredId.value = id;

    if (previous != null) {
      _applyMaterials(previous);
    }

    if (id != null) {
      _applyMaterials(id);
    }
  }

  void _handleHover(Offset position, Size size) {
    _setHovered(_pickPart(position, size));
  }

  // -----------------------------------------------------------------------
  // Selection
  // -----------------------------------------------------------------------

  void _setSelected(String? id) {
    final previous = _selectedId.value;

    if (previous == id) return;

    _selectedId.value = id;

    if (previous != null) {
      _applyMaterials(previous);
    }

    if (id != null) {
      _applyMaterials(id);
    }

    final severity = id != null ? widget.injuredParts[id] : null;
    widget.onPartSelected?.call(id, severity);
  }

  void _handleTap(Offset position, Size size) {
    final id = _pickPart(position, size);

    // Tap selected part again to deselect.
    // Tap empty space to clear selection.
    _setSelected(id == _selectedId.value ? null : id);
  }

  // -----------------------------------------------------------------------
  // Label colors
  // -----------------------------------------------------------------------

  Color _getLabelColor(String id) {
    final injury = widget.injuredParts[id];

    if (injury == InjurySeverity.severe) {
      return const Color(0xFFFF3030); // Red
    }
    if (injury == InjurySeverity.moderate) {
      return const Color(0xFFFF6400); // Deep Orange
    }
    if (injury == InjurySeverity.mild) {
      return const Color(0xFFFFD60A); // Yellow
    }
    if (injury == InjurySeverity.suspected) {
      return const Color(0xFFFF9800); // Orange
    }

    if (id == _selectedId.value) {
      return const Color(0xFF1E6BFF); // Blue
    }

    if (id == _hoveredId.value) {
      return const Color(0xFF00E676); // Bright Green
    }

    return const Color(0xFF1E6BFF);
  }

  Color _getLabelTextColor(String id) {
    final injury = widget.injuredParts[id];

    // Use dark text for lighter/brighter backgrounds for better contrast
    if (injury == InjurySeverity.mild ||
        injury == InjurySeverity.suspected ||
        id == _hoveredId.value) {
      return Colors.black87;
    }

    return Colors.white;
  }
  // -----------------------------------------------------------------------
  // Zoom
  // -----------------------------------------------------------------------

  void _zoomIn() {
    if (cameraDistance <= minZoom) return;

    orbitController.dollyBy(zoomStep);

    setState(() {
      cameraDistance = (cameraDistance - zoomStep).clamp(minZoom, maxZoom);
    });
  }

  void _zoomOut() {
    if (cameraDistance >= maxZoom) return;

    orbitController.dollyBy(-zoomStep);

    setState(() {
      cameraDistance = (cameraDistance + zoomStep).clamp(minZoom, maxZoom);
    });
  }

  // -----------------------------------------------------------------------
  // Dispose
  // -----------------------------------------------------------------------

  @override
  void dispose() {
    orbitController.releaseInput();

    _hoveredId.dispose();
    _selectedId.dispose();

    super.dispose();
  }

  // -----------------------------------------------------------------------
  // UI
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (error != null) {
      return SizedBox(
        height: 500,
        child: Center(
          child: Text(
            'Failed to load 3D model:\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!ready) {
      return const SizedBox(
        height: 500,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 430,
      width: double.infinity,
      child: Stack(
        children: [
          // 3D model.
          Positioned.fill(
            child: CameraInputSurface(
              controller: orbitController,
              onHover: _handleHover,
              onHoverExit: () => _setHovered(null),
              onTap: _handleTap,
              child: SceneView(scene),
            ),
          ),

          // Selected / hovered part label.
          Positioned(
            left: 12,
            bottom: 12,
            child: IgnorePointer(
              child: ValueListenableBuilder<String?>(
                valueListenable: _selectedId,
                builder: (context, selected, _) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: _hoveredId,
                    builder: (context, hovered, _) {
                      final id = hovered ?? selected;

                      if (id == null) {
                        return const SizedBox.shrink();
                      }

                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: _getLabelColor(id),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            prettyPartName(id),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _getLabelTextColor(id),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Zoom controls.
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                  ),
                  tooltip: 'Zoom in',
                  onPressed: cameraDistance > minZoom ? _zoomIn : null,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.onPrimary,
                  ),
                  tooltip: 'Zoom out',
                  onPressed: cameraDistance < maxZoom ? _zoomOut : null,
                  icon: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// CAMERA INPUT AND GESTURES
// ===========================================================================

typedef SurfacePointCallback = void Function(Offset position, Size size);

class CameraInputSurface extends StatefulWidget {
  final CameraController controller;
  final Widget child;

  /// Mouse hover (desktop / web).
  final SurfacePointCallback? onHover;

  final VoidCallback? onHoverExit;

  /// Click or tap that was not a drag.
  final SurfacePointCallback? onTap;

  const CameraInputSurface({
    super.key,
    required this.controller,
    required this.child,
    this.onHover,
    this.onHoverExit,
    this.onTap,
  });

  @override
  State<CameraInputSurface> createState() => _CameraInputSurfaceState();
}

class _CameraInputSurfaceState extends State<CameraInputSurface> {
  static const double _tapSlop = 8.0;

  static const Duration _hoverInterval = Duration(milliseconds: 40);

  final Map<int, Offset> _pointers = {};

  Offset? _lastFocalPoint;
  double? _lastSpan;

  // Tap detection.
  Offset? _downPosition;
  bool _movedTooFar = false;
  bool _multiTouch = false;

  // Hover throttling.
  final Stopwatch _hoverClock = Stopwatch()..start();

  Size _size = Size.zero;

  Offset get _focalPoint {
    final points = _pointers.values;

    return points.reduce((a, b) => a + b) / points.length.toDouble();
  }

  double get _span {
    final center = _focalPoint;

    final squaredDistances = _pointers.values
        .map((point) => math.pow((point - center).distance, 2))
        .toList();

    return math.sqrt(
      squaredDistances.reduce((a, b) => a + b) / squaredDistances.length,
    );
  }

  void _resetGesture() {
    if (_pointers.isEmpty) {
      _lastFocalPoint = null;
      _lastSpan = null;
      return;
    }

    _lastFocalPoint = _focalPoint;

    _lastSpan = _pointers.length > 1 ? _span : null;
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length == 1) {
      _downPosition = event.localPosition;
      _movedTooFar = false;
      _multiTouch = false;
    } else {
      _multiTouch = true;
    }

    _resetGesture();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;

    _pointers[event.pointer] = event.localPosition;

    if (_downPosition != null &&
        (event.localPosition - _downPosition!).distance > _tapSlop) {
      _movedTooFar = true;
    }

    if (_pointers.length == 1) {
      widget.controller.handleDragUpdate(event.delta);
      return;
    }

    final focalPoint = _focalPoint;
    final span = _span;

    if (_lastFocalPoint != null && _lastSpan != null && _lastSpan! > 0) {
      widget.controller.handleScaleUpdate(
        span / _lastSpan!,
        focalPoint - _lastFocalPoint!,
      );
    }

    _lastFocalPoint = focalPoint;
    _lastSpan = span;
  }

  void _onPointerUp(PointerUpEvent event) {
    final wasSingle =
        _pointers.length == 1 && _pointers.containsKey(event.pointer);

    if (wasSingle && !_movedTooFar && !_multiTouch) {
      widget.onTap?.call(event.localPosition, _size);
    }

    _removePointer(event);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _removePointer(event);
  }

  void _removePointer(PointerEvent event) {
    _pointers.remove(event.pointer);

    if (_pointers.isEmpty) {
      _downPosition = null;
    }

    _resetGesture();
  }

  void _onPointerHover(PointerHoverEvent event) {
    if (widget.onHover == null) return;

    if (_hoverClock.elapsed < _hoverInterval) return;

    _hoverClock.reset();

    widget.onHover!(event.localPosition, _size);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.biggest.isFinite) {
          widget.controller.viewportSize = constraints.biggest;

          _size = constraints.biggest;
        }

        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            return widget.controller.handleKeyEvent(event)
                ? KeyEventResult.handled
                : KeyEventResult.ignored;
          },
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              widget.controller.releaseInput();
            }
          },
          child: MouseRegion(
            onExit: (_) => widget.onHoverExit?.call(),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              onPointerCancel: _onPointerCancel,
              onPointerHover: _onPointerHover,
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  widget.controller.handleScroll(event.scrollDelta.dy);
                }
              },
              child: RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: {
                  EagerGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                        EagerGestureRecognizer
                      >(() => EagerGestureRecognizer(), (recognizer) {}),
                },
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
