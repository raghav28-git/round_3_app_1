import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _HeroSection(animation: _animationController),
                _FeaturesSection(),
                _SystemOverviewSection(),
                _DashboardPreviewSection(),
                _HowItWorksSection(),
                _BenefitsSection(),
                _CTASection(),
                _Footer(),
              ],
            ),
          ),
          _NavBar(),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            Icon(Icons.location_city, color: Colors.blue.shade900, size: 32),
            const SizedBox(width: 12),
            Text('Smart City Portal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
            const Spacer(),
            if (MediaQuery.of(context).size.width > 800) ...[
              _NavItem('Home'),
              _NavItem('Features'),
              _NavItem('Infrastructure'),
              _NavItem('Analytics'),
              _NavItem('About'),
            ],
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Admin Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String text;
  const _NavItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
        child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final AnimationController animation;
  const _HeroSection({required this.animation});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
        child: size.width > 900
            ? Row(
                children: [
                  Expanded(child: _HeroContent()),
                  const SizedBox(width: 60),
                  Expanded(child: _FloatingDashboard(animation: animation)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _HeroContent(),
                  const SizedBox(height: 40),
                  _FloatingDashboard(animation: animation),
                ],
              ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage City Infrastructure with Intelligence',
          style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
        ),
        const SizedBox(height: 24),
        Text(
          'A centralized platform to monitor, organize, and manage urban infrastructure assets such as roads, utilities, and public facilities in real-time.',
          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9), height: 1.6),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade900,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => context.go('/login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('View Dashboard', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ],
    );
  }
}

class _FloatingDashboard extends StatelessWidget {
  final AnimationController animation;
  const _FloatingDashboard({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * animation.value),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.dashboard_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Live Dashboard',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('Live', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _ModernStatCard('1,247', 'Total Assets', Icons.account_tree_rounded, const Color(0xFF6366F1)),
                    const SizedBox(width: 16),
                    _ModernStatCard('892', 'Good Status', Icons.check_circle_rounded, const Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _ModernStatCard('245', 'Maintenance', Icons.build_rounded, const Color(0xFFF59E0B)),
                    const SizedBox(width: 16),
                    _ModernStatCard('110', 'Critical', Icons.warning_rounded, const Color(0xFFEF4444)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _ModernStatCard(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
      color: Colors.white,
      child: Column(
        children: [
          Text('Powerful Infrastructure Management', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            children: [
              _FeatureCard(Icons.account_tree, 'Infrastructure Asset Tracking', 'Track all city infrastructure assets in one place'),
              _FeatureCard(Icons.monitor_heart, 'Real-Time Status Monitoring', 'Monitor infrastructure health in real-time'),
              _FeatureCard(Icons.analytics, 'Smart Analytics Dashboard', 'Get insights with powerful analytics'),
              _FeatureCard(Icons.search, 'Infrastructure Search & Filtering', 'Find assets quickly with advanced search'),
              _FeatureCard(Icons.build, 'Maintenance Tracking', 'Schedule and track maintenance activities'),
              _FeatureCard(Icons.security, 'Secure Admin Access', 'Role-based access control for security'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureCard(this.icon, this.title, this.description);

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 350,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _isHovered ? Colors.blue.shade200 : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, size: 48, color: Colors.blue.shade700),
            const SizedBox(height: 20),
            Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(widget.description, style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _SystemOverviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/land.jpeg',
                height: 400,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 80),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart Insights for Smarter Cities', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Text('Empower city authorities with real-time infrastructure tracking and analytics.', style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.6)),
                const SizedBox(height: 32),
                _BulletPoint('Centralized infrastructure data'),
                _BulletPoint('Maintenance monitoring'),
                _BulletPoint('Asset performance analytics'),
                _BulletPoint('City-wide infrastructure overview'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _DashboardPreviewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
      color: Colors.white,
      child: Column(
        children: [
          Text('Built for Modern City Administration', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 60),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/land1.jpeg',
              height: 500,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text('How It Works', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StepCard('1', 'Add Infrastructure Assets', Icons.add_circle),
              _StepCard('2', 'Monitor Infrastructure Status', Icons.monitor),
              _StepCard('3', 'Analyze Infrastructure Data', Icons.analytics),
              _StepCard('4', 'Maintain Smart City Systems', Icons.settings),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;
  const _StepCard(this.number, this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade900,
            child: Text(number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Icon(icon, size: 48, color: Colors.blue.shade700),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
      color: Colors.white,
      child: Column(
        children: [
          Text('Key Benefits', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            children: [
              _BenefitCard('Better Infrastructure Visibility', Icons.visibility),
              _BenefitCard('Faster Maintenance Decisions', Icons.speed),
              _BenefitCard('Centralized Data Management', Icons.storage),
              _BenefitCard('Improved Urban Planning', Icons.map),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const _BenefitCard(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.purple.shade50]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Colors.blue.shade700),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 100),
      color: Colors.black,
      child: Column(
        children: [
          Text('Start Managing Your City Infrastructure Today', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Access Admin Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Explore Features', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FooterColumn('Product', ['Features', 'Dashboard', 'Analytics']),
              _FooterColumn('Company', ['About', 'Contact']),
              _FooterColumn('Legal', ['Privacy', 'Terms']),
            ],
          ),
          const SizedBox(height: 40),
          Divider(color: Colors.grey.shade700),
          const SizedBox(height: 20),
          Text('© 2024 Smart City Infrastructure Portal', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;
  const _FooterColumn(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(item, style: TextStyle(color: Colors.grey.shade400)),
            )),
      ],
    );
  }
}
