import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sentence.dart';
import '../models/quiz_history.dart';

class AIService {
  Future<String?> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gemini_api_key');
  }

  Future<Map<String, String>> correctJapaneseSentence(Sentence sentence) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key Gemini belum disetel. Silakan atur di menu Setelan.');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    final prompt = '''
Anda adalah guru bahasa Jepang ahli. Periksa input bahasa Jepang berikut.
Tugas Anda:
1. Pastikan tata bahasa Jepang (jpText) benar dan natural.
2. Pastikan jpText tersebut sesuai dengan arti bahasa Indonesianya.
3. Periksa apakah cara baca (reading/kana) dan Romaji sudah cocok dengan jpText-nya. Jika pengguna salah mengetik Romaji atau kana, perbaiki agar sesuai dengan jpText.
Jika ada kesalahan pada jpText, reading, romaji, atau meaning, perbaiki bagian tersebut.
Berikan juga penjelasan mendetail dalam bahasa Indonesia mengenai koreksinya. Khusus jika terdapat kesalahan tata bahasa (grammar) pada kalimat Jepang, mohon berikan penjelasan terstruktur mengenai struktur SPOK (Subjek, Predikat, Objek, Keterangan) dari kalimat yang benar agar pengguna lebih paham.

Kalimat Jepang: "${sentence.jpText}"
Cara Baca (Kana): "${sentence.reading}"
Romaji: "${sentence.romaji}"
Arti Indonesia: "${sentence.meaning}"

Balas HANYA dalam format JSON dengan struktur berikut (tanpa blok markdown ```json):
{
  "corrected_jp": "kalimat bahasa jepang hasil koreksi",
  "corrected_reading": "cara baca kana hasil koreksi",
  "corrected_romaji": "romaji hasil koreksi",
  "corrected_meaning": "arti bahasa indonesia hasil koreksi",
  "explanation": "penjelasan singkat dalam bahasa Indonesia",
  "category": "kategori kesalahan (contoh: Romaji, Partikel, Kosakata, dll). Kosongkan jika tidak ada kesalahan."
}
''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null) {
        String jsonString = response.text!.trim();
        if (jsonString.startsWith('```json')) {
          jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
        } else if (jsonString.startsWith('```')) {
          jsonString = jsonString.replaceAll('```', '').trim();
        }
        
        final Map<String, dynamic> data = jsonDecode(jsonString);
        return {
          'corrected_jp': data['corrected_jp'] ?? sentence.jpText,
          'corrected_reading': data['corrected_reading'] ?? sentence.reading,
          'corrected_romaji': data['corrected_romaji'] ?? sentence.romaji,
          'corrected_meaning': data['corrected_meaning'] ?? sentence.meaning,
          'explanation': data['explanation'] ?? 'Tidak ada penjelasan.',
          'category': data['category'] ?? '',
        };
      } else {
        throw Exception('Tidak ada respons dari AI.');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi AI: $e');
    }
  }

  Future<List<QuizQuestion>> generateQuiz(List<Sentence> sentences) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key Gemini belum disetel. Silakan atur di menu Setelan.');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    // Prepare vocab list for prompt
    final vocabList = sentences.map((s) => '- Jepang: ${s.jpText} | Romaji: ${s.romaji} | Arti: ${s.meaning}').join('\n');

    final prompt = '''
Anda adalah guru bahasa Jepang interaktif. Saya memiliki daftar ${sentences.length} kosakata/kalimat berikut:
$vocabList

Buatlah kuis pilihan ganda berjumlah ${sentences.length} soal untuk menguji pemahaman saya terhadap daftar kosakata tersebut.
Tipe soal bisa berupa: terjemahan bahasa Jepang ke Indonesia, Indonesia ke Jepang, tebak partikel, tebak romaji, atau bacaan kanji.
Setiap soal harus memiliki 4 opsi jawaban (A, B, C, D) dan HANYA SATU opsi yang benar.

Berikan format balasan HANYA dalam JSON strict (tanpa markdown ```json).
Format JSON harus berupa Array of Object. Setiap object merepresentasikan 1 soal dengan struktur berikut:
[
  {
    "question": "Apa arti dari 食べる?",
    "options": ["Tidur", "Makan", "Minum", "Berjalan"],
    "correct_option": "Makan",
    "explanation": "食べる (taberu) artinya adalah Makan."
  }
]
Pastikan panjang Array sama dengan ${sentences.length}.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null) {
        String jsonString = response.text!.trim();
        if (jsonString.startsWith('```json')) {
          jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
        } else if (jsonString.startsWith('```')) {
          jsonString = jsonString.replaceAll('```', '').trim();
        }
        
        final List<dynamic> data = jsonDecode(jsonString);
        return data.map((item) => QuizQuestion(
          question: item['question'] ?? '',
          options: List<String>.from(item['options'] ?? []),
          correctOption: item['correct_option'] ?? '',
          userOption: '', // User hasn't answered yet
          explanation: item['explanation'] ?? '',
        )).toList();
      } else {
        throw Exception('Tidak ada respons dari AI.');
      }
    } catch (e) {
      throw Exception('Gagal membuat kuis: $e');
    }
  }
}

