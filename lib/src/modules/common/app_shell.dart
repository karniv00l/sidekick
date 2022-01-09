import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:i18next/i18next.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sidekick/src/components/organisms/app_bottom_bar.dart';
import 'package:sidekick/src/modules/common/utils/indexed_transition_switcher.dart';
import 'package:sidekick/src/modules/search/components/search_bar.dart';
import 'package:sidekick/src/modules/selected_detail/components/info_drawer.dart';

import '../../components/molecules/top_app_bar.dart';
import '../../components/organisms/shortcut_manager.dart';
import '../../modules/common/utils/layout_size.dart';
import '../../theme.dart';
import '../fvm/fvm.screen.dart';
import '../navigation/navigation.provider.dart';
import '../projects/projects.screen.dart';
import '../releases/releases.screen.dart';
import '../selected_detail/selected_detail.provider.dart';
import 'constants.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();

const pages = [
  FVMScreen(),
  ProjectsScreen(),
  ReleasesScreen(),
];

/// Main widget of the app
class AppShell extends HookWidget {
  /// Constructor
  const AppShell({Key key}) : super(key: key);

  NavigationRailDestination renderNavButton(
    BuildContext context,
    String label,
    IconData iconData,
  ) {
    return NavigationRailDestination(
      icon: Icon(iconData, size: 20),
      selectedIcon: Icon(
        iconData,
        size: 20,
        color: Theme.of(context).colorScheme.secondary,
      ),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LayoutSize.init(context);
    final navigation = useProvider(navigationProvider.notifier);
    final currentRoute = useProvider(navigationProvider);
    final selectedInfo = useProvider(selectedDetailProvider).state;
    final focusNode = useFocusNode();

    // Index of item selected
    final selectedIndex = useState(0);

    // Side effect when route changes
    useValueChanged(currentRoute, (_, __) {
      // Do not set index if its search
      if (currentRoute != NavigationRoutes.searchScreen) {
        selectedIndex.value = currentRoute.index;
      }
    });

    // Side effect when info is selected
    useValueChanged(selectedInfo, (_, __) {
      if (_scaffoldKey.currentState == null) return;
      final isOpen = _scaffoldKey.currentState.isEndDrawerOpen;
      final hasInfo = selectedInfo?.release != null;

      // Open drawer if not large layout and its not open
      if (hasInfo && !isOpen) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _scaffoldKey.currentState.openEndDrawer();
        });
      }
    });

    return SkShortcutManager(
      focusNode: focusNode,
      child: Scaffold(
        appBar: const SkAppBar(),
        bottomNavigationBar: const AppBottomBar(),
        endDrawer: const SelectedDetailDrawer(),
        backgroundColor: platformBackgroundColor(context),
        key: _scaffoldKey,
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: platformBackgroundColor(context),
              selectedIndex: selectedIndex.value,
              minWidth: kNavigationWidth,
              minExtendedWidth: kNavigationWidthExtended,
              extended: !LayoutSize.isSmall,
              onDestinationSelected: (index) {
                navigation.goTo(NavigationRoutes.values[index]);
              },
              destinations: [
                renderNavButton(
                  context,
                  I18Next.of(context).t('modules:common.navButtonDashboard'),
                  Icons.category,
                ),
                renderNavButton(
                  context,
                  I18Next.of(context).t('modules:common.navButtonProjects'),
                  MdiIcons.folderMultiple,
                ),
                renderNavButton(
                  context,
                  I18Next.of(context).t('modules:common.navButtonExplore'),
                  Icons.explore,
                ),
              ],
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Scaffold(
                    body: Container(
                      child: Row(
                        children: <Widget>[
                          // This is the main content.
                          Expanded(
                            child: IndexedTransitionSwitcher(
                              duration: const Duration(milliseconds: 250),
                              reverse: selectedIndex.value <
                                  (navigation.previous.index ?? 0),
                              transitionBuilder: (
                                child,
                                animation,
                                secondaryAnimation,
                              ) {
                                return SharedAxisTransition(
                                  fillColor: Colors.transparent,
                                  animation: animation,
                                  secondaryAnimation: secondaryAnimation,
                                  transitionType:
                                      SharedAxisTransitionType.vertical,
                                  child: child,
                                );
                              },
                              index: selectedIndex.value,
                              children: pages,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SearchBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
