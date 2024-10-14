class DynamicSetting {
  String label;
  String unit;
  double value;
  Function(double) onSave;

  DynamicSetting({
    required this.label,
    required this.unit,
    required this.value,
    required this.onSave,
  });
}
