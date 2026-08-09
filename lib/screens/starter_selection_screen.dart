import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/game_engine.dart';
import '../theme/wear_theme.dart';
import '../data/pokedex.dart';
import '../i18n/strings.dart';

class StarterSelectionScreen extends StatefulWidget {
  final GameEngine engine;
  const StarterSelectionScreen({super.key, required this.engine});

  @override
  State<StarterSelectionScreen> createState() => _StarterSelectionScreenState();
}

class _StarterSelectionScreenState extends State<StarterSelectionScreen> {
  int? _selectedStarter;

  @override
  void initState() {
    super.initState();
    AudioService().playBgm('title_screen');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Lab Image
          Positioned.fill(
            child: Image.asset(
              'assets/sprites/ui/oak_lab_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          if (_selectedStarter == null) ...[
            // Title Text
            Positioned(
              top: size.height * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tr('chooseStarter').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Left (Bulbasaur)
            Positioned(
              left: size.width * 0.5 - 25 - 60,
              top: size.height * 0.43,
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => setState(() => _selectedStarter = 1),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 2.5,
                      child: Image.asset(
                        'assets/sprites/normal/001_idle.gif',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    Container(width: 50, height: 50, color: Colors.transparent),
                  ],
                ),
              ),
            ),
            // Center (Charmander)
            Positioned(
              left: size.width * 0.5 - 25,
              top: size.height * 0.43,
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => setState(() => _selectedStarter = 4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 2.5,
                      child: Image.asset(
                        'assets/sprites/normal/004_idle.gif',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    Container(width: 50, height: 50, color: Colors.transparent),
                  ],
                ),
              ),
            ),
            // Right (Squirtle)
            Positioned(
              left: size.width * 0.5 - 25 + 60,
              top: size.height * 0.43,
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: () => setState(() => _selectedStarter = 7),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 2.5,
                      child: Image.asset(
                        'assets/sprites/normal/007_idle.gif',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    Container(width: 50, height: 50, color: Colors.transparent),
                  ],
                ),
              ),
            ),
          ],

          // Selection Overlay
          if (_selectedStarter != null) ...[
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.8)),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dex[_selectedStarter!].displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      color: WearTheme.typeColor(dex[_selectedStarter!].type),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Image.asset(
                    'assets/sprites/normal/${_selectedStarter!.toString().padLeft(3, '0')}_idle.gif',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cancel
                      GestureDetector(
                        onTap: () => setState(() => _selectedStarter = null),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Confirm
                      GestureDetector(
                        onTap: () {
                          widget.engine.applyBgm();
                          widget.engine.chooseStarter(_selectedStarter!);
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
