class Validators {
  
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
  );

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!passwordRegex.hasMatch(password)) {
      return 'Password must contain uppercase, number, and special character';
    }
    return null;
  }

  static String? validateDisplayName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePasswordMatch(
    String? password,
    String? confirmPassword,
  ) {
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
