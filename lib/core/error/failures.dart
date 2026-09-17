abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Terjadi kesalahan pada server']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal memuat data dari penyimpanan lokal']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Gagal mendapatkan lokasi GPS']);
}
