import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/attributebadge.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ayah.dart';
import '../Colors.dart';
import '../services/quranapi.dart';

class AyahList extends StatefulWidget {
  final int surahNumber;
  const AyahList({super.key, required this.surahNumber});

  @override
  State<AyahList> createState() => _AyahListState();
}

class _AyahListState extends State<AyahList> {
  List<Ayah> ayahList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAyahData();
  }

  Future<void> fetchAyahData() async {
    try {
      final fetchedAyat = await QuranApi.fetchAyatBySurah(widget.surahNumber);
      setState(() {
        ayahList = fetchedAyat;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching ayat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
            'Daftar Ayat',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ayahList.isEmpty
          ? const Center(
          child: Text('Tidak ada ayat ditemukan',
              style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: ayahList.length,
        itemBuilder: (context, index) {
          final ayah = ayahList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: gray,
                borderRadius: BorderRadius.circular(16),
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nomor Ayat
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/svgs/nomor-surah.svg',
                                  width: 36,
                                  height: 36,
                                ),
                                Text(
                                  '${ayah.numberInSurah}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Teks Arab + Atribut
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Teks Arab
                              Text(
                                ayah.arabicText,
                                style: GoogleFonts.amiri(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Artinya
                    Text(
                      ayah.translation,
                      style: GoogleFonts.poppins(
                        color: text.withOpacity(0.85),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.left,
                    ),

                    const SizedBox(height: 20),
                    // Wrap atribut: ruku, manzil, etc
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (ayah.ruku != null)
                          AttributeBadge(
                            text: 'Ruku: ${ayah.ruku}',
                            iconPath: 'assets/svgs/ruku1.svg',
                            color: primary,
                          ),
                        if (ayah.manzil != null)
                          AttributeBadge(
                            text: 'Manzil: ${ayah.manzil}',
                            iconPath: 'assets/svgs/manzil1.svg',
                            color: primary,
                          ),
                        if (ayah.page != null)
                          AttributeBadge(
                            text: 'Page: ${ayah.page}',
                            iconPath: 'assets/svgs/page1.svg',
                            color: primary,
                          ),
                        if (ayah.sajda == true)
                          AttributeBadge(
                            text: 'Sajda',
                            iconPath: 'assets/svgs/sajda1.svg',
                            color: orange,
                          ),
                      ],
                    ),
                  ],
                ),
            ),
          );
        },
      ),
    );
  }
}

class InfoBadge extends StatelessWidget {
  final String label;
  final Color color;

  const InfoBadge({
    super.key,
    required this.label,
    this.color = Colors.white24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}