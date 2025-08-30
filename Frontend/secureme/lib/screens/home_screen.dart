// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'link_analyzer_screen.dart';
import 'password_manager_screen.dart';
import '../providers/analytics_provider.dart';
import '../widgets/secureme_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardScreen(),
    const PasswordManagerScreen(),
    const LinkAnalyzerScreen(),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lock_rounded),
              label: 'Passwords',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.link_rounded),
              label: 'Link Scan',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[500],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        final isVerySmallScreen = screenWidth < 320;
        final padding = isVerySmallScreen ? 12.0 : 16.0;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: isSmallScreen ? 120 : 140,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth - 32,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SecureMeLogo(
                          size: isVerySmallScreen
                              ? 20
                              : isSmallScreen
                                  ? 24
                                  : 28),
                      SizedBox(
                          width: isVerySmallScreen
                              ? 6
                              : isSmallScreen
                                  ? 8
                                  : 12),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SecureMe',
                              style: GoogleFonts.inter(
                                fontSize: isVerySmallScreen
                                    ? 16
                                    : isSmallScreen
                                        ? 18
                                        : 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!isVerySmallScreen) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Your security is our priority',
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(padding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSecurityOverview(context),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  _buildQuickActions(context),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  _buildSecurityTips(context),
                  const SizedBox(height: 100), // Bottom padding for navigation
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecurityOverview(BuildContext context) {
    final analytics = Provider.of<AnalyticsProvider>(context);
    const alertsCount = 0; // Hardcoded to 0 as requested
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;
    final cardPadding = isVerySmallScreen ? 12.0 : 16.0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flex(
              direction: isVerySmallScreen ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: isVerySmallScreen
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isVerySmallScreen
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    'Security Overview',
                    style: GoogleFonts.inter(
                      fontSize: isVerySmallScreen
                          ? 16
                          : isSmallScreen
                              ? 17
                              : 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isVerySmallScreen) const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isVerySmallScreen ? 8 : 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Secure',
                        style: GoogleFonts.inter(
                          fontSize: isVerySmallScreen ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    _buildStatItem(
                      context,
                      'Passwords',
                      analytics.passwordCount.toString(),
                      Icons.lock_outline_rounded,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      context,
                      'Links Scanned',
                      analytics.linksAnalyzed.toString(),
                      Icons.link_rounded,
                      Colors.purple,
                    ),
                    _buildStatItem(
                      context,
                      'Alerts',
                      alertsCount.toString(),
                      Icons.warning_amber_rounded,
                      alertsCount > 0 ? Colors.orange : Colors.grey,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 360;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isVerySmallScreen ? 75 : 85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isVerySmallScreen ? 8 : 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isVerySmallScreen ? 18 : 20),
          ),
          SizedBox(height: isVerySmallScreen ? 6 : 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isVerySmallScreen
                  ? 16
                  : isSmallScreen
                      ? 17
                      : 18,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isVerySmallScreen ? 10 : 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: isVerySmallScreen
                ? 16
                : isSmallScreen
                    ? 17
                    : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (isVerySmallScreen) {
              // Stack vertically on very small screens
              return Column(
                children: [
                  _QuickActionCard(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Add Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordManagerScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _QuickActionCard(
                    icon: Icons.link_rounded,
                    label: 'Scan Link',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LinkAnalyzerScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _QuickActionCard(
                    icon: Icons.security_update_good_rounded,
                    label: 'Security Check',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Coming Soon!'),
                            content: const Text(
                                'We\'re working on this feature. Stay tuned!'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            } else {
              // Use row layout for larger screens
              return Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Add Password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PasswordManagerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.link_rounded,
                      label: 'Scan Link',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LinkAnalyzerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.security_update_good_rounded,
                      label: 'Security Check',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Coming Soon!'),
                              content: const Text(
                                  'We\'re working on this feature. Stay tuned!'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildSecurityTips(BuildContext context) {
    final tips = [
      'Enable two-factor authentication for added security',
      'Regularly update your passwords',
      'Be cautious of suspicious links in emails',
      'Use a unique password for each account',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Tips',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          tips.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    tips[index],
                    style: GoogleFonts.inter(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 320;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: isVerySmallScreen ? 12 : 16,
            horizontal: isVerySmallScreen ? 6 : 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isVerySmallScreen ? 8 : 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isVerySmallScreen ? 20 : 22,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 6 : 8),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isVerySmallScreen ? 10 : 12,
                  fontWeight: FontWeight.w500,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
