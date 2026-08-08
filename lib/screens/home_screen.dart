/// Tela principal do TamaPokeWear.
///
/// Layout para tela redonda:
/// - Pokémon animado no centro
/// - 4 barras de stats (arco superior)
/// - 4 botões de ação (arco inferior)
/// - Status message
/// - Gesture: tap = pet, swipe up = stat card, swipe horizontal = pokédex
library;

import 'package:flutter/material.dart';

import '../data/pokedex.dart';
import '../i18n/strings.dart';
import '../models/pet_state.dart';
import '../services/game_engine.dart';
import '../services/notification_service.dart';
import '../theme/wear_theme.dart';
import '../widgets/action_buttons.dart';
import '../widgets/biome_background.dart';
import '../widgets/bubbles_overlay.dart';
import '../widgets/poop_indicator.dart';
import '../widgets/stat_bars.dart';
import '../widgets/streak_badge.dart';
import 'catch_screen.dart';
import 'pokedex_screen.dart';
import 'egg_screen.dart';
import 'evolution_screen.dart';
import 'ceremony_screen.dart';
import 'feed_screen.dart';
import 'play_screen.dart';
import 'pokedex_screen.dart';
import 'settings_screen.dart';
import 'stat_card_screen.dart';
import 'starter_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  final GameEngine engine;

  const HomeScreen({super.key, required this.engine});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  GameEngine get engine => widget.engine;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late PageController _pageCtrl;
  late PageController _horizontalPageCtrl;
  bool _isBathing = false;
  bool _isFeeding = false;

  bool _isEating = false;
  bool _isEatingCandy = false;
  Color _eatingColor = Colors.red;
  Key _eatKey = UniqueKey();

  bool _showHeart = false;
  Key _heartKey = UniqueKey();

  bool _isShowingMedal = false;
  String _medalName = '';

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService().requestPermissions();
    });

    _pageCtrl = PageController(initialPage: 1);
    _horizontalPageCtrl = PageController(initialPage: 0);
    engine.onStateChanged = () { if (mounted) setState(() {}); };
    engine.onEvolutionReady = () { if (mounted) _showEvolution(); };
    engine.onFarewellReady = () { if (mounted) _showFarewell(); };
    engine.onRunawayReady = () { if (mounted) _showRunaway(); };
    engine.onMedalEarned = (m) { if (mounted) _showMedal(m); };
    engine.onStreakMilestone = (m) { if (mounted) _showStreakMilestone(m); };

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pageCtrl.dispose();
    _horizontalPageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = engine.pet;
    final size = MediaQuery.of(context).size;

    // Se precisa escolher o inicial
    if (pet.starterPick) {
      return StarterSelectionScreen(engine: engine);
    }

    // Se está em um ovo, mostra tela do ovo
    if (pet.isEgg) {
      return EggScreen(engine: engine);
    }

    final entry = dex[pet.speciesId];
    final displayName = pet.nick.isNotEmpty ? pet.nick : entry.displayName;

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        scrollDirection: Axis.vertical,
        controller: _pageCtrl,
        children: [
          // Index 0: Settings (swipe down)
          SettingsScreen(
            engine: engine,
            onOk: () {
              _pageCtrl.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
            },
          ),

          // Index 1: Horizontal swipe for Home and Pokedex
          PageView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalPageCtrl,
            children: [
              // Horizontal Page 0: Main Home Content
              GestureDetector(
                onTap: () {
                  if (_isFeeding) {
                    setState(() => _isFeeding = false);
                    return;
                  }
                  engine.petIt();
                  _showHeartAnimation();
                },
                onLongPress: _showReleaseDialog,
                child: Stack(
                  children: [
                    // Background (bioma + hora)
                    BiomeBackground(type: entry.type, sleeping: pet.sleeping),

                    // Conteúdo principal
                    Center(
                      child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Nome + Nível (topo)
                            Positioned(
                              top: size.height * 0.10,
                              child: Column(
                                children: [
                                  if (pet.streak > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: StreakBadge(streak: pet.streak),
                                    ),
                                  Text(
                                    '${displayName.toUpperCase()} Lv.${pet.level}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      color: pet.sleeping
                                          ? Colors.white
                                          : Colors.black87,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tr(engine.statusKey),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      color: pet.sleeping
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Stat bars (abaixo do sprite)
                            Positioned(
                              bottom: size.height * 0.28,
                              child: StatBars(
                                food: pet.fullness,
                                joy: pet.joy,
                                energy: pet.energy,
                                hygiene: pet.hygiene,
                                width: size.width * 0.70,
                                sleeping: pet.sleeping,
                              ),
                            ),

                            // Cocôs (desenhado antes do Pokémon para ficar atrás dele)
                            if (pet.poops > 0)
                              Positioned(
                                right: size.width * 0.18,
                                bottom: size.height * 0.45,
                                child: PoopIndicator(count: pet.poops),
                              ),

                            // Pokémon sprite (centro) com bounce
                            AnimatedBuilder(
                              animation: _bounceAnimation,
                              builder: (_, __) => Transform.translate(
                                offset: Offset(0, _bounceAnimation.value),
                                child: _buildSprite(pet, size),
                              ),
                            ),

                            // Bath Bubbles Overlay
                            if (_isBathing) const BubblesOverlay(),

                            // Eat Animation
                            if (_isEating)
                              Positioned(
                                top: size.height * 0.25,
                                child: TweenAnimationBuilder<double>(
                                  key: _eatKey,
                                  tween: Tween(begin: -50.0, end: 20.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.bounceOut,
                                  builder: (context, val, child) {
                                    return Transform.translate(
                                      offset: Offset(0, val),
                                      child: child,
                                    );
                                  },
                                  child: _isEatingCandy
                                      ? Icon(Icons.cake, color: _eatingColor, size: 32)
                                      : Transform.scale(
                                          scale: 1.5,
                                          child: BerryIcon(color: _eatingColor),
                                        ),
                                ),
                              ),

                            // Heart Animation
                            if (_showHeart)
                              Positioned(
                                top: size.height * 0.25,
                                right: size.width * 0.25,
                                child: TweenAnimationBuilder<double>(
                                  key: _heartKey,
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 1500),
                                  curve: Curves.easeOut,
                                  builder: (context, val, child) {
                                    return Opacity(
                                      opacity: val < 0.2 ? val * 5 : (val > 0.8 ? (1.0 - val) * 5 : 1.0),
                                      child: Transform.translate(
                                        offset: Offset(0, -40 * val),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: const Icon(Icons.favorite, color: Colors.redAccent, size: 32),
                                ),
                              ),

                            // Medal Popup Overlay
                            if (_isShowingMedal)
                              Positioned(
                                top: size.height * 0.28,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.elasticOut,
                                  builder: (context, val, child) {
                                    return Transform.scale(
                                      scale: val,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: size.width * 0.7,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF09000), // Laranja puxado pra ouro
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.black87, width: 2),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(tr('medal'), style: const TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text(_medalName, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // Evolution button
                            if (engine.canEvolveNow)
                              Positioned(
                                top: size.height * 0.35,
                                left: size.width * 0.1,
                                child: GestureDetector(
                                  onTap: _showEvolution,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                            // Farewell button
                            if (engine.canFarewellNow)
                              Positioned(
                                top: size.height * 0.35,
                                right: size.width * 0.1,
                                child: GestureDetector(
                                  onTap: _showFarewellDialog,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                            // Action buttons (arco inferior)
                            Positioned(
                              bottom: size.height * 0.03,
                              child: ActionButtons(
                                onFeed: () {
                                  setState(() => _isFeeding = !_isFeeding);
                                },
                                onPlay: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CatchScreen(engine: engine),
                                  ),
                                ),
                                onSleep: () => engine.toggleSleep(),
                                onBath: () {
                                  if (_isBathing) return;
                                  engine.bath();
                                  setState(() => _isBathing = true);
                                  Future.delayed(const Duration(seconds: 2), () {
                                    if (mounted)
                                      setState(() => _isBathing = false);
                                  });
                                },
                                sleeping: pet.sleeping,
                                width: size.width * 0.75,
                              ),
                            ),

                            // Feed overlay popup
                            if (_isFeeding)
                              Positioned(
                                bottom: size.height * 0.22,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black12),
                                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _foodItemBtn(Colors.redAccent, () => _feed(0, Colors.redAccent)),
                                      const SizedBox(width: 12),
                                      _foodItemBtn(Colors.lightBlue, () => _feed(1, Colors.lightBlue)),
                                      const SizedBox(width: 12),
                                      _foodItemBtn(Colors.greenAccent[400]!, () => _feed(2, Colors.greenAccent[400]!)),
                                      const SizedBox(width: 12),
                                      _foodItemBtn(Colors.pinkAccent, () => _feed(-1, Colors.pinkAccent, candy: true), isCandy: true),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Horizontal Page 1: Pokedex
              PokedexScreen(
                engine: engine,
                onReturnHome: () {
                  if (mounted) {
                    _horizontalPageCtrl.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),

          // Index 2: Stat Card (swipe up)
          StatCardScreen(engine: engine),
        ],
      ),
    );
  }

  Widget _buildSprite(dynamic pet, Size size) {
    final entry = dex[pet.speciesId];
    final spriteSize = size.width * 0.45;
    final folder = pet.shiny ? 'shiny' : 'normal';
    
    // Determine action based on state
    String action = 'idle';
    double offsetX = 0.0;
    bool flipX = false;

    if (pet.sleeping) {
      action = 'sleep';
    } else if (_isEating) {
      action = 'eat';
      offsetX = 0.0;
      flipX = false;
    } else if (_showHeart) {
      action = 'pose';
      offsetX = 0.0;
      flipX = false;
    } else {
      // Alternar animacao aleatoriamente com o tempo
      int ms = DateTime.now().millisecondsSinceEpoch;
      int sec = (ms ~/ 1000) % 20; // 20-second cycle

      if (sec >= 0 && sec < 5) {
        action = 'walk';
        // Walk right
        offsetX = ((ms % 5000) / 5000.0) * (size.width * 0.4) - (size.width * 0.2);
        flipX = true; // Sprites face left by default, so we flip to face right
      } else if (sec >= 5 && sec < 10) {
        action = 'idle';
      } else if (sec >= 10 && sec < 15) {
        action = 'walk';
        // Walk left
        offsetX = (size.width * 0.2) - ((ms % 5000) / 5000.0) * (size.width * 0.4);
        flipX = false; // Face left
      } else if (sec >= 15 && sec < 18) {
        action = 'idle';
      } else {
        action = 'pose';
      }
    }

    final path = 'assets/sprites/$folder/${pet.speciesId.toString().padLeft(3, '0')}_$action.gif';
    final fallbackPath = 'assets/sprites/$folder/${pet.speciesId.toString().padLeft(3, '0')}_idle.gif';

    Widget sprite = Image.asset(
      path,
      fit: BoxFit.none, // Don't stretch small GIFs to the large SizedBox
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          fallbackPath,
          fit: BoxFit.none,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                '#${pet.speciesId.toString().padLeft(3, '0')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: WearTheme.typeColor(entry.type),
                ),
              ),
            );
          },
        );
      },
    );

    return Transform.translate(
      offset: Offset(offsetX, 0),
      child: SizedBox(
        width: spriteSize,
        height: spriteSize,
        child: Transform.scale(
          scaleX: flipX ? -2.5 : 2.5,
          scaleY: 2.5,
          child: sprite,
        ),
      ),
    );
  }

  Widget _foodItemBtn(Color color, VoidCallback onTap, {bool isCandy = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isCandy
            ? Icon(Icons.cake, color: color, size: 18)
            : BerryIcon(color: color),
        ),
      ),
    );
  }

  void _feed(int index, Color color, {bool candy = false}) {
    if (candy) {
      engine.feedCandy();
    } else {
      engine.feedBerry(index);
    }

    setState(() {
      _isFeeding = false;
      _isEating = true;
      _isEatingCandy = candy;
      _eatingColor = color;
      _eatKey = UniqueKey();
    });
    
    _showHeartAnimation();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isEating = false);
    });
  }

  void _showHeartAnimation() {
    setState(() {
      _showHeart = true;
      _heartKey = UniqueKey();
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  void _showEvolution() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EvolutionScreen(engine: engine)),
    );
  }

  void _showFarewell() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CeremonyScreen(engine: engine, type: Ceremony.farewell),
      ),
    );
  }

  void _showRunaway() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CeremonyScreen(engine: engine, type: Ceremony.runaway),
      ),
    );
  }

  void _showFarewellDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Colors.pinkAccent, size: 28),
              const SizedBox(height: 4),
              Text(
                tr('goodbyeQ'),
                style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      engine.farewell();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CeremonyScreen(engine: engine, type: Ceremony.farewell),
                        ),
                      );
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.pink.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.pinkAccent, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReleaseDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.outbox_rounded, color: Colors.white70, size: 28),
              const SizedBox(height: 4),
              Text(
                tr('releaseQ'),
                style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      engine.release();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CeremonyScreen(engine: engine, type: Ceremony.release),
                        ),
                      );
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.redAccent, size: 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMedal(int medal) {
    setState(() {
      _isShowingMedal = true;
      _medalName = _getMedalName(medal);
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _isShowingMedal = false);
    });
  }

  String _getMedalName(int medal) {
    switch (medal) {
      case Medals.lv10: return 'LV 10';
      case Medals.lv25: return 'LV 25';
      case Medals.lv50: return 'LV 50';
      case Medals.streak7: return '7 DAY STREAK';
      case Medals.bond: return 'BEST FRIEND';
      case Medals.finalForm: return 'FINAL FORM';
      case Medals.fit: return 'FITNESS';
      case Medals.berry: return 'BERRY';
      default: return 'MYSTERY';
    }
  }

  void _showStreakMilestone(int days) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔥 $days ${tr('great')}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
      ),
    );
  }
}
