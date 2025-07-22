import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquidglass_container/liquidglass_container.dart';

void main() {
  testWidgets('LiquidGlassContainer 显示文本', (WidgetTester tester) async {
    final backgroundKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            RepaintBoundary(
              key: backgroundKey,
              child: Container(color: Colors.white),
            ),
            LiquidGlassContainer(
              backgroundKey: backgroundKey,
              color: Colors.blue.withAlpha(80),
              borderRadius: 8,
              child: const Text('李逵格拉斯'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('李逵格拉斯'), findsOneWidget);
  });
}