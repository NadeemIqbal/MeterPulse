import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../meters/domain/entities/meter.dart';
import '../cubit/reading_capture_cubit.dart';

/// Camera → OCR → edit → save flow for a reading.
class ReadingCapturePage extends StatelessWidget {
  const ReadingCapturePage({super.key, required this.meter});

  final Meter meter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReadingCaptureCubit>(
      create: (_) => sl<ReadingCaptureCubit>()..attach(meter),
      child: _CaptureView(meter: meter),
    );
  }
}

class _CaptureView extends StatefulWidget {
  const _CaptureView({required this.meter});

  final Meter meter;

  @override
  State<_CaptureView> createState() => _CaptureViewState();
}

class _CaptureViewState extends State<_CaptureView> {
  final _value = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  // Off by default so readings accumulate in the current cycle (that's what
  // produces the per-reading consumption deltas). Auto-suggested on only when
  // the current cycle is actually due; the user can always override.
  bool _startNewCycle = false;
  String? _prefilledFor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cubit = context.read<ReadingCaptureCubit>();
      // If the OS killed us mid-capture last time (e.g. the camera process
      // crashed), recover the photo instead of losing it.
      cubit.checkForLostImage();
      // Default the "new cycle" toggle from whether this cycle is due.
      final suggest = await cubit.shouldSuggestNewCycle();
      if (mounted) setState(() => _startNewCycle = suggest);
    });
  }

  @override
  void dispose() {
    _value.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take reading')),
      body: BlocConsumer<ReadingCaptureCubit, ReadingCaptureState>(
        listener: _onState,
        builder: (context, state) {
          return switch (state.stage) {
            CaptureStage.idle => _startOptions(context),
            CaptureStage.requestingPermission =>
              _busy('Requesting camera permission…'),
            CaptureStage.capturing => _busy('Opening camera…'),
            CaptureStage.processing => _busy('Reading the meter…'),
            CaptureStage.permissionDenied => _permissionDenied(context),
            CaptureStage.ready || CaptureStage.saving => _editor(context, state),
            CaptureStage.error => _errorRecovery(context, state),
            CaptureStage.saved => _busy('Saved'),
          };
        },
      ),
    );
  }

  void _onState(BuildContext context, ReadingCaptureState state) {
    if (state.stage == CaptureStage.ready &&
        state.detectedValue != null &&
        _prefilledFor != (state.imagePath ?? 'manual')) {
      _prefilledFor = state.imagePath ?? 'manual';
      _value.text = _formatForEditing(state.detectedValue!);
    }
    if (state.stage == CaptureStage.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reading saved')),
      );
      context.pop(true);
    }
    // Save failures keep the user in the editor; surface them as a snackbar.
    if (state.stage == CaptureStage.ready && state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    }
  }

  String _formatForEditing(double value) =>
      value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();

  Widget _busy(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(label),
        ],
      ),
    );
  }

  Widget _startOptions(BuildContext context) {
    final cubit = context.read<ReadingCaptureCubit>();
    return Padding(
      padding: AppSpacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(Icons.center_focus_strong_rounded,
              size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Capture ${widget.meter.name}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Photograph the dial and we\'ll read the number for you, or enter it '
            'by hand.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: cubit.captureFromCamera,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Take photo'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: cubit.pickFromGallery,
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Choose from gallery'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: cubit.enterManually,
            child: const Text('Enter manually'),
          ),
        ],
      ),
    );
  }

  Widget _permissionDenied(BuildContext context) {
    final cubit = context.read<ReadingCaptureCubit>();
    return Padding(
      padding: AppSpacing.page,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_photography_rounded,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: AppSpacing.lg),
            Text('Camera permission denied',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Grant camera access in settings, or enter the reading manually.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: cubit.openSettings,
              child: const Text('Open settings'),
            ),
            TextButton(
              onPressed: cubit.captureFromCamera,
              child: const Text('Try camera again'),
            ),
            TextButton(
              onPressed: cubit.enterManually,
              child: const Text('Enter manually'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorRecovery(BuildContext context, ReadingCaptureState state) {
    final cubit = context.read<ReadingCaptureCubit>();
    final theme = Theme.of(context);
    return Padding(
      padding: AppSpacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(Icons.error_outline_rounded,
              size: 64, color: theme.colorScheme.error),
          const SizedBox(height: AppSpacing.lg),
          Text('Capture failed',
              textAlign: TextAlign.center, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            state.error ?? 'Something went wrong opening the camera.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: cubit.captureFromCamera,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Try camera again'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: cubit.pickFromGallery,
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Choose from gallery'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: cubit.enterManually,
            child: const Text('Enter manually'),
          ),
        ],
      ),
    );
  }

  Widget _editor(BuildContext context, ReadingCaptureState state) {
    final theme = Theme.of(context);
    final saving = state.stage == CaptureStage.saving;

    return AbsorbPointer(
      absorbing: saving,
      child: ListView(
        padding: AppSpacing.page,
        children: [
          if (state.imagePath != null) ...[
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.card)),
              child: Image.file(
                File(state.imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: context.read<ReadingCaptureCubit>().captureFromCamera,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retake'),
              ),
            ),
          ],
          if (state.cameFromOcr && state.confidencePercent != null)
            _ocrBanner(context, state.confidencePercent!)
          else if (state.imagePath != null)
            _manualNeededBanner(context),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _value,
            autofocus: state.imagePath == null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: theme.textTheme.headlineSmall,
            decoration: InputDecoration(
              labelText: 'Reading',
              suffixText: widget.meter.unit,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.event_rounded),
                  title: const Text('Reading date'),
                  subtitle: Text(_date.toString().split(' ').first),
                  onTap: saving ? null : _pickDate,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.restart_alt_rounded),
                  title: const Text('Starts a new billing cycle'),
                  value: _startNewCycle,
                  onChanged:
                      saving ? null : (v) => setState(() => _startNewCycle = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: saving ? null : () => _save(context),
            child: saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save reading'),
          ),
        ],
      ),
    );
  }

  Widget _ocrBanner(BuildContext context, int confidence) {
    final theme = Theme.of(context);
    return AppCard(
      color: theme.colorScheme.secondaryContainer,
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded,
              color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Detected from the photo · about $confidence% confidence. '
              'Check it and edit if needed.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _manualNeededBanner(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(Icons.edit_rounded, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Couldn\'t read a number from the photo — enter it below.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save(BuildContext context) async {
    final cubit = context.read<ReadingCaptureCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final value = double.tryParse(_value.text.trim());
    if (value == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a valid reading')),
      );
      return;
    }

    if (await cubit.hasAnomaly(value)) {
      if (!context.mounted) return;
      final proceed = await _confirmAnomaly(context);
      if (proceed != true) return;
    }

    await cubit.save(
      value: value,
      date: _date,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      startNewCycle: _startNewCycle,
    );
  }

  Future<bool?> _confirmAnomaly(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lower than last reading'),
        content: const Text(
          'This reading is lower than the previous one. If the meter reset or '
          'rolled over, that\'s expected. Save it anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save anyway'),
          ),
        ],
      ),
    );
  }
}
