import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniplanner/screens/crear_cuenta.dart';

void main() {
  testWidgets('Prueba creación de cuenta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CrearCuenta()));

    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Registrarse'), findsOneWidget);

    // Prueba validación de correo
    await tester.enterText(find.byType(TextFormField).first, 'correo');
    await tester.tap(find.text('Registrarse'));
    await tester.pump();
    expect(find.text('Correo inválido'), findsOneWidget);

    // Prueba validación contraseña
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('Registrarse'));
    await tester.pump();
    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
  });
}