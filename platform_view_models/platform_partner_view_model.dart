import 'package:zhi_duo_duo/viewmodels/base_view_model.dart';
import 'package:zhi_duo_duo/core/services/api_service.dart';
import 'package:zhi_duo_duo/locator.dart';

class PlatformPartnerViewModel extends BaseViewModel {
  final ApiService api = locator<ApiService>();
  final List<String> partnerType = ['教育機構', '老師', '場地方'];
  String? selectedPartnerType;
  bool hasSearched = false; // 追蹤是否已執行過查詢
  
  setPartnerType(String? partnerType) {
    selectedPartnerType = partnerType;
    notifyListeners();
  }
  List<Partner> partner = [];
  List<Partner> institution = [];
  List<Partner> teacher = [];
  List<Partner> venue = [];
  Future<List<Partner>> loadPartner() async {
    return [
      Partner(id: 'A01', name: '哈佛文理補習班', type: '機構', status: '啟用'),
      Partner(id: 'B01', name: '張老師', type: '老師', status: '啟用'),
      Partner(id: 'C01', name: '成大教學大樓', type: '場地方	', status: '啟用'),
      Partner(id: 'B02', name: '陳講師	', type: '老師	', status: '啟用'),
    ];
  }
  Future<List<Partner>> loadInstitution() async {
    return [
      Partner(id: 'A01', name: '哈佛文理補習班', type: '教育機構', status: '啟用'),
      Partner(id: 'A02', name: '台大進修學院', type: '教育機構', status: '停用'),
      Partner(id: 'A03', name: '建國補習班', type: '教育機構', status: '啟用'),
      Partner(id: 'A04', name: '台北語言中心', type: '教育機構', status: '審核中'),
      Partner(id: 'A05', name: '成大資工補習班', type: '教育機構', status: '啟用'),
      Partner(id: 'A06', name: '高雄理工學院', type: '教育機構', status: '停用'),
    ];
  }
  Future<List<Partner>> loadTeacher() async {
    return [
      Partner(id: 'B01', name: '張老師', type: '老師', status: '啟用'),
      Partner(id: 'B02', name: '陳講師	', type: '老師	', status: '啟用'),
      Partner(id: 'B03', name: '王老師', type: '老師', status: '停用'),
      Partner(id: 'B04', name: '林教授', type: '老師', status: '審核中'),
      Partner(id: 'B05', name: '李講師', type: '老師', status: '啟用'),
    ];
  }
  Future<List<Partner>> loadVenue() async {
    return [
      Partner(id: 'C01', name: '成大教學大樓', type: '場地方	', status: 'success'),
      Partner(id: 'C02', name: '台北會議中心', type: '場地方', status: 'success'),
      Partner(id: 'C03', name: '高雄展覽館', type: '場地方', status: 'reject'),
      Partner(id: 'C04', name: '台中國際會堂', type: '場地方', status: 'pending'),
      Partner(id: 'C05', name: '新竹教育館', type: '場地方', status: 'success'),
    ];
  }

  Future<List<Partner>> loadTeachersFromApi() async {
    try {
      final response = await api.get('/admin/teachers');
      if (response['status'] == 'success') {
        final List<dynamic> results = response['data'];
        return results.map((item) {
          return Partner(
            id: item['id'] ?? '',
            name: item['user_name'] ?? '',
            type: '老師',
            status: item['status'] ?? ''
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Partner>> loadInstitutionsFromApi() async {
    try {
      final response = await api.get('/admin/institutions');
      if (response['status'] == 'success') {
        final List<dynamic> results = response['data'];
        return results.map((item) {
          return Partner(
            id: item['id'].toString(),
            name: item['institution_name'] ?? '',
            type: '教育機構',
            status: item['status'] ?? ''
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Partner>> loadVenuesFromApi() async {
    try {
      final response = await api.get('/admin/venues');
      if (response['status'] == 'success') {
        final List<dynamic> results = response['data'];
        return results.map((item) {
          return Partner(
            id: item['id'].toString(),
            name: item['venue_name'] ?? '',
            type: '場地方',
            status: item['status'] ?? ''
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Teacher?> loadTeacherDetail(String userId) async {
    try {
      final response = await api.get('/admin/teachers/$userId');

      if (response['status'] == 'success') {
        final data = response['data'];

        final teacher = Teacher(
          id: data['id'] ?? '',
          name: data['user_name'] ?? '',
          birthdate: data['birthdate'],
          gender: data['gender'],
          email: data['email'] ?? '',
          phone: data['phone'],
          status: data['status'] ?? '未知'
        );
        return teacher;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<Institution?> loadInstitutionDetail(String userId) async {
    try {
      final response = await api.get('/admin/institutions/$userId');

      if (response['status'] == 'success') {
        final data = response['data'];

        final institution = Institution(
          id: data['id'] ?? '',
          institutionName: data['institution_name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
          address: data['address'] ?? '',
          businessNumber: data['business_number'] ?? '',
        );
        return institution;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<Venue?> loadVenueDetail(String userId) async {
    try {
      final response = await api.get('/admin/venues/$userId');

      if (response['status'] == 'success') {
        final data = response['data'];

        final venue = Venue(
          id: data['id']?.toString() ?? '',
          venueName: data['venue_name'],
          representName: data['represent_name'],
          representBirthday: data['represent_birthday'],
          representGender: data['represent_gender'],
          email: data['email'],
          phone: data['phone'],
          address: data['address'],
          venueManager: data['venue_manager'],
          unifiedNumber: data['unified_number'],
          businessRegistration: data['business_registration'],
          venueSize: data['venue_size'],
          classroomCount: data['classroom_count'],
          availableDaysPerWeek: data['available_days_per_week'],
          maxStudentCapacity: data['max_student_capacity'],
          availableEquipment: data['available_equipment'],
          venueDescription: data['venue_description'],
          bankAccount: data['bank_account'],
          status: data['status'] ?? '未知'
        );
        return venue;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  

  Future<void> fetchPartner() async {
    setBusy(true);
    hasSearched = true; // 標記已執行過查詢
    
    switch (selectedPartnerType) {
      case '教育機構':
        // partner = await loadInstitution();
        partner = await loadInstitutionsFromApi();
        break;
      case '老師':
        // partner = await loadTeacher();
        partner = await loadTeachersFromApi();
        break;
      case '場地方':
        partner = await loadVenuesFromApi();
        break;
      default:
        partner = []; // 沒選類型就清空
    }

    setBusy(false);
    notifyListeners();
  }
  Future<dynamic> fetchPartnerDetail(String userId, String partnerType) async {
    dynamic result;
    switch (partnerType) {
      case '教育機構':
        result = await loadInstitutionDetail(userId);
        break;
      case '老師':
        result = await loadTeacherDetail(userId);
        break;
      case '場地方':
        result = await loadVenueDetail(userId);
        break;
      default:
        result = null; // 沒選類型就清空
    }
    return result;
  }

  Future<void> updatePartnerStatus(String partnerId, String partnerType, String newStatus) async {
    setBusy(true);
    try {
      String endpoint;
      switch (partnerType) {
        case '教育機構':
          endpoint = '/admin/institutions/$partnerId/status';
          break;
        case '老師':
          endpoint = '/admin/teachers/$partnerId/status';
          break;
        case '場地方':
          endpoint = '/admin/venues/$partnerId/status';
          break;
        default:
          setBusy(false);
          return;
      }

      final response = await api.put(endpoint, body: {'status': newStatus});

      if (response['status'] == 'success') {
        // 更新成功，只更新本地列表中的特定合作商狀態，不重新獲取整個列表
        final partnerIndex = partner.indexWhere((p) => p.id == partnerId);
        if (partnerIndex != -1) {
          final oldPartner = partner[partnerIndex];
          partner[partnerIndex] = Partner(
            id: oldPartner.id,
            name: oldPartner.name,
            type: oldPartner.type,
            phone: oldPartner.phone,
            birthdate: oldPartner.birthdate,
            gender: oldPartner.gender,
            nickName: oldPartner.nickName,
            education: oldPartner.education,
            createTime: oldPartner.createTime,
            updateTime: oldPartner.updateTime,
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

class Partner {
  final String id;
  final String name;
  final String type;
  final String? phone;
  final String? birthdate;
  final String? gender;
  final String? nickName;
  final String? education;
  final String? createTime;
  final String? updateTime;
  final String status;

  Partner({
    required this.id,
    required this.name,
    required this.type,
    this.phone,
    this.birthdate,
    this.gender,
    this.nickName,
    this.education,
    this.createTime,
    this.updateTime,
    required this.status
  });
}

class Teacher {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? birthdate;
  final String? gender;
  final String? nickName;
  final String? education;
  final String? createTime;
  final String? updateTime;
  final String status;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.birthdate,
    this.gender,
    this.nickName,
    this.education,
    this.createTime,
    this.updateTime,
    required this.status
  });
}

class Institution {
  final String? id;
  final String? authUid;
  final String? parentId;
  final String? institutionName;
  final String? email;
  final String? phone;
  final DateTime? createTime;
  final DateTime? updateTime;
  final String? address;
  final String? owner;
  final String? taxId;
  final String? bankAccount;
  final String? approvalNumber;
  final String? businessNumber;
  final String? description;
  final bool? valid;
  final Map<String, dynamic>? reviewLog;
  final String? status;
  final String? image;

  Institution({
    this.id,
    this.authUid,
    this.parentId,
    this.institutionName,
    this.email,
    this.phone,
    this.createTime,
    this.updateTime,
    this.address,
    this.owner,
    this.taxId,
    this.bankAccount,
    this.approvalNumber,
    this.businessNumber,
    this.description,
    this.valid,
    this.reviewLog,
    this.status,
    this.image,
  });
}

class Venue {
  final String id;
  final String? venueName;
  final String? representName;
  final String? representBirthday;
  final String? representGender;
  final String? email;
  final String? phone;
  final String? address;
  final String? venueManager;
  final String? unifiedNumber;
  final String? businessRegistration;
  final String? venueSize;
  final int? classroomCount;
  final int? availableDaysPerWeek;
  final int? maxStudentCapacity;
  final String? availableEquipment;
  final String? venueDescription;
  final String? bankAccount;
  final String status;

  Venue({
    required this.id,
    this.venueName,
    this.representName,
    this.representBirthday,
    this.representGender,
    this.email,
    this.phone,
    this.address,
    this.venueManager,
    this.unifiedNumber,
    this.businessRegistration,
    this.venueSize,
    this.classroomCount,
    this.availableDaysPerWeek,
    this.maxStudentCapacity,
    this.availableEquipment,
    this.venueDescription,
    this.bankAccount,
    required this.status,
  });
}

// /// Partner model
// class Partner {
//   final String id;
//   final String name;
//   final String type;
//   final String status;
//
//   Partner({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.status,
//   });
//
//   factory Partner.fromJson(Map<String, dynamic> json) {
//     return Partner(
//       id: json['id']?.toString() ?? '',
//       name: json['institution_name'] ?? '',
//       type: '機構', // 這裡固定「機構」
//       status: json['status'] ?? '未知',
//     );
//   }
// }