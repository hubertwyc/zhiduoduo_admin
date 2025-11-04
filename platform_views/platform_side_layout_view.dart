import 'package:zhi_duo_duo/ui/pages/platform_views/side_layout_view.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:zhi_duo_duo/router/app_router.gr.dart';

@RoutePage()
class PlatformSideLayoutView extends StatelessWidget {
  const PlatformSideLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return SideLayoutView(
      title: '智多多管理頁面',
      menuTitles: const [
        'Dashboard',
        '會員管理',
        '合作商管理',
        '審核驗證',
        '課程管理',
      ],
      routes: const [
        PlatformDashboardRoute(),
        PlatformMemberManagementRoute(),
        PlatformPartnerRoute(),
        PlatformVerifyRoute(),
        PlatformCourseManagementRoute(),
      ],
    );
  }
}