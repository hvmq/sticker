import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPlan = 'monthly';

  final features = [
    'Truy cập toàn bộ sticker Pro',
    'Không quảng cáo',
    'Sticker chất lượng cao',
    'Cập nhật sticker mới mỗi tuần',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nâng cấp Premium'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPlanSelector(),
            const SizedBox(height: 20),
            _buildUpgradeButton(),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Khi nâng cấp bạn sẽ nhận được:', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 10),
            ...features.map(
              (feature) => ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text(feature)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Column(
      children: [
        RadioListTile(
          title: const Text('Gói hằng tháng - 49.000đ'),
          value: 'monthly',
          groupValue: selectedPlan,
          onChanged: (value) {
            setState(() {
              selectedPlan = value!;
            });
          },
        ),
        RadioListTile(
          title: const Text('Gói hằng năm - 399.000đ (tiết kiệm 30%)'),
          value: 'yearly',
          groupValue: selectedPlan,
          onChanged: (value) {
            setState(() {
              selectedPlan = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildUpgradeButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Gọi logic thanh toán ở đây
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đang xử lý gói: ${selectedPlan == 'monthly' ? 'Hằng tháng' : 'Hằng năm'}')),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.deepPurple,
      ),
      child: const Text('Nâng cấp ngay', style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}
