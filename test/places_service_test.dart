import 'package:flutter_test/flutter_test.dart';
import 'package:hulp_admin/flutter_flow/places_service.dart';

/// Los casos vienen de respuestas reales de la API para puntos de Bogotá.
void main() {
  Map<String, dynamic> r(List<String> tipos, String direccion) =>
      {'types': tipos, 'formatted_address': direccion};

  group('elegirMejorDireccion', () {
    test('salta el plus code y se queda con la calle que viene detrás', () {
      // Respuesta real para 4.7400,-74.1200: el primero es un plus code.
      final resultados = [
        r(['plus_code'], '67P7PVQJ+X2'),
        r(['street_address'], 'Cl 129c # 152-89, Suba, Bogotá, Colombia'),
      ];
      expect(elegirMejorDireccion(resultados),
          'Cl 129c # 152-89, Suba, Bogotá, Colombia');
    });

    test('prefiere el portal aunque venga después de una vía', () {
      final resultados = [
        r(['route'], 'Cl. 128a #96-2 a 96-58, Bogotá, Colombia'),
        r(['premise', 'street_address'], 'Cl. 128a # 96-47, Bogotá, Colombia'),
      ];
      expect(elegirMejorDireccion(resultados),
          'Cl. 128a # 96-47, Bogotá, Colombia');
    });

    test('sin portal, sirve cualquier cosa que no sea un plus code', () {
      final resultados = [
        r(['plus_code'], '67P7MW54+6Q'),
        r(['route'], 'Unnamed Road, Bogotá, Colombia'),
      ];
      expect(elegirMejorDireccion(resultados), 'Unnamed Road, Bogotá, Colombia');
    });

    test('si solo hay plus code, se devuelve: mejor eso que nada', () {
      expect(elegirMejorDireccion([r(['plus_code'], '67P7MW54+6Q')]),
          '67P7MW54+6Q');
    });

    test('también limpia los niveles repetidos', () {
      final resultados = [
        r(['street_address'],
            'Cl. 128a # 96-43, Suba, Bogotá, D.C., Bogotá, Bogotá, D.C., Colombia'),
      ];
      expect(elegirMejorDireccion(resultados),
          'Cl. 128a # 96-43, Suba, Bogotá, D.C., Colombia');
    });

    test('sin resultados devuelve null, no una cadena vacía', () {
      // Quien llama distingue «no encontré» de «se llama así»: con null deja
      // la dirección que ya hubiera escrita, con '' la borraría.
      expect(elegirMejorDireccion(const []), isNull);
    });

    test('ignora entradas sin dirección en vez de reventar', () {
      final resultados = [
        {'types': ['street_address']},
        r(['route'], 'Calle 1, Bogotá'),
      ];
      expect(elegirMejorDireccion(resultados), 'Calle 1, Bogotá');
    });
  });
}
