import 'package:flutter/material.dart';
import 'package:liquidglass_container/liquidglass_container.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //navigatorKey: navigatorKey,
      title: 'Liquid Glass Demo',
      home: AboutPage()
    );
  }
}



class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final GlobalKey _backgroundKey = GlobalKey();
  Offset _glassOffset = const Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    final scaffoldBgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        //backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('About'),
      ),
      body: Stack(
        children: [
          // 背景内容
          RepaintBoundary(
            key: _backgroundKey,
            child: Container(
              color: scaffoldBgColor,
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'SourceHanSansCN',
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 90,
                            ),
                            children: const [
                              TextSpan(
                                text: '智能',
                                style: TextStyle(
                                  fontVariations: [
                                    FontVariation.weight(900.0),
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: '化\n从',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontVariations: [
                                    FontVariation.weight(100.0),
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: '这里\n',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontVariations: [FontVariation.weight(700)],
                                ),
                              ),
                              TextSpan(
                                text: '开始',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontVariations: [FontVariation.weight(900)],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 可拖动玻璃效果层
          Positioned(
            left: _glassOffset.dx,
            top: _glassOffset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _glassOffset += details.delta;
                });
              },
              child: LiquidGlassContainer(
                backgroundKey: _backgroundKey,
                //width: 300,
                //height: 300,
                //padding: 10,
                color: Theme.of(context).colorScheme.primaryFixedDim.withAlpha(80),
                borderRadius: 8,
                child: SizedBox(
                  child: Center(
                    child: Text(
                      '李逵格拉斯',
                      style: TextStyle(
                        fontSize: 38,
                        color: Theme.of(context).colorScheme.primary,
                        fontVariations: const [FontVariation.weight(900)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
