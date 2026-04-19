import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cadastro/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('mostra campos de e-mail, senha e botão de entrar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Ainda não tem conta? Cadastre-se'), findsOneWidget);
    });

    testWidgets('valida campos obrigatórios quando tenta entrar sem preencher', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu e-mail'), findsOneWidget);
      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('alterna visibilidade da senha ao tocar no ícone', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
