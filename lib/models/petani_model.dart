class Petani{
  Petani({
        required this.idPenjual,
        required this.nama,
        required this.nik,
        required this.alamat,
        required this.telp,
        required this.foto,
        required this.idKelompokTani,
        required this.status,
        required this.namaKelompok,
        required this.createdAt,
        required this.updatedAt,
    });
    String idPenjual;
    String nama;
    String nik;
    String alamat;
    String telp;
    String foto;
    String idKelompokTani;
    String status;
    String namaKelompok;
    String createdAt;
    String updatedAt;
    
    factory Petani.fromJson(Map<String, dynamic> json) => Petani(
        idPenjual: json["id_penjual"].toString(),
        nama: (json["nama"]==null || json["nama"]=='')?'':json["nama"].toString(),
        nik: (json["nik"]==null || json["nik"]=='')?'':json["nik"].toString(),
        alamat: json["alamat"].toString(),
        telp: json["telp"].toString(),
        foto: json["foto"].toString(),
        idKelompokTani: json["id_kelompok_tani"].toString(),
        status: json["status"].toString(),
        namaKelompok: json["nama_kelompok"].toString(),
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
    );

    Map<String, dynamic> toJson() => {  
    "id_penjual": idPenjual,
    "nama": nama,
    "nik": nik,
    "alamat": alamat,
    "telp": telp,
    "foto": foto,
    "id_kelompok_tani": idKelompokTani,
    "status": status,
    "nama_kelompok": namaKelompok,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}