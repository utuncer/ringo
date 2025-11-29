import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/app_colors.dart';
import '../data/notification_repository.dart';
import '../domain/notification.dart';

part 'notification_list_screen.g.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: AppColors.surfaceDark,
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text('Bildirim yok', style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationItem(notification: notification);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: notification.isRead
          ? Colors.transparent
          : AppColors.surfaceDark.withOpacity(0.5),
      leading: const Icon(Icons.notifications, color: AppColors.primary),
      title: Text(
        notification.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.content,
            style: const TextStyle(color: Colors.grey),
          ),
          if (notification.type == 'invitation') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final teamId = notification.metadata?['team_id'];
                    if (teamId != null) {
                      ref
                          .read(notificationRepositoryProvider)
                          .acceptInvitation(notification.id, teamId);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Kabul Et'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    final teamId = notification.metadata?['team_id'];
                    if (teamId != null) {
                      ref
                          .read(notificationRepositoryProvider)
                          .rejectInvitation(notification.id, teamId);
                    }
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('Reddet'),
                ),
              ],
            ),
          ],
        ],
      ),
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationRepositoryProvider).markAsRead(notification.id);
        }
      },
    );
  }
}

@riverpod
Stream<List<AppNotification>> notifications(Ref ref) {
  return ref.read(notificationRepositoryProvider).getNotifications();
}
