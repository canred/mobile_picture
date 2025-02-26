import 'package:flutter/material.dart';
import 'package:bottom_cupertino_tabbar/bottom_cupertino_tabbar.dart';

import '../pages/pages.dart';
//import 'example_manager/example_manager.dart';

class EasyTabbar extends StatefulWidget {
  const EasyTabbar({Key? key}) : super(key: key);

  @override
  State<EasyTabbar> createState() => _EasyTabbarState();
}

class _EasyTabbarState extends State<EasyTabbar> {
  @override
  Widget build(BuildContext context) {
    return BottomCupertinoTabbar(
      activeColor: Colors.blue,
      inactiveColor: Colors.grey[300]!,
      notificationsBadgeColor: Colors.red,
      firstActiveIndex: 0,
      resizeToAvoidBottomInset: false,
      showLabels: true,
      overrideIconsColor: true,
      tabbarModel: (model, nestedNavigator) {
        //ExampleManager().tabbarProviderModel = model;
        //ExampleManager().nestedNavigator = nestedNavigator;
      },
      onTabPressed: (index, model, nestedNavigator) {
        if (index != model.currentTab) {
          model.changePage(index);
        } else {
          if (nestedNavigator[index]?.currentContext != null) {
            Navigator.of(nestedNavigator[index]!.currentContext!).popUntil((route) => route.isFirst);
          }
        }
      },
      children: const [
        BottomCupertinoTab(
          tab: BottomCupertinoTabItem(
            icon: Icon(
              Icons.home,
              size: 22,
            ),
            label: "Home",
          ),
          page: HomePage(),
        ),
        BottomCupertinoTab(
          tab: BottomCupertinoTabItem(
            icon: Icon(
              Icons.notifications,
              size: 22,
            ),
            label: "Notifications",
          ),
          page: HistoryPage(),
        ),
      ],
    );
  }
}
