mixin FormValidators {
  String? textValidate(String name) {
    if (name.isEmpty) return 'Please enter a value';
    return null;
  }

  String? numberValidate(String value) {
    if (value.isEmpty) return 'Please enter a value';
    return null;
  }

  String? addressValidate(String address) {
    if (address.isEmpty || address == '\n') return 'Please enter a value';
    return null;
  }

  String? selectValidate(String name) {
    if (name.isEmpty) return 'Please select a value';
    return null;
  }

  String? radioValidate(String name) {
    if (name.isEmpty) return 'Please select a value';
    return null;
  }

  String? emailValidate(String email) {
    if (email.isEmpty) return 'Email cannot be empty';
    final regexp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regexp.hasMatch(email)) return 'Invalid email';
    return null;
  }

  String? pictureValidate(String picture) {
    if (picture.isEmpty) return 'Please take a selfie';
    return null;
  }
}
