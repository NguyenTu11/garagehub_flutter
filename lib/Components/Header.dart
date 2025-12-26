import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final double logoSize;
  const Header({Key? key, this.logoSize = 55}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50.withOpacity(0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'Assets/Images/logo_garagehub.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image,
                    size: logoSize * 0.7,
                    color: Colors.blue.shade200,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/search');
              },
              child: Container(
                height: 38,
                constraints: BoxConstraints(minWidth: 140, maxWidth: 260),
                padding: EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: Colors.blue.shade600,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Tìm kiếm...',
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.orange.shade400,
                      size: 24,
                    ),
                    onPressed: () {},
                    tooltip: 'Giỏ hàng',
                  ),
                  SizedBox(width: 2),
                  IconButton(
                    icon: Icon(
                      Icons.mark_chat_unread_rounded,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                    onPressed: () {},
                    tooltip: 'Tin nhắn',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
