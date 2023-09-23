import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:researchtool/api/project.dart';

class DraftModel with ChangeNotifier {
  String _draft = "";
  // Task가 모두 끝났음을 나타내는 변수 : isTrained

  bool _isTrained = false;
  bool _embeddingComplete = false;
  bool _isCopied = false;
  String? _currentThumbnailImage;
  List<dynamic> _table = [];
  List<dynamic> _reference = [];

  String get draft => _draft;
  bool get isTrained => _isTrained;
  bool get isCopied => _isCopied;
  bool get embeddingComplete => _embeddingComplete;
  String? get currentThumbnailImage => _currentThumbnailImage;
  List<dynamic> get table => _table;
  List<dynamic> get reference => _reference;

  Future<int> genDraft(projectId) async {
    _draft = "초안을 생성 중입니다...";
    _isTrained = false;
    _embeddingComplete = false;
    _currentThumbnailImage = null;

    _table = [];
    _reference = [];
    int draftId = -1;
    await for (final message in ProjectAPI.genDraft(projectId)) {
      if (!_embeddingComplete) {
        draftId = int.parse(message.substring(3));
        _draft = "";
        _embeddingComplete = true;

        notifyListeners();
      } else {
        if (message.contains("<br/>")) {
          final newline = message.replaceAll('<br/>', '''
\n
\u200B 
\n
''');

          _draft += newline;
          notifyListeners();
          continue;
        }

        _draft += message;
        notifyListeners();
      }
    }

    _isTrained = true;
    await ProjectAPI.editOnlyDraft(draftId, _draft);
    notifyListeners();
    return draftId;
  }

  Future<int> reGenDraft(draftId) async {
    _draft = "초안을 재생성 중입니다...";
    _isTrained = false;

    bool isFirst = true;
    await for (final message in ProjectAPI.reGenDraft(draftId)) {
      if (isFirst) {
        _draft = "";
        isFirst = false;
        notifyListeners();
      } else {
        if (message.contains("<br/>")) {
          final newline = message.replaceAll('<br/>', '''




''');

          _draft += newline;
          notifyListeners();
          continue;
        }

        _draft += message;
        notifyListeners();
      }
    }

    _isTrained = true;
    await ProjectAPI.editOnlyDraft(draftId, _draft);
    notifyListeners();
    return draftId;
  }

  void getDraftStatusforState(draftId) async {
    _draft = "";
    _isTrained = false;
    _reference = [];
    _table = [];
    _currentThumbnailImage = null;
    final status = await ProjectAPI.getDraftStatus(draftId);

    _isTrained = true;
    _embeddingComplete = true;

    _draft = status['draft'].replaceAll('<br/>', '''




''');

    _table = status['table'];
    _reference = status['source'];
    _currentThumbnailImage = status['image_link'];
    notifyListeners();
  }

  void editDraftwithAI(
      int draftId, String userInput, String selectedContents) async {
    await ProjectAPI.editOnlyDraft(draftId, _draft);
    if (userInput.isNotEmpty && selectedContents.isNotEmpty) {
      int startIndex = _draft.indexOf(selectedContents);

      int endIndex;
      if (startIndex != -1) {
        endIndex = startIndex + selectedContents.length - 1;
      } else {
        endIndex = -1;
      }

      _draft = '''
${_draft.substring(0, startIndex)}  
---
  
  
수정 중입니다.
  
  
---

 ${_draft.substring(endIndex + 1)}
 ''';

      _isTrained = false;
      notifyListeners();

      final res = await ProjectAPI.editDraftwithAI(
          draftId, selectedContents, userInput);

      _draft = res;

      notifyListeners();
    } else {}

    _isTrained = true;

    notifyListeners();
  }

  void setDraft(String text, int draftId) {
    _draft = text;
    ProjectAPI.editOnlyDraft(draftId, _draft);
    notifyListeners();
  }

  void clickImage(String imageLink) {
    _currentThumbnailImage = imageLink;
    notifyListeners();
  }

  void copyDraft(text) async {
    Clipboard.setData(ClipboardData(text: text));
    _isCopied = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 3000));
    _isCopied = false;
    notifyListeners();
  }
}
