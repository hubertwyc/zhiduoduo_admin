import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:zhi_duo_duo/ui/pages/base_view.dart';
import 'package:zhi_duo_duo/viewmodels/platform_view_models/platform_member_management_view_model.dart';
import 'package:zhi_duo_duo/ui/web_components/components.dart';
import 'package:intl/intl.dart';

@RoutePage()
class PlatformMemberManagementView extends StatelessWidget {
  const PlatformMemberManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => PlatformMemberManagementViewModel(),
      onModelReady: (model) => model.fetchStudentFromApi(),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
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
                    '會員管理',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(height: 16, color: Colors.grey,),
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
                  
                  // 查無資料顯示
                  if (!model.busy && model.memberList.isEmpty)
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
                              Icons.people_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '查無會員資料',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '目前沒有註冊的會員',
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
                  if (!model.busy && model.memberList.isNotEmpty)
                    SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columnSpacing: 24, // 欄位間距
                      columns: [
                        // DataColumn(label: centeredHeaderText('會員ID')),
                        DataColumn(label: centeredHeaderText('姓名')),
                        DataColumn(label: centeredHeaderText('Email')),
                        DataColumn(label: centeredHeaderText('狀態')),
                        // DataColumn(label: centeredHeaderText('課程狀態')),
                        DataColumn(label: centeredHeaderText('詳細資訊')),
                        DataColumn(label: centeredHeaderText('操作')),
                      ],
                      rows: List.generate(
                        model.memberList.length,
                            (index) {
                          final member = model.memberList[index];
                          return DataRow(
                            // 黑白相間：偶數白、奇數灰
                            color: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                if (index % 2 == 0) {
                                  return Colors.grey[100];// 偶數行淺灰
                                }
                                return Colors.white;// 奇數行白色
                              },
                            ),
                            cells: [
                              // centeredCell(cellText(member.id.toString())),
                              centeredCell(cellText(member.name)),
                              centeredCell(cellText(member.email)),
                              centeredCell(
                                StatusTag(
                                  text: statusToText(member.status),
                                  colorType: statusToColor(member.status),
                                )
                              ),
                              // centeredCell(
                              //   SmallButton(
                              //     backColor: ColorType.blue,
                              //     fontColor: ColorType.white,
                              //     text: '查看',
                              //     onPressed: () {},
                              //   ),
                              // ),
                              centeredCell(
                                SmallButton(
                                  backColor: ColorType.blue,
                                  fontColor: ColorType.white,
                                  text: '查看',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          backgroundColor: Colors.white,
                                          child: FutureBuilder<Member?>(
                                            future: model.fetchStudentDetail(member.id),
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
                                                width: 600,
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
                                                        const Text(
                                                          '會員詳細資訊',
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
                                                            _buildSectionCard(
                                                              title: '會員基本資料',
                                                              icon: Icons.person,
                                                              children: [
                                                                detailRowNew('學生姓名', detail.name),
                                                                detailRowNew('Email', detail.email),
                                                                detailRowNew('電話', detail.phone),
                                                                detailRowNew('生日', formatDate(detail.birthday)),
                                                                detailRowNew('性別', detail.gender),
                                                                detailRowNew('加入時間', formatDate(detail.joinTime, pattern: 'yyyy/MM/dd HH:mm:ss')),
                                                              ],
                                                            ),
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
                                  },
                                ),

                              ),
                              centeredCell(
                                    () {
                                  switch (member.status) {
                                    case 'enable':
                                      return FlatButton(
                                        backColor: ColorType.red,
                                        fontColor: ColorType.white,
                                        text: '停用',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext dialogContext) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                title: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.warning_amber_rounded,
                                                      color: const Color(0xFFDC2626),
                                                      size: 28,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      '確認停用',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '確定要停用會員「${member.name}」嗎？',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Container(
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange[50],
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(
                                                          color: Colors.orange[200]!,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.info_outline,
                                                            size: 20,
                                                            color: Colors.orange[700],
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              '停用後該會員將無法登入系統',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.orange[900],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(dialogContext).pop();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '取消',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(dialogContext).pop();
                                                      model.updateStudentStatus(member.id, 'disable');
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFFDC2626),
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      '確認停用',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    case 'disable':
                                      return FlatButton(
                                        backColor: ColorType.green,
                                        fontColor: ColorType.white,
                                        text: '啟用',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext dialogContext) {
                                              return AlertDialog(
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                title: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle_outline,
                                                      color: const Color(0xFF15803D),
                                                      size: 28,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      '確認啟用',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '確定要啟用會員「${member.name}」嗎？',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Container(
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green[50],
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(
                                                          color: Colors.green[200]!,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.info_outline,
                                                            size: 20,
                                                            color: Colors.green[700],
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              '啟用後該會員將可以正常登入系統',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.green[900],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(dialogContext).pop();
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '取消',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(dialogContext).pop();
                                                      model.updateStudentStatus(member.id, 'enable');
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF15803D),
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      '確認啟用',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }, 
                                      );

                                    default:
                                      return const SizedBox.shrink(); // 其他狀態不顯示
                                  }
                                }(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                ]
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
  /// 表頭置中
  Widget centeredHeaderText(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// 資料格置中
  DataCell centeredCell(Widget child) {
    return DataCell(
      Center(child: child),
    );
  }
  String statusToText(String status) {
    switch (status) {
      case 'enable':
        return '啟用';
      case 'disable':
        return '停用';
      case 'pending':
        return '審核中';
      default:
        return '未知'; // 預設藍色
    }
  }
  TagColorType statusToColor(String status) {
    switch (status) {
      case 'enable':
        return TagColorType.green;
      case 'disable':
        return TagColorType.red;
      case 'pending':
        return TagColorType.yellow;
      case 'cancel':
        return TagColorType.gray;
      default:
        return TagColorType.blue; // 預設藍色
    }
  }
  Widget detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片標題
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEF4136).withOpacity(0.1),
                  const Color(0xFFEF4136).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4136),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4136),
                  ),
                ),
              ],
            ),
          ),
          
          // 分隔線
          Divider(height: 1, color: Colors.grey[200]),
          
          // 卡片內容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRowNew(String label, String? value) {
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
              value?.isNotEmpty == true ? value! : '未填寫',
              style: TextStyle(
                fontSize: 14,
                color: value?.isNotEmpty == true ? Colors.grey[900] : Colors.grey[400],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(String? dateStr, {String pattern = 'yyyy/MM/dd'}) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      // RFC1123 格式: "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
      final inputFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
      final dateTime = inputFormat.parseUtc(dateStr); // 先轉成 UTC 時間
      return DateFormat(pattern).format(dateTime.toLocal());
    } catch (e) {
      return dateStr; // 如果還是失敗，就回傳原字串
    }
  }
}

class FlatButton extends StatelessWidget {
  final String text;
  final ColorType backColor;
  final ColorType fontColor;
  final VoidCallback? onPressed;

  const FlatButton({
    super.key,
    required this.text,
    required this.backColor,
    required this.fontColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: _colorSwitch(backColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: _colorSwitch(fontColor),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  Color _colorSwitch(ColorType type) {
    switch (type) {
      case ColorType.blue:
        return const Color(0xFF2563EB); // 深藍
      case ColorType.green:
        return const Color(0xFF15803D); // 綠色
      case ColorType.red:
        return const Color(0xFFDC2626); // 紅色
      case ColorType.yellow:
        return const Color(0xFFFBBF24); // 黃色
      case ColorType.cyan:
        return const Color(0xFF06B6D4); // 青色
      case ColorType.gray:
        return const Color(0xFF6B7280); // 灰色
      case ColorType.black:
        return Colors.black;
      case ColorType.white:
        return Colors.white;
    }
  }
}

class LinkTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double fontSize;
  final Color color;

  const LinkTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.fontSize = 16,
    this.color = const Color(0xFF2563EB), // 預設藍色
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero, // 移除多餘內距
        minimumSize: Size(0, 0),  // 讓按鈕不要佔滿
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: Colors.transparent, // 移除水波紋（可選）
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          decoration: TextDecoration.underline, // 底線
        ),
      ),
    );
  }
}