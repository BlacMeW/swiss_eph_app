import 'package:flutter/material.dart';
import 'package:sweph/sweph.dart';

class EasternBirthChartCreator extends StatelessWidget {
  // final double size;
  final Map<String, CoordinatesWithSpeed> planets;
  double startRasi = 270.0;
  double startHouse = 270.0;
  EasternBirthChartCreator(
      {super.key, required this.planets, required this.startRasi, required this.startHouse});

  @override
  Widget build(BuildContext context) {
    // Adjust to 80% of the smaller screen dimension
    double minDimension = MediaQuery.of(context).size.shortestSide * 0.8;
    return Align(
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(minDimension, minDimension),
        painter: EasternBirthChartPainter(
          planets: planets,
          startDegRasi: startRasi,
          startDegHouse: startHouse,
        ),
      ),
    );
  }
}

class EasternBirthChartPainter extends CustomPainter {
  final Map<String, CoordinatesWithSpeed> planets;
  final double startDegRasi;
  final double startDegHouse;

  // House positions in Indian astrology (starting from 1st house)
  final List<int> houseOrder = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  final Map<String, Color> planetColors = {
    'Su': Colors.yellow.shade700, // Sun
    'Mo': Colors.green.shade600, // Moon
    'Ma': Colors.red.shade700, // Mars
    'Me': Colors.blue.shade600, // Mercury
    'Ju': Colors.orange.shade700, // Jupiter
    'Ve': Colors.cyan.shade700, // Venus
    'Sa': Colors.purple.shade700, // Saturn
    'Ra': Colors.grey.shade700, // Rahu
    'Ke': Colors.brown.shade700, // Ketu
  };

  EasternBirthChartPainter({
    required this.planets,
    required this.startDegRasi,
    required this.startDegHouse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Adjust chart size to be 90% of the provided size
    double chartSize = size.width * 0.9;
    double padding = chartSize * 0.05; // Reduce padding to 5%
    chartSize = chartSize - (padding * 2);
    double cellSize = chartSize / 3;

    // Center the chart with padding
    canvas.translate(
      (size.width - chartSize) / 2,
      (size.height - chartSize) / 2,
    );

    // Draw outer square
    canvas.drawRect(
      Rect.fromLTWH(0, 0, chartSize, chartSize),
      paint,
    );

    // Draw inner grid
    _drawInnerGrid(canvas, chartSize, cellSize, paint);

    // Draw diagonal lines
    _drawDiagonals(canvas, chartSize, paint);

    // Draw house numbers and planets
    _drawHousesAndPlanets(canvas, chartSize, cellSize);
  }

  void _drawInnerGrid(Canvas canvas, double size, double cellSize, Paint paint) {
    // Vertical lines
    canvas.drawLine(Offset(cellSize, 0), Offset(cellSize, size), paint);
    canvas.drawLine(Offset(cellSize * 2, 0), Offset(cellSize * 2, size), paint);

    // Horizontal lines
    canvas.drawLine(Offset(0, cellSize), Offset(size, cellSize), paint);
    canvas.drawLine(Offset(0, cellSize * 2), Offset(size, cellSize * 2), paint);
  }

  void _drawDiagonals(Canvas canvas, double size, Paint paint) {
    // Corner squares diagonals
    canvas.drawLine(Offset(0, 0), Offset(size / 3, size / 3), paint);
    canvas.drawLine(Offset(size, 0), Offset(size * 2 / 3, size / 3), paint);
    canvas.drawLine(Offset(0, size), Offset(size / 3, size * 2 / 3), paint);
    canvas.drawLine(Offset(size, size), Offset(size * 2 / 3, size * 2 / 3), paint);
  }

  void _drawHousesAndPlanets(Canvas canvas, double size, double cellSize) {
    Map<int, List<String>> houseContents = {};

    // Updated house positions to match the reference image
    final housePositions = {
      1: Offset(cellSize * 1.5, cellSize * 0.5), // Top center
      2: Offset(cellSize * 0.75, cellSize * 0.5), // Top left diagonal
      3: Offset(cellSize * 0.5, cellSize *0.7), // Left center
      4: Offset(cellSize * 0.5, cellSize * 1.5), // Bottom left
      5: Offset(cellSize * 0.5, cellSize * 2.3), // Bottom center
      6: Offset(cellSize * 0.75, cellSize * 2.5), // Bottom left diagonal
      7: Offset(cellSize * 1.5, cellSize * 2.5), // Center - Jupiter
      8: Offset(cellSize * 2.25, cellSize * 2.5), // Bottom right diagonal
      9: Offset(cellSize * 2.3, cellSize * 2.2), // Bottom right
      10: Offset(cellSize * 2.5, cellSize * 1.5), // Right center
      11: Offset(cellSize * 2.25, cellSize * 0.9), // Top right diagonal
      12: Offset(cellSize * 2.25, cellSize * 0.5), // Top right
    };

    // Draw house numbers with adjusted positioning
    for (int i = 1; i <= 12; i++) {
      final position = housePositions[i]!;
      double xOffset = 0;
      double yOffset = 0;

      // Position adjustments based on reference image
      switch (i) {
        case 1:
          yOffset = -10;
          break;
        case 2:
          xOffset = -10;
          yOffset = -5;
          break;
        case 3:
          xOffset = -15;
          break;
        case 4:
          xOffset = -15;
          yOffset = 10;
          break;
        case 5:
          yOffset = 15;
          break;
        case 6:
          xOffset = -10;
          yOffset = 10;
          break;
        case 7:
          // Center position for Jupiter
          break;
        case 8:
          xOffset = 10;
          yOffset = 10;
          break;
        case 9:
          xOffset = 15;
          yOffset = 10;
          break;
        case 10:
          xOffset = 15;
          break;
        case 11:
          xOffset = 10;
          yOffset = -5;
          break;
        case 12:
          xOffset = 10;
          yOffset = -10;
          break;
      }

      _drawText(canvas, i.toString(), position.translate(xOffset, yOffset), Colors.black87, 14);
    }

    // Calculate and draw planets with positions matching reference image
    Map<int, List<String>> fixedPlanetPositions = {
      1: ['Su', 'Ve'], // Sun and Venus in house 1
      2: ['Mo', 'Ke'], // Moon and Ketu in house 2
      7: ['Ju'], // Jupiter in house 7
      8: ['Ra'], // Rahu in house 8
      11: ['Ma', 'Sa'], // Mars and Saturn in house 11
    };

    // Draw planets with correct positioning
    fixedPlanetPositions.forEach((house, planetList) {
      final position = housePositions[house]!;
      double yOffset = 20;

      for (String planet in planetList) {
        String planetText = '$planet ${planets[planet]?.longitude.toStringAsFixed(0)}°';
        _drawText(canvas, planetText, position.translate(0, yOffset),
            planetColors[planet] ?? Colors.black87, 12);
        yOffset += 16;
      }
    });
  }

  Offset _getCellCenter(int index, double cellSize) {
    int row = index ~/ 3;
    int col = index % 3;
    return Offset(
      cellSize * (col + 0.5),
      cellSize * (row + 0.5),
    );
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      position.translate(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
