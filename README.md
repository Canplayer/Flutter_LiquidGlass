<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# LiquidGlassContainer
`LiquidGlassContainer` is a Flutter widget that simulates a fluid, refractive glass container using custom shaders and real-time background capture. It creates a visually rich and dynamic lens-like distortion effect, perfect for Apple-26 style UI designs.
![效果预览](https://raw.githubusercontent.com/Canplayer/Flutter_LiquidGlass/main/assets/logo.png)
## ✨ Features
- 💧 Realistic lens distortion using `FragmentShader` (Yes, supports Web)
- 🌈 Supports refraction, chromatic dispersion, and distortion effects
- 🧊 Captures and crops live background content using a `GlobalKey`
- 💡 Highly customizable: color, shadow, padding, and visual parameters
- 📦 Built-in integration with [`smooth_corner`](https://pub.dev/packages/smooth_corner)
- 🎨 Smooth corner rendering with adjustable border radius and smoothness
- 🎉 Almost supports all platforms that Flutter supports
 
## How To Use
### 1.Create a Background Key
Wrap your background with a RepaintBoundary and assign a GlobalKey:

```dart
final GlobalKey _backgroundKey = GlobalKey();

RepaintBoundary(
  key: _backgroundKey,
  child: YourBackgroundWidget(),
);
```
### 2.Use the LiquidGlassContainer
```dart
LiquidGlassContainer(
  width: 300,
  height: 200,
  backgroundKey: _backgroundKey,
  borderRadius: 20,
  color: Colors.white.withOpacity(0.1),
  child: Center(child: Text("Hello Glass")),
);
```
### Example
```dart
final GlobalKey _backgroundKey = GlobalKey();
...
Scaffold(
  body: Stack(
    children: [
      // Background
      RepaintBoundary(
        key: _backgroundKey,
        child: Container(
          child: Text(
            "李逵\n格拉斯",
            style: TextStyle(
              fontSize: 80,
              color: Theme.o(context)colorSchemeprimary,
            ),
          ),
        ),
      ),
      Positioned(
        child: LiquidGlassContainer(
          backgroundKey: _backgroundKey,
          color:Theme.of(context).colorSchemeprimaryFixedDim.withAlpha(120),
          borderRadius: 8,
          child: const SizedBox(
            child: Center(
              child: Text(
                'LIQUID GLASS',
                style: TextStyle(
                  fontSize: 38,
                  fontVariations: const[FontVariation.weight(900)],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
```


## Additional information
This plugin is very power-hungry due to my limited optimization skills. It refreshes rapidly and uses an outdated, inefficient cropping method. Your GPU might get hot!🔥
If you're interested in this project, please help improve it.

The liquid glass effect is based on [`Liquid *Ass`](https://www.shadertoy.com/view/wfdSDf) (yes, that's the actual name).

