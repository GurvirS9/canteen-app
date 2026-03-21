import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:student_app/data/models/order.dart';
import 'package:student_app/presentation/providers/auth_provider.dart';
import 'package:student_app/presentation/providers/order_provider.dart';
import 'package:student_app/presentation/providers/theme_provider.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final user = auth.user;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkHeroGradient
                      : AppColors.heroGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          backgroundImage: user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl)
                              : null,
                          child: user?.avatarUrl == null
                              ? const Icon(Icons.person,
                                  size: 36, color: AppColors.primary)
                              : null,
                        )
                            .animate()
                            .scale(duration: 400.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        Text(
                          user?.name ?? 'Student',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                        Text(
                          user?.rollNumber ?? '',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13),
                        ).animate().fadeIn(delay: 150.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              // User info card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _infoCard(context, user),
              ),
              const SizedBox(height: 16),

              // Order history
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Order History', style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: 10),
              orderProvider.orderHistory.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No orders yet.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderProvider.orderHistory.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final order = orderProvider.orderHistory[i];
                        return _orderHistoryTile(context, order)
                            .animate()
                            .fadeIn(delay: (i * 80).ms)
                            .slideX(begin: 0.05);
                      },
                    ),
              const SizedBox(height: 16),

              // Settings section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Settings', style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: 10),
              _settingsTile(
                context,
                icon: Icons.info_outline_rounded,
                label: 'App Version',
                trailing: Text(
                  AppConstants.appVersion,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              _settingsTile(
                context,
                icon: Icons.phone_outlined,
                label: 'Contact Support',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call: +91 1234 567890')),
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Appearance', style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<ThemeMode>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: theme.cardTheme.color,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: AppColors.primary,
                  ),
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto, size: 18)),
                    ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.wb_sunny_rounded, size: 18)),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.nightlight_round, size: 18)),
                  ],
                  selected: {context.watch<ThemeProvider>().themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    context.read<ThemeProvider>().setThemeMode(newSelection.first);
                  },
                ),
              ),

              // Logout
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow(context, Icons.email_outlined, 'Email',
              user?.email ?? '-'),
          const Divider(height: 20),
          _infoRow(context, Icons.phone_outlined, 'Phone',
              user?.phone ?? '-'),
        ],
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }

  Widget _orderHistoryTile(BuildContext context, Order order) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.success, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.id,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontSize: 13)),
                Text(order.displaySummary,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            '₹${order.totalAmount.toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(BuildContext context,
      {required IconData icon,
      required String label,
      Widget? trailing,
      VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: theme.cardTheme.color,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: theme.textTheme.bodyLarge),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?'),
        content: const Text('You will be signed out of CampusEats.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      final navigator = Navigator.of(context);
      await auth.logout();
      navigator.pushNamedAndRemoveUntil(AppConstants.loginRoute, (_) => false);
    }
  }
}
