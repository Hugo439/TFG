/// Modelo de datos para distribución de recetas de IA por día.
///
/// Responsabilidad:
/// - Parsear índices de recetas desde respuesta JSON de IA
///
/// Campos:
/// - **breakfast**: índice de receta para desayuno en array recipes
/// - **lunch**: índice de receta para comida
/// - **snack**: índice de receta para merienda
/// - **dinner**: índice de receta para cena
///
/// Formato JSON esperado:
/// ```json
/// {
///   "breakfast": 0,  // índice en array recipes
///   "lunch": 4,
///   "snack": 8,
///   "dinner": 12
/// }
/// ```
///
/// Uso:
/// 1. AiMenuResponseModel contiene Map<String, DayMenuDataModel>
/// 2. Cada día apunta a índices del array de 28 recetas
/// 3. getRecipeIndicesInOrder() devuelve [0, 4, 8, 12] en orden correcto
class DayMenuDataModel {
  final int? breakfast;
  final int? lunch;
  final int? snack;
  final int? dinner;

  DayMenuDataModel({this.breakfast, this.lunch, this.snack, this.dinner});

  factory DayMenuDataModel.fromJson(Map<String, dynamic> json) {
    return DayMenuDataModel(
      breakfast: json['breakfast'] as int?,
      lunch: json['lunch'] as int?,
      snack: json['snack'] as int?,
      dinner: json['dinner'] as int?,
    );
  }

  /// Devuelve índices de recetas en orden correcto del día.
  ///
  /// Orden: breakfast → lunch → snack → dinner
  ///
  /// Usado por AiMenuMapper para mapear recetas a entidades.
  List<int> getRecipeIndicesInOrder() {
    final indices = <int>[];
    if (breakfast != null) indices.add(breakfast!);
    if (lunch != null) indices.add(lunch!);
    if (snack != null) indices.add(snack!);
    if (dinner != null) indices.add(dinner!);
    return indices;
  }
}
