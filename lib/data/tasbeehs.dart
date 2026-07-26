/// Popular tasbeehs with Arabic text, transliteration, and translations.
class Tasbeeh {
  final String id;
  final String arabic;
  final String transliteration;
  final String english;
  final String urdu;

  /// Traditional count for one round.
  final int target;

  const Tasbeeh({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.english,
    required this.urdu,
    required this.target,
  });
}

const List<Tasbeeh> kTasbeehs = [
  Tasbeeh(
    id: 'subhanallah',
    arabic: 'سُبْحَانَ اللهِ',
    transliteration: 'SubhanAllah',
    english: 'Glory be to Allah',
    urdu: 'اللہ پاک ہے',
    target: 33,
  ),
  Tasbeeh(
    id: 'alhamdulillah',
    arabic: 'الْحَمْدُ لِلَّهِ',
    transliteration: 'Alhamdulillah',
    english: 'All praise is for Allah',
    urdu: 'تمام تعریفیں اللہ کے لیے ہیں',
    target: 33,
  ),
  Tasbeeh(
    id: 'allahuakbar',
    arabic: 'اللهُ أَكْبَرُ',
    transliteration: 'Allahu Akbar',
    english: 'Allah is the Greatest',
    urdu: 'اللہ سب سے بڑا ہے',
    target: 34,
  ),
  Tasbeeh(
    id: 'lailahaillallah',
    arabic: 'لَا إِلَٰهَ إِلَّا اللهُ',
    transliteration: 'La ilaha illallah',
    english: 'There is no god but Allah',
    urdu: 'اللہ کے سوا کوئی معبود نہیں',
    target: 100,
  ),
  Tasbeeh(
    id: 'astaghfirullah',
    arabic: 'أَسْتَغْفِرُ اللهَ',
    transliteration: 'Astaghfirullah',
    english: 'I seek forgiveness from Allah',
    urdu: 'میں اللہ سے معافی مانگتا ہوں',
    target: 100,
  ),
  Tasbeeh(
    id: 'subhanallahi_wa_bihamdihi',
    arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
    transliteration: 'SubhanAllahi wa bihamdihi',
    english: 'Glory be to Allah and all praise is His',
    urdu: 'اللہ پاک ہے اور اسی کی تعریف ہے',
    target: 100,
  ),
  Tasbeeh(
    id: 'subhanallahil_azeem',
    arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ الْعَظِيمِ',
    transliteration: 'SubhanAllahi wa bihamdihi, SubhanAllahil-Azeem',
    english:
        'Glory and praise be to Allah; glory be to Allah, the Magnificent',
    urdu: 'اللہ پاک ہے اپنی حمد کے ساتھ، اللہ عظمت والا پاک ہے',
    target: 33,
  ),
  Tasbeeh(
    id: 'lahawla',
    arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
    transliteration: 'La hawla wa la quwwata illa billah',
    english: 'There is no power nor might except with Allah',
    urdu: 'گناہ سے بچنا اور نیکی کی طاقت صرف اللہ کی توفیق سے ہے',
    target: 100,
  ),
  Tasbeeh(
    id: 'durood',
    arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
    transliteration: 'Allahumma salli \'ala Muhammadin wa \'ala aali Muhammad',
    english:
        'O Allah, send blessings upon Muhammad and upon the family of Muhammad',
    urdu: 'اے اللہ، محمد ﷺ اور آلِ محمد پر درود بھیج',
    target: 100,
  ),
];
