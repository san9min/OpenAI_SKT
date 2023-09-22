import 'package:file_picker/file_picker.dart';

class FileData {
  int serverId; //BE ID
  int fileListId; //FE ID
  PlatformFile contents;

  FileData({
    required this.fileListId,
    required this.serverId,
    required this.contents,
  });
}
