
import 'package:barbergofe/models/profile/appointment_model.dart';
import 'package:barbergofe/viewmodels/appointment/appointment_viewmodel.dart';
import 'package:barbergofe/views/appointment/handlers/appointment_detail_handler.dart';
import 'package:barbergofe/views/appointment/widgets/contact_card.dart';
import 'package:barbergofe/views/appointment/widgets/empty_state.dart';
import 'package:barbergofe/views/appointment/widgets/info_card.dart';
import 'package:barbergofe/views/appointment/widgets/section_title.dart';
import 'package:barbergofe/views/appointment/widgets/status_card.dart';
import 'package:barbergofe/views/appointment/widgets/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  AppointmentDetailHandler? _handler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHandler();
      _handler?.loadAppointments();
    });
  }

  void _initHandler() {
    final viewModel = context.read<AppointmentViewModel>();
    _handler = AppointmentDetailHandler(
      context: context,
      viewModel: viewModel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(), // ✅ Dùng context.pop() trực tiếp
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Trạng thái hồ sơ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AppointmentViewModel>(
        builder: (context, viewModel, child) {
          return _buildBody(viewModel);
        },
      ),
    );
  }

  // ==================== BODY STATES ====================

  Widget _buildBody(AppointmentViewModel viewModel) {
    if (viewModel.isLoading && viewModel.appointments.isEmpty) {
      return _buildLoadingState();
    }

    if (viewModel.errorMessage != null && viewModel.appointments.isEmpty) {
      return _buildErrorState(viewModel.errorMessage!);
    }

    if (viewModel.appointments.isEmpty) {
      return EmptyAppointmentState(
        onRegisterNow: () => context.push('/PartnerSignUpForm'), // ✅ Direct navigation
      );
    }

    final appointment = viewModel.appointments.first;
    return _buildAppointmentDetail(appointment);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải dữ liệu...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _handler?.loadAppointments(), // ✅ Safe call
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  // ==================== APPOINTMENT DETAIL ====================

  Widget _buildAppointmentDetail(AppointmentModel appointment) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            StatusCard(status: appointment.status),
            const SizedBox(height: 24),

            // Thông tin yêu cầu
            const SectionTitle(title: 'Thông tin yêu cầu'),
            const SizedBox(height: 16),
            InfoCard(appointment: appointment),
            const SizedBox(height: 24),

            // Thông tin liên hệ
            const SectionTitle(title: 'Thông tin liên hệ'),
            const SizedBox(height: 16),
            ContactCard(
              appointment: appointment,
              onCopy: _handler?.copyToClipboard ?? (_, __) {}, // ✅ Safe fallback
            ),
            const SizedBox(height: 24),

            // Timeline
            const SectionTitle(title: 'Lịch sử trạng thái'),
            const SizedBox(height: 16),
            TimelineWidget(appointment: appointment),
            const SizedBox(height: 32),

            // Action Buttons (nếu là pending)
            if (appointment.status == 'pending')
              _buildActionButtons(appointment),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppointmentModel appointment) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handler?.cancelAppointment(appointment),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text('Hủy yêu cầu'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}