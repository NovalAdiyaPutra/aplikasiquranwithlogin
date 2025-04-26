class Ayah {
  final String arabicText;
  final String translation;
  final int numberInSurah;
  final int? ruku;
  final int? manzil;
  final int? page;
  final bool? sajda;

  Ayah({
    required this.arabicText,
    required this.translation,
    required this.numberInSurah,
    this.ruku,
    this.manzil,
    this.page,
    this.sajda,
  });

}
