import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchBar extends StatefulWidget {
  final Function(String, double, double) onCitySelected; // Modificado para incluir latitude e longitude

  const SearchBar({required this.onCitySelected, super.key});

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = []; // Armazenar sugestões com mais detalhes
  OverlayEntry? _overlayEntry;

  void _fetchSuggestions(String query) async {
    debugPrint('Fetching suggestions for: $query');

    if (query.isEmpty) {
      _hideSuggestions();
      return;
    }

    try {
      // Usando a API de geocodificação do Open-Meteo
      final response = await http.get(Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10&language=en&format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Response: $data'); // Depuração para verificar a resposta
        if (data['results'] != null && data['results'] is List) {
          setState(() {
            _suggestions = (data['results'] as List).cast<Map<String, dynamic>>();
          });
          debugPrint('Suggestions fetched: $_suggestions');
          _showSuggestions();
        } else {
          debugPrint('No suggestions found in API response');
          _hideSuggestions();
        }
      } else {
        debugPrint('Failed to fetch suggestions: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        _hideSuggestions();
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      _hideSuggestions();
    }
  }

  void _showSuggestions() {
    if (_suggestions.isEmpty) {
      debugPrint('No suggestions to show');
      return;
    }

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint('RenderBox is null, cannot show suggestions');
      return;
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 4.0,
          child: SizedBox(
            height: 200,
            child: ListView.builder(  
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                final cityName = suggestion['name'] ?? 'Unknown';
                final region = suggestion['admin1'] ?? 'Unknown';
                final country = suggestion['country'] ?? 'Unknown';
                final latitude = suggestion['latitude'] as double?;
                final longitude = suggestion['longitude'] as double?;

                return ListTile(
                  title: Text('$cityName, $region, $country'),
                  onTap: () {
                    if (latitude != null && longitude != null) {
                      widget.onCitySelected('$cityName, $region, $country', latitude, longitude);
                      _controller.clear();
                      _hideSuggestions();
                    } else {
                      debugPrint('Error: Latitude or longitude missing for suggestion');
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    debugPrint('Suggestions overlay shown');
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _suggestions = [];
    });
    debugPrint('Suggestions hidden');
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideSuggestions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search city',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              _hideSuggestions();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withValues(),
        ),
        onChanged: (query) {
          _fetchSuggestions(query);
        },
        onSubmitted: (query) {

          if (_suggestions.isNotEmpty) {
            final suggestion = _suggestions.first;
            final latitude = suggestion['latitude'] as double?;
            final longitude = suggestion['longitude'] as double?;
            if (latitude != null && longitude != null) {
              widget.onCitySelected(query, latitude, longitude);
              _controller.clear();
              _hideSuggestions();
            }
          }
        },
      ),
    );
  }
}