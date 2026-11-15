// App Pages
import 'package:exolab/core/statics/structures/pageSpecifics.dart';

enum WeekDays { M, T, W, Th, F, Sa, S }

enum AppPages { home, assessments, trends, alerts, account }

List<PageSpecifics> workingPages = [
  PageSpecifics(
    name: "Home",
    type: AppPages.home,
    iconPath: "assets/icons/house.svg",
  ),
  PageSpecifics(
    name: "Assessments",
    type: AppPages.assessments,
    iconPath: "assets/icons/list.svg",
  ),
  PageSpecifics(
    name: "Trends",
    type: AppPages.trends,
    iconPath: "assets/icons/chart.svg",
  ),
  PageSpecifics(
    name: "Alerts",
    type: AppPages.alerts,
    iconPath: "assets/icons/bell.svg",
  ),
  PageSpecifics(
    name: "Account",
    type: AppPages.account,
    iconPath: "assets/icons/",
  ),
];
