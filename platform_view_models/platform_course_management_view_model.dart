import 'package:zhi_duo_duo/viewmodels/base_view_model.dart';
import 'package:zhi_duo_duo/core/services/api_service.dart';
import 'package:zhi_duo_duo/locator.dart';

class PlatformCourseManagementViewModel extends BaseViewModel {
  final ApiService api = locator<ApiService>();
  List<Course> courseList = [];
  String? selectedCourseStatus; // null=全部, 'approved'=已審核, 'pending'=未審核
  bool hasSearched = false; // 追蹤是否已經執行過查詢
  // Future<List<Course>> loadCourseList() async {
  //   return [
  //     Course(
  //       id: 'C-1001',
  //       courseName: 'Python 入門',
  //       teacher: '張老師',
  //       institution: 'ABC 補習班',
  //       startDate: '2025-06-01',
  //       status: '進行中',
  //       totalAmount: 'NT\$ 0',
  //     ),
  //
  //     Course(
  //       id: 'C-1002',
  //       courseName: 'Flutter 全端開發',
  //       teacher: '李講師',
  //       institution: '無',
  //       startDate: '2025-06-10',
  //       status: '待上架',
  //       totalAmount: 'NT\$ 0',
  //     ),
  //
  //     Course(
  //       id: 'C-1003',
  //       courseName: '數學基礎班',
  //       teacher: '陳老師',
  //       institution: 'DEF 補習班',
  //       startDate: '2025-07-01',
  //       status: '進行中',
  //       totalAmount: 'NT\$ 0',
  //     ),
  //
  //     Course(
  //       id: 'C-1004',
  //       courseName: 'Java 程式設計',
  //       teacher: '王講師',
  //       institution: 'GHI 補習班',
  //       startDate: '2025-05-15',
  //       status: '已結束',
  //       totalAmount: 'NT\$ 45,000',
  //     ),
  //
  //     Course(
  //       id: 'C-1005',
  //       courseName: '英文會話進階',
  //       teacher: 'Smith 老師',
  //       institution: 'JKL 補習班',
  //       startDate: '2025-08-01',
  //       status: '待上架',
  //       totalAmount: 'NT\$ 0',
  //     ),
  //
  //   ];
  // }
  // Future<void> fetchCourseList() async {
  //   setBusy(true);
  //   courseList = await loadCourseList();
  //   setBusy(false);
  //   notifyListeners();
  // }
  // 設置課程狀態篩選
  void setCourseStatus(String? status) {
    selectedCourseStatus = status;
    notifyListeners();
  }

  // 根據狀態篩選載入課程
  Future<void> loadCourses() async {
    setBusy(true);
    hasSearched = true; // 標記已經執行查詢
    try {
      String endpoint;
      if (selectedCourseStatus == 'pending') {
        // 獲取未審核課程
        endpoint = '/course/pending';
      } else if (selectedCourseStatus == 'approved') {
        // 獲取已審核課程（passed 和 rejected）
        endpoint = '/admin/courses';
      } else {
        // 獲取全部課程
        endpoint = '/admin/courses';
      }

      final response = await api.get(endpoint);
      if (response['status'] == 'success') {
        // 根據不同 API 使用不同的 key
        List<dynamic> results;
        if (selectedCourseStatus == 'pending') {
          // /course/pending 返回 'courses' key
          results = response['courses'] ?? [];
        } else {
          // /admin/courses 返回 'data' key
          results = response['data'] ?? [];
        }
        
        // 如果選擇「已審核」，過濾掉 pending 狀態
        List<dynamic> filteredResults = results;
        if (selectedCourseStatus == 'approved') {
          filteredResults = results.where((item) {
            final status = item['status'] ?? '';
            return status != 'pending';
          }).toList();
        }
        
        courseList = filteredResults.map((item) {
          return Course(
            id: item['id']?.toString() ?? '',
            courseName: item['course_name'] ?? '',
            teacher: item['teacher_name'] ?? item['teacher'] ?? '',
            institution: item['institution'] ?? '',
            startDate: item['start_date'] ?? '',
            status: item['status'] ?? '',
            totalAmount: item['price'].toString(),
          );
        }).toList();
      } else {
        courseList = [];
      }
    } catch (e) {
      print('Error loading courses: $e');
      courseList = [];
    }
    setBusy(false);
    notifyListeners();
  }

  // 獲取課程詳細信息
  Future<Map<String, dynamic>?> fetchCourseDetail(String courseId) async {
    setBusy(true);
    try {
      final response = await api.get('/admin/courses/$courseId');
      setBusy(false);
      if (response['status'] == 'success') {
        return response['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching course detail: $e');
      setBusy(false);
      return null;
    }
  }

  // 獲取課程學生列表
  Future<List<dynamic>> fetchCourseStudents(String courseId) async {
    setBusy(true);
    try {
      final response = await api.get('/admin/$courseId/student-list');
      if (response['status'] == 'success') {
        setBusy(false);
        return response['students'] ?? [];
      } else {
        setBusy(false);
        return [];
      }
    } catch (e) {
      setBusy(false);
      return [];
    }
  }

  // 審核課程（通過或不通過）
  Future<bool> reviewCourse(String courseId, String status) async {
    setBusy(true);
    try {
      print('[reviewCourse] start: $courseId, $status');
      final response = await api.put(
        '/admin/course/$courseId/review_noauth',
        body: {
          'status': status, // 'passed' 或 'rejected'
        },
      );
      print('[reviewCourse] response: $response');
      setBusy(false);
      if (response['status'] == 'success') {
        print('[reviewCourse] success, reload courses');
        await loadCourses();
        print('[reviewCourse] reload done');
        return true;
      }
      print('[reviewCourse] failed, status: ${response['status']}');
      return false;
    } catch (e, s) {
      print('[reviewCourse] Error: $e');
      print('[reviewCourse] Stack: $s');
      setBusy(false);
      return false;
    }
  }
}

class Course {
  final String id;
  final String courseName;
  final String teacher;
  final String institution;
  final String startDate;
  final String status;
  final String totalAmount;

  Course({
    required this.id,
    required this.courseName,
    required this.teacher,
    required this.institution,
    required this.startDate,
    required this.status,
    required this.totalAmount,
  });
}
