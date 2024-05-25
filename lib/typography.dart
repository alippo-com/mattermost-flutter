enum FontTypes {
  Roboto,
  OpenSans,
}

enum FontStyles {
  Normal,
  Italic,
  Bold,
}

final Map<String, double> fontSizes = {
  'small': 12.0,
  'medium': 16.0,
  'large': 20.0,
};

class Typography {
  static TextStyle getStyle({
    required FontTypes type,
    required String size,
    required FontStyles style,
  }) {
    String fontFamily;
    switch (type) {
      case FontTypes.Roboto:
        fontFamily = 'Roboto';
        break;
      case FontTypes.OpenSans:
        fontFamily = 'OpenSans';
        break;
    }

    double fontSize = fontSizes[size] ?? 16.0;
    FontWeight fontWeight;
    FontStyle fontStyle;

    switch (style) {
      case FontStyles.Normal:
        fontWeight = FontWeight.normal;
        fontStyle = FontStyle.normal;
        break;
      case FontStyles.Italic:
        fontWeight = FontWeight.normal;
        fontStyle = FontStyle.italic;
        break;
      case FontStyles.Bold:
        fontWeight = FontWeight.bold;
        fontStyle = FontStyle.normal;
        break;
    }

    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }
}
