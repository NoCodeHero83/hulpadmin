/// Punto de entrada del mapa interactivo.
///
/// `hulp_admin` se despliega como app web, pero `flutter test` corre en la
/// máquina virtual de Dart, donde `package:web` y `dart:ui_web` no existen.
/// Importar la implementación real desde el selector rompía toda la batería de
/// pruebas con errores de compilación de un paquete de terceros — un fallo que
/// no dice nada sobre el código propio y cuesta un rato entender.
///
/// Con esta indirección, la web recibe el mapa de verdad y la VM un sustituto
/// que se pinta como «no disponible».
export 'mapa_punto_stub.dart'
    if (dart.library.js_interop) 'mapa_punto_web.dart';
