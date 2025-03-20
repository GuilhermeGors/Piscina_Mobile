import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchBar extends StatefulWidget {
  final Function(String, double, double, {String? region, String? country}) onCitySelected;
  final Function(String) onError;

  const SearchBar({required this.onCitySelected, required this.onError, super.key});

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  String? _errorMessage;
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  void _fetchSuggestions(String query) async {
    debugPrint('Fetching suggestions for: $query');

    if (query.isEmpty) {
      _hideSuggestions();
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10&language=en&format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Response: $data');
        if (data['results'] != null && data['results'] is List) {
          setState(() {
            _suggestions = (data['results'] as List).cast<Map<String, dynamic>>();
            _errorMessage = null;
          });
          _showSuggestions();
        } else {
          debugPrint('No suggestions found in API response');
          setState(() {
            _errorMessage = 'No results found for "$query"';
          });
          _showSuggestions();
        }
      } else {
        debugPrint('Failed to fetch suggestions: ${response.statusCode}');
        setState(() {
          _errorMessage = 'Failed to connect. Check your internet.';
        });
        _showSuggestions();
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      setState(() {
        _errorMessage = 'Connection error. Please try again.';
      });
      _showSuggestions();
    }
  }

  void _fetchCityCoordinates(String cityName) async {
    try {
      final response = await http.get(Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$cityName&count=1&language=en&format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Direct search API Response: $data');
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final latitude = result['latitude'] as double?;
          final longitude = result['longitude'] as double?;
          if (latitude != null && longitude != null) {
            widget.onCitySelected(cityName, latitude, longitude);
            _controller.clear();
            _hideSuggestions();
          } else {
            widget.onError('Coordinates not found for "$cityName"');
            _hideSuggestions();
          }
        } else {
          widget.onError('"$cityName" does not exist or is not a valid location.');
          _hideSuggestions();
        }
      } else {
        debugPrint('Failed to fetch coordinates: ${response.statusCode}');
        widget.onError('Failed to connect. Check your internet.');
        _hideSuggestions();
      }
    } catch (e) {
      debugPrint('Error fetching coordinates: $e');
      widget.onError('Connection error. Please try again.');
      _hideSuggestions();
    }
  }

  void _showSuggestions() {
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
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  )
                : _suggestions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No suggestions available',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          final cityName = suggestion['name'] ?? 'Unknown';
                          final region = suggestion['admin1'] ?? '';
                          final country = suggestion['country'] ?? '';
                          final latitude = suggestion['latitude'] as double?;
                          final longitude = suggestion['longitude'] as double?;

                              return ListTile(
      title: Text('$cityName${region.isNotEmpty ? ', $region' : ''}${country.isNotEmpty ? ', $country' : ''}'),
      onTap: () {
        if (latitude != null && longitude != null) {
          widget.onCitySelected(cityName, latitude, longitude, region: region, country: country);
          _controller.clear();
          _hideSuggestions();
        } else {
          debugPrint('Error: Missing coordinates');
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
      _errorMessage = null;
    });
    debugPrint('Suggestions hidden');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _hideSuggestions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
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
            fillColor: Colors.white,
          ),
          onChanged: (query) {
            _fetchSuggestions(query);
          },
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              _fetchCityCoordinates(query);
            }
          },
        ),
      ),
    );
  }
}