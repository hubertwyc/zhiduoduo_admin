import 'dart:convert';
import 'package:zhi_duo_duo/viewmodels/base_view_model.dart';
import 'package:zhi_duo_duo/core/services/api_service.dart';
import 'package:zhi_duo_duo/locator.dart';

class PlatformVerifyViewModel extends BaseViewModel {
  final ApiService api = locator<ApiService>();
  final List<String> partnerType = ['教育機構', '老師', '場地方'];
  String? selectedPartnerType;
  bool hasSearched = false; // 追蹤是否已經執行過查詢
  
  setPartnerType(String? partnerType) {
    selectedPartnerType = partnerType;
    notifyListeners();
  }
  List<ApplyList> applyList = [];
  Future<List<ApplyList>> loadApplyList() async {
    return [
      ApplyList(number: 'R1001', applicant: '王小美', type: '會員', status: '待審核'),
      ApplyList(number: 'R1002', applicant: '黃老師', type: '老師', status: '待審核'),
      ApplyList(number: 'R1001', applicant: '成大第一活動中心', type: '場地方', status: '已通過'),
      ApplyList(number: 'R1001', applicant: '大碩研究所補習班', type: '機構', status: '待審核'),
      ApplyList(number: 'R1001', applicant: '傅師傅', type: '老師', status: '已通過'),
    ];
  }
  Future<void> fetchApplyList() async {
    setBusy(true);
    applyList = await loadApplyList();
    setBusy(false);
    notifyListeners();
  }
  Future<void> loadApplyListFromApi(String? partnerType) async {
    setBusy(true);
    try {
      switch (partnerType) {
        case '教育機構':
          partnerType = 'institution';
          break;
        case '老師':
          partnerType = 'teacher';
          break;
        case '場地方':
          partnerType = 'venue';
          break;
        default:
          partnerType;
      }
          final response = await api.get('/admin/pending?partner_type=$partnerType');
          if (response['status'] == 'success') {
            final List<dynamic> results = response['data'];
        applyList = results.map((item) {
          return ApplyList(
            number: item['id'] ?? '',
            applicant: item['name'] ?? '',
            type: _convertTypeToChineseDisplay(item['type']),
            status: item['status'] ?? '未知',
          );
        }).toList();
      } else {
        applyList = [];
      }
    } catch (e) {
      // 失敗就給空清單
      applyList = [];
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // 將英文類型轉換為中文顯示
  String _convertTypeToChineseDisplay(String? type) {
    if (type == null) return '未知';
    switch (type.toLowerCase()) {
      case 'institution':
        return '教育機構';
      case 'teacher':
        return '老師';
      case 'venue':
        return '場地方';
      default:
        return type;
    }
  }

  // 輔助函數：安全地將對象或列表轉換為字符串列表
  List<String>? _parseToStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) {
        if (e is Map) {
          // 如果列表元素是 Map，嘗試提取 content 欄位（base64 圖片資料）
          return e['content']?.toString() ?? e.toString();
        }
        return e.toString();
      }).toList();
    }
    if (value is Map) {
      // 如果是單個 Map 物件，嘗試提取 content 欄位
      final content = value['content']?.toString();
      if (content != null && content.isNotEmpty) {
        return [content];
      }
      return [value.toString()];
    }
    if (value is String) {
      // 如果是字符串，嘗試解析為 JSON
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) {
            if (e is Map) {
              return e['content']?.toString() ?? e.toString();
            }
            return e.toString();
          }).toList();
        }
        return [decoded.toString()];
      } catch (e) {
        return [value];
      }
    }
    return [value.toString()];
  }

  Future<void> fetchApplyListFromApi() async {
    setBusy(true);
    hasSearched = true; // 標記已經執行過查詢

    switch (selectedPartnerType) {
      case '教育機構':
        await loadApplyListFromApi(selectedPartnerType);
        break;
      case '老師':
        await loadApplyListFromApi(selectedPartnerType);
        break;
      case '場地方':
        await loadApplyListFromApi(selectedPartnerType);
        break;
      default:
        await loadApplyListFromApi(selectedPartnerType);
    }
    setBusy(false);
    notifyListeners();
  
  }

  Future<Teacher?> loadTeacherDetail(String userId) async {
    setBusy(true);
    try {
      final response = await api.get('/admin/teachers/$userId');

      if (response['status'] == 'success') {
        final data = response['data'];

        final teacher = Teacher(
          id: data['id'] ?? '',
          name: data['user_name'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'],
          birthdate: data['birthday'],
          gender: data['gender'],
          nickName: data['nickname'],
          introduction: data['introduction'],
          teachingExperience: data['teaching_experience'],
          education: data['education'],
          idCardUrl: _parseToStringList(data['id_card_url']),
          certificationUrl: _parseToStringList(data['certification_url']),
          bankAccount: data['bank_account'],
          payoutMethod: data['payout_method'],
          institutionId: data['institution_id'],
          image: data['image'],
          valid: data['valid'],
          reviewLog: data['review_log'],
          createTime: data['join_time'],
          updateTime: data['update_time'],
          status: data['status'] ?? '未知',
          authUid: data['auth_uid'],
        );
        return teacher;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<Institution?> loadInstitutionDetail(String userId) async {
    setBusy(true);
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
    setBusy(true);
    try {
      final response = await api.get('/admin/venues/$userId');

      if (response['status'] == 'success') {
        final data = response['data'];
        
        // 使用 fromJson 工廠方法創建 Venue 物件
        final venue = Venue.fromJson(data);
        return venue;
      }
    } catch (e) {
      return null;
    } finally {
      setBusy(false);
    }
    return null;
  }

  Future<dynamic> fetchPartnerDetail(String userId, String partnerType) async {
    setBusy(true);
    
    dynamic result;
    switch (selectedPartnerType) {
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
        result = null;
    }
    setBusy(false);
    notifyListeners();
    return result;
  }
  Future<void> updateTeacherStatus(String id, String newStatus) async {
    setBusy(true);
    try {
      final response = await api.put(
        '/admin/teachers/$id/status',
        body: {'status': newStatus}
      );
      if (response['status'] == 'success') {
        // 更新成功，重新獲取申請列表
        await loadApplyListFromApi(selectedPartnerType);
      }
    } catch (e) {
      // 處理錯誤
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> updateInstitutionStatus(String id, String newStatus) async {
    setBusy(true);
    try {
      final response = await api.put(
        '/admin/institutions/$id/status',
        body: {'status': newStatus}
      );
      if (response['status'] == 'success') {
        // 更新成功，重新獲取申請列表
        await loadApplyListFromApi(selectedPartnerType);
      }
    } catch (e) {
      // 處理錯誤
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> updateVenueStatus(String id, String newStatus) async {
    setBusy(true);
    try {
      final response = await api.put(
        '/admin/venues/$id/status',
        body: {'status': newStatus}
      );
      if (response['status'] == 'success') {
        // 更新成功，重新獲取申請列表
        await loadApplyListFromApi(selectedPartnerType);
      }
    } catch (e) {
      // 處理錯誤
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // 根據選擇的 partner 類型決定呼叫哪個更新方法
  Future<void> updatePartnerStatus(String id, String newStatus) async {
    switch (selectedPartnerType) {
      case '教育機構':
        await updateInstitutionStatus(id, newStatus);
        break;
      case '老師':
        await updateTeacherStatus(id, newStatus);
        break;
      case '場地方':
        await updateVenueStatus(id, newStatus);
        break;
      default:
        break;
    }
  }
}

class ApplyList {
  final String number;
  final String applicant;
  final String type;
  final String status;
  
  ApplyList({
    required this.number,
    required this.applicant,
    required this.type,
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
  final String? introduction;
  final String? teachingExperience;
  final dynamic education;
  final List<String>? idCardUrl;
  final List<String>? certificationUrl;
  final String? bankAccount;
  final String? payoutMethod;
  final String? institutionId;
  final String? image;
  final bool? valid;
  final Map<String, dynamic>? reviewLog;
  final String? createTime;
  final String? updateTime;
  final String status;
  final String? authUid;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.birthdate,
    this.gender,
    this.nickName,
    this.introduction,
    this.teachingExperience,
    this.education,
    this.idCardUrl,
    this.certificationUrl,
    this.bankAccount,
    this.payoutMethod,
    this.institutionId,
    this.image,
    this.valid,
    this.reviewLog,
    this.createTime,
    this.updateTime,
    required this.status,
    this.authUid,
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
  final String? id;
  
  // 基本資料 - 場地代表人
  final String? representName;      // 場地代表人姓名
  final DateTime? representBirthday; // 生日
  final String? representGender;     // 性別
  final String? email;               // Email
  final String? phone;               // 聯繫電話
  final String? address;             // 聯繫地址
  
  // 場地資訊
  final String? venueName;           // 場地名稱
  final String? venueManager;        // 負責人
  final String? unifiedNumber;       // 統一編號
  final String? businessRegistration; // 公司登記號碼

  // 場地尺寸
  final String? venueSize;           // 場地大小
  final int? classroomCount;         // 教室數量
  final int? availableDaysPerWeek;   // 可使用天數
  final int? maxStudentCapacity;     // 可容納學生數
  
  // 場地設備說明
  final String? availableEquipment;  // 可提供設備（教學設備及器材）
  
  // 場地視覺說明
  final List<String>? venueImages;   // 場地照片（多張）
  final String? venueIntroVideo;     // 場地介紹影片
  
  // 場地身分驗證
  final String? ownershipType;       // 場地所有權類型: "owned" (自有) 或 "leased" (租賃)
  final List<String>? ownershipProof; // 自有證明文件（立案證明）
  final List<String>? landlordConsent; // 房東許可可證明（房東同意文件）
  final List<String>? leaseAgreement;  // 租約
  final List<String>? businessLicense; // 公司登記證明
  
  // 銀行帳號
  final String? bankAccount;         // 銀行帳號
  final List<String>? bankBookCover; // 銀行封面照片
  
  // 場地描述
  final String? venueDescription;    // 場地描述（特色、位置優勢、適合的課程類型等）
  
  // 系統欄位
  final DateTime? joinTime;          // 加入時間
  final DateTime? updateTime;        // 更新時間
  final bool? valid;                 // 是否通過審核
  final String? status;              // 狀態
  final Map<String, dynamic>? reviewLog; // 審核記錄
  final String? authUid;             // Firebase Auth UID

  Venue({
    this.id,
    // 基本資料
    this.representName,
    this.representBirthday,
    this.representGender,
    this.email,
    this.phone,
    this.address,
    // 場地資訊
    this.venueName,
    this.venueManager,
    this.unifiedNumber,
    this.businessRegistration,
    // 場地尺寸
    this.venueSize,
    this.classroomCount,
    this.availableDaysPerWeek,
    this.maxStudentCapacity,
    // 場地設備
    this.availableEquipment,
    // 場地視覺
    this.venueImages,
    this.venueIntroVideo,
    // 身分驗證
    this.ownershipType,
    this.ownershipProof,
    this.landlordConsent,
    this.leaseAgreement,
    this.businessLicense,
    // 銀行帳號
    this.bankAccount,
    this.bankBookCover,
    // 場地描述
    this.venueDescription,
    // 系統欄位
    this.joinTime,
    this.updateTime,
    this.valid,
    this.status,
    this.reviewLog,
    this.authUid,
  });

  // 從 JSON 建立 Venue 物件
  factory Venue.fromJson(Map<String, dynamic> json) {
    // 輔助函數：安全地將對象或列表轉換為字符串列表
    List<String>? _parseToStringList(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) {
          if (e is Map) {
            // 如果列表元素是 Map，嘗試提取 content 欄位（base64 圖片資料）
            return e['content']?.toString() ?? e.toString();
          }
          return e.toString();
        }).toList();
      }
      if (value is Map) {
        // 如果是單個 Map 物件，嘗試提取 content 欄位
        final content = value['content']?.toString();
        if (content != null && content.isNotEmpty) {
          return [content];
        }
        return [value.toString()];
      }
      if (value is String) {
        // 如果是字符串，嘗試解析為 JSON
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) {
              if (e is Map) {
                return e['content']?.toString() ?? e.toString();
              }
              return e.toString();
            }).toList();
          }
          if (decoded is Map) {
            final content = decoded['content']?.toString();
            if (content != null && content.isNotEmpty) {
              return [content];
            }
          }
        } catch (e) {
          // 解析失敗，直接返回字符串
          return [value];
        }
      }
      return null;
    }

    return Venue(
      id: json['id'],
      // 基本資料
      representName: json['represent_name'],
      representBirthday: json['represent_birthday'] != null 
          ? DateTime.tryParse(json['represent_birthday']) 
          : null,
      representGender: json['represent_gender'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      // 場地資訊
      venueName: json['venue_name'],
      venueManager: json['venue_manager'],
      unifiedNumber: json['unified_number'],
      businessRegistration: json['business_registration'],
      // 場地尺寸
      venueSize: json['venue_size'],
      classroomCount: json['classroom_count'],
      availableDaysPerWeek: json['available_days_per_week'],
      maxStudentCapacity: json['max_student_capacity'],
      // 場地設備
      availableEquipment: json['available_equipment'],
      // 場地視覺 - 使用輔助函數處理
      venueImages: _parseToStringList(json['venue_images']),
      venueIntroVideo: json['venue_intro_video'],
      // 身分驗證 - 使用輔助函數處理
      ownershipType: json['ownership_type'],
      ownershipProof: _parseToStringList(json['ownership_proof']),
      landlordConsent: _parseToStringList(json['landlord_consent']),
      leaseAgreement: _parseToStringList(json['lease_agreement']),
      businessLicense: _parseToStringList(json['business_license']),
      // 銀行帳號
      bankAccount: json['bank_account'],
      bankBookCover: _parseToStringList(json['bank_book_cover']),
      // 場地描述
      venueDescription: json['venue_description'],
      // 系統欄位
      joinTime: json['join_time'] != null 
          ? DateTime.tryParse(json['join_time']) 
          : null,
      updateTime: json['update_time'] != null 
          ? DateTime.tryParse(json['update_time']) 
          : null,
      valid: json['valid'],
      status: json['status'],
      reviewLog: json['review_log'],
      authUid: json['auth_uid'],
    );
  }

  // 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // 基本資料
      'represent_name': representName,
      'represent_birthday': representBirthday?.toIso8601String(),
      'represent_gender': representGender,
      'email': email,
      'phone': phone,
      'address': address,
      // 場地資訊
      'venue_name': venueName,
      'venue_manager': venueManager,
      'unified_number': unifiedNumber,
      'business_registration': businessRegistration,
      // 場地尺寸
      'venue_size': venueSize,
      'classroom_count': classroomCount,
      'available_days_per_week': availableDaysPerWeek,
      'max_student_capacity': maxStudentCapacity,
      // 場地設備
      'available_equipment': availableEquipment,
      // 場地視覺
      'venue_images': venueImages,
      'venue_intro_video': venueIntroVideo,
      // 身分驗證
      'ownership_type': ownershipType,
      'ownership_proof': ownershipProof,
      'landlord_consent': landlordConsent,
      'lease_agreement': leaseAgreement,
      'business_license': businessLicense,
      // 銀行帳號
      'bank_account': bankAccount,
      'bank_book_cover': bankBookCover,
      // 場地描述
      'venue_description': venueDescription,
      // 系統欄位
      'join_time': joinTime?.toIso8601String(),
      'update_time': updateTime?.toIso8601String(),
      'valid': valid,
      'status': status,
      'review_log': reviewLog,
      'auth_uid': authUid,
    };
  }
}