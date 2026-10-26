class NameFormatter {
  static String formatFullName(String firstName, String lastName) {
    String capitalize(String text) {
      if (text.isEmpty) return '';
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }

    return '${capitalize(firstName)} ${capitalize(lastName)}';
  }
}
