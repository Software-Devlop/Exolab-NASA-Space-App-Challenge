import 'package:exolab/core/statics/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UIController {
  final AppPages currentPage;
  final String? analysis;

  const UIController({this.currentPage = AppPages.home, this.analysis});

  UIController copyWith({AppPages? currentPage, String? analysis}) {
    return UIController(
      currentPage: currentPage ?? this.currentPage,
      analysis: analysis ?? this.analysis,
    );
  }
}

class UIControllerManager extends Notifier<UIController> {
  @override
  UIController build() {
    // 5. Mandatory build method required by Riverpod Notifier
    return const UIController();
  }

  set currentPage(AppPages appPage) {
    state = state.copyWith(currentPage: appPage);
  }

  set rememberedAnalysis(String? analysis) {
    state = state.copyWith(analysis: analysis);
  }
}

// 6. Don't forget to expose your Notifier via a Provider:
final uiControllerProvider =
    NotifierProvider<UIControllerManager, UIController>(
      UIControllerManager.new,
    );
