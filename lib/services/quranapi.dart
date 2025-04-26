import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/ayah.dart';

class QuranApi {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  // Ambil daftar surah
  static Future<List<Surah>> fetchSurahList() async {
    final response = await http.get(Uri.parse('$baseUrl/surah'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> surahs = data['data'];
      return surahs.map((e) => Surah.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load surah list');
    }
  }

  // Ambil daftar ayat dari suatu surah (gabungkan Arab + Indo)
  static Future<List<Ayah>> fetchAyatBySurah(int surahNumber) async {
    final arabUrl = Uri.parse('$baseUrl/surah/$surahNumber');
    final indoUrl = Uri.parse('$baseUrl/surah/$surahNumber/id.indonesian');

    final arabResponse = await http.get(arabUrl);
    final indoResponse = await http.get(indoUrl);

    final sajdaResponse = await http.get(Uri.parse('$baseUrl/sajda/en.asad'));

    if (arabResponse.statusCode == 200 &&
        indoResponse.statusCode == 200 &&
        sajdaResponse.statusCode == 200) {
      final arabAyahs = json.decode(arabResponse.body)['data']['ayahs'] as List;
      final indoAyahs = json.decode(indoResponse.body)['data']['ayahs'] as List;
      final sajdaAyahs = json.decode(sajdaResponse.body)['data']['ayahs'] as List;

      // Mapping nomor ayat global yang termasuk sajda
      final sajdaNumbers = sajdaAyahs.map((e) => e['number']).toSet();

      // Cek dan hapus Bismillah
      if (arabAyahs.isNotEmpty && surahNumber != 1 && surahNumber != 9) {
        const bismillah = "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ";
        const bismillahId = "Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang";

        final firstArabic = arabAyahs[0]['text'] as String;
        final firstTranslation = indoAyahs[0]['text'] as String;

        if (firstArabic.startsWith(bismillah)) {
          arabAyahs[0]['text'] = firstArabic.replaceFirst(bismillah, '').trim();
          indoAyahs[0]['text'] = firstTranslation.replaceFirst(bismillahId, '').trim();
        }
      }

      // Gabungkan semua ayat beserta atribut tambahan
      List<Ayah> combined = [];
      for (int i = 0; i < arabAyahs.length; i++) {
        final arabAyah = arabAyahs[i];
        final indoAyah = indoAyahs[i];

        final number = arabAyah['number']; // global number
        final sajda = sajdaNumbers.contains(number);
        // final audioUrl = await _fetchAudioUrl(number);

        combined.add(
          Ayah(
            arabicText: arabAyah['text'],
            translation: indoAyah['text'],
            numberInSurah: arabAyah['numberInSurah'],
            ruku: arabAyah['ruku'],
            manzil: arabAyah['manzil'],
            page: arabAyah['page'],
            sajda: sajda,
            // audioUrl: audioUrl,
          ),
        );
      }

      return combined;
    } else {
      throw Exception('Failed to load ayat or sajda data');
    }
  }

  //Ambil data ruku
  static Future<List<Map<String, dynamic>>> fetchRukuMeta(int rukuNumber) async {
    final url = Uri.parse('$baseUrl/ruku/$rukuNumber/en.asad');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayahs = data['data']['ayahs'] as List;

      return ayahs.map((ayah) {
        return {
          'ruku': ayah['ruku'],
          'manzil': ayah['manzil'],
          'numberInSurah': ayah['numberInSurah'],
          'surahNumber': ayah['surah']['number'],
          'surahName': ayah['surah']['englishName']
        };
      }).toList();
    } else {
      throw Exception('Failed to load ruku metadata');
    }
  }

  // Ambil data manzil
  static Future<List<Map<String, dynamic>>> fetchManzilMeta(int manzilNumber) async {
    final url = Uri.parse('$baseUrl/manzil/$manzilNumber/en.asad');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayahs = data['data']['ayahs'] as List;

      return ayahs.map((ayah) {
        return {
          'ruku': ayah['ruku'],
          'manzil': ayah['manzil'],
          'numberInSurah': ayah['numberInSurah'],
          'surahNumber': ayah['surah']['number'],
          'surahName': ayah['surah']['englishName']
        };
      }).toList();
    } else {
      throw Exception('Failed to load manzil metadata');
    }
  }

  // Ambil data Page
  static Future<List<Map<String, dynamic>>> fetchPageMeta(int pageNumber) async {
    final url = Uri.parse('$baseUrl/page/$pageNumber/en.asad');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayahs = data['data']['ayahs'] as List;

      return ayahs.map((ayah) {
        return {
          'page': ayah['page'],
          'ruku': ayah['ruku'],
          'manzil': ayah['manzil'],
          'numberInSurah': ayah['numberInSurah'],
          'surahNumber': ayah['surah']['number'],
          'surahName': ayah['surah']['englishName']
        };
      }).toList();
    } else {
      throw Exception('Failed to load page metadata');
    }
  }

  // Ambil data sajda
  static Future<List<Map<String, dynamic>>> fetchSajdaAyahs() async {
    final url = Uri.parse('$baseUrl/sajda/en.asad');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final ayahs = data['data']['ayahs'] as List;

      return ayahs.map((ayah) {
        final sajdaInfo = ayah['sajda'];
        return {
          'number': ayah['number'],
          'surahNumber': ayah['surah']['number'],
          'surahName': ayah['surah']['englishName'],
          'numberInSurah': ayah['numberInSurah'],
          'juz': ayah['juz'],
          'manzil': ayah['manzil'],
          'page': ayah['page'],
          'ruku': ayah['ruku'],
          'sajdaRecommended': sajdaInfo['recommended'],
          'sajdaObligatory': sajdaInfo['obligatory'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load sajda ayahs');
    }
  }

  // Ambil Audio
  // static Future<String> _fetchAudioUrl(int ayahNumber) async {
  //   final response = await http.get(Uri.parse('$baseUrl/ayah/$ayahNumber/ar.alafasy'));
  //
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     return data['data']['audio'];
  //   } else {
  //     throw Exception('Failed to load audio');
  //   }
  // }
}