import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

/// The message shown in place of a list. The wording is fixed by the visual
/// system, so every empty state in the application is built from one of the
/// named constructors below.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.action});

  /// Nothing matches the search.
  const EmptyState.noRoutes({Key? key, Widget? action})
      : this(
          key: key,
          message: 'На эту дату рейсов нет. Измените дату или направление.',
          action: action,
        );

  /// The passenger has not booked anything yet.
  const EmptyState.noTrips({Key? key, Widget? action})
      : this(
          key: key,
          message:
              'Вы ещё не бронировали поездки. Найдите рейс на нужную дату.',
          action: action,
        );

  /// The driver has not published anything yet.
  const EmptyState.noPublishedRoutes({Key? key, Widget? action})
      : this(
          key: key,
          message: 'Вы ещё не публиковали маршруты. '
              'Опубликуйте первый — его увидят попутчики.',
          action: action,
        );

  /// Offline, showing whatever was loaded last.
  const EmptyState.offline({Key? key, Widget? action})
      : this(
          key: key,
          message: 'Нет соединения. Показаны последние загруженные рейсы.',
          action: action,
        );

  /// The request failed.
  const EmptyState.loadFailed({Key? key, Widget? action})
      : this(
          key: key,
          message:
              'Не удалось загрузить рейсы. Проверьте соединение и повторите.',
          action: action,
        );

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screen,
        vertical: Spacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: AppTypography.body.copyWith(color: context.colors.moss),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(height: Spacing.block),
            action!,
          ],
        ],
      ),
    );
  }
}
