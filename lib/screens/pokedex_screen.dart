import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../services/audio_service.dart';

class PokedexScreen extends StatefulWidget {
  final GameEngine engine;
  const PokedexScreen({super.key, required this.engine});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  final Set<int> _showingShiny = {};

  @override
  Widget build(BuildContext context) {
    final pet = widget.engine.pet;
    
    return Scaffold(
      backgroundColor: const Color(0xFFB0B9FF),
      body: Column(
        children: [
          // Espaçamento para não cortar na borda circular do relógio
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          
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
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 60),
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

                return GestureDetector(
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
