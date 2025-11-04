import 'package:zhi_duo_duo/core/services/api_service.dart';
import 'package:zhi_duo_duo/locator.dart';
import 'package:zhi_duo_duo/viewmodels/base_view_model.dart';

class PlatformMemberManagementViewModel extends BaseViewModel {
  final ApiService api = locator<ApiService>();
  List<Member> memberList = [];
  // Future<List<Member>> loadMemberList() async {
  //   return [
  //     Member(id: '001', name: '王小明', email: 'xm@example.com', status: '啟用'),
  //     Member(id: '002', name: '陳小華', email: 'ch@example.com', status: '啟用'),
  //     Member(id: '003', name: '林小美', email: 'lm@example.com', status: '停用'),
  //     Member(id: '004', name: '張小強', email: 'zq@example.com', status: '啟用'),
  //     Member(id: '005', name: '李小雅', email: 'ly@example.com', status: '啟用'),
  //     Member(id: '006', name: '劉小東', email: 'ld@example.com', status: '停用'),
  //     Member(id: '007', name: '黃小文', email: 'hw@example.com', status: '啟用'),
  //     Member(id: '008', name: '吳小萍', email: 'wp@example.com', status: '待審核'),
  //     Member(id: '009', name: '趙小宇', email: 'zy@example.com', status: '待審核'),
  //     Member(id: '010', name: '孫小佳', email: 'sj@example.com', status: '啟用'),
  //   ];
  // }
  //
  // Future<void> fetchMemberList() async {
  //   setBusy(true);
  //   memberList = await loadMemberList();
  //   setBusy(false);
  //   notifyListeners();
  // }

  Future<void> fetchStudentFromApi() async {
    setBusy(true);
    try {
      final response = await api.get('/admin/students');

      if (response['status'] == 'success') {
        final List<dynamic> results = response['data'];
        memberList = results.map((item) {
          return Member(
            id: item['id'] ?? '',
            name: item['user_name'] ?? '',
            email: item['email'] ?? '',
            status: item['status'] ?? '未知',
          );
        }).toList();
      } else {
        memberList = [];
      }
    } catch (e) {
      // 失敗就給空清單
      memberList = [];
    }
    setBusy(false);
    notifyListeners();
  }
  Future<Member?> fetchStudentDetail(String userId) async {
    setBusy(true);
    try {
      final response = await api.get('/admin/students/$userId');

      if (response['status'] == 'success') {
        final data = response['data'];

        final member = Member(
          id: data['id'] ?? '',
          name: data['user_name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'],
          birthday: data['birthday'],
          gender: data['gender'],
          joinTime: data['join_time'],
          status: data['status'] ?? '未知',
        );
        return member;
      }
    } catch (e) {
      return null;
    } finally {
      setBusy(false);
    }
    return null;
  }
  Future<void> updateStudentStatus(String userId, String newStatus) async {
    setBusy(true);
    try {
      final response = await api.put('/admin/students/$userId/status', body: {'status': newStatus});

      if (response['status'] == 'success') {
        // 更新成功，只更新本地列表中的特定會員狀態，不重新獲取整個列表
        final memberIndex = memberList.indexWhere((member) => member.id == userId);
        if (memberIndex != -1) {
          final oldMember = memberList[memberIndex];
          memberList[memberIndex] = Member(
            id: oldMember.id,
            name: oldMember.name,
            email: oldMember.email,
            phone: oldMember.phone,
            birthday: oldMember.birthday,
            gender: oldMember.gender,
            joinTime: oldMember.joinTime,
            status: newStatus,
          );
        }
      }
    } catch (e) {
      // 處理錯誤
    } finally {
      setBusy(false);
    }
    notifyListeners();
  }
}

class Member {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? birthday;
  final String? gender;
  final String? joinTime;
  final String status;

  Member({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.birthday,
    this.gender,
    this.joinTime,
    required this.status,
  });
}