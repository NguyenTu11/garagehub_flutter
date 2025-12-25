import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final double logoSize;
  const Header({Key? key, this.logoSize = 40}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + Search icon (logo sát trái, search sát logo)
          Row(
            children: [
              Image.asset(
                'Assets/Images/logo_garagehub.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image,
                  size: logoSize * 0.7,
                  color: Colors.blue.shade200,
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.search, color: Colors.blue.shade700),
                onPressed: () {},
                tooltip: 'Tìm kiếm',
              ),
            ],
          ),
          // Notification + Message icons (sát bên phải)
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Colors.blue.shade700,
                ),
                onPressed: () {},
                tooltip: 'Thông báo',
              ),
              SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.message_outlined, color: Colors.blue.shade700),
                onPressed: () {},
                tooltip: 'Tin nhắn',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
