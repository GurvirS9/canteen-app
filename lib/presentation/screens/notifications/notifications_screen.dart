import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:student_app/data/models/notification_model.dart';
import 'package:student_app/presentation/providers/notification_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton(
              onPressed: notifProvider.markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🔔', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 16),
                  Text('No notifications yet',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final notif = notifications[i];
                return _NotifTile(notif: notif)
                    .animate()
                    .fadeIn(delay: (i * 50).ms)
                    .slideX(begin: 0.1);
              },
            ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;

  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOffer = notif.type == NotificationType.offer;

    return GestureDetector(
      onTap: () => context.read<NotificationProvider>().markRead(notif.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead
              ? theme.cardTheme.color
              : (isOffer
                  ? AppColors.secondary.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(14),
          border: notif.isRead
              ? null
              : Border.all(
                  color: isOffer
                      ? AppColors.secondary.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.25),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isOffer
                    ? AppColors.secondary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isOffer ? '🎁' : '🍽️',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notif.timestamp),
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
