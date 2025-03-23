import 'package:flutter/material.dart';

class FlutterSalesGraph extends StatefulWidget {
  final List<double> salesData;
  final List<String> labels;
  final double maxBarHeight;
  final double barWidth;
  final List<Color> colors;
  final double dateLineHeight;

  const FlutterSalesGraph({
    super.key,
    required this.salesData,
    required this.labels,
    this.maxBarHeight = 200.0,
    this.barWidth = 24.0,
    this.colors = const [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.cyan,
      Colors.amber,
      Colors.indigo,
      Colors.lime,
      Colors.deepOrange,
      Colors.pink,
    ],
    this.dateLineHeight = 20.0,
  });

  @override
  _FlutterSalesGraphState createState() => _FlutterSalesGraphState();
}

class _FlutterSalesGraphState extends State<FlutterSalesGraph> {
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.salesData.isEmpty ||
        widget.labels.isEmpty ||
        widget.salesData.length != widget.labels.length) {
      return Center(child: Text('No data available or labels mismatch.'));
    }

    final double maxSales = widget.salesData.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: double.infinity,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(widget.salesData.length, (index) {
                      final sales = widget.salesData[index];
                      final label = widget.labels[index];
                      final barWidth = maxSales > 0
                          ? (sales / maxSales) * widget.maxBarHeight
                          : 2.0;
                      final color = widget.colors[index % widget.colors.length];

                      return GestureDetector(
                        onLongPress: () {
                          setState(() {
                            _pressedIndex = index;
                          });
                        },
                        onLongPressEnd: (_) {
                          setState(() {
                            _pressedIndex = null;
                          });
                        },
                        child: Container(
                          height: widget.barWidth,
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                height: widget.barWidth,
                                width: barWidth.toDouble(),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              if (_pressedIndex == index)
                                Positioned(
                                  left: barWidth + 10,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    color: Colors.black87,
                                    child: Text(
                                      '\$${sales.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                child: Container(
                                  height: widget.barWidth,
                                  width: widget.dateLineHeight,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}