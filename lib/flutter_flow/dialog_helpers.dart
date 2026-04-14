import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';

Future<void> showCenteredDialog(BuildContext context, Widget child) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        alignment: AlignmentDirectional(0.0, 0.0)
            .resolve(Directionality.of(context)),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(dialogContext).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child,
        ),
      );
    },
  );
}

void navigateWithFade(BuildContext context, String routeName) {
  context.pushNamed(
    routeName,
    extra: <String, dynamic>{
      '__transition_info__': TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.fade,
        duration: Duration(milliseconds: 0),
      ),
    },
  );
}
