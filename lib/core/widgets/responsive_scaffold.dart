import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Navigation item definition for responsive shell
class NavigationItemData {
  final String label;
  final String vernacularLabel;
  final IconData icon;
  final IconData selectedIcon;
  final String routeName;

  const NavigationItemData({
    required this.label,
    required this.vernacularLabel,
    required this.icon,
    required this.selectedIcon,
    required this.routeName,
  });
}

/// Responsive Scaffold that switches between NavigationRail (tablets/desktops)
/// and NavigationBar (phones) for seamless classroom and teacher usage.
class ResponsiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  static const List<NavigationItemData> destinations = [
    NavigationItemData(
      label: 'Home',
      vernacularLabel: 'गृह',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      routeName: '/',
    ),
    NavigationItemData(
      label: 'Lessons',
      vernacularLabel: 'पाठ',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      routeName: '/lessons',
    ),
    NavigationItemData(
      label: 'Classroom',
      vernacularLabel: 'कक्षा',
      icon: Icons.record_voice_over_outlined,
      selectedIcon: Icons.record_voice_over,
      routeName: '/classroom',
    ),
    NavigationItemData(
      label: 'Translator',
      vernacularLabel: 'अनुवाद',
      icon: Icons.translate_outlined,
      selectedIcon: Icons.translate,
      routeName: '/translator',
    ),
    NavigationItemData(
      label: 'Worksheets',
      vernacularLabel: 'पत्रक',
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
      routeName: '/worksheets',
    ),
    NavigationItemData(
      label: 'Flashcards',
      vernacularLabel: 'कार्ड',
      icon: Icons.style_outlined,
      selectedIcon: Icons.style,
      routeName: '/flashcards',
    ),
    NavigationItemData(
      label: 'Diagnostics',
      vernacularLabel: 'स्थिति',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      routeName: '/diagnostics',
    ),
  ];

  const ResponsiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= AppSpacing.tabletBreakpoint;

    final currentTitle = title ?? destinations[selectedIndex].label;

    final appBar = AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  currentTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Text(
                  destinations[selectedIndex].vernacularLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const Text(
            'PALASH-Vaani (पलाश-वाणी) • Vernacular Pedagogy',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
      actions: [
        // Offline Status indicator badge placeholder for Milestone 1 / Milestone 2
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.offline.withValues(alpha: 0.12),
                borderRadius: AppSpacing.roundedPill,
                border: Border.all(color: AppColors.offline.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: AppColors.offline),
                  SizedBox(width: 5),
                  Text(
                    'Offline Ready',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.offline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...?actions,
      ],
    );

    if (isTablet) {
      // Tablet Layout with persistent NavigationRail
      return Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onIndexChanged,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: const Icon(Icons.school, color: Colors.white, size: 20),
                ),
              ),
              destinations: destinations.map((d) {
                return NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // Phone Layout with scrollable or adaptive NavigationBar
    // On phones, show the top primary items, and provide a bottom sheet or more menu if needed
    // In NavigationBar, Material 3 allows up to 7 items or we show the 5 primary tabs + drawer
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex >= 5 ? 4 : selectedIndex,
        onDestinationSelected: (idx) {
          if (idx == 4) {
            _showMoreMenu(context);
          } else {
            onIndexChanged(idx);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Lessons',
          ),
          NavigationDestination(
            icon: Icon(Icons.record_voice_over_outlined),
            selectedIcon: Icon(Icons.record_voice_over),
            label: 'Classroom',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate),
            label: 'Translator',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: const Text('Worksheets (कार्यपत्रक)'),
                  subtitle: const Text('Offline bilingual worksheet generator'),
                  selected: selectedIndex == 4,
                  onTap: () {
                    Navigator.pop(ctx);
                    onIndexChanged(4);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.style_outlined, color: AppColors.primary),
                  title: const Text('Flashcards (फ़्लैशकार्ड)'),
                  subtitle: const Text('Bilingual visual vocabulary deck'),
                  selected: selectedIndex == 5,
                  onTap: () {
                    Navigator.pop(ctx);
                    onIndexChanged(5);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined, color: AppColors.primary),
                  title: const Text('Diagnostics & Settings (सिस्टम स्थिति)'),
                  subtitle: const Text('Hardware telemetry, latencies, model status'),
                  selected: selectedIndex == 6,
                  onTap: () {
                    Navigator.pop(ctx);
                    onIndexChanged(6);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
