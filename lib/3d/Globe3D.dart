import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:math' as math;
import 'dart:html' as html;

/// Real 3D globe with manual gestures (no OrbitControls)
class Globe3D extends StatefulWidget {
  const Globe3D({
    super.key,
    required this.diameter,
    required this.textureAsset,
  });

  final double diameter;
  final String textureAsset;

  @override
  State<Globe3D> createState() => _Globe3DState();
}

class _Globe3DState extends State<Globe3D> {
  final GlobalKey _glKey = GlobalKey();
  late FlutterGlPlugin _gl;
  THREE.WebGLRenderer? _renderer;
  THREE.Scene? _scene;
  THREE.PerspectiveCamera? _camera;
  THREE.Mesh? _globe;

  double _dpr = 1.0;
  Size? _size;
  bool _ready = false;        // UI ready to show canvas view
  bool _glReady = false;      // GL context + renderer ready
  int? _textureId;
  String? _viewType;          // web: HtmlElementView type

  // gesture state
  Offset? _lastFocal;
  double _zoom = 3.2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    // Let layout settle
    await Future.delayed(const Duration(milliseconds: 50));

    final renderBox = _glKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || renderBox.size.isEmpty) {
      // try again next frame if size not ready
      WidgetsBinding.instance.addPostFrameCallback((_) => _init());
      return;
    }

    _size = renderBox.size;
    _dpr = MediaQuery.of(context).devicePixelRatio;

    _gl = FlutterGlPlugin();
    final divId = "globe-canvas-${DateTime.now().millisecondsSinceEpoch}";

    await _gl.initialize(options: {
      "antialias": true,
      "alpha": false,
      "width": (_size!.width * _dpr).toInt(),
      "height": (_size!.height * _dpr).toInt(),
      "dpr": _dpr,
      if (kIsWeb) "divId": divId,
    });

    if (kIsWeb) {
      // Register the platform view and show it immediately
      ui.platformViewRegistry.registerViewFactory(divId, (int viewId) {
        final el = _gl.element as html.Element; // must return HtmlElement
        // Give concrete CSS pixels so HtmlElementView doesn't default to 100%
        el.style.width = '${_size!.width}px';
        el.style.height = '${_size!.height}px';
        // Try to also size an inner canvas if present
        final canvas = el.querySelector('canvas');
        if (canvas is html.CanvasElement) {
          canvas.style.width = '${_size!.width}px';
          canvas.style.height = '${_size!.height}px';
        }
        return el;
      });
      setState(() {
        _viewType = divId;
        _ready = true; // show HtmlElementView now
      });
      // Allow DOM attach
      await Future.delayed(const Duration(milliseconds: 60));
    }

    await _gl.prepareContext();

    // Ensure the underlying canvas has numeric width/height attributes and CSS size
    final pixelWidth = (_size!.width * _dpr).toInt();
    final pixelHeight = (_size!.height * _dpr).toInt();

    if (kIsWeb) {
      final el = _gl.element;
      if (el is html.CanvasElement) {
        el.width = pixelWidth;
        el.height = pixelHeight;
        el.style.width = '${_size!.width}px';
        el.style.height = '${_size!.height}px';
      } else if (el is html.Element) {
        el.style.width = '${_size!.width}px';
        el.style.height = '${_size!.height}px';
        final canvas = el.querySelector('canvas');
        if (canvas is html.CanvasElement) {
          canvas.width = pixelWidth;
          canvas.height = pixelHeight;
          canvas.style.width = '${_size!.width}px';
          canvas.style.height = '${_size!.height}px';
        }
      }
    }

    // Now that the canvas is live, create the Three renderer
    final params = {
      "canvas": _gl.element,
      "gl": _gl.gl, // pass GL using the correct key expected by three_dart
      "antialias": true,
      "alpha": false,
      "width": pixelWidth,
      "height": pixelHeight,
    };
    _renderer = THREE.WebGLRenderer(params);
    _renderer!.setPixelRatio(_dpr);
    _renderer!.setSize(_size!.width, _size!.height, false);

    _scene = THREE.Scene();
    _camera = THREE.PerspectiveCamera(55, _size!.width / _size!.height, 0.1, 1000);
    _camera!.position.set(0, 0, _zoom);

    // Lights
    final dirLight = THREE.DirectionalLight(0xffffff, 1.0);
    dirLight.position.set(1, 1, 2);
    _scene!.add(dirLight);
    _scene!.add(THREE.AmbientLight(0xffffff, 0.35));

    // Globe mesh
    final geometry = THREE.SphereGeometry(1.5, 64, 64);
    final texture = await _loadTexture(widget.textureAsset);
    texture.generateMipmaps = true;
    texture.anisotropy = 8;
    final material = THREE.MeshPhongMaterial({"map": texture});
    _globe = THREE.Mesh(geometry, material);
    _scene!.add(_globe!);

    // Attach web DOM event listeners because Flutter gestures don't penetrate HtmlElementView
    if (kIsWeb) {
      final root = _gl.element;
      html.CanvasElement? canvas;
      if (root is html.CanvasElement) {
        canvas = root;
      } else if (root is html.Element) {
        final c = root.querySelector('canvas');
        if (c is html.CanvasElement) canvas = c;
      }

      if (canvas != null) {
        // prevent page scroll on wheel and zoom camera
        canvas.onWheel.listen((e) {
          e.preventDefault();
          final dy = e.deltaY;
          _zoom = (_zoom + dy * 0.002).clamp(2.0, 6.0).toDouble();
          _camera?.position.set(0, 0, _zoom);
        });

        // rotate on drag
        html.Point<num>? last;
        canvas.onMouseDown.listen((e) {
          last = html.Point(e.client.x, e.client.y);
        });
        canvas.onMouseUp.listen((e) => last = null);
        canvas.onMouseLeave.listen((e) => last = null);
        canvas.onMouseMove.listen((e) {
          if (last == null || _globe == null) return;
          final dx = e.client.x - last!.x;
          final dy = e.client.y - last!.y;
          _globe!.rotation.y += dx * 0.005;
          _globe!.rotation.x += dy * 0.005;
          last = html.Point(e.client.x, e.client.y);
        });
      }
    }

    setState(() {
      _textureId = _gl.textureId;
      _glReady = true;
      if (!kIsWeb) _ready = true; // on mobile/desktop we show Texture()
    });

    _animate();
  }

  Future<THREE.Texture> _loadTexture(String assetPath) {
    final c = Completer<THREE.Texture>();
    THREE.TextureLoader(null).load(assetPath, (tex) => c.complete(tex));
    return c.future;
  }

  void _animate() {
    if (!mounted || _renderer == null) return;

    // Only render after GL is ready
    if (_glReady) {
      _renderer!.render(_scene!, _camera!);
      final id = _gl.textureId;
      if (id != null && !kIsWeb) {
        // On mobile/desktop Texture widget needs updating
        _gl.updateTexture(id);
      }
    }

    if (kIsWeb) {
      html.window.requestAnimationFrame((_) => _animate());
    } else {
      Future.microtask(_animate);
    }
  }

  // ScaleGestureRecognizer = pan (rotate) + pinch (zoom) — mobile/desktop only
  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocal = details.focalPoint;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    // Zoom
    _zoom = (_zoom / details.scale).clamp(2.0, 6.0).toDouble();
    _camera?.position.set(0, 0, _zoom);

    // Rotate
    if (_lastFocal != null && _globe != null) {
      final dx = details.focalPoint.dx - _lastFocal!.dx;
      final dy = details.focalPoint.dy - _lastFocal!.dy;
      _globe!.rotation.y += dx * 0.005;
      _globe!.rotation.x += dy * 0.005;
    }
    _lastFocal = details.focalPoint;
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _lastFocal = null;
  }

  @override
  void dispose() {
    try {
      _renderer?.dispose();
      _gl.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!_ready) {
      child = const ColoredBox(color: Colors.black);
    } else if (kIsWeb) {
      // On web we render the registered HTML canvas
      child = HtmlElementView(viewType: _viewType!);
    } else {
      // On mobile/desktop we use the Flutter Texture
      child = (_textureId != null)
          ? Texture(textureId: _textureId!)
          : const ColoredBox(color: Colors.blue);
    }

    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: AspectRatio(
        key: _glKey,
        aspectRatio: 1,
        child: child,
      ),
    );
  }
}