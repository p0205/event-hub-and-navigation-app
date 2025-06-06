import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavControls extends StatelessWidget {
  const NavControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {}, // 实现缩放
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () {}, // 重置视图
          ),
        ],
      ),
    );
  }
}