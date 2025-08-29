import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'link_analyzer_screen.dart';
import 'password_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardScreen(),
    const PasswordManagerScreen(),
    const LinkAnalyzerScreen(),
    const _ProfileScreen(),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Welcome Back',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
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
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildSecurityStatus(context),
              const SizedBox(height: 24),
              _buildRecentActivity(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_outline_rounded,
                label: 'Add New',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.search_rounded,
                label: 'Search',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.security_rounded,
                label: 'Security',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityStatus(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Security Status',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.85,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '85% Secure',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Improve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                'Password Updated',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '2 hours ago',
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            );
          },
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Screen',
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
