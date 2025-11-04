import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:zhi_duo_duo/ui/pages/base_view.dart';
import 'package:zhi_duo_duo/viewmodels/platform_view_models/platform_dashboard_view_model.dart';

@RoutePage()
class PlatformDashboardView extends StatelessWidget {
  const PlatformDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => PlatformDashboardViewModel(),
      onModelReady: (model) => model.fetchPendingTask(),
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
                    'Dashboard',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Divider(height: 16, color: Colors.grey),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      StatCard(title: "總會員數", value: "1,234"),
                      SizedBox(width: 16),
                      StatCard(title: "待審核合作商", value: "89"),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      StatCard(title: "每週活躍會員", value: "567"),
                      SizedBox(width: 16),
                      StatCard(title: "每月活躍會員", value: "2,400"),
                      SizedBox(width: 16),
                      StatCard(title: "每年活躍會員", value: "10,500"),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '待處理任務',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Divider(height: 16, color: Colors.grey),
                  SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columns: [
                        DataColumn(label: headerText('任務')),
                        DataColumn(label: headerText('狀態'))
                      ],
                      rows: List.generate(
                          model.pendingTask.length,
                              (index) {
                            final pendingTask = model.pendingTask[index];
                            return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                      if (index % 2 == 0) {
                                        return Colors.grey[100];
                                      }
                                      return Colors.white;
                                    }
                                ),
                                cells: [
                                  DataCell(cellText(pendingTask.task)),
                                  DataCell(cellText(pendingTask.status))
                                ]
                            );
                          }
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '交易數據',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Divider(height: 16, color: Colors.grey),
                  Row(
                    children: [
                      StatCard(title: "今日營收", value: "NT\$ 45,600"),
                      SizedBox(width: 16),
                      StatCard(title: "本週營收", value: "NT\$ 189,400"),
                      SizedBox(width: 16),
                      StatCard(title: "本月營收", value: "NT\$ 756,800"),
                    ],
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
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 120,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide( //外框線
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          elevation: 2,
          color: Colors.white, // 改成白底更乾淨
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
