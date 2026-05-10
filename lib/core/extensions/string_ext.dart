extension StringExtensions on String {
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength - suffix.length) + suffix;
  }

  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get sanitizedFileName {
    return replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }
}
