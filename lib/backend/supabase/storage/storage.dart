import '/flutter_flow/upload_data.dart';
import '../supabase.dart';

Future<List<String>> uploadSupabaseStorageFiles({
  required String bucketName,
  required List<SelectedFile> selectedFiles,
}) =>
    Future.wait(
      selectedFiles.map(
        (media) => uploadSupabaseStorageFile(
          bucketName: bucketName,
          selectedFile: media,
        ),
      ),
    );

Future<String> uploadSupabaseStorageFile({
  required String bucketName,
  required SelectedFile selectedFile,
}) async {
  final storageBucket = SupaFlow.client.storage.from(bucketName);
  await storageBucket.uploadBinary(
    selectedFile.storagePath,
    selectedFile.bytes,
    fileOptions: FileOptions(contentType: null),
  );
  return storageBucket.getPublicUrl(selectedFile.storagePath);
}

Future deleteSupabaseFileFromPublicUrl(String publicUrl) async {
  final storagePath = SupaFlow.client.storage.pathFromPublicUrl(publicUrl);
  if (storagePath == null) {
    return;
  }

  final bucketName = storagePath.split('/').first;
  final filePath = storagePath.split('/').skip(1).join('/');
  await SupaFlow.client.storage.from(bucketName).remove([filePath]);
}

extension _SupabaseBucketExtensions on SupabaseStorageClient {
  String? pathFromPublicUrl(String publicUrl) {
    final publicUrlPrefix = '$url/object/public/';
    final urlParts = publicUrl.split(publicUrlPrefix);
    if (urlParts.length != 2) {
      return null;
    }
    final fullStoragePath = urlParts.last;
    final storagePathParts = fullStoragePath.split('/');
    if (storagePathParts.length <= 1) {
      return null;
    }
    return fullStoragePath;
  }
}

/// Bucket privado para documentos de identidad y bancarios. A diferencia del
/// resto, aqui NO se guarda una URL publica: se guarda la RUTA, y el acceso se
/// concede firmandola en el momento de mostrarla. Una URL publica de estos
/// documentos seria legible por cualquiera que la tuviera, y los nombres son
/// marcas de tiempo, o sea enumerables.
const kBucketDocumentosPrivados = 'documentos-privados';

/// Sube al bucket privado y devuelve la ruta dentro del bucket.
Future<String> uploadSupabaseStoragePrivateFile({
  required SelectedFile selectedFile,
  String bucketName = kBucketDocumentosPrivados,
}) async {
  await SupaFlow.client.storage.from(bucketName).uploadBinary(
        selectedFile.storagePath,
        selectedFile.bytes,
        fileOptions: FileOptions(contentType: null, upsert: true),
      );
  return selectedFile.storagePath;
}

/// Firma una ruta del bucket privado. [segundos] es la validez del enlace.
Future<String> signedUrlForPrivatePath(
  String path, {
  int segundos = 3600,
  String bucketName = kBucketDocumentosPrivados,
}) =>
    SupaFlow.client.storage.from(bucketName).createSignedUrl(path, segundos);

/// True si el valor guardado es una ruta privada y no una URL publica.
/// Los registros antiguos y las certificaciones siguen siendo URLs http.
bool isPrivateStoragePath(String? valor) =>
    valor != null && valor.isNotEmpty && !valor.startsWith('http');

Future<void> deleteSupabasePrivateFile(
  String path, {
  String bucketName = kBucketDocumentosPrivados,
}) async {
  if (path.isEmpty) return;
  await SupaFlow.client.storage.from(bucketName).remove([path]);
}
