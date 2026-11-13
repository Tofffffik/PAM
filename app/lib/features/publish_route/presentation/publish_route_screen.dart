import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/router/navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/spacing.dart';
import '../../../data/repositories/route_repository.dart';
import '../../../shared/formatting.dart';
import '../../../shared/state/catalog.dart';
import '../../../shared/validators.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/domain/session_controller.dart';

/// The driver's form.
///
/// Date and time come from pickers and are checked together: the departure
/// must be at least a quarter of an hour ahead and within the publishing
/// horizon. Seats and price accept only digits as they are typed and are
/// checked against their ranges on submit. Leaving a form that has been
/// touched asks first. A valid form is handed to [routesProvider]; once it is
/// stored the form closes with a confirmation message.
class PublishRouteScreen extends ConsumerStatefulWidget {
  const PublishRouteScreen({super.key});

  @override
  ConsumerState<PublishRouteScreen> createState() =>
      _PublishRouteScreenState();
}

class _PublishRouteScreenState extends ConsumerState<PublishRouteScreen> {
  static const TimeOfDay _defaultTime = TimeOfDay(hour: 17, minute: 40);

  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  DateTime _day =
      DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1));
  TimeOfDay _time = _defaultTime;

  final TextEditingController _from = TextEditingController();
  final TextEditingController _to = TextEditingController();
  late final TextEditingController _date = TextEditingController(
    text: Formatting.dateField(_day),
  );
  late final TextEditingController _timeText = TextEditingController(
    text: _formatTime(_time),
  );
  final TextEditingController _seats = TextEditingController(text: '3');
  final TextEditingController _price = TextEditingController(text: '180');

  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _dirty = false;
  bool _saving = false;

  DateTime get _departure =>
      DateTime(_day.year, _day.month, _day.day, _time.hour, _time.minute);

  @override
  void initState() {
    super.initState();
    for (final TextEditingController controller in <TextEditingController>[
      _from,
      _to,
      _seats,
      _price,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    _date.dispose();
    _timeText.dispose();
    _seats.dispose();
    _price.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  static String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _swapCities() {
    final String from = _from.text;
    _from.text = _to.text;
    _to.text = from;
  }

  Future<void> _pickDate() async {
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _day.isBefore(today) ? today : _day,
      firstDate: today,
      lastDate: today.add(Validators.departureHorizon),
      helpText: 'Дата выезда',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _day = picked;
      _dirty = true;
    });
    _date.text = Formatting.dateField(picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Время выезда',
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _dirty = true;
    });
    _timeText.text = _formatTime(picked);
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_form.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    final String? driverId = ref.read(sessionProvider)?.id;
    if (driverId == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await ref.read(routesProvider.notifier).publish(
            RouteDraft(
              driverId: driverId,
              fromCity: _from.text.trim(),
              toCity: _to.text.trim(),
              departureAt: _departure,
              seatsTotal: int.parse(_seats.text),
              price: Validators.parsePrice(_price.text)!,
            ),
          );
    } on ArgumentError {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Проверьте число мест и цену')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Маршрут опубликован')),
    );
    _leave();
  }

  /// Lets go of the unsaved-changes guard and closes the form. The pop waits
  /// for the next frame: until [PopScope] is rebuilt with `canPop: true` it
  /// would still refuse.
  void _leave() {
    setState(() => _dirty = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.popOrGo(AppRoutes.trips);
    });
  }

  Future<void> _confirmLeave() async {
    final bool leave = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Не публиковать маршрут?'),
            content: const Text('Введённые данные не сохранятся.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Остаться'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Выйти'),
              ),
            ],
          ),
        ) ??
        false;
    if (leave && mounted) _leave();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return PopScope<Object?>(
      canPop: !_dirty,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Новый маршрут')),
        body: Form(
          key: _form,
          autovalidateMode: _autovalidate,
          child: ListView(
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
                validator: Validators.cityPair,
              ),
              const SizedBox(height: Spacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: AppTextField(
                      key: const ValueKey<String>('publish-date'),
                      label: 'Дата',
                      controller: _date,
                      readOnly: true,
                      onTap: _pickDate,
                      trailing: Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: colors.moss,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: AppTextField(
                      key: const ValueKey<String>('publish-time'),
                      label: 'Время',
                      controller: _timeText,
                      readOnly: true,
                      onTap: _pickTime,
                      // Date and time make one value; its message goes under
                      // the time, the field changed last in the usual order.
                      validator: (_) => Validators.departure(_departure),
                      trailing: Icon(
                        Icons.schedule,
                        size: 18,
                        color: colors.moss,
                      ),
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
                      key: const ValueKey<String>('publish-seats'),
                      label: 'Мест',
                      controller: _seats,
                      validator: Validators.seats,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: AppTextField(
                      key: const ValueKey<String>('publish-price'),
                      label: 'Цена за место, L',
                      controller: _price,
                      validator: Validators.price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        LengthLimitingTextInputFormatter(7),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'От ${Validators.seatsMin} до ${Validators.seatsMax} мест, '
                'цена до ${Validators.priceMax.round()} L.',
                style: AppTypography.caption.copyWith(color: colors.moss),
              ),
            ],
          ),
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
            onPressed: _saving ? null : _submit,
          ),
        ),
      ),
    );
  }
}
