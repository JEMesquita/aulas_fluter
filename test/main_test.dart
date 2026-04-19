import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cadastro/main.dart';

void main() {
  testWidgets('MyApp inicia na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
