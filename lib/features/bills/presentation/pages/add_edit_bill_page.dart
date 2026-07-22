import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/file_storage_service.dart';
import '../../../../core/services/image_capture_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../meters/domain/entities/meter.dart';
import '../../domain/entities/bill.dart';
import '../cubit/bill_form_cubit.dart';

/// Add or edit a bill (manual entry with an optional photo of the paper bill).
class AddEditBillPage extends StatelessWidget {
  const AddEditBillPage({super.key, required this.meter, this.bill});

  final Meter meter;
  final Bill? bill;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillFormCubit>(
      create: (_) => sl<BillFormCubit>(),
      child: _BillForm(meter: meter, bill: bill),
    );
  }
}

class _BillForm extends StatefulWidget {
  const _BillForm({required this.meter, this.bill});

  final Meter meter;
  final Bill? bill;

  @override
  State<_BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<_BillForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _units;
  late final TextEditingController _notes;

  late DateTime _billDate;
  DateTime? _dueDate;
  bool _isPaid = false;

  /// Newly captured photo pending persistence, and the already-saved path.
  String? _newPhotoTempPath;
  String? _existingPhotoPath;

  bool get _isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();
    final b = widget.bill;
    _amount = TextEditingController(text: b?.billAmount.toString() ?? '');
    _units = TextEditingController(text: b?.unitsBilled?.toString() ?? '');
    _notes = TextEditingController(text: b?.notes ?? '');
    _billDate = b?.billDate ?? DateTime.now();
    _dueDate = b?.dueDate;
    _isPaid = b?.isPaid ?? false;
    _existingPhotoPath = b?.photoPath;
  }

  @override
  void dispose() {
    _amount.dispose();
    _units.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? get _photoToShow => _newPhotoTempPath ?? _existingPhotoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit bill' : 'Add bill')),
      body: BlocConsumer<BillFormCubit, BillFormState>(
        listener: (context, state) {
          if (state.status == BillFormStatus.success) {
            context.pop(true);
          } else if (state.status == BillFormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error ?? 'Could not save the bill.')),
            );
          }
        },
        builder: (context, state) {
          final saving = state.status == BillFormStatus.saving;
          return AbsorbPointer(
            absorbing: saving,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: AppSpacing.page,
                children: [
                  TextFormField(
                    controller: _amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(labelText: 'Bill amount'),
                    validator: (v) {
                      final n = double.tryParse((v ?? '').trim());
                      if (n == null) return 'Enter the bill amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _units,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Units billed (optional)',
                      suffixText: widget.meter.unit,
                    ),
                    validator: (v) {
                      final trimmed = (v ?? '').trim();
                      if (trimmed.isEmpty) return null;
                      return double.tryParse(trimmed) == null
                          ? 'Enter a valid number'
                          : null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.event_rounded),
                          title: const Text('Bill date'),
                          subtitle: Text(_billDate.toString().split(' ').first),
                          onTap: () => _pickBillDate(),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.event_available_rounded),
                          title: const Text('Due date (optional)'),
                          subtitle: Text(
                            _dueDate == null
                                ? 'Not set'
                                : _dueDate.toString().split(' ').first,
                          ),
                          trailing: _dueDate == null
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => setState(() => _dueDate = null),
                                ),
                          onTap: () => _pickDueDate(),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.task_alt_rounded),
                          title: const Text('Paid'),
                          value: _isPaid,
                          onChanged: (v) => setState(() => _isPaid = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _photoSection(context),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _notes,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: saving ? null : _submit,
                    child: saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Save changes' : 'Add bill'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _photoSection(BuildContext context) {
    final theme = Theme.of(context);
    final photo = _photoToShow;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bill photo (optional)',
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: AppSpacing.sm),
          if (photo != null) ...[
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.field)),
              child: Image.file(
                File(photo),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _newPhotoTempPath = null;
                  _existingPhotoPath = null;
                }),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Remove'),
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto() async {
    final granted = await sl<PermissionService>().requestCamera();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission is required')),
      );
      return;
    }
    final path = await sl<ImageCaptureService>().captureFromCamera();
    if (path != null) setState(() => _newPhotoTempPath = path);
  }

  Future<void> _pickPhoto() async {
    final path = await sl<ImageCaptureService>().pickFromGallery();
    if (path != null) setState(() => _newPhotoTempPath = path);
  }

  Future<void> _pickBillDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _billDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _billDate = picked);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _billDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  double? _parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Persist a freshly captured photo; keep the existing one otherwise.
    var photoPath = _existingPhotoPath;
    if (_newPhotoTempPath != null) {
      photoPath = await sl<FileStorageService>().persistImage(_newPhotoTempPath!);
    }

    final existing = widget.bill;
    final bill = Bill(
      id: existing?.id,
      meterId: widget.meter.id!,
      billingCycleId: existing?.billingCycleId,
      billAmount: _parse(_amount.text)!,
      billDate: _billDate,
      dueDate: _dueDate,
      unitsBilled: _parse(_units.text),
      isPaid: _isPaid,
      paidDate: _isPaid ? (existing?.paidDate ?? DateTime.now()) : null,
      photoPath: photoPath,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    if (!mounted) return;
    await context.read<BillFormCubit>().save(bill);
  }
}
