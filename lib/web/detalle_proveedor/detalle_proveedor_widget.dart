import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/web/menu/menu_widget.dart';
import 'dart:math' show min;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'detalle_proveedor_model.dart';
export 'detalle_proveedor_model.dart';

/// REQ-002 v2.0.0 — Página dedicada que reemplaza al pop-up
/// `InformacionProveedorWidget`. La lógica de datos y los helpers de documentos
/// se conservan idénticos a la versión v1.0.0; solo cambia la presentación.
class DetalleProveedorWidget extends StatefulWidget {
  const DetalleProveedorWidget({
    super.key,
    required this.proveedorId,
    this.categoriaid,
    this.categorianombre,
  });

  final String? proveedorId;
  final String? categoriaid;
  final String? categorianombre;

  static String routeName = 'DetalleProveedor';
  static String routePath = '/detalleProveedor';

  @override
  State<DetalleProveedorWidget> createState() => _DetalleProveedorWidgetState();
}

class _DetalleProveedorWidgetState extends State<DetalleProveedorWidget> {
  late DetalleProveedorModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Paleta (alineada a FlutterFlowTheme y a los colores ya usados en el proyecto)
  static const Color _chipBg = Color(0xFFDFF9D2);
  static const Color _chipText = Color(0xFF18AC4C);
  static const Color _inactiveBg = Color(0xFFFFE9CC);
  static const Color _inactiveText = Color(0xFFD6A100);
  static const Color _breadcrumb = Color(0xFF5E252B);
  static const Color _cardBorder = Color(0x7C766C4D);
  static const Color _labelGray = Color(0xFF4A4A4A);
  static const Color _valueGray = Color(0xFF606060);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetalleProveedorModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Helpers de documentos (idénticos a v1.0.0) ───────────────────────────

  String _extractFilename(String? url) {
    if (url == null || url.isEmpty) return 'Sin archivo';
    try {
      final segs = Uri.parse(url).pathSegments;
      return segs.isNotEmpty ? segs.last : 'Sin archivo';
    } catch (_) {
      return 'Sin archivo';
    }
  }

  bool _isImageUrl(String url) {
    final ext = url.toLowerCase().split('?').first.split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp'].contains(ext);
  }

  Widget _pdfPlaceholder() => Container(
        color: const Color(0xFFEAEAEA),
        child: const Center(
          child: Icon(Icons.picture_as_pdf_outlined,
              size: 40, color: Color(0xFFD32F2F)),
        ),
      );

  Widget _emptyPlaceholder(BuildContext context) => Container(
        color: const Color(0xFFEAEAEA),
        child: Center(
          child: Icon(Icons.insert_drive_file_outlined,
              size: 40, color: FlutterFlowTheme.of(context).secondaryText),
        ),
      );

  Widget _buildEmptyColumn() => const Expanded(child: SizedBox());

  Widget _buildDocRow(List<Widget> expandedCards) {
    assert(expandedCards.length <= 3);
    final items = <Widget>[];
    for (int i = 0; i < 3; i++) {
      if (i > 0) items.add(const SizedBox(width: 12));
      items.add(i < expandedCards.length ? expandedCards[i] : _buildEmptyColumn());
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: items);
  }

  Widget _buildDocumentCard(
    BuildContext context, {
    required String label,
    required String? url,
    required String downloadPrefix,
    required String? proveedorId,
    DateTime? uploadDate,
  }) {
    final docKey = '${downloadPrefix}_${proveedorId ?? 'x'}';
    final isDownloading = _model.downloadingDocs[docKey] == true;
    final hasUrl = url != null && url.isNotEmpty;
    final filename = _extractFilename(url);

    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).tertiary),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: hasUrl && _isImageUrl(url!)
                  ? Image.network(url, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _pdfPlaceholder())
                  : hasUrl
                      ? _pdfPlaceholder()
                      : _emptyPlaceholder(context),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  filename,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        fontSize: 11,
                        letterSpacing: 0,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
              ),
              const SizedBox(width: 4),
              if (hasUrl)
                const Icon(Icons.check_circle, size: 16, color: Color(0xFF43A047))
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'No cargado',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(),
                          fontSize: 11,
                          letterSpacing: 0,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                  ),
                ),
            ],
          ),
          if (uploadDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Subido el ${DateFormat('dd/MM/yyyy').format(uploadDate)}',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    fontSize: 11,
                    letterSpacing: 0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ],
          if (hasUrl) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                label: const Text('Ver documento'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: FlutterFlowTheme.of(context).primary,
                  side: BorderSide(color: FlutterFlowTheme.of(context).primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: GoogleFonts.inter(fontSize: 13),
                ),
                onPressed: () async {
                  try {
                    await _model.openDocument(url!);
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se pudo abrir el documento'),
                      ));
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined, size: 16),
                label: Text(isDownloading ? 'Descargando...' : 'Descargar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: FlutterFlowTheme.of(context).primary,
                  side: BorderSide(color: FlutterFlowTheme.of(context).primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: GoogleFonts.inter(fontSize: 13),
                ),
                onPressed: isDownloading
                    ? null
                    : () async {
                        final ext = filename.contains('.')
                            ? filename.split('.').last
                            : 'bin';
                        final fileName =
                            '${downloadPrefix}_${proveedorId ?? 'doc'}.$ext';
                        safeSetState(
                            () => _model.downloadingDocs[docKey] = true);
                        try {
                          await _model.downloadDocument(url!, fileName);
                        } catch (e) {
                          if (mounted) {
                            final msg = e
                                    .toString()
                                    .toLowerCase()
                                    .contains('timeout')
                                ? 'La descarga tardó demasiado. Intente nuevamente.'
                                : 'Error al descargar el documento';
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(msg)));
                          }
                        } finally {
                          safeSetState(
                              () => _model.downloadingDocs[docKey] = false);
                        }
                      },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers de presentación (REQ-002 v2.0.0) ─────────────────────────────

  /// REQ-002 v2.0.0 §11.5: ID de proveedor derivado, solo presentación.
  String _idProveedor(UsuariosRow? row) {
    final anio = (row?.fechaRegistro?.year ?? DateTime.now().year).toString();
    final idNum = row?.idUsuario;
    final padded =
        idNum != null ? idNum.toString().padLeft(4, '0') : '----';
    return 'PROV-$anio-$padded';
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 22, color: FlutterFlowTheme.of(context).primary),
          const SizedBox(width: 8),
          Text(
            texto,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  fontSize: 20,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
          ),
        ],
      ),
    );
  }

  /// Bloque label + valor de solo lectura (Datos básicos / Facturación).
  Widget _infoText(BuildContext context, String label, String? value,
      {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.inter(),
                fontSize: 13,
                letterSpacing: 0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          (value == null || value.isEmpty) ? '—' : value,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                fontSize: 15,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: valueColor ?? FlutterFlowTheme.of(context).primaryText,
              ),
        ),
      ],
    );
  }

  Widget _metaItem(BuildContext context, IconData icon, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: FlutterFlowTheme.of(context).primary),
        const SizedBox(width: 6),
        Text(
          texto,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                font: GoogleFonts.inter(),
                fontSize: 13,
                letterSpacing: 0,
                color: _labelGray,
              ),
        ),
      ],
    );
  }

  Widget _serviceChip(BuildContext context, String texto, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.check_circle, size: 14, color: _chipText),
          const SizedBox(width: 6),
          Text(
            texto,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  fontSize: 12,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  color: _chipText,
                ),
          ),
        ],
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 0.5),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, 2))
        ],
      );

  // ── Navegación ────────────────────────────────────────────────────────────

  void _volverAlListado() {
    if (Navigator.of(context).canPop()) {
      context.safePop();
    } else {
      context.pushNamed(
        Proveedores2Widget.routeName,
        queryParameters: {
          'categoriaid':
              serializeParam(widget.categoriaid, ParamType.String),
          'categorianombre':
              serializeParam(widget.categorianombre, ParamType.String),
        }.withoutNulls,
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wrapWithModel(
                model: _model.menuModel,
                updateCallback: () => safeSetState(() {}),
                child: MenuWidget(),
              ),
              Expanded(
                child: FutureBuilder<List<UsuariosRow>>(
                  future: UsuariosTable().querySingleRow(
                    queryFn: (q) => q.eqOrNull('id', widget.proveedorId),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      );
                    }
                    final rows = snapshot.data!;
                    final usuario = rows.isNotEmpty ? rows.first : null;

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopBar(context, usuario),
                            const SizedBox(height: 20),
                            _buildHeaderCard(context, usuario),
                            const SizedBox(height: 24),
                            _buildMiddleRow(context, usuario),
                            const SizedBox(height: 24),
                            _buildLowerRow(context, usuario),
                            const SizedBox(height: 24),
                            _buildHistorial(context),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, UsuariosRow? usuario) {
    final nombre =
        '${usuario?.nombres ?? ''} ${usuario?.apellidos ?? ''}'.trim();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async => _volverAlListado(),
                child: Text(
                  'Proveedores',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                        color: _breadcrumb,
                        fontSize: 16,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right, color: _breadcrumb, size: 22),
              ),
              Flexible(
                child: Text(
                  nombre.isEmpty ? 'Proveedor' : nombre,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic),
                        color: _breadcrumb,
                        fontSize: 16,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Volver al listado'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _valueGray,
            side: const BorderSide(color: Color(0xFF8A8A8A)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            textStyle: GoogleFonts.inter(fontSize: 14),
          ),
          onPressed: () => _volverAlListado(),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, UsuariosRow? usuario) {
    final nombre =
        '${usuario?.nombres ?? ''} ${usuario?.apellidos ?? ''}'.trim();
    final activo = usuario?.disponibilidad == true;
    final instagram = usuario?.redesSociales.isNotEmpty == true
        ? usuario!.redesSociales.first
        : 'Sin Instagram';
    final facebook = (usuario?.redesSociales.length ?? 0) > 1
        ? usuario!.redesSociales.elementAt(1)
        : 'Sin Facebook';
    final fecha = usuario?.fechaRegistro;

    return Container(
      width: double.infinity,
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 900;
          final left = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.network(
                  valueOrDefault<String>(
                    usuario?.fotoPerfilUrl,
                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                  ),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEAEAEA),
                    child: Icon(Icons.person,
                        size: 48,
                        color: FlutterFlowTheme.of(context).secondaryText),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nombre.isEmpty ? 'Sin nombre' : nombre,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font:
                                GoogleFonts.inter(fontWeight: FontWeight.w700),
                            fontSize: 24,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: activo ? _chipBg : _inactiveBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activo ? 'Activo' : 'Inactivo',
                        style: FlutterFlowTheme.of(context)
                            .bodySmall
                            .override(
                              font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600),
                              fontSize: 13,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              color: activo ? _chipText : _inactiveText,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _metaItem(
                            context,
                            Icons.location_on_outlined,
                            valueOrDefault<String>(
                                usuario?.ciudad, 'Sin ciudad')),
                        _metaItem(context, Icons.phone_outlined,
                            valueOrDefault<String>(usuario?.telefono, '—')),
                        _metaItem(
                            context, Icons.camera_alt_outlined, instagram),
                        _metaItem(context, Icons.facebook, facebook),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final center = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Servicios principales',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      fontSize: 13,
                      letterSpacing: 0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(height: 8),
              _buildServiciosPrincipalesChips(context),
            ],
          );

          final right = Column(
            crossAxisAlignment:
                narrow ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Inscripción recibida',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      fontSize: 13,
                      letterSpacing: 0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: FlutterFlowTheme.of(context).primary),
                  const SizedBox(width: 6),
                  Text(
                    fecha != null ? dateTimeFormat("d MMM, y", fecha) : '—',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font:
                              GoogleFonts.inter(fontWeight: FontWeight.w600),
                          fontSize: 15,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'ID de proveedor',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(),
                      fontSize: 13,
                      letterSpacing: 0,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                _idProveedor(usuario),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      fontSize: 16,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
              ),
            ],
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                left,
                const SizedBox(height: 20),
                center,
                const SizedBox(height: 20),
                right,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: left),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: center),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: right),
            ],
          );
        },
      ),
    );
  }

  /// Chips de "Servicios principales" — NUEVA consulta (REQ-002 v2.0.0 §11.4).
  Widget _buildServiciosPrincipalesChips(BuildContext context) {
    return FutureBuilder<List<VwProfesionalesServiciosRow>>(
      future: VwProfesionalesServiciosTable().queryRows(
        queryFn: (q) => q.eqOrNull('profesional_id', widget.proveedorId),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        final nombres = snapshot.data!
            .map((e) => e.servicioNombre)
            .where((e) => e != null && e.isNotEmpty)
            .map((e) => e!)
            .toSet()
            .toList();
        if (nombres.isEmpty) {
          return Text(
            'Sin servicios',
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(),
                  fontSize: 12,
                  letterSpacing: 0,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          );
        }
        final visibles = nombres.take(4).toList();
        final restantes = nombres.length - visibles.length;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...visibles.map((n) => _serviceChip(context, n)),
            if (restantes > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+$restantes',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        fontSize: 12,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: _chipText,
                      ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMiddleRow(BuildContext context, UsuariosRow? usuario) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 900;
        final docs = _buildDocumentosCard(context, usuario);
        final refs = _buildReferenciasCard(context);
        if (narrow) {
          return Column(
            children: [docs, const SizedBox(height: 24), refs],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: docs),
            const SizedBox(width: 24),
            Expanded(flex: 1, child: refs),
          ],
        );
      },
    );
  }

  Widget _buildDocumentosCard(BuildContext context, UsuariosRow? usuario) {
    final cedula = usuario?.cedula;
    final cuenta = usuario?.cuentaBancaria;
    final contrato = usuario?.contrato;
    final uploadDate = usuario?.fechaRegistro;
    final loadedRegistro = [cedula, cuenta, contrato]
        .where((u) => u != null && u.isNotEmpty)
        .length;

    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle(context, Icons.description_outlined, 'Documentos'),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$loadedRegistro/3 cargados',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          fontSize: 12,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E7D32),
                        ),
                  ),
                ),
              ),
            ],
          ),
          // Documentos de registro
          Text(
            'Documentos de registro',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  fontSize: 16,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primary,
                ),
          ),
          const SizedBox(height: 12),
          if (loadedRegistro == 0)
            _emptyState(
              context,
              Icons.upload_file_outlined,
              'Este proveedor aún no tiene documentos de registro cargados',
            )
          else
            LayoutBuilder(
              builder: (context, c) {
                final isMobile = c.maxWidth < 600;
                final cards = <Widget>[
                  if (cedula != null && cedula.isNotEmpty)
                    _buildDocumentCard(context,
                        label: 'Cédula',
                        url: cedula,
                        downloadPrefix: 'cedula',
                        proveedorId: widget.proveedorId,
                        uploadDate: uploadDate),
                  if (cuenta != null && cuenta.isNotEmpty)
                    _buildDocumentCard(context,
                        label: 'Cuenta bancaria',
                        url: cuenta,
                        downloadPrefix: 'cuenta_bancaria',
                        proveedorId: widget.proveedorId,
                        uploadDate: uploadDate),
                  if (contrato != null && contrato.isNotEmpty)
                    _buildDocumentCard(context,
                        label: 'Contrato',
                        url: contrato,
                        downloadPrefix: 'contrato',
                        proveedorId: widget.proveedorId,
                        uploadDate: uploadDate),
                ];
                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < cards.length; i++) ...[
                        cards[i],
                        if (i < cards.length - 1) const SizedBox(height: 12),
                      ]
                    ],
                  );
                }
                return _buildDocRow(
                    cards.map((c) => Expanded(child: c)).toList());
              },
            ),
          const SizedBox(height: 24),
          // Certificaciones
          Text(
            'Certificaciones',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  fontSize: 16,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primary,
                ),
          ),
          const SizedBox(height: 12),
          _buildCertificaciones(context),
        ],
      ),
    );
  }

  Widget _buildCertificaciones(BuildContext context) {
    return FutureBuilder<List<CertificacionesRow>>(
      future: CertificacionesTable().queryRows(
        queryFn: (q) => q.eqOrNull('usuario_id', widget.proveedorId),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        final validCerts =
            snapshot.data!.where((c) => c.documentoUrl.isNotEmpty).toList();
        if (validCerts.isEmpty) {
          return _emptyState(
            context,
            Icons.workspace_premium_outlined,
            'Este proveedor aún no tiene certificaciones registradas',
          );
        }
        return LayoutBuilder(
          builder: (context, c) {
            final isMobile = c.maxWidth < 600;
            if (isMobile) {
              final items = <Widget>[];
              for (int i = 0; i < validCerts.length; i++) {
                items.add(_buildDocumentCard(
                  context,
                  label: validCerts[i].entidadCertificadora,
                  url: validCerts[i].documentoUrl,
                  downloadPrefix: 'certificacion',
                  proveedorId: validCerts[i].id,
                  uploadDate: validCerts[i].createdAt,
                ));
                if (i < validCerts.length - 1) {
                  items.add(const SizedBox(height: 12));
                }
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: items);
            }
            final rows = <Widget>[];
            for (int i = 0; i < validCerts.length; i += 3) {
              final slice =
                  validCerts.sublist(i, min(i + 3, validCerts.length));
              rows.add(_buildDocRow(
                slice
                    .map((cert) => Expanded(
                          child: _buildDocumentCard(
                            context,
                            label: cert.entidadCertificadora,
                            url: cert.documentoUrl,
                            downloadPrefix: 'certificacion',
                            proveedorId: cert.id,
                            uploadDate: cert.createdAt,
                          ),
                        ))
                    .toList(),
              ));
              if (i + 3 < validCerts.length) rows.add(const SizedBox(height: 12));
            }
            return Column(mainAxisSize: MainAxisSize.min, children: rows);
          },
        );
      },
    );
  }

  Widget _buildReferenciasCard(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, Icons.people_alt_outlined, 'Referencias'),
          FutureBuilder<List<ReferenciasLaboralesRow>>(
            future: ReferenciasLaboralesTable().queryRows(
              queryFn: (q) => q.eqOrNull('usuario_id', widget.proveedorId),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                );
              }
              final referencias = snapshot.data!;
              if (referencias.isEmpty) {
                return _emptyState(context, Icons.person_off_outlined,
                    'Sin referencias registradas');
              }
              return Column(
                children: referencias
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _referenceItem(context, r),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _referenceItem(BuildContext context, ReferenciasLaboralesRow r) {
    final iniciales = r.nombreReferencia
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).tertiary),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _chipBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              iniciales.isEmpty ? '?' : iniciales,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    color: _chipText,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  r.nombreReferencia,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        fontSize: 14,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                ),
                Text(
                  r.telefonoReferencia,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        fontSize: 13,
                        letterSpacing: 0,
                        color: const Color(0xFF0D70E7),
                      ),
                ),
                Text(
                  r.relacionLaboral,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(),
                        fontSize: 12,
                        letterSpacing: 0,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _refActionButton(context, Icons.remove_red_eye_outlined, 'Ver',
                  () => _verReferencia(context, r)),
              const SizedBox(height: 6),
              _refActionButton(context, Icons.phone_outlined, 'Llamar',
                  () => _llamar(context, r.telefonoReferencia)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _refActionButton(BuildContext context, IconData icon, String label,
      VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: FlutterFlowTheme.of(context).primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: FlutterFlowTheme.of(context).primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    fontSize: 12,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _verReferencia(BuildContext context, ReferenciasLaboralesRow r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(r.nombreReferencia,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoText(ctx, 'Teléfono', r.telefonoReferencia),
            const SizedBox(height: 8),
            _infoText(ctx, 'Relación', r.relacionLaboral),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _llamar(BuildContext context, String telefono) async {
    try {
      await _model.llamarTelefono(telefono);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar la llamada')),
        );
      }
    }
  }

  Widget _buildLowerRow(BuildContext context, UsuariosRow? usuario) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 900;
        final datos = _buildDatosBasicosCard(context, usuario);
        final factura = _buildFacturacionCard(context, usuario);
        final servicios = _buildServiciosOfrecidosCard(context);
        if (narrow) {
          return Column(
            children: [
              datos,
              const SizedBox(height: 24),
              factura,
              const SizedBox(height: 24),
              servicios,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: datos),
            const SizedBox(width: 24),
            Expanded(child: factura),
            const SizedBox(width: 24),
            Expanded(child: servicios),
          ],
        );
      },
    );
  }

  Widget _buildDatosBasicosCard(BuildContext context, UsuariosRow? usuario) {
    final instagram = usuario?.redesSociales.isNotEmpty == true
        ? usuario!.redesSociales.first
        : 'Sin Instagram';
    final facebook = (usuario?.redesSociales.length ?? 0) > 1
        ? usuario!.redesSociales.elementAt(1)
        : 'Sin Facebook';
    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, Icons.person_outline, 'Datos básicos'),
          _infoText(context, 'Tipo de documento', usuario?.tipoDocumento),
          const SizedBox(height: 14),
          _infoText(context, 'Número de documento', usuario?.numeroDocumento),
          const SizedBox(height: 14),
          _infoText(context, 'Instagram', instagram),
          const SizedBox(height: 14),
          _infoText(context, 'Facebook', facebook),
          const SizedBox(height: 14),
          _infoText(context, 'Dirección', usuario?.direccion),
          const SizedBox(height: 14),
          _infoText(context, 'País', usuario?.pais),
        ],
      ),
    );
  }

  Widget _buildFacturacionCard(BuildContext context, UsuariosRow? usuario) {
    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(24),
      child: FutureBuilder<List<CuentasBancariasRow>>(
        future: CuentasBancariasTable().querySingleRow(
          queryFn: (q) => q.eqOrNull('usuario_id', widget.proveedorId),
        ),
        builder: (context, snapshot) {
          final cuenta = (snapshot.data?.isNotEmpty ?? false)
              ? snapshot.data!.first
              : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                  context, Icons.account_balance_wallet_outlined, 'Facturación'),
              if (!snapshot.hasData)
                Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              else ...[
                _infoText(context, 'Entidad', cuenta?.entidadBancaria),
                const SizedBox(height: 14),
                _infoText(context, 'Tipo de cuenta', cuenta?.tipoCuenta),
                const SizedBox(height: 14),
                _infoText(context, 'Número de cuenta', cuenta?.numeroCuenta),
                const SizedBox(height: 14),
                _infoText(context, 'RUT', usuario?.registroTributario),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Servicios ofrecidos — reutiliza el custom widget de FlutterFlow tal cual
  /// (REQ-002 v2.0.0 §11.6, sin cambios de lógica respecto a v1.0.0).
  Widget _buildServiciosOfrecidosCard(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, Icons.handyman, 'Servicios ofrecidos'),
          FutureBuilder<List<ProfesionalServiciosRow>>(
            future: ProfesionalServiciosTable().queryRows(
              queryFn: (q) => q.eqOrNull('usuario_id', widget.proveedorId),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                );
              }
              final servicios = snapshot.data!;
              return LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth.isFinite ? c.maxWidth : 300.0;
                  return SizedBox(
                    width: w,
                    height: 300,
                    child: custom_widgets.CrearProveedor(
                      width: w,
                      height: 300,
                      serviciosid:
                          servicios.map((e) => e.servicioId).toList(),
                      action: (serviciosidsss) async {},
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistorial(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: _cardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
              context, Icons.access_time, 'Historial de servicios'),
          FutureBuilder<List<VwSolicitudesServiciosCompletaRow>>(
            future: VwSolicitudesServiciosCompletaTable().queryRows(
              queryFn: (q) => q.eqOrNull('profesional_id', widget.proveedorId),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                );
              }
              final historial = snapshot.data!.toList()
                ..sort((a, b) => (b.fecha ?? DateTime(1900))
                    .compareTo(a.fecha ?? DateTime(1900)));
              if (historial.isEmpty) {
                return _emptyState(context, Icons.history_toggle_off,
                    'Sin historial de servicios');
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < historial.length; i++) ...[
                      _timelineNode(context, historial[i]),
                      if (i < historial.length - 1)
                        Container(
                          width: 48,
                          height: 2,
                          margin: const EdgeInsets.only(top: 18),
                          color: FlutterFlowTheme.of(context).tertiary,
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _estadoLabel(String? estado) {
    switch (estado) {
      case 'finalizadas':
        return 'Servicio completado';
      case 'aceptadas':
        return 'Servicio activo';
      case 'entrantes':
        return 'Pendiente';
      case 'canceladas':
        return 'Cancelado';
      default:
        return 'Reprogramado';
    }
  }

  Widget _timelineNode(
      BuildContext context, VwSolicitudesServiciosCompletaRow item) {
    final fecha = item.fecha != null
        ? dateTimeFormat("d/M/y", item.fecha)
        : '—';
    final hora =
        item.hora?.time != null ? dateTimeFormat("Hm", item.hora?.time) : '';
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _chipBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, size: 18, color: _chipText),
          ),
          const SizedBox(height: 8),
          Text(
            _estadoLabel(item.estadoSolicitud),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  fontSize: 14,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            valueOrDefault<String>(item.servicioNombre, 'Servicio'),
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(),
                  fontSize: 12,
                  letterSpacing: 0,
                  color: _labelGray,
                ),
          ),
          if ((item.clienteNombreCompleto ?? '').isNotEmpty)
            Text(
              'Cliente: ${item.clienteNombreCompleto}',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    fontSize: 12,
                    letterSpacing: 0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          const SizedBox(height: 2),
          Text(
            hora.isEmpty ? fecha : '$fecha - $hora',
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.inter(),
                  fontSize: 11,
                  letterSpacing: 0,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 44, color: FlutterFlowTheme.of(context).secondaryText),
            const SizedBox(height: 10),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
