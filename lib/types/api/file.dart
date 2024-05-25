class FileInfo {
  String? id;
  int? bytesRead;
  String? channel_id;
  String? clientId;
  int? create_at;
  int? delete_at;
  String extension;
  bool? failed;
  bool has_preview_image;
  int height;
  String? localPath;
  String mime_type;
  String? mini_preview;
  String name;
  String post_id;
  int size;
  int? update_at;
  String? uri;
  String user_id;
  int width;
  Map<String, dynamic>? postProps;
  FileInfo({required this.extension, required this.has_preview_image, required this.height, required this.mime_type, required this.name, required this.post_id, required this.size, required this.user_id, required this.width});
}

class FilesState {
  Map<String, FileInfo> files;
  Map<String, List<String>> fileIdsByPostId;
  String? filePublicLink;
  FilesState({required this.files, required this.fileIdsByPostId});
}

class FileUploadResponse {
  List<FileInfo> file_infos;
  List<String> client_ids;
  FileUploadResponse({required this.file_infos, required this.client_ids});
}

class FileSearchParams {
  String terms;
  bool is_or_search;
  FileSearchParams({required this.terms, required this.is_or_search});
}
