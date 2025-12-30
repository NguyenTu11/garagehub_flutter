import 'package:flutter/material.dart';
import '../../Models/AppointmentModel.dart';
import '../../Services/AppointmentService.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final AppointmentService _service = AppointmentService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedVehicleType;
  List<String> _selectedServices = [];
  List<TimeSlot> _availableSlots = [];

  bool _isLoading = false;
  bool _isLoadingSlots = false;

  final List<String> _vehicleTypes = ['xe số', 'tay ga', 'xe côn'];
  final List<String> _serviceOptions = [
    'Thay nhớt',
    'Sửa phanh',
    'Kiểm tra động cơ',
    'Bảo dưỡng định kỳ',
  ];
  final List<String> _timeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableSlots() async {
    if (_selectedDate == null) return;

    setState(() => _isLoadingSlots = true);
    try {
      final dateStr = _selectedDate!.toIso8601String().split('T')[0];
      final slots = await _service.getAvailableSlots(dateStr);
      setState(() {
        _availableSlots = slots;
        _selectedTime = null;
      });
    } catch (e) {
      debugPrint('Error fetching slots: $e');
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  bool _isSlotAvailable(String time) {
    final slot = _availableSlots.firstWhere(
      (s) => s.time == time,
      orElse: () => TimeSlot(time: time, available: true),
    );
    return slot.available;
  }

  int _getSlotCount(String time) {
    final slot = _availableSlots.firstWhere(
      (s) => s.time == time,
      orElse: () => TimeSlot(time: time, count: 0),
    );
    return slot.count;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchAvailableSlots();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Vui lòng chọn ngày');
      return;
    }
    if (_selectedTime == null) {
      _showError('Vui lòng chọn giờ');
      return;
    }
    if (_selectedVehicleType == null) {
      _showError('Vui lòng chọn loại xe');
      return;
    }
    if (_selectedServices.isEmpty) {
      _showError('Vui lòng chọn ít nhất một dịch vụ');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appointment = AppointmentModel(
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        date: _selectedDate,
        time: _selectedTime,
        vehicleType: _selectedVehicleType,
        services: _selectedServices,
        note: _noteController.text.trim(),
      );

      final result = await _service.createAppointment(appointment);

      if (result['success'] == true) {
        _showSuccess(result['message'] ?? 'Đặt lịch thành công!');
        _resetForm();
      } else {
        _showError(result['message'] ?? 'Đặt lịch thất bại');
      }
    } catch (e) {
      _showError('Có lỗi xảy ra. Vui lòng thử lại.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _noteController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedVehicleType = null;
      _selectedServices = [];
      _availableSlots = [];
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Đặt lịch sửa xe',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Thông tin khách hàng',
                icon: Icons.person,
                color: Colors.blue,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(
                        'Họ tên *',
                        Icons.person_outline,
                      ),
                      validator: (v) =>
                          v?.isEmpty == true ? 'Vui lòng nhập họ tên' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration(
                        'Số điện thoại *',
                        Icons.phone,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v?.isEmpty == true ? 'Vui lòng nhập SĐT' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        'Email (không bắt buộc)',
                        Icons.email,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Thông tin đặt lịch',
                icon: Icons.event,
                color: Colors.green,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate != null
                                  ? 'Ngày: ${_formatDate(_selectedDate!)}'
                                  : 'Chọn ngày sửa *',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chọn giờ *',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingSlots)
                      const Center(child: CircularProgressIndicator())
                    else if (_selectedDate == null)
                      Text(
                        'Vui lòng chọn ngày trước',
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _timeSlots.map((time) {
                          final isAvailable = _isSlotAvailable(time);
                          final count = _getSlotCount(time);
                          final isSelected = _selectedTime == time;

                          return GestureDetector(
                            onTap: isAvailable
                                ? () => setState(() => _selectedTime = time)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green.shade600
                                    : !isAvailable
                                    ? Colors.grey.shade300
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green.shade600
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    time,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : !isAvailable
                                          ? Colors.grey
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    isAvailable ? '($count/3)' : 'Đầy',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: _inputDecoration(
                        'Loại xe *',
                        Icons.two_wheeler,
                      ),
                      items: _vehicleTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.substring(0, 1).toUpperCase() +
                                type.substring(1),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => _selectedVehicleType = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Dịch vụ cần sửa *',
                icon: Icons.build,
                color: Colors.orange,
                child: Column(
                  children: _serviceOptions.map((service) {
                    final isSelected = _selectedServices.contains(service);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(service),
                      activeColor: Colors.orange.shade600,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        setState(() {
                          if (isSelected) {
                            _selectedServices.remove(service);
                          } else {
                            _selectedServices.add(service);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Ghi chú',
                icon: Icons.note,
                color: Colors.grey,
                child: TextFormField(
                  controller: _noteController,
                  decoration: _inputDecoration(
                    'Ghi chú thêm (nếu có)',
                    Icons.edit_note,
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Đặt lịch',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/search-appointment',
                  ),
                  child: Text(
                    'Tra cứu lịch hẹn đã đặt →',
                    style: TextStyle(color: Colors.blue.shade600),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
    );
  }
}

extension ColorShade on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
  }
}
