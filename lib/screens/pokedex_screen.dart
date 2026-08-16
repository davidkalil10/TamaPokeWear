import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../services/audio_service.dart';
import '../i18n/strings.dart';

class PokedexScreen extends StatefulWidget {
  final GameEngine engine;
  final VoidCallback? onReturnHome;
  final bool isMobileWrapper;

  const PokedexScreen({super.key, required this.engine, this.onReturnHome, this.isMobileWrapper = false});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final Set<int> _showingShiny = {};

  void _attemptSwap(int targetId, bool targetShiny) {
    if (targetId == widget.engine.pet.speciesId && targetShiny == widget.engine.pet.shiny) {
      // Ignorar se já for exatamente o mesmo que o pet ativo
      return;
    }

    final isVeteran = widget.engine.isCurrentPetVeteran();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isVeteran ? Icons.star_rounded : Icons.warning_rounded,
                  color: isVeteran ? Colors.amber : Colors.redAccent,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  isVeteran ? tr('pcVeteranTitle') : tr('pcNewbieTitle'),
                  style: TextStyle(
                    fontSize: 14,
                    color: isVeteran ? Colors.amber : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  isVeteran ? tr('pcVeteranMsg') : tr('pcNewbieMsg'),
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVeteran ? Colors.blueAccent : Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: const Size(0, 30),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.engine.swapWithArchived(targetId, targetShiny);
                    widget.onReturnHome?.call();
                  },
                  child: Text(
                    isVeteran ? tr('pcVeteranSave') : tr('pcNewbieRelease'),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.engine.pet;
    
    return Scaffold(
      backgroundColor: const Color(0xFFB0B9FF),
      body: Column(
        children: [
          // Espaçamento para não cortar na borda circular do relógio
          SizedBox(height: MediaQuery.of(context).size.height * (widget.isMobileWrapper ? 0.25 : 0.15)),
          
          Text(
            'POKEDEX ${pet.registeredCount}/151',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 1.0,
            ),
          ),
          
          const SizedBox(height: 10),
          
          Expanded(
            child: GridView.builder(
              // Padding extra no final para conseguir rolar até o último pokémon
              padding: EdgeInsets.only(
                left: widget.isMobileWrapper ? 70 : 30, 
                right: widget.isMobileWrapper ? 70 : 30, 
                bottom: widget.isMobileWrapper ? 90 : 60
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, 
                mainAxisSpacing: 12, 
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: 151,
              itemBuilder: (context, index) {
                final id = index + 1;
                final registered = pet.isRegistered(id);
                final shinyReg = pet.isShinyRegistered(id);
                final showShiny = _showingShiny.contains(id);

                final folder = showShiny ? 'shiny' : 'normal';
                final path = 'assets/sprites/$folder/${id.toString().padLeft(3, '0')}_idle.gif';

                Widget sprite = Image.asset(
                  path,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset('assets/sprites/thumbs/$id.png', fit: BoxFit.contain), // Fallback para as thumbs
                );

                if (!registered) {
                  sprite = ColorFiltered(
                    colorFilter: const ColorFilter.mode(Color(0xFF101020), BlendMode.srcATop),
                    child: sprite,
                  );
                }

                // Indicador de PC Box
                if (widget.engine.hasArchivedPet(id, showShiny)) {
                  sprite = Stack(
                    alignment: Alignment.center,
                    children: [
                      sprite,
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(Icons.catching_pokemon, color: Colors.redAccent, size: 14),
                      ),
                    ],
                  );
                }

                return GestureDetector(
                  onLongPress: () {
                    if (registered && widget.engine.hasArchivedPet(id, showShiny)) {
                      AudioService().playEvolve();
                      _attemptSwap(id, showShiny);
                    }
                  },
                  onTap: () {
                    if (registered) {
                      AudioService().playPlay(); // Toca som ao clicar
                      if (shinyReg) {
                        setState(() {
                          if (showShiny) {
                            _showingShiny.remove(id);
                          } else {
                            _showingShiny.add(id);
                          }
                        });
                      }
                    } else {
                      AudioService().playDeny(); // Toca som de erro se bloqueado
                    }
                  },
                  child: sprite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
