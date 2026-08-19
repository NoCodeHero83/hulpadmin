import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulp_admin/components/selector_ubicacion_widget.dart';
import 'package:hulp_admin/flutter_flow/ubicacion_helpers.dart';

/// El selector se monta dentro de formularios muy anidados y estrechos, así que
/// lo que más importa aquí es que no desborde y que avise al padre cuando toca.
void main() {
  Future<void> montar(
    WidgetTester tester, {
    required void Function(Coordenadas?) onCambio,
    Coordenadas? iniciales,
    String direccion = '',
    double ancho = 320,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: ancho,
            child: SelectorUbicacionWidget(
              onCambio: onCambio,
              coordenadasIniciales: iniciales,
              direccionActual: () => direccion,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('sin punto invita a capturarlo y no avisa nada al padre',
      (tester) async {
    var llamadas = 0;
    await montar(tester, onCambio: (_) => llamadas++);

    expect(find.textContaining('Sin punto exacto'), findsOneWidget);
    expect(llamadas, 0);
  });

  testWidgets('pegar coordenadas válidas avisa al padre y las confirma',
      (tester) async {
    Coordenadas? recibido;
    var llamadas = 0;
    await montar(tester, onCambio: (c) {
      recibido = c;
      llamadas++;
    });

    await tester.enterText(find.byType(TextFormField), '4.710989, -74.072092');
    await tester.pump();

    expect(llamadas, 1);
    expect(recibido, const Coordenadas(4.710989, -74.072092));
    expect(find.textContaining('Punto guardado'), findsOneWidget);
  });

  testWidgets('un texto que no son coordenadas deja al padre en null',
      (tester) async {
    Coordenadas? recibido = const Coordenadas(1, 1);
    await montar(tester, onCambio: (c) => recibido = c);

    await tester.enterText(find.byType(TextFormField), 'por la esquina');
    await tester.pump();

    expect(recibido, isNull);
    expect(find.textContaining('No encontré coordenadas'), findsOneWidget);
  });

  testWidgets('siembra al padre con el punto ya guardado', (tester) async {
    // Sin esto, abrir el formulario de edición y guardar sin tocar la
    // ubicación la borraría.
    Coordenadas? recibido;
    await montar(
      tester,
      onCambio: (c) => recibido = c,
      iniciales: const Coordenadas(4.710989, -74.072092),
    );
    await tester.pump();

    expect(recibido, const Coordenadas(4.710989, -74.072092));
    expect(find.text('4.710989, -74.072092'), findsOneWidget);
  });

  testWidgets('avisa del par invertido', (tester) async {
    await montar(tester, onCambio: (_) {});

    await tester.enterText(find.byType(TextFormField), '-74.072092, 4.710989');
    await tester.pump();

    expect(find.textContaining('invertidas'), findsOneWidget);
  });

  testWidgets('quitar el punto lo borra en el padre', (tester) async {
    Coordenadas? recibido;
    await montar(
      tester,
      onCambio: (c) => recibido = c,
      iniciales: const Coordenadas(4.710989, -74.072092),
    );
    await tester.pump();
    expect(recibido, isNotNull);

    await tester.tap(find.byTooltip('Quitar la ubicación'));
    await tester.pump();

    expect(recibido, isNull);
  });

  testWidgets('no desborda en un panel estrecho', (tester) async {
    await montar(
      tester,
      onCambio: (_) {},
      iniciales: const Coordenadas(4.710989, -74.072092),
      direccion: 'Cra 8 #16-41, Cota, Cundinamarca, Colombia',
      ancho: 260,
    );
    await tester.pump();
    // tester falla solo si hubo un overflow pintado.
    expect(tester.takeException(), isNull);
  });
}
