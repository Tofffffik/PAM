import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/spacing.dart';
import '../shared/demo_data.dart';
import '../shared/models/booking.dart';
import '../shared/models/route.dart' as model;
import '../shared/widgets/app_buttons.dart';
import '../shared/widgets/app_text_field.dart';
import '../shared/widgets/booking_status_chip.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/filter_chips.dart';
import '../shared/widgets/route_row.dart';
import '../shared/widgets/seat_pips.dart';

/// Temporary screen that puts every component state and every empty-state
/// wording side by side, so that the ones the normal flow never reaches can
/// still be looked at. It is deleted once the router lands at L3.
class SandboxScreen extends StatelessWidget {
  const SandboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Компоненты и состояния')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xxxl),
        children: const <Widget>[
          _Section('Места'),
          _SeatPipsGallery(),
          _Section('Строка маршрута'),
          _RouteRowGallery(),
          _Section('Статус брони'),
          _StatusGallery(),
          _Section('Кнопки'),
          _ButtonsGallery(),
          _Section('Поля и чипы'),
          _FieldsGallery(),
          _Section('Пустые состояния'),
          _EmptyStatesGallery(),
          _Section('Сообщения'),
          _MessagesGallery(),
          _Section('Тёмная тема'),
          _DarkPreview(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.screen,
        Spacing.block,
        Spacing.screen,
        Spacing.md,
      ),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(color: context.colors.moss),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SeatPipsGallery extends StatelessWidget {
  const _SeatPipsGallery();

  @override
  Widget build(BuildContext context) {
    return const _Block(
      children: <Widget>[
        SeatPips(total: 5, free: 3),
        SizedBox(height: Spacing.md),
        SeatPips(total: 4, free: 1),
        SizedBox(height: Spacing.md),
        SeatPips(total: 4, free: 0),
        SizedBox(height: Spacing.md),
        SeatPips(total: 12, free: 9),
      ],
    );
  }
}

class _RouteRowGallery extends StatelessWidget {
  const _RouteRowGallery();

  @override
  Widget build(BuildContext context) {
    final List<model.Route> sample = <model.Route>[
      demoRouteById('r7'),
      demoRouteById('r9'),
      demoRouteById('r2'),
      demoRouteById('r10'),
    ];

    return _Block(
      children: <Widget>[
        for (int i = 0; i < sample.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: Spacing.sm),
          RouteRow(
            route: sample[i],
            freeSeats: sample[i].freeSeats(demoBookings),
          ),
        ],
      ],
    );
  }
}

class _StatusGallery extends StatelessWidget {
  const _StatusGallery();

  @override
  Widget build(BuildContext context) {
    return const _Block(
      children: <Widget>[
        BookingStatusChip(status: BookingStatus.active),
        SizedBox(height: Spacing.md),
        BookingStatusChip(status: BookingStatus.cancelled),
      ],
    );
  }
}

class _ButtonsGallery extends StatelessWidget {
  const _ButtonsGallery();

  @override
  Widget build(BuildContext context) {
    return _Block(
      children: <Widget>[
        PrimaryButton(label: 'Забронировать место', onPressed: () {}),
        const SizedBox(height: Spacing.md),
        const PrimaryButton(label: 'Забронировать место'),
        const SizedBox(height: Spacing.md),
        SecondaryButton(label: 'Опубликовать маршрут', onPressed: () {}),
        const SizedBox(height: Spacing.md),
        DangerButton(label: 'Отменить бронь', onPressed: () {}),
        const SizedBox(height: Spacing.md),
        AppTextButton(label: 'Забыли пароль', onPressed: () {}),
      ],
    );
  }
}

class _FieldsGallery extends StatelessWidget {
  const _FieldsGallery();

  @override
  Widget build(BuildContext context) {
    return _Block(
      children: <Widget>[
        const AppTextField(label: 'Почта', hint: 'name@student.utm.md'),
        const SizedBox(height: Spacing.lg),
        const AppTextField(
          label: 'Цена за место, L',
          hint: '180',
          errorText: 'Цена должна быть больше нуля',
        ),
        const SizedBox(height: Spacing.lg),
        Row(
          children: <Widget>[
            const FilterToggleChip(label: 'Сегодня', selected: true),
            const SizedBox(width: Spacing.sm),
            const FilterToggleChip(label: 'Есть места', selected: false),
          ],
        ),
      ],
    );
  }
}

class _EmptyStatesGallery extends StatelessWidget {
  const _EmptyStatesGallery();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        EmptyState.noRoutes(),
        EmptyState.noTrips(),
        EmptyState.noPublishedRoutes(),
        EmptyState.offline(),
        EmptyState.loadFailed(),
      ],
    );
  }
}

class _MessagesGallery extends StatelessWidget {
  const _MessagesGallery();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return _Block(
      children: <Widget>[
        Text(
          'Место забронировано',
          style: AppTypography.body.copyWith(color: colors.ok),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          'Маршрут опубликован',
          style: AppTypography.body.copyWith(color: colors.ok),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          'Свободно только 2 места.',
          style: AppTypography.body.copyWith(color: colors.warn),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          'Отменить бронь? Места вернутся в продажу.',
          style: AppTypography.body.copyWith(color: colors.ink),
        ),
      ],
    );
  }
}

/// The dark scheme rendered next to the light one, so the second theme does
/// not depend on changing a system setting to be seen.
class _DarkPreview extends StatelessWidget {
  const _DarkPreview();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (BuildContext context) {
          return ColoredBox(
            color: context.colors.paper,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Block(
                    children: <Widget>[
                      RouteRow(
                        route: demoRouteById('r9'),
                        freeSeats: demoRouteById('r9')
                            .freeSeats(demoBookings),
                      ),
                      const SizedBox(height: Spacing.lg),
                      PrimaryButton(
                        label: 'Забронировать место',
                        onPressed: () {},
                      ),
                      const SizedBox(height: Spacing.md),
                      const BookingStatusChip(
                        status: BookingStatus.cancelled,
                      ),
                    ],
                  ),
                  const EmptyState.noTrips(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
