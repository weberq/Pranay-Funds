import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // --- Colors inspired by your logo ---
  static const Color primaryColor = Color(0xFFF39C12);
  static const Color secondaryColor = Color(0xFFE67E22);
  static const Color surfaceColor = Color(0xFFF8F9FA);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);

  // --- Text Styles ---
  static final TextStyle headline = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: onSurfaceColor,
  );

  static final TextStyle title = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: onSurfaceColor,
  );

  static final TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 16,
    color: Colors.black54,
  );

  static final TextStyle body = GoogleFonts.lato(
    fontSize: 16,
    color: onSurfaceColor,
  );

  static final TextStyle amountStyle = GoogleFonts.lato(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: onSurfaceColor,
  );
}
