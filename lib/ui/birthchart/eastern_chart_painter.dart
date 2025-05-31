import 'package:flutter/material.dart';
import 'package:sweph/sweph.dart';

class EasternBirthChartCreator extends StatelessWidget {
  // final double size;
  final Map<String, CoordinatesWithSpeed> planets;
  double startRasi = 270.0;
  double startHouse = 270.0;
  HouseCuspData houseCuspData;
  EasternBirthChartCreator(
      {super.key, required this.planets, required this.startRasi, required this.startHouse,required this.houseCuspData});

  @override
  Widget build(BuildContext context) {
    // Adjust to 80% of the smaller screen di mension
    double minDimension = MediaQuery.of(context).size.shortestSide * 0.8;
    return Align(
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(minDimension, minDimension),
        painter: EasternBirthChartPainter(
          planets: planets,
          startDegRasi: startRasi,
          startDegHouse: startHouse,
          houseCuspData: houseCuspData,
        ),
      ),
    );
  }
}

class EasternBirthChartPainter extends CustomPainter {
  final Map<String, CoordinatesWithSpeed> planets;
  final double startDegRasi;
  final double startDegHouse;
  final HouseCuspData houseCuspData;

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
    required this.houseCuspData,
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

    final ASC = houseCuspData.ascmc[0]; // Ascendant in degrees
    final MC=houseCuspData.cusps[9]; // Midheaven in degrees
    // Calculate house positions for planets
    for (var entry in planets.entries) {
      // Convert to house position (1-12)
      double longitude = entry.value.longitude;
      // double housePos = ((longitude - startDegHouse) / 30.0);
      double housePos = ((longitude) / 30.0);
      if (housePos < 0) housePos += 12;
      int house = (housePos.floor() % 12) + 1;

      // Add planet to house contents
      houseContents.putIfAbsent(house, () => []).add(entry.key);
    }
    double longitude = ASC.toDouble();

    double housePos = ((longitude - 0.0) / 30.0);
    if (housePos < 0) housePos += 12;
    int house = (housePos.floor() % 12) + 1;

    // Add planet to house contents
    houseContents.putIfAbsent(house, () => []).add("A");

    longitude = MC.toDouble();
    housePos = ((longitude - 0.0) / 30.0);
    if (housePos < 0) housePos += 12;
    house = (housePos.floor() % 12) + 1;
    // Add planet to house contents
    houseContents.putIfAbsent(house, () => []).add("M");

    // House positions mapping
    final housePositions = {
      1: Offset(cellSize * 1.5, cellSize * 0.03), // Top center
      2: Offset(cellSize * 0.75, cellSize * 0.03), // Top left diagonal
      3: Offset(cellSize * 0.15, cellSize * 0.25), // Left center
      4: Offset(cellSize * 0.5, cellSize * 1.0), // Bottom left
      5: Offset(cellSize * 0.20, cellSize * 2.0), // Bottom center
      6: Offset(cellSize * 0.8, cellSize * 2.3), // Bottom left diagonal
      7: Offset(cellSize * 1.5, cellSize * 2.0), // Center - Jupiter
      8: Offset(cellSize * 2.15, cellSize * 2.25), // Bottom right diagonal
      9: Offset(cellSize * 2.8, cellSize * 2.0), // Bottom right
      10: Offset(cellSize * 2.5, cellSize * 1.0), // Right center
      11: Offset(cellSize * 2.8, cellSize * 0.3), // Top right diagonal
      12: Offset(cellSize * 2.2, cellSize * 0.03), // Top right
    };

    // Draw house numbers
    // for (int i = 1; i <= 12; i++) {
    //   final position = housePositions[i]!;
    //   _drawText(canvas, i.toString(), position.translate(0, -10), Colors.black87, 14);
    // }

    // Draw planets in their calculated houses
    houseContents.forEach((house, planetList) {
      final position = housePositions[house]!;
      double yOffset = 15;

      for (String planet in planetList) {
        double longitude = (planets[planet]?.longitude ?? 0.0) % 30.0;
        if (planet == "A") {
          longitude = houseCuspData.ascmc[0].toDouble()% 30.0; // Ascendant
        }
        if (planet == "M") {
          longitude = houseCuspData.cusps[9].toDouble()% 30.0; // Midheaven
        }
        String planetText = '$planet ${longitude.toStringAsFixed(0)}°';

        _drawText(canvas, planetText, position.translate(0, yOffset),
            planetColors[planet] ?? Colors.black87, 13);
        yOffset += 16;
      }
    });
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
