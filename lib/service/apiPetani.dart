import 'dart:convert';
import 'dart:ffi';
import 'package:flutter_pagination/models/petani_model.dart';
import 'package:flutter_pagination/models/kelompok.dart';
import 'package:flutter_pagination/models/erormsg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiStatic {
  static final String host = 'https://dev.wefgis.com';
  static String _token = "";

  /// Mengambil list Petani dengan pagination dan filter.
  /// [pageKey]: halaman saat ini (mulai dari 1)
  /// [_s]: keyword pencarian (kosongkan jika tidak ada)
  /// [_selectedChoice]: status publish, misal "Y"
  /// [pageSize]: jumlah data per halaman
  static Future<List<Petani>> getPetaniFilter(
    int pageKey,
    String _s,
    String _selectedChoice, {
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse("$host/api/petani").replace(queryParameters: {
        'page': pageKey.toString(),
        'size': pageSize.toString(),
        's': _s,
        'publish': _selectedChoice,
      });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        // Pastikan key 'data' ada dan merupakan List
        if (json.containsKey('data') && json['data'] is List) {
          final List<dynamic> list = json['data'];

          // Konversi JSON ke model
          final allData = list.map((item) => Petani.fromJson(item)).toList();

          // Filter berdasarkan angkatan (berdasarkan 2 digit awal dari nik)
          if (_selectedChoice.isNotEmpty) {
            return allData
                .where((petani) =>
                    petani.nik != nullptr &&
                    petani.nik.length >= 2 &&
                    petani.nik.startsWith(_selectedChoice))
                .toList();
          }

          return allData;
        } else {
          return [];
        }
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
        return [];
      }
    } catch (e, stack) {
      print('Exception in getPetaniFilter: $e');
      print(stack);
      return [];
    }
  }

  /// Menghapus data Petani berdasarkan [id].
  /// Kembalikan true jika berhasil, false jika gagal.
  static Future<bool> deletePetani(String idPenjual) async {
    try {
      final uri = Uri.parse("$host/api/petani/$idPenjual");
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Gagal hapus data petani, status: ${response.statusCode}');
        return false;
      }
    } catch (e, stack) {
      print('Exception in deletePetani: $e');
      print(stack);
      return false;
    }
  }

static Future<ErrorMSG> savePetani(id, petani, filepath) async {
    try {
      var url=Uri.parse('$host/api/petani');
      if(id != ''){
        url=Uri.parse('$host/api/petani/'+id);
      }    
      final request = http.MultipartRequest('POST', url)
      ..fields['nama'] = petani['nama']
      ..fields['nik'] = petani['nik']
      ..fields['alamat'] = petani['alamat']
      ..fields['telp'] = petani['telp']
      ..fields['id_kelompok_tani'] = petani['id_kelompok_tani']
      ..fields['status'] = petani['status'];

    if(filepath!=''){
        request.files.add(await http.MultipartFile.fromPath('foto', filepath));
      }
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {

          //print(jsonDecode(respStr));
          return ErrorMSG.fromJson(jsonDecode(responseBody));
        } else {
          //return ErrorMSG.fromJson(jsonDecode(response.body));
          return ErrorMSG(success: false,message: 'err Request');
        }
    } catch (e) {
      ErrorMSG responseRequest = ErrorMSG(success: false,message: 'error caught : $e');
      return responseRequest;
    }    
  }

static Future<bool> updatePetani(Petani petani) async {
  try {
    final response = await http.put(
      Uri.parse("https://dev.wefgis.com/api/petani/${petani.idPenjual}"),
      body: jsonEncode(petani.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      print('Failed to update petani: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Exception updatePetani: $e');
    return false;
  }
}

  static Future<List<Kelompok>> getKelompokTani() async{
    try {
      final response= await http.get(Uri.parse("$host/api/kelompoktani"),
      headers: {
        'Authorization':'Bearer '+_token,
      });      
      if (response.statusCode==200) {
        var json=jsonDecode(response.body);
        final parsed=json.cast<Map<String, dynamic>>();
        return parsed.map<Kelompok>((json)=>Kelompok.fromJson(json)).toList();
      } else {
        return [];
      }
      } catch (e) {
        return [];
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final response = await http.post(
      Uri.parse('$host/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "device_name": deviceName,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user_type', data['user']['type']);
      return {'success': true, 'type': data['user']['type']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    }
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  static Future<String?> getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> getToken() async {
    Future<SharedPreferences> preferences = SharedPreferences.getInstance();
    final SharedPreferences  prefs = await preferences;
    _token = prefs.getString('token') ?? "";
    }
  
}