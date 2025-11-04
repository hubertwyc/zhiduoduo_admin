import 'package:flutter/material.dart';
import 'package:zhi_duo_duo/ui/pages/base_view.dart';
import 'package:zhi_duo_duo/viewmodels/platform_view_models/side_layout_view_model.dart';
import 'package:auto_route/auto_route.dart';

class SideLayoutView extends StatelessWidget {
  final List<String> menuTitles;
  final List<PageRouteInfo> routes;
  final String title;

  const SideLayoutView({
    super.key,
    required this.menuTitles,
    required this.routes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BaseView<SideLayoutViewModel>(
      modelProvider: () => SideLayoutViewModel(),
      builder: (BuildContext context, SideLayoutViewModel vm, Widget? child) {
        return AutoTabsRouter(
          routes: routes,
          builder: (BuildContext context, Widget child) {
            final tabsRouter = AutoTabsRouter.of(context);
            return Scaffold(
              body: Row(
                children: [
                  Container(
                    width: 200,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(1, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24.0,
                            horizontal: 16.0,
                          ),
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: menuTitles.length,
                            itemBuilder: (context, index) {
                              final selected = index == tabsRouter.activeIndex;
                              final isHovering = index == vm.hoverIndex;

                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onEnter: (_) => vm.setHoverIndex(index),
                                onExit: (_) => vm.setHoverIndex(-1),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFF007BFF)
                                        : isHovering
                                          ? const Color(0x1A007BFF)
                                          : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    title: Text(
                                      menuTitles[index],
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF007BFF),
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    onTap: () =>
                                        tabsRouter.setActiveIndex(index),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
