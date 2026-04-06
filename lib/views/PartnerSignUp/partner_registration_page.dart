import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerRegistrationScreen extends StatelessWidget {
  const PartnerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với nút back
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Trở thành đối tác',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Tiêu đề chính
                const Text(
                  'Trở thành đối tác cùng Barber GO\nTăng thu nhập, mở rộng khách hàng.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 40),

                // Phần Quyền lợi
                _buildSectionTitle('Quyền lợi:'),
                const SizedBox(height: 16),
                _buildBenefitItem('Quản lý lịch hẹn dễ dàng'),
                _buildBenefitItem('Tiếp cận khách hàng mới'),
                _buildBenefitItem('Tăng độ tin cậy cho tiệm'),
                _buildBenefitItem('Quảng bá thương hiệu'),
                const SizedBox(height: 40),

                // Phần Chính sách hợp tác
                _buildSectionTitle('Chính sách hợp tác:'),
                const SizedBox(height: 16),
                _buildPolicyItem('Hoàn toàn miễn phí đăng ký ban đầu'),
                _buildPolicyItem('Không ràng buộc hợp đồng dài'),
                _buildPolicyItem('Có thể dừng hợp tác bất kỳ lúc nào'),
                _buildPolicyItem('Hỗ trợ kỹ thuật và chăm sóc đối tác 24/7'),
                _buildPolicyItem('Cam kết bảo mật thông tin tiệm và khách'),
                const SizedBox(height: 40),

                // Divider
                const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
                const SizedBox(height: 32),

                // Nút đăng ký
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Xử lý đăng ký đối tác
                      _handleRegistration(context);
                    },
                    child: const Text(
                      'BẮT ĐẦU ĐĂNG KÝ LÀM ĐỐI TÁC',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Thông tin thêm (nếu cần)
                const Center(
                  child: Text(
                    'Quá trình đăng ký chỉ mất 5 phút',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                color: Colors.blue,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRegistration(BuildContext context) {
    // Xử lý logic đăng ký ở đây
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bắt đầu đăng ký'),
        content: const Text(
          'Bạn có muốn bắt đầu quá trình đăng ký làm đối tác Barber GO không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigator.pop(context);
              // Điều hướng đến màn hình đăng ký chi tiết
              // Navigator.push(context, MaterialPageRoute(builder: (_) => PartnerSignUpScreen()));
              context.pushNamed('PartnerSignUpForm');
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }
}

// Màn hình đăng ký chi tiết (nếu cần)
class PartnerSignUpScreen extends StatelessWidget {
  const PartnerSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký đối tác'),
      ),
      body: const Center(
        child: Text('Màn hình đăng ký chi tiết'),
      ),
    );
  }
}