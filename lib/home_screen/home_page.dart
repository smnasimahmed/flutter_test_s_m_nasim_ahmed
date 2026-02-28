import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daraz_task/constant/color/const_colour.dart';
import 'package:daraz_task/home_screen/controller/home_page_controller.dart';
import 'package:daraz_task/home_screen/widgets/banner_widget.dart';
import 'package:daraz_task/home_screen/widgets/product_grid_for_tab.dart';
import 'package:daraz_task/routes/app_routes.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColour.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingProducts.value && controller.allProducts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: ConstColour.primary),
            );
          }
          return _HomeBodyView(controller: controller);
        }),
      ),
    );
  }
}

class _HomeBodyView extends StatefulWidget {
  final HomePageController controller;

  const _HomeBodyView({required this.controller});

  @override
  State<_HomeBodyView> createState() => _HomeBodyViewState();
}

class _HomeBodyViewState extends State<_HomeBodyView> {
  late PageController _pageController;
  bool _syncingFromTab = false;
  bool _syncingFromPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.controller.tabController.index);
    widget.controller.tabController.addListener(_onTabControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.tabController.removeListener(_onTabControllerChanged);
    _pageController.dispose();
    super.dispose();
  }

  /// Called when TabBar indicator changes (user tapped a tab)
  void _onTabControllerChanged() {
    if (_syncingFromPage) return;
    if (!widget.controller.tabController.indexIsChanging) return;
    final index = widget.controller.tabController.index;
    if (_pageController.hasClients) {
      _syncingFromTab = true;
      _pageController
          .animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
          .then((_) => _syncingFromTab = false);
    }
  }

  /// Called when user swipes the PageView
  void _onPageChanged(int index) {
    if (_syncingFromTab) return;
    _syncingFromPage = true;
    widget.controller.tabController.animateTo(index);
    _syncingFromPage = false;
  }

  @override
  Widget build(BuildContext context) {
    // Height available for the PageView (screen minus safeArea top, appBar, tabBar)
    final safeTop = MediaQuery.of(context).padding.top;
    final screenH = MediaQuery.of(context).size.height;
    const appBarH = kToolbarHeight; // 56
    const tabBarH = 50.0;
    final pageViewH = screenH - safeTop - appBarH - tabBarH;

    return RefreshIndicator(
      color: ConstColour.primary,
      onRefresh: widget.controller.onRefresh,
      child: CustomScrollView(
        controller: widget.controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Collapsible banner / search bar ─────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: false,
            snap: true,
            backgroundColor: ConstColour.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Obx(() => BannerWidget(user: widget.controller.currentUser.value)),
            ),
            actions: [
              Obx(
                () => GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.profilePage),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: widget.controller.currentUser.value != null
                        ? Center(
                            child: Text(
                              widget.controller.currentUser.value!.fullName
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky tab bar ───────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Obx(
                      () => TabBar(
                        controller: widget.controller.tabController,
                        isScrollable: true,
                        indicatorColor: ConstColour.primary,
                        indicatorWeight: 3,
                        labelColor: ConstColour.primary,
                        unselectedLabelColor: ConstColour.textMedium,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                        tabs: widget.controller.tabLabels
                            .map((l) => Tab(text: _capitalize(l)))
                            .toList(),
                      ),
                    ),
                    const Divider(height: 0, thickness: 1, color: ConstColour.divider),
                  ],
                ),
              ),
            ),
          ),

          // ── Tab content: PageView (horizontal) inside SliverToBoxAdapter ─
          SliverToBoxAdapter(
            child: Obx(() {
              if (widget.controller.tabLabels.length <= 1) {
                return const SizedBox(height: 300);
              }
              return SizedBox(
                height: pageViewH,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const PageScrollPhysics(),
                  itemCount: widget.controller.tabLabels.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (_, tabIndex) => ProductGridForTab(
                    tabIndex: tabIndex,
                    controller: widget.controller,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}

// ─── Sticky tab bar persistent header delegate ───────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  double get minExtent => 49.0;

  @override
  double get maxExtent => 49.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(_TabBarDelegate old) => child != old.child;
}
