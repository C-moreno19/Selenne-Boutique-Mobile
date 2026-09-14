import 'package:flutter/material.dart';

/// Helper para diseño responsivo
class Responsive {
  /// Retorna true si es un dispositivo móvil (< 600px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Retorna true si es un tablet (>= 600px && < 1200px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Retorna true si es desktop (>= 1200px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Obtiene el ancho de la pantalla
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtiene el alto de la pantalla
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Calcula el número de columnas del grid según el breakpoint
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Calcula el padding responsivo
  static EdgeInsets getPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Calcula el tamaño de fuente responsivo, acotado por breakpoint para que
  /// no crezca sin límite en tablet/desktop/web.
  static double getFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.2;
    }
  }

  /// Retorna el padding horizontal responsivo
  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 24.0;
    }
  }

  /// Retorna el padding vertical responsivo
  static double getVerticalPadding(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  /// Calcula el spacing responsivo
  static double getSpacing(BuildContext context,
      {double mobileSize = 8,
      double tabletSize = 12,
      double desktopSize = 16}) {
    if (isMobile(context)) {
      return mobileSize;
    } else if (isTablet(context)) {
      return tabletSize;
    } else {
      return desktopSize;
    }
  }
}
