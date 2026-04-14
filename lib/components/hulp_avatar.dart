import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Avatar circular que carga la foto de perfil del usuario.
/// Si la URL es nula, vacia, invalida o falla al cargar, muestra las
/// iniciales sobre un fondo con el color primario de la plataforma.
class HulpAvatar extends StatelessWidget {
  const HulpAvatar({
    super.key,
    this.photoUrl,
    this.name,
    this.size = 40.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String? photoUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  bool get _hasValidUrl {
    final url = photoUrl?.trim() ?? '';
    return url.isNotEmpty && url.startsWith('http');
  }

  String get _initials {
    final n = (name ?? '').trim();
    if (n.isEmpty) return '?';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? FlutterFlowTheme.of(context).primary;
    final fg = foregroundColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasValidUrl
          ? Image.network(
              photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildInitials(fg),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return _buildInitials(fg);
              },
            )
          : _buildInitials(fg),
    );
  }

  Widget _buildInitials(Color fg) {
    return Center(
      child: Text(
        _initials,
        style: GoogleFonts.inter(
          color: fg,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
