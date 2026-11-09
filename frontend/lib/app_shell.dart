import 'package:flutter/material.dart';

import 'app_widgets.dart';
import 'demo_data.dart';

part 'dashboard_home.dart';
part 'inbox_view.dart';
part 'workspace_views.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.onSignOut,
    this.userEmail,
    this.demoMode = false,
  });

  final VoidCallback onSignOut;
  final String? userEmail;
  final bool demoMode;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static const _navItems = <_NavItem>[
    _NavItem('Dashboard', Icons.grid_view_rounded),
    _NavItem('Inbox', Icons.forum_outlined),
    _NavItem('Automações', Icons.account_tree_outlined),
    _NavItem('Audiência', Icons.people_outline_rounded),
    _NavItem('Configurações', Icons.settings_outlined),
  ];

  void _showAction(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateTo(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            title: Text(
              _navItems[_selectedIndex].label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                tooltip: 'Ajuda',
                onPressed: () => _showAction('Central de ajuda em breve.'),
                icon: const Icon(Icons.help_outline_rounded),
              ),
              PopupMenuButton<String>(
                tooltip: 'Conta',
                onSelected: (value) {
                  if (value == 'logout') widget.onSignOut();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(widget.userEmail ?? 'Modo demonstração'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Sair'),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Avatar(label: 'MC', size: 34),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              if (!isCompact)
                _Sidebar(
                  selectedIndex: _selectedIndex,
                  navItems: _navItems,
                  demoMode: widget.demoMode,
                  userEmail: widget.userEmail,
                  onSelected: _navigateTo,
                ),
              Expanded(
                child: _ContentArea(
                  selectedIndex: _selectedIndex,
                  demoMode: widget.demoMode,
                  onNavigate: _navigateTo,
                  onAction: _showAction,
                ),
              ),
            ],
          ),
          bottomNavigationBar: isCompact
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _navigateTo,
                  destinations: _navItems
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                )
              : null,
        );
      },
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;

  IconData get selectedIcon => icon;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedIndex,
    required this.navItems,
    required this.demoMode,
    required this.userEmail,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<_NavItem> navItems;
  final bool demoMode;
  final String? userEmail;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Row(
              children: [
                const LogoMark(compact: true),
                const SizedBox(width: 10),
                Text(
                  'MaisuChat',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Avatar(label: 'AC', size: 34, color: Color(0xFF0F766E)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acme Commerce',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2),
                        Text('Workspace principal', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.unfold_more_rounded,
                      size: 18, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    'WORKSPACE',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                ...navItems.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: ListTile(
                          selected: selectedIndex == entry.key,
                          selectedTileColor: scheme.secondaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Icon(entry.value.icon, size: 20),
                          title: Text(
                            entry.value.label,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onTap: () => onSelected(entry.key),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          if (demoMode)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: StatusPill(
                label: 'Modo demonstração',
                tone: StatusTone.info,
                icon: Icons.science_outlined,
              ),
            ),
          Divider(height: 1, color: scheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Avatar(label: 'MC', size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    userEmail ?? 'Conta de demonstração',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentArea extends StatelessWidget {
  const _ContentArea({
    required this.selectedIndex,
    required this.demoMode,
    required this.onNavigate,
    required this.onAction,
  });

  final int selectedIndex;
  final bool demoMode;
  final ValueChanged<int> onNavigate;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final content = switch (selectedIndex) {
      0 => _DashboardHome(
          demoMode: demoMode,
          onNavigate: onNavigate,
          onAction: onAction,
        ),
      1 => _InboxView(onAction: onAction),
      2 => _AutomationsView(onAction: onAction),
      3 => const _AudienceView(),
      _ => _SettingsView(demoMode: demoMode),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: content,
        ),
      ),
    );
  }
}
