import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../enums/screens.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_screen_provider.dart';
import '../../providers/screen_size_provider.dart';
import '../../utils/common_utils.dart';
import '../financial_cards/financial_card_list.dart';
import '../identity_cards/identity_card_list.dart';
import '../logins/login_list.dart';
import '../notes/note_list.dart';
import '../settings/settings_view.dart';

const noteIcon = Icon(Icons.book);
const identityCardIcon = Icon(Icons.person);
const loginIcon = Icon(Icons.mail_outlined);
const financialCardIcon = Icon(Icons.credit_card);
const settingsIcon = Icon(Icons.settings);

class HomeScreen extends ConsumerWidget {
  static const path = '/home';
  // Change to ConsumerWidget
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    final screenSize = getScreenSize(context);

    // Avoid modifying the provider state directly in the build method
    // Use a post-frame callback to update the state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(screenSizeProvider.notifier).state = screenSize;
    });

    return Scaffold(
      body: Row(
        children: [
          if (screenSize != ScreenSize.small) _buildNavigationRail(ref),
          Expanded(
            child: _buildContent(
              selectedIndex,
            ),
          ),
        ],
      ),
      bottomNavigationBar: screenSize == ScreenSize.small
          ? _buildBottomNavigationBar(context, ref)
          : null,
    );
  }

  Widget _buildNavigationRail(WidgetRef ref) {
    // Update method signature
    var selectedIndex = ref.watch(selectedIndexProvider);
    return Column(
      children: [
        Expanded(
          child: NavigationRail(
            selectedIndex: selectedIndex < 5 ? selectedIndex : null,
            onDestinationSelected: (int index) {
              ref
                  .read(selectedIndexProvider.notifier)
                  .selectIndex(index); // Update state
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: loginIcon,
                selectedIcon: loginIcon,
                label: Text('Logins'),
              ),
              NavigationRailDestination(
                icon: financialCardIcon,
                selectedIcon: financialCardIcon,
                label: Text('Cards'),
              ),
              NavigationRailDestination(
                icon: identityCardIcon,
                selectedIcon: identityCardIcon,
                label: Text('Identity'),
              ),
              NavigationRailDestination(
                icon: noteIcon,
                selectedIcon: noteIcon,
                label: Text('Notes'),
              ),
              NavigationRailDestination(
                icon: settingsIcon,
                selectedIcon: settingsIcon,
                label: Text('Settings'),
              ),
            ],
          ),
        ),
        // const Spacer(),
        InkWell(
          onTap: () {
            ref.read(authProvider.notifier).logout();
          },
          borderRadius: BorderRadius.circular(24.0),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
            ),
            height: 32,
            width: 54,
            child: const Icon(
              Icons.logout,
              semanticLabel: 'Logout',
            ),
          ),
        ),
        const SizedBox(height: 8), // Add some padding at the bottom
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: ref.watch(selectedIndexProvider),
        onTap: (int index) {
          ref.read(selectedIndexProvider.notifier).selectIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: loginIcon,
            label: 'Logins',
          ),
          BottomNavigationBarItem(
            icon: financialCardIcon,
            label: 'Cards',
          ),
          BottomNavigationBarItem(
            icon: identityCardIcon,
            label: 'Identity',
          ),
          BottomNavigationBarItem(
            icon: noteIcon,
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: settingsIcon,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int selectedIndex) {
    // Update method signature
    switch (selectedIndex) {
      case 0:
        return const LoginList();
      case 1:
        return const FinancialCardList();
      case 2:
        return const IdentityCardList();
      case 3:
        return const NoteList();
      case 4:
        return const SettingsScreen();
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }
}
