import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'package:sweph/sweph.dart';
import '../../bloc_lib/calculation/astrocalculation_bloc.dart';
// import '../../lib/birth_chart_preview.dart';

class HoroscopeChartApp extends StatefulWidget {
  const HoroscopeChartApp({super.key});

  @override
  _HoroscopeChartState createState() => _HoroscopeChartState();
}

class _HoroscopeChartState extends State<HoroscopeChartApp> {
  double juliDate = 0.0;
  Map<String, CoordinatesWithSpeed> planets =
      {}; // Initialize an empty map for planet positions

  @override
  void initState() {
    super.initState();
    // swissLib = MySwissLib();
    // _loadPlanetPositions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Horoscope Chart")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // double chartSize =
          // min(constraints.maxWidth, constraints.maxHeight) * 0.8;
          return Row(
            children: [
              BlocConsumer<AstroCalculationBloc, AstroCalculationState>(
                  listener: (context, state) {
                if (state is CompleteCalculation) {
                  setState(() {
                    planets = state.planetsPosition;
                    juliDate = state.julianDate;
                  });
                }
              }, builder: (context, state) {
                // return SizedBox();
                return _buildCalculator(context, juliDate);
              }),
              HoroscopeWheel(planets: planets)
              // BirthChartPreview(),
            ],
            // child: HoroscopeWheel(size: chartSize, planets: planets),
          );
        },
      ),
    );
  }

  Widget _buildCalculator(BuildContext context, double juliDate) {
    return TextButton.icon(
      icon: const Icon(
        Icons.calculate,
        color: Colors.white,
      ),
      label: const Text(
        'Calculate',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        // Navigator.pushNamed(context, '/calculator');
        // context
        //     .read<AstroCalculationBloc>()
        //     .add(CalculatePlanetsPosition(jd: juliDate, et: true));
      },
    );
  }
}

class HoroscopeWheel extends StatelessWidget {
  // final double size;
  final Map<String, CoordinatesWithSpeed> planets;
  const HoroscopeWheel({super.key, required this.planets});

  @override
  Widget build(BuildContext context) {
    double screenSizeWidth = MediaQuery.of(context).size.width * 0.35;
    double screenSizeHeight = MediaQuery.of(context).size.height * 0.35;
    return Align(
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(screenSizeWidth, screenSizeHeight),
        // painter: HoroscopePainter(planets: planets),
        // painter: BirthChartPainter(planets: planets, startDegRasi: -90.0),
      ),
    );
  }
}

class HoroscopePainter extends CustomPainter {
  final Map<String, double> planets;

  HoroscopePainter({required this.planets});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    List<Color> planetColor = [
      Colors.yellow,
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.brown
    ];

    // Apply a horizontal mirror transformation
    canvas.save();
    canvas.translate(size.width * 1.0, 0);
    // canvas.translate(
    // center.dx, 0); // Move the origin to the center horizontally
    canvas.scale(-1, 1); // Flip the canvas horizontally

    // Background color for the wheel
    final paintBackground = Paint()..color = Colors.black.withOpacity(0.8);
    canvas.drawCircle(center, radius, paintBackground);

    // Draw Outer Circle
    final paintOuterCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, paintOuterCircle);

    for (int i = 0; i < 12; i++) {
      // Each zodiac sign gets a 30-degree segment, starting from 90 degrees
      final angle = (i * 30 - 90) *
          pi /
          180; // Adjusted to place 0° at the top (Ascendant)

      // Calculate the start position for each line at the edge of the circle
      final start = Offset(
        center.dx +
            radius * cos(angle), // Start point is at the edge of the circle
        center.dy + radius * sin(angle),
      );

      // The end point will be the center of the circle
      final end = center; // End point is at the center

      // Paint configuration for the dividing lines
      final paintDivision = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw the division line connecting the edge of the circle to the center
      canvas.drawLine(start, end, paintDivision);
    }

    for (int i = 0; i < 360; i++) {
      // Calculate the angle for each degree (0-359)
      final angle =
          (i - 90) * pi / 180; // Adjust to start 0° from the top (Ascendant)

      // Calculate the start and end positions for each line
      final start = Offset(
        center.dx +
            radius * cos(angle), // Start point at the edge of the circle
        center.dy + radius * sin(angle),
      );
      final end = Offset(
        center.dx +
            (radius - (size.width * 0.03)) *
                cos(angle), // End point closer to the center
        center.dy + (radius - (size.width * 0.03)) * sin(angle),
      );

      // Paint configuration for the lines
      final paintDivision = Paint()
        ..color = Colors.yellowAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1; // Thinner lines for 1-degree divisions

      // Draw each 1-degree division line
      canvas.drawLine(start, end, paintDivision);
    }

    // Draw planets' positions dynamically based on the updated `planets` map
    int planetIndex = 0;
    for (var planet in planets.entries) {
      planetIndex++;
      final angle = (planet.value - 90) *
          pi /
          180; // Adjusted for counterclockwise rotation
      final planetOffset = Offset(
        center.dx + (radius - (size.width * 0.15)) * cos(angle),
        center.dy + (radius - (size.width * 0.15)) * sin(angle),
      );

      // Draw planet names near the planet
      final planetNamePainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      planetNamePainter.text = TextSpan(
        text: planet.key,
        style: TextStyle(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
            color: planetColor[planetIndex - 1]),
      );
      planetNamePainter.layout();
      planetNamePainter.paint(
        canvas,
        Offset(planetOffset.dx - (size.width * 0.03),
            planetOffset.dy - (size.height * 0.05)),
      );
    }

    // Optional: Add a circle in the center to represent the "Ascendant" point or any other
    final paintCenter = Paint()
      ..color = Colors.yellow.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.05, paintCenter);

    // Restore the canvas to its original state (without mirror)
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WesternBirthChartPainter extends CustomPainter {
  final Map<String, CoordinatesWithSpeed>
      planets; // Planet positions in degrees

  List<Color> planetColor = [
    Colors.yellow,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.brown
  ];
  WesternBirthChartPainter({required this.planets});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 3.5, size.height / 2);
    //-Offset(80, 0);
    final radius = size.width / 2;

    // Background
    final paintBackground = Paint()..color = Colors.black;
    canvas.drawCircle(center, radius, paintBackground);

    // Outer Circle (Zodiac Wheel)
    final paintOuterCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, paintOuterCircle);

    // Zodiac Sign Divisions (0° Aries at Top, Anticlockwise)
    final paintDivision = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;
    for (int i = 0; i < 12; i++) {
      final angle =
          ((270 - i * 30) % 360) * pi / 180; // Adjusting for 0° Aries at Top
      final start = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, center, paintDivision);
    }

    // House Divisions (0° Aries at Top, Anticlockwise)
    // final paintHouse = Paint()
    //   ..color = Colors.blueGrey
    //   ..strokeWidth = 1.5;
    // for (int i = 0; i < 12; i++) {
    //   final angle = ((270 - i * 30) % 360) * pi / 180;
    //   final start = Offset(
    //     center.dx + (radius * 0.8) * cos(angle),
    //     center.dy + (radius * 0.8) * sin(angle),
    //   );
    //   canvas.drawLine(start, center, paintHouse);
    // }

    // Degree Markers (0° Aries at Top, Anticlockwise)
    final paintMarker = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    for (int i = 0; i < 360; i += 5) {
      final angle = ((270 - i) % 360) * pi / 180;
      final start = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final end = Offset(
        center.dx + (radius * 0.95) * cos(angle),
        center.dy + (radius * 0.95) * sin(angle),
      );
      canvas.drawLine(start, end, paintMarker);
    }

    // Calculate Planet Positions (0° Aries at Top, Anticlockwise)
    final planetOffsets = <String, Offset>{};

    for (var planet in planets.entries) {
      final angle = ((270 - planet.value.longitude) % 360) *
          pi /
          180; // Adjusting for 0° Aries at Top
      final planetOffset = Offset(
        center.dx + (radius * 0.7) * cos(angle),
        center.dy + (radius * 0.7) * sin(angle),
      );
      planetOffsets[planet.key] = planetOffset;
    }

    // Draw Aspect Lines (0° Aries at Top, Anticlockwise)
    final paintAspect = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 1.5;
    for (var p1 in planetOffsets.entries) {
      for (var p2 in planetOffsets.entries) {
        if (p1.key != p2.key) {
          final diff =
              (planets[p1.key]!.longitude - planets[p2.key]!.longitude).abs();
          if (diff == 60 || diff == 90 || diff == 120 || diff == 180) {
            canvas.drawLine(p1.value, p2.value, paintAspect);
          }
        }
      }
    }

    int planetIndex = 0;

    // Draw Planets (0° Aries at Top, Anticlockwise)
    for (var planet in planets.entries) {
      planetIndex++;
      final angle = ((270 - planet.value.longitude) % 360) *
          pi /
          180; // Adjusting for 0° Aries at Top
      final planetOffset = Offset(
        center.dx + (radius * 0.7) * cos(angle),
        center.dy + (radius * 0.7) * sin(angle),
      );

      // Draw Planet Name
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..text = TextSpan(
          text: planet.key,
          style: TextStyle(
            fontSize: size.width * 0.048,
            fontWeight: FontWeight.bold,
            color: planetColor[planetIndex - 1],
          ),
        );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(planetOffset.dx - (textPainter.width / 2),
            planetOffset.dy - (textPainter.height / 2)),
      );

      // Draw Planet Name
      final textPainter2 = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..text = TextSpan(
          text: "\n\n\n${planet.value.longitude.toInt()}°",
          style: TextStyle(
            fontSize: size.width * 0.025,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      textPainter2.layout();
      textPainter2.paint(
        canvas,
        Offset(planetOffset.dx - (textPainter2.width / 2),
            planetOffset.dy - (textPainter2.height / 2)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
