import 'package:barbergofe/viewmodels/appointment/appointment_viewmodel.dart';
import 'package:barbergofe/views/PartnerSignUp/handlers/partner_signup_handler.dart';
import 'package:barbergofe/views/PartnerSignUp/widgets/partner_error_banner.dart';
import 'package:barbergofe/views/PartnerSignUp/widgets/partner_form_field.dart';
import 'package:barbergofe/views/PartnerSignUp/widgets/partner_time_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PartnerSignUpFormScreenV2 extends StatefulWidget {
  const PartnerSignUpFormScreenV2({super.key});

  @override
  State<PartnerSignUpFormScreenV2> createState() =>
      _PartnerSignUpFormScreenV2State();
}

class _PartnerSignUpFormScreenV2State extends State<PartnerSignUpFormScreenV2> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _openTimeController = TextEditingController(text: '09:00');
  final _closeTimeController = TextEditingController(text: '21:00');
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();

  late PartnerSignupHandler _handler;
  bool _isCheckingAppointment = false;
  bool _hasPendingAppointment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHandler();
      _initialize();
    });
  }

  void _initHandler() {
    final viewModel = context.read<AppointmentViewModel>();
    _handler = PartnerSignupHandler(
      context: context,
      viewModel: viewModel,
      formKey: _formKey,
      shopNameController: _shopNameController,
      phoneController: _phoneController,
      emailController: _emailController,
      openTimeController: _openTimeController,
      closeTimeController: _closeTimeController,
      addressController: _addressController,
      detailAddressController: _detailAddressController,
    );
  }

  Future<void> _initialize() async {
    await _handler.prefillUserInfo();
    await _checkExistingAppointment();
  }

  Future<void> _checkExistingAppointment() async {
    setState(() => _isCheckingAppointment = true);

    final hasPending = await _handler.checkExistingAppointment();

    setState(() {
      _hasPendingAppointment = hasPending;
      _isCheckingAppointment = false;
    });

    if (_hasPendingAppointment && mounted) {
      _handler.showExistingAppointmentDialog();
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentViewModel>(
      builder: (context, appointmentVM, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    _buildHeader(),
                    const SizedBox(height: 40),

                    // Loading indicator
                    if (_isCheckingAppointment) _buildLoadingIndicator(),

                    // Error banner
                    if (appointmentVM.errorMessage != null)
                      PartnerErrorBanner(
                        errorMessage: appointmentVM.errorMessage!,
                        onDismiss: _handler.clearError,
                      ),

                    // Form fields
                    _buildFormFields(),

                    const SizedBox(height: 60),

                    // Submit button
                    _buildSubmitButton(appointmentVM),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== BUILD METHODS ====================

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: _handler.goBack,
          icon: const Icon(Icons.chevron_left),
        ),
        const Expanded(
          child: Text(
            'Thông tin cửa tiệm của bạn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Tên cửa tiệm
        PartnerFormField(
          label: 'Tên cửa tiệm:',
          controller: _shopNameController,
          hint: 'Nhập tên cửa tiệm',
          validator: _handler.validateShopName,
        ),
        const Divider(color: Colors.grey, height: 40),

        // Số điện thoại
        PartnerFormField(
          label: 'Số điện thoại:',
          controller: _phoneController,
          hint: 'Nhập số điện thoại',
          keyboardType: TextInputType.phone,
          validator: _handler.validatePhone,
        ),
        const Divider(color: Colors.grey, height: 40),

        // Email
        PartnerFormField(
          label: 'Email:',
          controller: _emailController,
          hint: 'Nhập email',
          keyboardType: TextInputType.emailAddress,
          validator: _handler.validateEmail,
        ),
        const Divider(color: Colors.grey, height: 40),

        // Giờ mở cửa - đóng cửa
        PartnerTimePickerField(
          label: 'Giờ mở cửa - đóng cửa:',
          openController: _openTimeController,
          closeController: _closeTimeController,
          onTapOpen: () => _handler.selectTime(
            controller: _openTimeController,
            isOpenTime: true,
          ),
          onTapClose: () => _handler.selectTime(
            controller: _closeTimeController,
            isOpenTime: false,
          ),
        ),
        const Divider(color: Colors.grey, height: 40),

        // Địa chỉ
        PartnerFormField(
          label: 'Địa chỉ:',
          controller: _addressController,
          hint: 'Phường Trung Mỹ Tây, Tp...',
          validator: _handler.validateAddress,
        ),
        const Divider(color: Colors.grey, height: 40),

        // Địa chỉ cụ thể
        _buildDetailAddressField(),
      ],
    );
  }

  Widget _buildDetailAddressField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              'Địa chỉ cụ thể:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextFormField(
              controller: _detailAddressController,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(12),
                border: InputBorder.none,
                hintText: 'Nhập địa chỉ cụ thể của tiệm...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              validator: _handler.validateDetailAddress,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AppointmentViewModel appointmentVM) {
    final isDisabled = _hasPendingAppointment || appointmentVM.isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _handler.submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B4B8A),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: appointmentVM.isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          'NỘP HỒ SƠ ĐĂNG KÝ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}