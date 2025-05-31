import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweph/sweph.dart';

// import 'package:swiss_eph/lib/birth_chart_preview.dart';

import '../../bloc_lib/calculation/astrocalculation_bloc.dart';
import 'eastern_chart_painter.dart';

class HoroscopeView extends StatefulWidget {
  const HoroscopeView({super.key});

  @override
  State<HoroscopeView> createState() => _HoroscopeViewState();
}

class _HoroscopeViewState extends State<HoroscopeView> with SingleTickerProviderStateMixin {
  // late var planets = <ChartPlanet>[];
  late var houses = <ChartHouse>[];
  double juliDate = 0.0;
  Map<String, CoordinatesWithSpeed> planets = {};
  late TabController _tabController;

  // late var planets = <ChartPlanet>[];
  // late var houses = <ChartHouse>[];
  late HouseCuspData houseCuspData;
  // Map<String, CoordinatesWithSpeed> swissplanets = {};
  @override
  void initState() {
    super.initState();
    houseCuspData = HouseCuspData([], []);
    _tabController = TabController(length: 4, vsync: this); // Changed from 3 to 4
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Horoscope Chart"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Western"),
            Tab(text: "Eastern"),
            Tab(text: "Planets"),
            Tab(text: "Houses"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // First tab - Western Chart
          BlocConsumer<AstroCalculationBloc, AstroCalculationState>(
            listener: (context, state) {
              if (state is CompleteCalculation) {
                setState(() {
                  planets = state.planetsPosition;
                  juliDate = state.julianDate;
                  houseCuspData = state.houseCuspData;
                  houses = state.houses;
                });
              }
            },
            builder: (context, state) {
              double asc = 0.0;
              if (houseCuspData.ascmc.isNotEmpty) {
                asc = houseCuspData.ascmc[0];
              }
              return Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.width * 0.35,
                  child: HoroscopeCreator(
                    planets: planets,
                    startRasi: 0.0,
                    startHouse: asc,
                  ),
                ),
              );
            },
          ),
          // Second tab - Eastern Chart
          BlocConsumer<AstroCalculationBloc, AstroCalculationState>(
            listener: (context, state) {
              if (state is CompleteCalculation) {
                setState(() {
                  planets = state.planetsPosition;
                  juliDate = state.julianDate;
                  houseCuspData = state.houseCuspData;
                  houses = state.houses;
                });
              }
            },
            builder: (context, state) {
              double asc = 0.0;
              if (houseCuspData.ascmc.isNotEmpty) {
                asc = houseCuspData.ascmc[0];
              }
              return Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  child: EasternBirthChartCreator(
                    planets: planets,
                    startRasi: 0.0,
                    startHouse: asc,
                  ),
                ),
              );
            },
          ),
          // Existing Planets tab
          BlocConsumer<AstroCalculationBloc, AstroCalculationState>(
            listener: (context, state) {
              if (state is CompleteCalculation) {
                setState(() {
                  planets = state.planetsPosition;
                  juliDate = state.julianDate;
                  houseCuspData = state.houseCuspData;
                  houses = state.houses;
                });
              }
            },
            builder: (context, state) {
              return _buildPlanetDataTable();
            },
          ),
          // Existing Houses tab
          BlocConsumer<AstroCalculationBloc, AstroCalculationState>(
            listener: (context, state) {
              if (state is CompleteCalculation) {
                setState(() {
                  planets = state.planetsPosition;
                  juliDate = state.julianDate;
                  houseCuspData = state.houseCuspData;
                  houses = state.houses;
                });
              }
            },
            builder: (context, state) {
              return _buildHouseDataTable();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Add this to show all items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.circle_outlined),
            label: 'Western',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.square_outlined),
            label: 'Eastern',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Planets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Houses',
          ),
        ],
        currentIndex: _tabController.index,
        onTap: (index) {
          setState(() {
            _tabController.index = index;
          });
        },
      ),
    );
  }

  Widget _buildPlanetDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Allow horizontal scrolling
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Allow vertical scrolling
        child: DataTable(
          columnSpacing: 20, // Add spacing between columns
          columns: const [
            DataColumn(
                label: Text("Planet", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
            DataColumn(
                label:
                    Text("Longitude", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
            DataColumn(
                label:
                    Text("Latitude", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text("Speed", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          ],
          rows: planets.entries.map((planet) {
            return DataRow(
              cells: [
                DataCell(
                    Text(planet.key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                DataCell(
                    Text(convertToDMS(planet.value.longitude), style: TextStyle(fontSize: 14))),
                DataCell(Text(convertToDMS(planet.value.latitude), style: TextStyle(fontSize: 14))),
                DataCell(Text(convertToDMS(planet.value.speedInLongitude),
                    style: TextStyle(fontSize: 14))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHouseDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text("House", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text("Position", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        ],
        rows: houses.asMap().entries.map((entry) {
          int houseNumber = entry.key + 1;
          double position = entry.value.position;
          return DataRow(
            cells: [
              DataCell(Text("House $houseNumber",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
              DataCell(Text(convertToDMS(position))),
            ],
          );
        }).toList(),
      ),
    );
  }

  String convertToDMS(double decimalDegrees) {
    int degrees = decimalDegrees.floor();
    double minutesDecimal = (decimalDegrees - degrees) * 60;
    int minutes = minutesDecimal.floor();
    double seconds = (minutesDecimal - minutes) * 60;

    return "$degrees° $minutes' ${seconds.toStringAsFixed(2)}\"";
  }
}

class HoroscopeCreator extends StatelessWidget {
  // final double size;
  final Map<String, CoordinatesWithSpeed> planets;
  double startRasi = 270.0;
  double startHouse = 270.0;
  HoroscopeCreator(
      {super.key, required this.planets, required this.startRasi, required this.startHouse});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(MediaQuery.of(context).size.width * 0.45),
      painter: BirthChartPainter(
        planets: planets,
        startDegRasi: startRasi,
        startDegHouse: startHouse,
      ),
    );
  }
}

class BirthChartPainter extends CustomPainter {
  final Map<String, CoordinatesWithSpeed> planets; // Planet positions in degrees

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

  Offset center = Offset(0, 0);
  double radius = 0; // radius
  double startDegRasi = 270.0;
  double startDegHouse = 270.0;
  BirthChartPainter(
      {required this.planets, required this.startDegRasi, required this.startDegHouse});

  void resize(Size size) {
    if (startDegRasi > 360) {
      startDegRasi = startDegRasi - 360;
    }
    center = Offset(size.width / 2, size.height / 2);
    radius = size.width / 2;
  }

  void setStartDegRasi(double deg) {
    // setState(() {
    startDegRasi = deg + 270.0;
    if (startDegRasi > 360) {
      startDegRasi = startDegRasi - 360;
    }
    // });
  }

  void setStartDegHouse(double deg) {
    // setState(() {
    startDegHouse = deg + 270.0;
    if (startDegHouse > 360) {
      startDegHouse = startDegHouse - 360;
    }
    // });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (startDegRasi > 360) {
      startDegRasi = startDegRasi - 360;
    }
    center = Offset(size.width / 2, size.height / 2);
    //-Offset(80, 0);
    radius = size.width / 2;

    // Background
    final paintBackground = Paint()..color = Colors.black;
    canvas.drawCircle(center, radius, paintBackground);

    // Outer Circle (Zodiac Wheel)
    final paintOuterCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, paintOuterCircle);

    drawRasi(canvas, size, Colors.yellowAccent, startDegRasi);
    drawHouseLine(canvas, size, Colors.blue, startDegHouse);
    drawPlanet(canvas, size, planets, startDegRasi);
    drawDeg(canvas, size, Colors.yellow, 5, startDegRasi);
  }

  void drawRasi(Canvas canvas, Size size, Color lineColor, double startDeg) {
    // Zodiac Sign Divisions (0° Aries at Top, Anticlockwise)
    double sDeg = startDeg + 270.0;
    if (sDeg > 360) {
      sDeg = sDeg - 360;
    }
    final paintDivision = Paint()
      ..color = lineColor
      ..strokeWidth = 0.6;
    for (int i = 0; i < 12; i++) {
      final angle = ((sDeg - i * 30) % 360) * pi / 180; // Adjusting for 0° Aries at Top
      // debugPrint("$i = angle $angle");
      final start = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, center, paintDivision);
    }
  }

  void drawHouseLine(Canvas canvas, Size size, Color lineColor, double startDegHouse) {
    double houseDeg = 270.0 - startDegHouse;
    if (houseDeg > 360) {
      houseDeg -= 360;
    }

    final paintDivision = Paint()
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      final angle = ((houseDeg - i * 30) % 360) * pi / 180; // Adjusting for 0° Aries at Top
      final start = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      drawDashedLine(canvas, paintDivision, start, center, dashLength: 5, gapLength: 3);

      // Calculate text position
      final midAngle = ((houseDeg - (i * 30) - 15) % 360) * pi / 180; // Midpoint of house
      final textOffset = Offset(
        center.dx + (radius * 0.85) * cos(midAngle),
        center.dy + (radius * 0.85) * sin(midAngle),
      );

      // Draw house number
      drawHouseNumber(canvas, textOffset, (i + 1).toString());
    }
  }

  void drawHouseNumber(Canvas canvas, Offset position, String number) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..text = TextSpan(
        text: number,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - (textPainter.width / 2), position.dy - (textPainter.height / 2)),
    );
  }

  void drawPlanet(
      Canvas canvas, Size size, Map<String, CoordinatesWithSpeed> dplanets, double startDeg) {
    int planetIndex = 0;
    double sDeg = startDeg + 270.0;
    if (sDeg > 360) {
      sDeg = sDeg - 360;
    }
    // Draw Planets (0° Aries at Top, Anticlockwise)
    for (var planet in dplanets.entries) {
      planetIndex++;
      final angle =
          ((sDeg - planet.value.longitude) % 360) * pi / 180; // Adjusting for 0° Aries at Top
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
        Offset(
            planetOffset.dx - (textPainter.width / 2), planetOffset.dy - (textPainter.height / 2)),
      );
    }
  }

  void drawDeg(Canvas canvas, Size size, Color lineColor, int byDeg, double startDeg) {
    // Zodiac Sign Divisions (0° Aries at Top, Anticlockwise)
    double sDeg = startDeg + 270.0;
    if (sDeg > 360) {
      sDeg = sDeg - 360;
    }
    // Degree Markers (0° Aries at Top, Anticlockwise)
    final paintMarker = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (int i = 0; i < 360; i += byDeg) {
      final angle = ((sDeg - i) % 360) * pi / 180;
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
  }

  void drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end,
      {double dashLength = 5, double gapLength = 3}) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double distance = sqrt(dx * dx + dy * dy);
    final double dashCount = distance / (dashLength + gapLength);
    final double dashDx = (dx / distance) * dashLength;
    final double gapDx = (dx / distance) * gapLength;
    final double dashDy = (dy / distance) * dashLength;
    final double gapDy = (dy / distance) * gapLength;

    Offset currentPoint = start;
    for (int i = 0; i < dashCount; i++) {
      final Offset nextPoint = Offset(currentPoint.dx + dashDx, currentPoint.dy + dashDy);
      canvas.drawLine(currentPoint, nextPoint, paint);
      currentPoint = Offset(currentPoint.dx + dashDx + gapDx, currentPoint.dy + dashDy + gapDy);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
