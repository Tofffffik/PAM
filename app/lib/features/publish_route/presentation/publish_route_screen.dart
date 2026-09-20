import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../shared/formatting.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_text_field.dart';

/// The driver's form. Validation arrives at L3, the request at L5.
class PublishRouteScreen extends StatefulWidget {
  const PublishRouteScreen({super.key});

  @override
  State<PublishRouteScreen> createState() => _PublishRouteScreenState();
}

class _PublishRouteScreenState extends State<PublishRouteScreen> {
  final TextEditingController _from = TextEditingController();
  final TextEditingController _to = TextEditingController();
  final TextEditingController _date = TextEditingController(
    text: Formatting.dateField(DateTime.now().add(const Duration(days: 1))),
  );
  final TextEditingController _time = TextEditingController(text: '17:40');
  final TextEditingController _seats = TextEditingController(text: '3');
  final TextEditingController _price = TextEditingController(text: '180');

  bool _published = false;

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _date.dispose();
    _time.dispose();
    _seats.dispose();
    _price.dispose();
    super.dispose();
  }

  void _swapCities() {
    final String from = _from.text;
    setState(() {
      _from.text = _to.text;
      _to.text = from;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Новый маршрут')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.screen,
          Spacing.sm,
          Spacing.screen,
          Spacing.block,
        ),
        children: <Widget>[
          CityPairField(
            fromController: _from,
            toController: _to,
            onSwap: _swapCities,
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AppTextField(
                  label: 'Дата',
                  controller: _date,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Время',
                  controller: _time,
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AppTextField(
                  label: 'Мест',
                  controller: _seats,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Цена за место, L',
                  controller: _price,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          if (_published) ...<Widget>[
            const SizedBox(height: Spacing.block),
            Text(
              'Маршрут опубликован',
              style: AppTypography.body.copyWith(color: colors.ok),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          Spacing.screen,
          0,
          Spacing.screen,
          Spacing.lg,
        ),
        child: PrimaryButton(
          label: 'Опубликовать маршрут',
          onPressed: () => setState(() => _published = true),
        ),
      ),
    );
  }
}
