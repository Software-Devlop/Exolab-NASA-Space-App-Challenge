import 'package:exolab/core/statics/constants.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:exolab/features/main/presentation/controllers/UIController.dart';
import 'package:exolab/features/main/presentation/pages/accountPage.dart';
import 'package:exolab/features/main/presentation/pages/assessments/assessmentsPage.dart';
import 'package:exolab/features/main/presentation/pages/base/widgets/leftBar.dart';
import 'package:exolab/features/main/presentation/pages/emptyPage.dart';
import 'package:exolab/features/main/presentation/pages/home/homePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({super.key});

  @override
  ConsumerState<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends ConsumerState<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(uiControllerProvider).currentPage;
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Bar
            LeftBar(currentPage: currentPage),

            // Dashboard
            DashboardWidget(currentPage: currentPage),
          ],
        ),
      ),
    );
  }
}

class DashboardWidget extends StatelessWidget {
  final AppPages currentPage;

  const DashboardWidget({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Offstage(
            offstage: currentPage != AppPages.home,
            child: const HomePage(),
          ),

          if (currentPage != AppPages.home)
            currentPage == AppPages.assessments
                ? AssessmentsPage()
                : currentPage == AppPages.account
                ? AccountPage()
                : const EmptyPage(),
        ],
      ),
    );
  }
}

// class DashboardWidget extends StatelessWidget {
//   final AppPages currentPage;
//   const DashboardWidget({super.key, required this.currentPage});

//   @override
//   Widget build(BuildContext context) {
//     switch (currentPage) {
//       case AppPages.home:
//         return HomePage();
//       default:
//         return EmptyPage();
//     }
//   }
// }
