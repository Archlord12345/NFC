import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../presentation/providers/auth_provider.dart';

/// Page de profil utilisateur.
class ProfilePage extends StatelessWidget {
  final VoidCallback onLogout;
  const ProfilePage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.utilisateur;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),
              // ── Avatar ──
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                  child: const Icon(Icons.person, size: 44, color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user?.email.split('@').first.toUpperCase() ?? 'ALEX JOHNSON',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user?.email ?? 'alex@example.com',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Options ──
              _ProfileTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {},
              ),
              _ProfileTile(
                icon: Icons.security,
                title: 'Security',
                onTap: () {},
              ),
              _ProfileTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {},
              ),
              _ProfileTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _ProfileTile(
                icon: Icons.logout,
                title: 'Logout',
                isDestructive: true,
                onTap: onLogout,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title,
            style: theme.textTheme.bodyLarge?.copyWith(color: color)),
        trailing: Icon(Icons.chevron_right,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }
}
