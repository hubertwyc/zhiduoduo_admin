import 'package:zhi_duo_duo/viewmodels/base_view_model.dart';

class PlatformDashboardViewModel extends BaseViewModel {
  List<PendingTask> pendingTask = [];
  Future<List<PendingTask>> loadPendingTask() async {
    return [
      PendingTask(task: '合作商申請審核	', status: '待審核'),
      PendingTask(task: '課程上架審核	', status: '待審核'),
    ];
  }
  Future<void> fetchPendingTask() async {
    setBusy(true);
    pendingTask = await loadPendingTask();
    setBusy(false);
    notifyListeners();
  }
}
class PendingTask {
  final String task;
  final String status;

  PendingTask({
    required this.task,
    required this.status
  });
}