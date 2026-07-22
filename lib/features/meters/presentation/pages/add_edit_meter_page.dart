import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/meter_palette.dart';
import '../../domain/entities/meter.dart';
import '../../domain/entities/meter_type.dart';
import '../cubit/meter_form_cubit.dart';
import '../meter_type_ui.dart';

/// Add or edit a meter. The widget owns all field state; [MeterFormCubit] only
/// persists and reports the outcome.
class AddEditMeterPage extends StatelessWidget {
  const AddEditMeterPage({super.key, this.meter});

  final Meter? meter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MeterFormCubit>(
      create: (_) => sl<MeterFormCubit>(),
      child: _MeterForm(meter: meter),
    );
  }
}

class _MeterForm extends StatefulWidget {
  const _MeterForm({this.meter});

  final Meter? meter;

  @override
  State<_MeterForm> createState() => _MeterFormState();
}

class _MeterFormState extends State<_MeterForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _number;
  late final TextEditingController _unit;
  late final TextEditingController _readingDay;
  late final TextEditingController _rollover;
  late final TextEditingController _threshold;
  late final TextEditingController _expectedMonthly;
  late final TextEditingController _notes;

  late MeterType _type;
  Color? _color;
  bool _isActive = true;

  bool get _isEditing => widget.meter != null;

  @override
  void initState() {
    super.initState();
    final m = widget.meter;
    _type = m?.type ?? MeterType.electricity;
    _name = TextEditingController(text: m?.name ?? '');
    _number = TextEditingController(text: m?.meterNumber ?? '');
    _unit = TextEditingController(text: m?.unit ?? _type.defaultUnit);
    _readingDay =
        TextEditingController(text: (m?.expectedReadingDayOfMonth ?? 1).toString());
    _rollover = TextEditingController(text: m?.rolloverValue?.toString() ?? '');
    _threshold =
        TextEditingController(text: m?.highUsageThreshold?.toString() ?? '');
    _expectedMonthly =
        TextEditingController(text: m?.expectedMonthlyUnits?.toString() ?? '');
    _notes = TextEditingController(text: m?.notes ?? '');
    _color = m?.colorValue != null ? Color(m!.colorValue!) : _type.defaultColor;
    _isActive = m?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _number,
      _unit,
      _readingDay,
      _rollover,
      _threshold,
      _expectedMonthly,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTypeChanged(MeterType type) {
    setState(() {
      final previousDefaultUnit = _type.defaultUnit;
      _type = type;
      // Auto-fill the unit if the user hadn't customised it.
      if (_unit.text.isEmpty || _unit.text == previousDefaultUnit) {
        _unit.text = type.defaultUnit;
      }
      _color ??= type.defaultColor;
    });
  }

  double? _parseDouble(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.meter;
    final meter = Meter(
      id: existing?.id,
      name: _name.text.trim(),
      meterNumber: _number.text.trim().isEmpty ? null : _number.text.trim(),
      type: _type,
      unit: _unit.text.trim(),
      isActive: _isActive,
      expectedReadingDayOfMonth: int.parse(_readingDay.text.trim()),
      rolloverValue: _parseDouble(_rollover.text),
      colorValue: _color?.toARGB32(),
      iconCodePoint: null,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      highUsageThreshold: _parseDouble(_threshold.text),
      expectedMonthlyUnits: _parseDouble(_expectedMonthly.text),
      reminderStartDaysBefore: existing?.reminderStartDaysBefore,
      reminderFrequencyDays: existing?.reminderFrequencyDays,
      billReminderFrequencyDays: existing?.billReminderFrequencyDays,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    context.read<MeterFormCubit>().save(meter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit meter' : 'Add meter')),
      body: BlocConsumer<MeterFormCubit, MeterFormState>(
        listener: (context, state) {
          if (state.status == MeterFormStatus.success) {
            context.pop(true);
          } else if (state.status == MeterFormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? 'Could not save the meter.')),
            );
          }
        },
        builder: (context, state) {
          final saving = state.status == MeterFormStatus.saving;
          return AbsorbPointer(
            absorbing: saving,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: AppSpacing.page,
                children: [
                  _sectionLabel(context, 'Basics'),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Meter name',
                      hintText: 'e.g. Home electricity',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _number,
                    decoration: const InputDecoration(
                      labelText: 'Meter number (optional)',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _sectionLabel(context, 'Type'),
                  _typeSelector(),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a unit' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _sectionLabel(context, 'Colour'),
                  _colorPicker(),
                  const SizedBox(height: AppSpacing.lg),
                  _sectionLabel(context, 'Cycle & alerts'),
                  TextFormField(
                    controller: _readingDay,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Reading day of month',
                      helperText: 'The day you usually read this meter (1–31)',
                    ),
                    validator: _validateDay,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _expectedMonthly,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Expected monthly units (optional)',
                    ),
                    validator: _validateOptionalNumber,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _threshold,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'High-usage threshold (optional)',
                      helperText: 'Flag the meter when usage crosses this',
                    ),
                    validator: _validateOptionalNumber,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _rollover,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Rollover / max value (optional)',
                      helperText: 'Value at which the dial wraps back to 0',
                    ),
                    validator: _validateOptionalNumber,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _sectionLabel(context, 'Notes'),
                  TextFormField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: AppSpacing.sm),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active'),
                      subtitle: const Text('Inactive meters are hidden from the dashboard'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: saving ? null : _submit,
                    child: saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Save changes' : 'Add meter'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String? _validateDay(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1 || n > 31) return 'Enter a day between 1 and 31';
    return null;
  }

  String? _validateOptionalNumber(String? v) {
    final trimmed = (v ?? '').trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed) == null ? 'Enter a valid number' : null;
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: theme.textTheme.titleSmall
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }

  Widget _typeSelector() {
    return Wrap(
      spacing: AppSpacing.sm,
      children: MeterType.values.map((type) {
        final selected = type == _type;
        return ChoiceChip(
          selected: selected,
          avatar: Icon(type.icon, size: 18),
          label: Text(type.label),
          onSelected: (_) => _onTypeChanged(type),
        );
      }).toList(),
    );
  }

  Widget _colorPicker() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: MeterPalette.swatches.map((color) {
        final selected = _color?.toARGB32() == color.toARGB32();
        return GestureDetector(
          onTap: () => setState(() => _color = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 3,
                    )
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
