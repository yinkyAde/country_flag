import 'package:flutter/material.dart';

import 'Globe3D.dart';

class Flag3DGlobePage extends StatelessWidget {
  const Flag3DGlobePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Flag Globe (3D)', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = (constraints.biggest.shortestSide * 0.9).clamp(280.0, 560.0);
            return SizedBox(
              width: size,
              height: size,
              child: Globe3D(
                diameter: size,
                textureAsset: 'assets/globe_texture.png',
              ),
            );
          },
        ),
      ),
    );
  }
}