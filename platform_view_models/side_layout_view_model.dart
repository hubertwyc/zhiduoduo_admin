import 'package:flutter/foundation.dart';

class SideLayoutViewModel extends ChangeNotifier {
  int _hoverIndex = -1;
  int get hoverIndex => _hoverIndex;

  void setHoverIndex(int index) {
    if (_hoverIndex == index) return;
    _hoverIndex = index;
    notifyListeners();
  }
}