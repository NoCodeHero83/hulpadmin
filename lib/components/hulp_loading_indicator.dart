import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class HulpLoadingIndicator extends StatelessWidget {
  const HulpLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50.0,
        height: 50.0,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            FlutterFlowTheme.of(context).primary,
          ),
        ),
      ),
    );
  }
}
