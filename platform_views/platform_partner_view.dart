import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:zhi_duo_duo/ui/pages/base_view.dart';
import 'package:zhi_duo_duo/viewmodels/platform_view_models/platform_partner_view_model.dart';
import 'package:zhi_duo_duo/ui/web_components/components.dart';
import 'package:intl/intl.dart';

@RoutePage()
class PlatformPartnerView extends StatelessWidget {
  const PlatformPartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => PlatformPartnerViewModel(),
      // onModelReady: (model) => model.fetchPartner(),
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
                    '合作商管理',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Divider(height: 16, color: Colors.grey),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 100,
                          maxWidth: 160, // 控制最大寬度
                        ),
                        child: DropdownButtonFormField<String>(
                          value: model.selectedPartnerType,
                          hint: Text('合作商類型'),
                          items: const [
                            DropdownMenuItem(value: '教育機構', child: Text('教育機構')),
                            DropdownMenuItem(value: '老師', child: Text('老師')),
                            DropdownMenuItem(value: '場地方', child: Text('場地方')),
                          ],
                          onChanged: (newValue) => model.setPartnerType(newValue),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Colors.grey), // 邊框顏色
                            ),
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        height: 48,

                        child: ElevatedButton(
                            onPressed: () { model.fetchPartner(); },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('查詢', style: TextStyle(color: Colors.white, fontSize: 16),)
                        ),
                      ),

                    ],
                  ),

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
                  if (!model.busy && model.partner.isEmpty && model.hasSearched)
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
                              '目前沒有符合條件的合作商',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (!model.busy && model.partner.isNotEmpty)
                    SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columnSpacing: 24, // 欄位間距
                      columns: [
                        // DataColumn(label: headerText('合作商ID')),
                        DataColumn(label: headerText('名稱')),
                        DataColumn(label: headerText('類型')),
                        DataColumn(label: headerText('狀態')),
                        DataColumn(label: headerText('詳細資訊')),
                        DataColumn(label: headerText('操作')),
                      ],
                      rows: List.generate(
                        model.partner.length,
                          (index) {
                          final partner = model.partner[index];
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
                              // DataCell(cellText(partner.id.toString())),
                              DataCell(cellText(partner.name)),
                              DataCell(cellText(partner.type)),
                              DataCell(
                                StatusTag(
                                  text: statusToText(partner.status),
                                  colorType: statusToColor(partner.status),
                                )
                              ),
                              DataCell(
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
                                          child: FutureBuilder<dynamic>(
                                            future: model.fetchPartnerDetail(partner.id, partner.type),
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
                                                          '詳細資訊',
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
                                                          children: buildDetailRow(partner.type, detail),
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
                                      }
                                    );
                                  },
                                )
                              ),
                              DataCell(
                                    () {
                                  switch (partner.status) {
                                    case 'succeed':
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
                                                      '確定要停用合作商「${partner.name}」嗎？',
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
                                                              '停用後該合作商將無法使用系統功能',
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
                                                      model.updatePartnerStatus(partner.id, partner.type, 'rejected');
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
                                    case 'rejected':
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
                                                      '確定要啟用合作商「${partner.name}」嗎？',
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
                                                              '啟用後該合作商將可以正常使用系統功能',
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
                                                      model.updatePartnerStatus(partner.id, partner.type, 'succeed');
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
  String statusToText(String status) {
    switch (status) {
      case 'succeed':
        return '啟用';
      case 'rejected':
        return '停用';
      case 'pending':
        return '審核中';
      default:
        return '未知'; // 預設藍色
    }
  }
  TagColorType statusToColor(String status) {
    switch (status) {
      case 'succeed':
        return TagColorType.green;
      case 'rejected':
        return TagColorType.red;
      case 'pending':
        return TagColorType.yellow;
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
  List<Widget> buildDetailRow(String partnerType, dynamic detail) {
    switch (partnerType) {
      case '教育機構':
        return [
          _buildSectionCard(
            title: '機構基本資料',
            icon: Icons.school,
            children: [
              detailRowNew('機構名稱', detail.institutionName),
              detailRowNew('負責人', detail.owner),
              detailRowNew('Email', detail.email),
              detailRowNew('聯絡電話', detail.phone),
              detailRowNew('地址', detail.address),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '機構證件資訊',
            icon: Icons.business_center,
            children: [
              detailRowNew('統一編號', detail.taxId),
              detailRowNew('立案字號', detail.approvalNumber),
              detailRowNew('商業登記編號', detail.businessNumber),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '銀行資訊',
            icon: Icons.account_balance,
            children: [
              detailRowNew('銀行帳號', detail.bankAccount),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '機構描述',
            icon: Icons.description,
            children: [
              detailRowNew('描述', detail.description),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '機構照片',
            icon: Icons.image,
            children: [
              detailRowNew('照片', detail.image != null && detail.image.isNotEmpty ? '已上傳' : '未上傳'),
            ],
          ),
        ]; 
      case '老師':
        return [
          _buildSectionCard(
            title: '老師基本資料',
            icon: Icons.person,
            children: [
              detailRowNew('姓名', detail.name),
              detailRowNew('暱稱', detail.nickName),
              detailRowNew('生日', formatDate(detail.birthdate)),
              detailRowNew('性別', detail.gender),
              detailRowNew('Email', detail.email),
              detailRowNew('聯絡電話', detail.phone),
            ],
          ),
        ];
      case '場地方':
        return [
          _buildSectionCard(
            title: '場地代表人資料',
            icon: Icons.person,
            children: [
              detailRowNew('代表人姓名', detail.representName),
              detailRowNew('生日', formatDate(detail.representBirthday)),
              detailRowNew('性別', detail.representGender),
              detailRowNew('Email', detail.email),
              detailRowNew('聯絡電話', detail.phone),
              detailRowNew('聯絡地址', detail.address),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '場地基本資訊',
            icon: Icons.location_on,
            children: [
              detailRowNew('場地名稱', detail.venueName),
              detailRowNew('負責人', detail.venueManager),
              detailRowNew('統一編號', detail.unifiedNumber),
              detailRowNew('公司登記號碼', detail.businessRegistration),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '場地規模',
            icon: Icons.square_foot,
            children: [
              detailRowNew('場地大小', detail.venueSize),
              detailRowNew('教室數量', detail.classroomCount?.toString()),
              detailRowNew('可使用天數/週', detail.availableDaysPerWeek?.toString()),
              detailRowNew('可容納學生數', detail.maxStudentCapacity?.toString()),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '場地設備與描述',
            icon: Icons.devices_other,
            children: [
              detailRowNew('可提供設備', detail.availableEquipment),
              detailRowNew('場地描述', detail.venueDescription),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '銀行資訊',
            icon: Icons.account_balance,
            children: [
              detailRowNew('銀行帳號', detail.bankAccount),
            ],
          ),
        ];
      default:
        return [];
    }
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