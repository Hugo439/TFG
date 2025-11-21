class Validators {
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Correo electrónico inválido';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  static String? requiredValidator(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName obligatorio';
    }
    return null;
  }

  static String? numberValidator(String? value, [String fieldName = 'Número']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName obligatorio';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName debe ser un número válido';
    }
    return null;
  }

  static String? decimalValidator(String? value, [String fieldName = 'Número']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName obligatorio';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName debe ser un número válido';
    }
    return null;
  }

  static String? heightValidator(String? value) {
    final error = numberValidator(value, 'Altura');
    if (error != null) return error;
    
    final height = int.parse(value!);
    if (height < 50 || height > 300) {
      return 'Altura debe estar entre 50 y 300 cm';
    }
    return null;
  }

  static String? weightValidator(String? value) {
    final error = decimalValidator(value, 'Peso');
    if (error != null) return error;
    
    final weight = double.parse(value!);
    if (weight < 20 || weight > 500) {
      return 'Peso debe estar entre 20 y 500 kg';
    }
    return null;
  }
}