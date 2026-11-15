import 'package:exolab/core/presentation/globalWidgets/custContainer.dart';
import 'package:exolab/core/statics/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HorizontalPageSlider extends StatefulWidget {
  final double? width;
  final double? height;
  final Widget? topWidget;
  final int maxNbOfPage;
  final int currentPage;
  final List<Widget>? pages;
  final Widget? fixedWidget;
  final Function(int value) onPageChange;
  final Widget? pagesPlaceholder;
  final bool allowPageIndexing;
  final void Function(PointerEnterEvent event)? onEnterTop;
  final void Function(PointerExitEvent)? onExitTop;

  const HorizontalPageSlider({
    super.key,
    this.width,
    this.height,
    this.topWidget,
    required this.maxNbOfPage,
    required this.currentPage,
    this.pages,
    required this.onPageChange,
    this.fixedWidget,
    this.pagesPlaceholder,
    this.allowPageIndexing = true,
    this.onEnterTop,
    this.onExitTop,
  });

  @override
  State<HorizontalPageSlider> createState() => _HorizontalPageSliderState();
}

class _HorizontalPageSliderState extends State<HorizontalPageSlider> {
  late final PageController _pageController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.currentPage);
  }

  @override
  void didUpdateWidget(covariant HorizontalPageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentPage != oldWidget.currentPage &&
        _pageController.hasClients &&
        !_isAnimating) {
      _pageController.animateToPage(
        widget.currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handlePageChange(int value) {
    if (value == widget.currentPage) return;

    widget.onPageChange(value);
  }

  Future<void> _animateToPage(int value) async {
    if (!_pageController.hasClients ||
        value < 0 ||
        value >= (widget.pages?.length ?? 0)) {
      return;
    }

    if (value == widget.currentPage) return;

    _isAnimating = true;

    await _pageController.animateToPage(
      value,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );

    _isAnimating = false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages;

    return CustContainer(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.fromLTRB(25, 18, 8, 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: MouseRegion(
              opaque: true,
              onEnter: widget.onEnterTop,
              onExit: widget.onExitTop,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.topWidget ?? const SizedBox.shrink(),
                  Row(
                    spacing: 10,
                    children: [
                      if (widget.allowPageIndexing && widget.maxNbOfPage > 0)
                        Text(
                          "${widget.currentPage >= 0 && widget.currentPage < widget.maxNbOfPage ? widget.currentPage + 1 : 1}/${widget.maxNbOfPage}",
                          style: context.text.titleSmall,
                        ),
                      PageIndicatorWidget(
                        pagesNb: widget.maxNbOfPage,
                        currentPage: widget.currentPage,
                        onTap: (value) {
                          _animateToPage(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (pages != null)
            pages.isEmpty
                ? (widget.pagesPlaceholder ?? const SizedBox.shrink())
                : Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: _handlePageChange,
                      physics: const BouncingScrollPhysics(),
                      padEnds: false,
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: pages[index],
                        );
                      },
                    ),
                  ),

          if (widget.fixedWidget != null) widget.fixedWidget!,
        ],
      ),
    );
  }
}

class IndicatorWidget extends StatelessWidget {
  final double width;
  final Color color;
  final VoidCallback? onTap;

  const IndicatorWidget({
    super.key,
    required this.width,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 13,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

class SelectedPageIndicator extends StatelessWidget {
  const SelectedPageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return IndicatorWidget(width: 50, color: context.colors.tertiary);
  }
}

class OnePageIndicator extends StatelessWidget {
  final VoidCallback onTap;

  const OnePageIndicator({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IndicatorWidget(
      width: 13,
      color: context.colors.primary,
      onTap: onTap,
    );
  }
}

class MoreThanOnePageIndicator extends StatelessWidget {
  final VoidCallback onTap;

  const MoreThanOnePageIndicator({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IndicatorWidget(
      width: 26,
      color: context.colors.primary,
      onTap: onTap,
    );
  }
}

class PageIndicatorWidget extends StatelessWidget {
  final int pagesNb;
  final int currentPage;
  final Function(int) onTap;

  const PageIndicatorWidget({
    super.key,
    required this.pagesNb,
    required this.currentPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pagesNb <= 0) return const SizedBox.shrink();

    return Row(
      spacing: 5,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (currentPage >= 2)
          MoreThanOnePageIndicator(onTap: () => onTap(currentPage - 2)),
        if (currentPage >= 1)
          OnePageIndicator(onTap: () => onTap(currentPage - 1)),
        const SelectedPageIndicator(),
        if (currentPage < pagesNb - 1)
          OnePageIndicator(onTap: () => onTap(currentPage + 1)),
        if (currentPage < pagesNb - 2)
          MoreThanOnePageIndicator(onTap: () => onTap(currentPage + 2)),
      ],
    );
  }
}

class ColoredPage extends StatelessWidget {
  final Color color;
  final String title;

  const ColoredPage({super.key, required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// import 'package:exolab/core/presentation/globalWidgets/custContainer.dart';
// import 'package:exolab/core/statics/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class HorizontalPageSlider extends StatelessWidget {
//   final double? width;
//   final double? height;
//   final Widget? topWidget;
//   final int maxNbOfPage;
//   final int currentPage;
//   final List<Widget>? pages;
//   final Widget? fixedWidget;
//   final Function(int value) onPageChange;
//   final Widget? pagesPlaceholder;
//   final bool allowPageIndexing;
//   final void Function(PointerEnterEvent event)? onEnterTop;
//   final void Function(PointerExitEvent)? onExitTop;

//   const HorizontalPageSlider({
//     super.key,
//     this.width,
//     this.height,
//     this.topWidget,
//     required this.maxNbOfPage,
//     required this.currentPage,
//     this.pages,
//     required this.onPageChange,
//     this.fixedWidget,
//     this.pagesPlaceholder,
//     this.allowPageIndexing = true,
//     this.onEnterTop,
//     this.onExitTop,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CustContainer(
//       width: width,
//       height: height,
//       padding: EdgeInsets.fromLTRB(25, 18, 8, 20),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(right: 20),
//             child: MouseRegion(
//               opaque: true,
//               onEnter: onEnterTop,
//               onExit: onExitTop,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   topWidget ?? const SizedBox.shrink(),
//                   Row(
//                     spacing: 10,
//                     children: [
//                       if (allowPageIndexing && maxNbOfPage > 0)
//                         Text(
//                           // Display 1-based index to the user (e.g., "1/3" instead of "0/3")
//                           "${currentPage >= 0 && currentPage < maxNbOfPage ? currentPage + 1 : 1}/$maxNbOfPage",
//                           style: context.text.titleSmall,
//                         ),
//                       PageIndicatorWidget(
//                         pagesNb: maxNbOfPage,
//                         currentPage: currentPage,
//                         onTap: (value) =>
//                             onPageChange(value), // Passed correctly here
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (pages != null)
//             pages!.isEmpty
//                 ? (pagesPlaceholder ?? const SizedBox.shrink())
//                 : (currentPage >= 0 && currentPage < pages!.length)
//                 ? Expanded(
//                     child: pages![currentPage],
//                   ) // Directly use currentPage as 0-based index!
//                 : (pagesPlaceholder ?? const SizedBox.shrink()),
//           if (fixedWidget != null) fixedWidget!,
//         ],
//       ),
//     );
//   }
// }

// class IndicatorWidget extends StatelessWidget {
//   final double width;
//   final Color color;
//   final VoidCallback?
//   onTap; // Changed to standard VoidCallback for clean tap handling

//   const IndicatorWidget({
//     super.key,
//     required this.width,
//     required this.color,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap, // Fixed: Just pass the callback directly
//       child: Container(
//         width: width,
//         height: 13,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(15),
//         ),
//       ),
//     );
//   }
// }

// class SelectedPageIndicator extends StatelessWidget {
//   const SelectedPageIndicator({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return IndicatorWidget(width: 50, color: context.colors.tertiary);
//   }
// }

// class OnePageIndicator extends StatelessWidget {
//   final VoidCallback onTap;
//   const OnePageIndicator({super.key, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return IndicatorWidget(
//       width: 13,
//       color: context.colors.primary,
//       onTap: onTap,
//     );
//   }
// }

// class MoreThanOnePageIndicator extends StatelessWidget {
//   final VoidCallback onTap;
//   const MoreThanOnePageIndicator({super.key, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return IndicatorWidget(
//       width: 26,
//       color: context.colors.primary,
//       onTap: onTap,
//     );
//   }
// }

// class PageIndicatorWidget extends StatelessWidget {
//   final int pagesNb;
//   final int currentPage;
//   final Function(int) onTap;

//   const PageIndicatorWidget({
//     super.key,
//     required this.pagesNb,
//     required this.currentPage,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (pagesNb <= 0) return const SizedBox.shrink();

//     return Row(
//       spacing: 5,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (currentPage >= 2)
//           MoreThanOnePageIndicator(onTap: () => onTap(currentPage - 2)),

//         if (currentPage >= 1)
//           OnePageIndicator(onTap: () => onTap(currentPage - 1)),

//         const SelectedPageIndicator(),

//         if (currentPage < pagesNb - 1)
//           OnePageIndicator(onTap: () => onTap(currentPage + 1)),

//         if (currentPage < pagesNb - 2)
//           MoreThanOnePageIndicator(onTap: () => onTap(currentPage + 2)),
//       ],
//     );
//   }
// }

// // Simple helper widget to color our pages
// class ColoredPage extends StatelessWidget {
//   final Color color;
//   final String title;

//   const ColoredPage({super.key, required this.color, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: color,
//       child: Center(
//         child: Text(
//           title,
//           style: const TextStyle(
//             fontSize: 24,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }
