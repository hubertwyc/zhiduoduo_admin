import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:zhi_duo_duo/ui/pages/base_view.dart';
import 'package:zhi_duo_duo/viewmodels/platform_view_models/platform_course_management_view_model.dart';
import 'package:zhi_duo_duo/ui/web_components/components.dart';
import 'package:intl/intl.dart';

@RoutePage()
class PlatformCourseManagementView extends StatelessWidget {
  const PlatformCourseManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => PlatformCourseManagementViewModel(),
      // onModelReady: (model) => model.loadCourses(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '課程管理',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Divider(height: 16, color: Colors.grey),
                  SizedBox(height: 16),
                  
                  // 篩選欄位
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 100,
                          maxWidth: 160,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: model.selectedCourseStatus,
                          hint: Text('課程狀態'),
                          items: const [
                            DropdownMenuItem(value: 'approved', child: Text('已審核')),
                            DropdownMenuItem(value: 'pending', child: Text('未審核')),
                          ],
                          onChanged: (newValue) => model.setCourseStatus(newValue),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () { model.loadCourses(); },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('查詢', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  
                  // 載入中顯示
                  if (model.busy)
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '載入中...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // 查無資料顯示（只有在不忙碌、已經執行過查詢且資料為空時才顯示）
                  if (!model.busy && model.hasSearched && model.courseList.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '查無資料',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '目前沒有符合條件的課程',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // 資料表格顯示（只有在不忙碌且有資料時才顯示）
                  if (!model.busy && model.courseList.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columnSpacing: 24, // 欄位間距
                          columns: [
                            // DataColumn(label: headerText('課程ID')),
                            DataColumn(label: headerText('課程名稱')),
                            DataColumn(label: headerText('講師')),
                            DataColumn(label: headerText('機構')),
                            DataColumn(label: headerText('開始日期')),
                            DataColumn(label: headerText('狀態')),
                            DataColumn(label: headerText('總金額')),
                            DataColumn(label: headerText('操作')),
                          ],
                          rows: List.generate(
                            model.courseList.length,
                                (index) {
                              final courseList = model.courseList[index];
                              return DataRow(
                                // 黑白相間：偶數白、奇數灰
                                color: WidgetStateProperty.resolveWith<Color?>(
                                      (Set<WidgetState> states) {
                                    if (index % 2 == 0) {
                                      return Colors.grey[100];       // 偶數行淺灰
                                    }
                                    return Colors.white;     // 奇數行白色
                                  },
                                ),
                                cells: [
                                  // DataCell(cellText(courseList.id.toString())),
                                  DataCell(cellText(courseList.courseName)),
                                  DataCell(cellText(courseList.teacher)),
                                  DataCell(cellText(courseList.institution)),
                                  DataCell(cellText(formatDate(courseList.startDate))),
                                  DataCell(
                                    StatusTag(
                                      text: statusToText(courseList.status),
                                      colorType: statusToColor(courseList.status),
                                    )
                                  ),
                                  DataCell(cellText(courseList.totalAmount)),
                                  DataCell(
                                    Row(
                                      children: [
                                        SmallButton(
                                          backColor: ColorType.blue,
                                          fontColor: ColorType.white,
                                          text: '查看',
                                          onPressed: () {
                                            _showCourseDetailDialog(context, model, courseList.id);
                                          },
                                        ),
                                        SizedBox(width: 8),
                                        // 根據狀態顯示不同按鈕
                                        if (courseList.status == 'pending') ...[
                                          SmallButton(
                                            backColor: ColorType.green,
                                            fontColor: ColorType.white,
                                            text: '通過',
                                            onPressed: () {
                                              _showReviewDialog(context, model, courseList.id, courseList.courseName, 'passed');
                                            },
                                          ),
                                          SizedBox(width: 8),
                                          SmallButton(
                                            backColor: ColorType.red,
                                            fontColor: ColorType.white,
                                            text: '不通過',
                                            onPressed: () {
                                              _showReviewDialog(context, model, courseList.id, courseList.courseName, 'rejected');
                                            },
                                          ),
                                        ] else ...[
                                          SmallButton(
                                            backColor: ColorType.cyan,
                                            fontColor: ColorType.white,
                                            text: '查看報名',
                                            onPressed: () {
                                              _showEnrollmentDialog(context, model, courseList.id, courseList.courseName);
                                            },
                                          ),
                                          SizedBox(width: 8),
                                          // SmallButton(
                                          //   backColor: ColorType.red,
                                          //   fontColor: ColorType.white,
                                          //   text: '下架',
                                          //   onPressed: () {
                                          //     // TODO: 實現下架功能
                                          //   },
                                          // ),
                                        ],
                                      ],
                                    )
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget headerText(String text) {
    return Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16
        )
    );
  }

  Widget cellText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
  String formatDate(String? dateStr, {String pattern = 'yyyy/MM/dd'}) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      DateTime dateTime;
      
      // 嘗試解析 ISO 8601 格式 (例如: 2025-09-11T10:14:08.113059+00:00)
      if (dateStr.contains('T')) {
        dateTime = DateTime.parse(dateStr);
      } else if (dateStr.contains('GMT') || dateStr.contains(',')) {
        // RFC1123 格式: "EEE, dd MMM yyyy HH:mm:ss 'GMT'" 或 "Sun, 28 Sep 2025 00:00:00 GMT"
        try {
          final inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
          dateTime = inputFormat.parseUtc(dateStr);
        } catch (e) {
          // 嘗試不帶引號的格式
          final inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss z", 'en_US');
          dateTime = inputFormat.parseUtc(dateStr);
        }
      } else {
        // 嘗試直接解析
        dateTime = DateTime.parse(dateStr);
      }
      
      return DateFormat(pattern).format(dateTime.toLocal());
    } catch (e) {
      print('Date format error: $e, dateStr: $dateStr');
      // 如果還是失敗，嘗試提取日期部分
      try {
        // 嘗試從字串中提取日期部分 (例如: "Sun, 28 Sep 2025" -> "28 Sep 2025")
        final match = RegExp(r'(\d{1,2})\s+(\w{3})\s+(\d{4})').firstMatch(dateStr);
        if (match != null) {
          return '${match.group(3)}/${_monthToNumber(match.group(2)!)}/${match.group(1)!.padLeft(2, '0')}';
        }
      } catch (_) {}
      return dateStr; // 最後才回傳原字串
    }
  }
  
  String _monthToNumber(String month) {
    const months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12',
    };
    return months[month] ?? '01';
  }
  String statusToText(String status) {
    // 移除前後空格並轉換為小寫進行比對
    final cleanStatus = status.trim().toLowerCase();
    switch (cleanStatus) {
      case 'passed':
        return '已上架';
      case 'rejected':
        return '拒絕上架';
      case 'pending':
        return '審核中';
      case 'cancelled':
        return '取消上架';
      case 'disabled':
        return '已下架';
      default:
        print('Unknown status: "$status" (cleaned: "$cleanStatus")');
        return '未知';
    }
  }
  TagColorType statusToColor(String status) {
    // 移除前後空格並轉換為小寫進行比對
    final cleanStatus = status.trim().toLowerCase();
    switch (cleanStatus) {
      case 'passed':
        return TagColorType.green;
      case 'rejected':
        return TagColorType.red;
      case 'pending':
        return TagColorType.yellow;
      case 'cancelled':
        return TagColorType.cyan;
      case 'disabled':
        return TagColorType.gray;
      default:
        return TagColorType.blue; // 預設藍色
    }
  }

  void _showCourseDetailDialog(BuildContext context, PlatformCourseManagementViewModel model, String courseId) async {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: model.fetchCourseDetail(courseId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('載入失敗'),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text('沒有資料'),
              );
            }

            final detail = snapshot.data!;
            return Container(
              padding: const EdgeInsets.all(24),
              width: 700,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '課程詳細資訊',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 課程照片
                          if (detail['image'] != null && detail['image'].toString().isNotEmpty) ...[
                            Center(
                              child: Container(
                                width: double.infinity,
                                height: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    detail['image'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
                                            const SizedBox(height: 8),
                                            Text('無法載入圖片', style: TextStyle(color: Colors.grey[600])),
                                          ],
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[100],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ] else ...[
                            Center(
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text('未上傳課程圖片', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          // 基本資訊
                          _buildInfoRow('課程名稱', detail['course_name'] ?? ''),
                          _buildInfoRow('教師', detail['teacher_name'] ?? ''),
                          _buildInfoRow('機構', detail['institution_name'] ?? '無'),
                          _buildInfoRow('科目', detail['subject'] ?? ''),
                          _buildInfoRow('價格', 'NT\$ ${detail['price']?.toString() ?? '0'}'),
                          _buildInfoRow('課程時數', '${detail['duration']?.toString() ?? '0'} 小時'),
                          _buildInfoRow('人數上限', '${detail['participant_limit']?.toString() ?? '0'} 人'),
                          _buildInfoRow('已報名人數', '${detail['enrollment']?.toString() ?? '0'} 人'),
                          _buildInfoRow('上課地點', detail['location'] ?? ''),
                          _buildInfoRow('上課時間', detail['class_time'] ?? ''),
                          _buildInfoRow('開始日期', formatDate(detail['start_date'] ?? '')),
                          _buildInfoRow('結束日期', formatDate(detail['end_date'] ?? '')),
                          _buildInfoRow('評分', '${detail['rating']?.toString() ?? '0.0'} ⭐ (${detail['rating_count']?.toString() ?? '0'} 則評價)'),
                          _buildInfoRow('狀態', statusToText(detail['status'] ?? '')),
                          _buildInfoRow('建立時間', formatDate(detail['create_time'] ?? '', pattern: 'yyyy/MM/dd HH:mm')),
                          _buildInfoRow('更新時間', formatDate(detail['update_time'] ?? '', pattern: 'yyyy/MM/dd HH:mm')),
                          
                          // 課程描述（使用相同風格）
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4136),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '課程描述',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  detail['description'] ?? '無描述',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: detail['description'] != null && detail['description'].toString().isNotEmpty 
                                        ? Colors.grey[900] 
                                        : Colors.grey[400],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (detail['review_log'] != null && (detail['review_log'] as List).isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              '審核記錄',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...((detail['review_log'] as List).map((log) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '狀態: ${statusToText(log['status'] ?? '')}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '時間: ${formatDate(log['time'] ?? '', pattern: 'yyyy/MM/dd HH:mm')}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  if (log['reason'] != null && log['reason'].toString().isNotEmpty)
                                    Text(
                                      '原因: ${log['reason']}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                            ))),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('關閉'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標籤區域
          Container(
            constraints: const BoxConstraints(minWidth: 120),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4136),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 數值區域
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '未填寫',
              style: TextStyle(
                fontSize: 14,
                color: value.isNotEmpty ? Colors.grey[900] : Colors.grey[400],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context, PlatformCourseManagementViewModel model, String courseId, String courseName, String action) {
    final isApprove = action == 'passed';
    final actionText = isApprove ? '通過' : '不通過';
    final color = isApprove ? Colors.green : Colors.red;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(isApprove ? Icons.check_circle_outline : Icons.cancel_outlined, color: color, size: 28),
              const SizedBox(width: 12),
              Text('確認$actionText', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(courseName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isApprove ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isApprove ? Colors.green[200]! : Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: isApprove ? Colors.green[700] : Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isApprove ? '通過後此課程將上架並對學生開放報名' : '不通過後此課程將被拒絕，需要重新申請審核',
                        style: TextStyle(fontSize: 13, color: isApprove ? Colors.green[800] : Colors.red[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              child: Text('取消', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                navigator.pop();
                final success = await model.reviewCourse(courseId, action);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(success ? '課程$actionText成功' : '課程$actionText失敗', style: const TextStyle(fontSize: 16)),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(actionText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showEnrollmentDialog(BuildContext context, PlatformCourseManagementViewModel model, String courseId, String courseName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          child: FutureBuilder<List<dynamic>>(
            future: model.fetchCourseStudents(courseId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  width: 800,
                  height: 400,
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  width: 800,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '報名學生列表',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  courseName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 60),
                      Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text('載入失敗: ${snapshot.error}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  width: 800,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '報名學生列表',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  courseName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 60),
                      Icon(Icons.people_outline, color: Colors.grey, size: 64),
                      const SizedBox(height: 16),
                      const Text('目前沒有學生報名', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              }

              final students = snapshot.data!;
              return Container(
                padding: const EdgeInsets.all(24),
                width: 900,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '報名學生列表',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                courseName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '共 ${students.length} 人',
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Flexible(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columnSpacing: 24,
                            headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                            columns: [
                              DataColumn(label: headerText('學生姓名')),
                              DataColumn(label: headerText('聯絡電話')),
                              DataColumn(label: headerText('Email')),
                              DataColumn(label: headerText('報名日期')),
                              DataColumn(label: headerText('付款狀態')),
                            ],
                            rows: List.generate(
                              students.length,
                              (index) {
                                final student = students[index];
                                return DataRow(
                                  color: WidgetStateProperty.resolveWith<Color?>(
                                    (Set<WidgetState> states) {
                                      if (index % 2 == 0) {
                                        return Colors.white;
                                      }
                                      return Colors.grey[50];
                                    },
                                  ),
                                  cells: [
                                    DataCell(cellText(student['name'] ?? '未提供')),
                                    DataCell(cellText(student['phone'] ?? '未提供')),
                                    DataCell(cellText(student['email'] ?? '未提供')),
                                    DataCell(cellText(formatDate(student['create_date'] ?? ''))),
                                    DataCell(
                                      _buildPaymentStatusTag(student['status'] ?? 'unknown'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('關閉'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentStatusTag(String status) {
    Color bgColor;
    Color textColor;
    String text;
    
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        text = '已付款';
        break;
      case 'pending':
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        text = '待付款';
        break;
      case 'failed':
      case 'cancelled':
        bgColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        text = '失敗';
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        text = '未知';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
