import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth_corner/smooth_corner.dart';

class LiquidGlassContainer extends StatefulWidget {
  /// 子组件
  final Widget? child;

  /// 容器宽度
  final double? width;

  /// 容器高度
  final double? height;

  //圆角数值
  final double? borderRadius;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  //背景key
  final GlobalKey backgroundKey;

  /// 阴影颜色
  final Color? shadowColor;

  /// 阴影模糊半径
  final double shadowBlurRadius;

  /// 阴影扩散半径
  final double shadowSpreadRadius;

  /// 阴影距离
  final double shadowOffset;

  /// 玻璃颜色
  final Color color;

  /// 圆角平滑度
  final double smoothness;

  /// 缩放/折射系数
  final double refraction;

  /// 色散系数
  final double chromaticDispersion;

  /// 扭曲强度
  final double distortionStrength;

  /// 扭曲坡度
  final double distortionSlope;

  const LiquidGlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius = 10.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
    required this.backgroundKey,
    this.shadowColor,
    this.shadowBlurRadius = 40.0,
    this.shadowSpreadRadius = 5.0,
    this.shadowOffset = 30.0,
    this.color = Colors.transparent,
    this.smoothness = 1,
    this.refraction = 0.97,
    this.chromaticDispersion = 0.01,
    this.distortionStrength = 0.8,
    this.distortionSlope = -0.5,
  });

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer> {
  final ValueNotifier<Size> _sizeNotifier = ValueNotifier<Size>(Size.zero);
  ui.FragmentShader? _shader;
  ui.Image? _backgroundImage;
  Timer? _captureTimer;

  @override
  void initState() {
    super.initState();
    _loadShader();
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      _captureBackground();
    });
    _scheduleSizeUpdate();
    //_scheduleBackgroundCapture();
  }

  void _scheduleSizeUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateSize());
  }

  void _updateSize() {
    if (!mounted) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      _sizeNotifier.value = box.size;
    }
  }

  Future<void> _loadShader() async {
      final program = await ui.FragmentProgram.fromAsset(
        'packages/liquidglass_container/assets/shaders/aero_lens.frag',
      );
      setState(() => _shader = program.fragmentShader());
  }

  void _scheduleBackgroundCapture() {
    // _captureTimer?.cancel();
    // _captureTimer = Timer(const Duration(milliseconds: 0), _captureBackground);
    //下一帧刷新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureBackground();
    });
  }

  Future<void> _captureBackground() async {
    if (!mounted) return;
    final boundary = widget.backgroundKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    if (boundary != null) {
      try {
        // 获取玻璃容器在屏幕中的位置
        final containerBox = context.findRenderObject() as RenderBox?;
        if (containerBox == null) return;

        final containerPosition = containerBox.localToGlobal(Offset.zero);
        final containerSize =
            Size(_sizeNotifier.value.width, _sizeNotifier.value.height);

        // 获取整个背景图像
        final fullImage = await boundary.toImage(pixelRatio: 1);

        // 裁剪出玻璃容器区域
        final croppedImage = await _cropImage(
          fullImage,
          containerPosition,
          containerSize,
          boundary,
        );

        setState(() => _backgroundImage = croppedImage);
        fullImage.dispose(); // 释放完整图像内存
      } catch (e) {
        if (kDebugMode) {
          print('Error capturing background image: $e');
        }
      }
    }
  }

  Future<ui.Image> _cropImage(
    ui.Image sourceImage,
    Offset position,
    Size size,
    RenderRepaintBoundary boundary,
  ) async {
    // 计算边界相对于RepaintBoundary的位置
    final boundaryPosition = boundary.localToGlobal(Offset.zero);
    final relativePosition = position - boundaryPosition;

    // 创建裁剪区域
    final cropRect = Rect.fromLTWH(
      relativePosition.dx,
      relativePosition.dy,
      size.width,
      size.height,
    );

    // 确保裁剪区域在图像范围内
    final safeRect = Rect.fromLTWH(
      cropRect.left,
      cropRect.top,
      cropRect.width,
      cropRect.height,
    );

    // 创建裁剪画布
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // 绘制裁剪区域
    canvas.drawImageRect(
      sourceImage,
      safeRect,
      Rect.fromLTWH(0, 0, safeRect.width, safeRect.height),
      Paint(),
    );

    final picture = recorder.endRecording();
    return picture.toImage(safeRect.width.toInt(), safeRect.height.toInt());
  }

  @override
  void didUpdateWidget(LiquidGlassContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.backgroundKey != widget.backgroundKey) {
    _scheduleBackgroundCapture();
    // }
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      _scheduleSizeUpdate();
    }
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _shader?.dispose();
    _backgroundImage?.dispose();
    _sizeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 阴影层
        Positioned.fill(
          child: Container(
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius:
                    BorderRadius.circular(widget.borderRadius ?? 30.0),
                smoothness: 0.6,
              ),
              shadows: [
                BoxShadow(
                  color: widget.shadowColor ??
                      Theme.of(context).colorScheme.primary.withAlpha(80),
                  blurRadius: widget.shadowBlurRadius,
                  spreadRadius: widget.shadowSpreadRadius,
                  offset: Offset(0, widget.shadowOffset),
                ),
              ],
            ),
          ),
        ),
        // 主内容
        ClipPath(
          clipper: ShapeBorderClipper(
            shape: SmoothRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 30.0),
              smoothness: 0.6,
            ),
          ),
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<Size>(
          valueListenable: _sizeNotifier,
          builder: (context, size, _) => _buildPaintedContainer(context, size),
        );
      },
    );
  }

  Widget _buildPaintedContainer(BuildContext context, Size size) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _scheduleSizeUpdate();
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          children: [
            Positioned.fill(
              child: (_shader != null && _backgroundImage != null)
                    ? CustomPaint(
                        size: Size(size.width, size.height),
                        painter: LensShaderPainter(
                          color: widget.color,
                          shader: _shader!,
                          backgroundImage: _backgroundImage!,
                          borderRadius: widget.borderRadius ?? 10,
                          padding: 0,
                          smoothness: widget.smoothness,
                          refraction: widget.refraction,
                          chromaticDispersion: widget.chromaticDispersion,
                          distortionStrength: widget.distortionStrength,
                          distortionSlope: widget.distortionSlope,
                        ),
                      )
                    : const SizedBox.shrink(),
            ),

            // shader 效果层

            // 内容层
            Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

class LensShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image backgroundImage;
  final double borderRadius;
  final double padding;
  final Color color;
  final double smoothness;
  final double refraction;
  final double chromaticDispersion;
  final double distortionStrength;
  final double distortionSlope;

  LensShaderPainter({
    required this.shader,
    required this.backgroundImage,
    required this.borderRadius,
    required this.padding,
    required this.color,
    required this.smoothness,
    required this.refraction,
    required this.chromaticDispersion,
    required this.distortionStrength,
    required this.distortionSlope,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, padding); // 传入padding值
    shader.setFloat(3, borderRadius); // 圆角半径
    shader.setFloat(4, smoothness); // 圆角平滑度
    shader.setFloat(5, refraction); // 缩放/折射系数
    shader.setFloat(6, chromaticDispersion); // 色散系数
    shader.setFloat(7, distortionStrength); // 扭曲强度
    shader.setFloat(8, distortionSlope); // 扭曲坡度
    shader.setFloat(9, color.red.toDouble()/255); // R
    shader.setFloat(10, color.green.toDouble()/255); // G
    shader.setFloat(11, color.blue.toDouble()/255); // B
    shader.setFloat(12, color.alpha.toDouble()/255);

    shader.setImageSampler(0, backgroundImage);

    final paint = Paint()..shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(LensShaderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.padding != padding ||
      oldDelegate.smoothness != smoothness ||
      oldDelegate.refraction != refraction ||
      oldDelegate.chromaticDispersion != chromaticDispersion ||
      oldDelegate.distortionStrength != distortionStrength ||
      oldDelegate.distortionSlope != distortionSlope ||
      oldDelegate.color != color ||
      oldDelegate.backgroundImage != backgroundImage;
}
