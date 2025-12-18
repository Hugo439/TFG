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

  /// Devuelve los índices de recetas en el orden correcto:
  /// breakfast → lunch → snack → dinner
  List<int> getRecipeIndicesInOrder() {
    final indices = <int>[];
    if (breakfast != null) indices.add(breakfast!);
    if (lunch != null) indices.add(lunch!);
    if (snack != null) indices.add(snack!);
    if (dinner != null) indices.add(dinner!);
    return indices;
  }
}
