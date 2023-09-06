import 'package:flutter/material.dart';
import 'package:researchtool/api/project.dart';

class DraftModel with ChangeNotifier {
  String _draft = "초안을 생성 중입니다...";
  bool _isTrained = false;
  String get draft => _draft;
  bool get isTrained => _isTrained;

  void getDraftStatusforState(draftId) async {
    _draft = "초안을 생성 중입니다...";
    _isTrained = false;
    final status = await ProjectAPI.getDraftStatus(draftId);

    _isTrained = true;
    _draft = status['draft'];
    notifyListeners();
  }

  void setDraft(String text) {
    _draft = text;
    notifyListeners();
  }
}
