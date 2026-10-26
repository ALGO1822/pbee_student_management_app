class Validator {
  static String? requiredField(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid $fieldName';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    } else if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? password(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Password is required';
  } else if (value.trim().length < 8) {
    return 'Password must be at least 8 characters long';
  } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  } else if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter';
  } else if (!RegExp(r'\d').hasMatch(value)) {
    return 'Password must contain at least one number';
  } else if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
    return 'Password must contain at least one special character';
  }
  return null;
}


  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    } else if (value.trim().length < 5) {
      return 'Address seems too short';
    } else if (!RegExp(r'^[a-zA-Z0-9\s,.-]+$').hasMatch(value.trim())) {
      return 'Invalid characters in address';
    }
    return null;
  }

  static String? dropdown(String? value, {String fieldName = 'Option'}) {
    if (value == null) {
      return 'Please select a $fieldName';
    }
    return null;
  }
}
