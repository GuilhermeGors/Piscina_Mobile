import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchBar extends StatefulWidget {
  final Function(String, String?, String?, double, double) onCitySelected;
  final Function(String) onError; // Novo callback para erros

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
          'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=en&format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Response: $data');
        if (data['results'] != null && data['results'] is List) {
          setState(() {
            _suggestions = (data['results'] as List).cast<Map<String, dynamic>>().take(5).toList();
            _errorMessage = null;
          });
          debugPrint('Suggestions fetched: $_suggestions');
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
          _errorMessage = 'Failed to connect. Check your internet and try again.';
        });
        _showSuggestions();
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
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
        debugPrint('API Response for direct search: $data');
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final latitude = result['latitude'] as double?;
          final longitude = result['longitude'] as double?;
          final state = result['admin1'] as String?;
          final country = result['country'] as String?;
          if (latitude != null && longitude != null) {
            widget.onCitySelected(cityName, state, country, latitude, longitude);
            _controller.clear();
            _hideSuggestions();
          } else {
            widget.onError('Could not retrieve coordinates for "$cityName"');
            _hideSuggestions();
          }
        } else {
          widget.onError('"$cityName" does not exist or is not a valid location.');
          _hideSuggestions();
        }
      } else {
        debugPrint('Failed to fetch coordinates: ${response.statusCode}');
        widget.onError('Failed to connect. Check your internet and try again.');
        _hideSuggestions();
      }
    } catch (e) {
      debugPrint('Error fetching coordinates: $e');
      widget.onError('An error occurred while searching for "$cityName". Please try again.');
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
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 6.0,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _suggestions.length > 5 ? 5 : _suggestions.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[300],
                          height: 1,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          final cityName = suggestion['name'] ?? 'Unknown';
                          final region = suggestion['admin1'] ?? '';
                          final country = suggestion['country'] ?? '';
                          final latitude = suggestion['latitude'] as double?;
                          final longitude = suggestion['longitude'] as double?;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: const Icon(
                              Icons.location_city,
                              color: Colors.blueAccent,
                              size: 24,
                            ),
                            title: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: cityName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (region.isNotEmpty || country.isNotEmpty)
                                    TextSpan(
                                      text: ', $region${region.isNotEmpty && country.isNotEmpty ? ', ' : ''}$country',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            onTap: () {
                              if (latitude != null && longitude != null) {
                                widget.onCitySelected(cityName, region, country, latitude, longitude);
                                _controller.clear();
                                _hideSuggestions();
                              } else {
                                debugPrint('Error: Latitude or longitude missing');
                              }
                            },
                            tileColor: Colors.white,
                            hoverColor: Colors.grey[100],
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search for a city...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _controller.clear();
                _hideSuggestions();
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black),
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