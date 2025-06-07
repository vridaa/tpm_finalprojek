class Transaksi {
  final int id;
  final int idUser;
  final int idProduk;
  final int jumlah;
  final double totalHarga;
  final String status;
  final String metodePembayaran;
  final String alamatPengiriman;
  final DateTime? waktuPengiriman;
  final String? trackingLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaksi({
    required this.id,
    required this.idUser,
    required this.idProduk,
    required this.jumlah,
    required this.totalHarga,
    this.status = 'pending',
    required this.metodePembayaran,
    required this.alamatPengiriman,
    this.waktuPengiriman,
    this.trackingLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      idUser: json['id_user'],
      idProduk: json['id_produk'],
      jumlah: json['jumlah'],
      totalHarga: json['total_harga'].toDouble(),
      status: json['status'],
      metodePembayaran: json['metode_pembayaran'],
      alamatPengiriman: json['alamat_pengiriman'],
      waktuPengiriman:
          json['waktu_pengiriman'] != null
              ? DateTime.parse(json['waktu_pengiriman'])
              : null,
      trackingLink: json['tracking_link'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class CreateTransaksiRequest {
  final int idProduk;
  final int jumlah;
  final double totalHarga;
  final String metodePembayaran;
  final String alamatPengiriman;
  final String? catatan;
  final int idUser;
  final String status;

  CreateTransaksiRequest({
    required this.idProduk,
    required this.jumlah,
    required this.totalHarga,
    required this.metodePembayaran,
    required this.alamatPengiriman,
    this.catatan,
    required this.idUser,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'id_produk': idProduk,
      'jumlah': jumlah,
      'total_harga': totalHarga,
      'metode_pembayaran': metodePembayaran,
      'alamat_pengiriman': alamatPengiriman,
      if (catatan != null) 'catatan': catatan,
      'id_user': idUser,
      'status': status,
    };
  }
}

class TransaksiResponse {
  final String message;
  final Transaksi? transaksi;

  TransaksiResponse({required this.message, this.transaksi});

  factory TransaksiResponse.fromJson(Map<String, dynamic> json) {
    return TransaksiResponse(
      message: json['message'],
      transaksi:
          json['data'] != null
              ? Transaksi.fromJson(json['data']['transaksi'])
              : null,
    );
  }
}
