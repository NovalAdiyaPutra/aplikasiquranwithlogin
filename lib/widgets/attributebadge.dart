import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AttributeBadge extends StatelessWidget {
  final String text;
  final String iconPath;
  final Color color;

  const AttributeBadge({
    super.key,
    required this.text,
    required this.iconPath,
    this.color = Colors.white24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            height: 30,
            width: 20,
            color: Colors.black,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
