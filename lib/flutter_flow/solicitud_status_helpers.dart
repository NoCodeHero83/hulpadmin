import 'package:flutter/material.dart';

Color solicitudStatusBackgroundColor(String? estado) {
  switch (estado) {
    case 'entrantes':
      return const Color(0xFFE9EBEC);
    case 'aceptadas':
      return const Color(0xFFD6EAFF);
    case 'finalizadas':
      return const Color(0xFFDFF9D2);
    case 'canceladas':
    case 'reagendadas':
      return const Color(0xFFF9DCDF);
    default:
      return const Color(0xFFFFF5D6);
  }
}

Color solicitudStatusForegroundColor(String? estado) {
  switch (estado) {
    case 'entrantes':
      return const Color(0xFF6C757D);
    case 'aceptadas':
      return const Color(0xFF007BFF);
    case 'finalizadas':
      return const Color(0xFF388212);
    case 'canceladas':
    case 'reagendadas':
      return const Color(0xFFDC3545);
    default:
      return const Color(0xFFD6A100);
  }
}

String solicitudStatusLabel(String? estado) {
  switch (estado) {
    case 'entrantes':
      return 'Pendiente';
    case 'aceptadas':
      return 'Activo';
    case 'canceladas':
      return 'Cancelado';
    case 'finalizadas':
      return 'Finalizado';
    case 'reagendadas':
      return 'Reagendada';
    default:
      return 'En curso';
  }
}
