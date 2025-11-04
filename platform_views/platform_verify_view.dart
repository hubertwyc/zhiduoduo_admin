import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:zhi_duo_duo/ui/pages/base_view.dart';
import 'package:zhi_duo_duo/viewmodels/platform_view_models/platform_verify_view_model.dart';
import 'package:zhi_duo_duo/ui/web_components/components.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

@RoutePage()
class PlatformVerifyView extends StatelessWidget {
  const PlatformVerifyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => PlatformVerifyViewModel(),
      // onModelReady: (model) => model.loadApplyListFromApi(),
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
                      '審核驗證',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(height: 16, color: Colors.grey,),
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
                            onPressed: () { model.fetchApplyListFromApi(); },
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
                    SizedBox(height: 24),
                    
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
                    if (!model.busy && model.hasSearched && model.applyList.isEmpty)
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
                                '目前沒有符合條件的審核資料',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    if (!model.busy && model.applyList.isNotEmpty)
                      SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 24, // 欄位間距
                        columns: [
                          // DataColumn(label: headerText('申請編號')),
                          DataColumn(label: headerText('申請者/機構')),
                          DataColumn(label: headerText('類型')),
                          DataColumn(label: headerText('狀態')),
                          DataColumn(label: headerText('操作')),
                        ],
                        rows: List.generate(
                          model.applyList.length,
                              (index) {
                            final applicant = model.applyList[index];
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
                                // DataCell(cellText(applicant.number)),
                                DataCell(cellText(applicant.applicant)),
                                DataCell(cellText(applicant.type)),
                                DataCell(
                                  StatusTag(
                                    text: statusToText(applicant.status),
                                    colorType: statusToColor(applicant.status),
                                  )
                                ),
                                DataCell(
                                  Row(
                                    children: [
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
                                                  future: model.fetchPartnerDetail(applicant.number, applicant.type),
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
                                                                children: buildDetailRow(applicant.type, detail),
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
                                      ),
                                      SizedBox(width: 8),
                                      SmallButton(
                                        backColor: ColorType.green,
                                        fontColor: ColorType.white,
                                        text: '通過',
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
                                                      '確認通過審核',
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
                                                      '確定要通過「${applicant.applicant}」的審核申請嗎？',
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
                                                              '通過後該申請者將可以開始使用系統',
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
                                                      model.updatePartnerStatus(applicant.number, 'succeed');
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
                                                      '確認通過',
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
                                      ),
                                      SizedBox(width: 8),
                                      SmallButton(
                                        backColor: ColorType.red,
                                        fontColor: ColorType.white,
                                        text: '不通過',
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
                                                      Icons.cancel_outlined,
                                                      color: const Color(0xFFDC2626),
                                                      size: 28,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      '確認不通過審核',
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
                                                      '確定要拒絕「${applicant.applicant}」的審核申請嗎？',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Container(
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red[50],
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(
                                                          color: Colors.red[200]!,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.warning_outlined,
                                                            size: 20,
                                                            color: Colors.red[700],
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Expanded(
                                                            child: Text(
                                                              '不通過後該申請者將無法使用系統',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors.red[900],
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
                                                      model.updatePartnerStatus(applicant.number, 'rejected');
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
                                                      '確認不通過',
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
                                      ),
                                    ],
                                  ),
                                ),
                                // DataCell(
                                //   SmallButton(
                                //     backColor: ColorType.blue,
                                //     fontColor: ColorType.white,
                                //     text: '通過',
                                //     onPressed: () {
                                //     },
                                //   ),
                                // ),
                                // DataCell(
                                //   SmallButton(
                                //     backColor: ColorType.red,
                                //     fontColor: ColorType.white,
                                //     text: '不通過',
                                //     onPressed: () {
                                //     },
                                //   ),
                                // ),
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
    // 直接使用中文類型進行判斷
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
              detailRowMultiline('描述', detail.description),
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
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '教學資訊',
            icon: Icons.school,
            children: [
              detailRowMultiline('自我介紹', detail.introduction),
              detailRowMultiline('教學經驗', detail.teachingExperience),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '學歷資訊',
            icon: Icons.menu_book,
            children: [
              detailRowNew('學歷', detail.education != null ? '已填寫' : '未填寫'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '證件資訊',
            icon: Icons.credit_card,
            children: [
              detailRowList('身分證', detail.idCardUrl),
              detailRowList('證照/證書', detail.certificationUrl),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '銀行資訊',
            icon: Icons.account_balance,
            children: [
              detailRowNew('銀行帳號', detail.bankAccount),
              detailRowNew('付款方式', detail.payoutMethod),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '所屬機構',
            icon: Icons.business,
            children: [
              detailRowNew('機構ID', detail.institutionId),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionCard(
            title: '個人照片',
            icon: Icons.image,
            children: [
              detailRowNew('照片', detail.image != null && detail.image.isNotEmpty ? '已上傳' : '未上傳'),
            ],
          ),
        ];
      case '場地方':
        return [
          // 基本資料
          _buildSectionCard(
            title: '基本資料',
            icon: Icons.person,
            children: [
              detailRowNew('場地代表人姓名', detail.representName),
              detailRowNew('性別', detail.representGender),
              detailRowNew('生日', detail.representBirthday != null 
                  ? DateFormat('yyyy/MM/dd').format(detail.representBirthday) 
                  : ''),
              detailRowNew('Email', detail.email),
              detailRowNew('聯絡電話', detail.phone),
              detailRowNew('聯絡地址', detail.address),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 場地資訊
          _buildSectionCard(
            title: '場地資訊',
            icon: Icons.business,
            children: [
              detailRowNew('場地名稱', detail.venueName),
              detailRowNew('負責人', detail.venueManager),
              detailRowNew('統一編號', detail.unifiedNumber),
              detailRowNew('公司登記', detail.businessRegistration),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 場地尺寸
          _buildSectionCard(
            title: '場地尺寸',
            icon: Icons.straighten,
            children: [
              detailRowNew('坪數', detail.venueSize),
              detailRowNew('教室數', detail.classroomCount?.toString() ?? ''),
              detailRowNew('可使用天數', detail.availableDaysPerWeek?.toString() ?? ''),
              detailRowNew('可容納學生數', detail.maxStudentCapacity?.toString() ?? ''),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 場地設備說明
          _buildSectionCard(
            title: '場地設備說明',
            icon: Icons.devices,
            children: [
              detailRowMultiline('可提供設備', detail.availableEquipment),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 場地視覺說明
          _buildSectionCard(
            title: '場地視覺說明',
            icon: Icons.photo_library,
            children: [
              detailRowImages('場地照片', detail.venueImages),
              detailRowNew('場地介紹影片', detail.venueIntroVideo != null ? '已上傳' : '未上傳'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 場地身分驗證
          _buildSectionCard(
            title: '場地身分驗證',
            icon: Icons.verified,
            children: [
              detailRowList('立案證明', detail.ownershipProof),
              detailRowList('房東許可證明', detail.landlordConsent),
              detailRowList('租約', detail.leaseAgreement),
              detailRowList('公司登記', detail.businessLicense),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 場地身份證明
          _buildSectionCard(
            title: '場地身份證明',
            icon: Icons.home,
            children: [
              detailRowNew('場地所有權類型', detail.ownershipType == 'owned' ? '自有' : 
                       detail.ownershipType == 'leased' ? '租賃' : detail.ownershipType ?? ''),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 銀行資訊
          _buildSectionCard(
            title: '銀行資訊',
            icon: Icons.account_balance,
            children: [
              detailRowNew('銀行帳號', detail.bankAccount),
              detailRowList('銀行封面', detail.bankBookCover),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 場地描述
          _buildSectionCard(
            title: '場地描述',
            icon: Icons.description,
            children: [
              detailRowMultiline('描述', detail.venueDescription),
            ],
          ),
        ];
      default:
        return [
          detailRow('錯誤', '未知的類型: $partnerType'),
        ];
    }
  }

  Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFEF4136),
        ),
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

  Widget detailRowMultiline(String label, String? value) {
    return Container(
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
          // 標籤
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 內容
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              value?.isNotEmpty == true ? value! : '未填寫',
              style: TextStyle(
                fontSize: 14,
                color: value?.isNotEmpty == true ? Colors.grey[900] : Colors.grey[400],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRowList(String label, List<String>? items) {
    return Container(
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
          // 標籤
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 檔案列表或未上傳提示
          items != null && items.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Builder(
                      builder: (context) => Container(
                        margin: EdgeInsets.only(bottom: index < items.length - 1 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () => _showFileDialog(context, item, index + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.insert_drive_file,
                                      color: Colors.green[700],
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '檔案 ${index + 1}${items.length > 1 ? " (共${items.length}個)" : ""}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              : Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[400], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '未上傳',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget detailRowImages(String label, List<String>? imageUrls) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (imageUrls != null && imageUrls.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '共 ${imageUrls.length} 張',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          imageUrls != null && imageUrls.isNotEmpty
              ? Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: imageUrls.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    // 檢查是否為完整的 base64 data URI
                    if (url.startsWith('data:image')) {
                      // Base64 圖片格式: data:image/jpeg;base64,/9j/4AAQ...
                      try {
                        final base64String = url.split(',').last;
                        final bytes = base64Decode(base64String);
                        return Builder(
                          builder: (context) => GestureDetector(
                            onTap: () => _showImageDialog(context, url, isBase64: true, hasPrefix: true),
                            child: Stack(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!, width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      bytes,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: const Center(
                            child: Icon(Icons.error, size: 40, color: Colors.red),
                          ),
                        );
                      }
                    } else if (url.startsWith('http://') || url.startsWith('https://')) {
                      // URL 圖片
                      return Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => _showImageDialog(context, url, isBase64: false, hasPrefix: false),
                          child: Stack(
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // 純 base64 字串（沒有 data URI 前綴）
                      try {
                        final bytes = base64Decode(url);
                        return Builder(
                          builder: (context) => GestureDetector(
                            onTap: () => _showImageDialog(context, url, isBase64: true, hasPrefix: false),
                            child: Stack(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!, width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      bytes,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } catch (e) {
                        return Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[300]!),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, size: 40, color: Colors.red),
                                const SizedBox(height: 8),
                                Text(
                                  '無效格式',
                                  style: TextStyle(fontSize: 12, color: Colors.red[700]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    }
                  }).toList(),
                )
              : Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.image_not_supported, color: Colors.grey[400], size: 40),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '未上傳照片',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '此場地尚未上傳任何照片',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl, {required bool isBase64, required bool hasPrefix}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: isBase64
                  ? Image.memory(
                      hasPrefix 
                          ? base64Decode(imageUrl.split(',').last)
                          : base64Decode(imageUrl),
                      fit: BoxFit.contain,
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFileDialog(BuildContext context, String fileData, int fileNumber) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: MediaQuery.of(context).size.width * 0.8,
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
                  Text(
                    '檔案 $fileNumber',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildFilePreview(fileData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(String fileData) {
    // 嘗試判斷檔案類型並顯示
    try {
      // 如果是 base64 圖片，嘗試顯示
      if (fileData.startsWith('data:image') || _isValidBase64Image(fileData)) {
        final bytes = fileData.startsWith('data:image')
            ? base64Decode(fileData.split(',').last)
            : base64Decode(fileData);
        return Center(
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildFileInfo(fileData);
            },
          ),
        );
      } else if (fileData.startsWith('http://') || fileData.startsWith('https://')) {
        // URL 圖片
        return Center(
          child: Image.network(
            fileData,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildFileInfo(fileData);
            },
          ),
        );
      } else {
        // 其他類型的檔案，顯示資訊
        return _buildFileInfo(fileData);
      }
    } catch (e) {
      return _buildFileInfo(fileData);
    }
  }

  bool _isValidBase64Image(String data) {
    try {
      final bytes = base64Decode(data);
      // 檢查常見圖片格式的檔頭
      if (bytes.length > 4) {
        // PNG: 89 50 4E 47
        if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
        // JPEG: FF D8 FF
        if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
        // GIF: 47 49 46
        if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Widget _buildFileInfo(String fileData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 48, color: Colors.blue[700]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '檔案資訊',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '檔案大小: ${fileData.length} 字元',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Base64 預覽:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: SelectableText(
                fileData.length > 500 
                    ? '${fileData.substring(0, 500)}...\n\n(總長度: ${fileData.length} 字元)'
                    : fileData,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: Colors.grey[800],
                ),
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