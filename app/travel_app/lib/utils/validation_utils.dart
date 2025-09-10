class ValidationUtils {
  /// Validates an email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Basic email validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  /// Check if an email address is valid (returns boolean)
  static bool isValidEmail(String value) {
    if (value.isEmpty) return false;
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(value);
  }

  /// Validates a name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  /// Validates a phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Allow + and digits
    final phoneRegex = RegExp(r'^[+]?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    
    return null;
  }

  /// Validates a passport number
  static String? validatePassportNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Passport number is required';
    }
    
    if (value.length < 5) {
      return 'Enter a valid passport number';
    }
    
    return null;
  }

  /// Validates nationality
  static String? validateNationality(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nationality is required';
    }
    
    if (value.length < 3) {
      return 'Enter a valid nationality';
    }
    
    return null;
  }

  /// Validates an OTP code
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    // OTPs are typically numeric and 4-6 digits
    final otpRegex = RegExp(r'^[0-9]{4,6}$');
    if (!otpRegex.hasMatch(value)) {
      return 'Enter a valid OTP';
    }
    
    return null;
  }
}
