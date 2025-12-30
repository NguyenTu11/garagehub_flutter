import 'package:flutter/material.dart';

class ServiceCards extends StatelessWidget {
  const ServiceCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_ServiceCardData> services = [
      _ServiceCardData(
        icon: Icons.local_shipping_rounded,
        color: Colors.blue.shade500,
        title: "Vận chuyển",
      ),
      _ServiceCardData(
        icon: Icons.verified_rounded,
        color: Colors.green.shade500,
        title: "Chính hãng",
      ),
      _ServiceCardData(
        icon: Icons.headset_mic_rounded,
        color: Colors.amber.shade600,
        title: "Tư vấn",
      ),
      _ServiceCardData(
        icon: Icons.credit_card_rounded,
        color: Colors.purple.shade400,
        title: "Thanh toán",
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Row(
        children: List.generate(services.length, (i) {
          return Expanded(
            child: _ServiceCard(
              data: services[i],
              isFirst: i == 0,
              isLast: i == services.length - 1,
            ),
          );
        }),
      ),
    );
  }
}

class _ServiceCardData {
  final IconData icon;
  final Color color;
  final String title;
  _ServiceCardData({
    required this.icon,
    required this.color,
    required this.title,
  });
}

class _ServiceCard extends StatelessWidget {
  final _ServiceCardData data;
  final bool isFirst;
  final bool isLast;
  const _ServiceCard({
    required this.data,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: isFirst ? 0 : 6, right: isLast ? 0 : 6),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.13),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(10),
            child: Icon(data.icon, color: data.color, size: 32),
          ),
          SizedBox(height: 8),
          Text(
            data.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: data.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
