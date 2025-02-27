import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweph/sweph.dart';
// import 'package:swiss_eph/lib/birth_chart_preview.dart';
// import 'package:swiss_eph/lib/flutter-birth-chart/src/chart/chart_data.dart';
import '../bloc_lib/calculation/astrocalculation_bloc.dart';
import 'birthchart/entry_form.dart';
import 'horoscope_view.dart';
// Import your SwissLib class

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});

  @override
  _PanelScreenState createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  String houseCusps = "Loading...";
  String swissVersion = "";
  String moonPosition = "Loading...";
  Map<String, CoordinatesWithSpeed> planets = {};
  List<ChartHouse> houses = [];
  double juliDate = 0.0;
  double ayanasa = 0.0;
  // late MySwissLib swissLib;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Scrollbar(
        // thumbVisibility: true,
        // child:
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DateEntryWidget(
                onSubmit: (int year,
                    int month,
                    int day,
                    int hour,
                    int min,
                    int sec,
                    bool isUT,
                    double latDeg,
                    double latMin,
                    double lonDeg,
                    double lonMin,
                    double timeZone,
                    Hsys houseSystem,
                    SiderealMode siderealMode,
                    SwephFlag flags) {},
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: double.infinity, // 🔥 Available width အကုန်ယူမယ်
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocConsumer<AstroCalculationBloc, AstroCalculationState>(
                        listener: (context, state) {
                          if (state is JulianDateConverted) {
                            setState(() {
                              juliDate = state.julianDate;
                              context.read<AstroCalculationBloc>().add(
                                  CalculatePlanetsPosition(
                                      jd: state.julianDate, et: state.et));
                            });
                          } else if (state is PlanetsPositionCalculated) {
                            setState(() {
                              planets = state.planetsPosition;
                              juliDate = state.julianDate;
                            });
                          } else if (state is CompleteCalculation) {
                            setState(() {
                              planets = state.planetsPosition;
                              juliDate = state.julianDate;
                              houses = state.houses;
                              ayanasa = state.ayanasa;
                            });
                          }
                        },
                        builder: (context, state) {
                          swissVersion = Sweph.swe_version();
                          return Text(
                            "Ayanasa ${convertToDMS(ayanasa)} \nSwiss Eph Version $swissVersion",
                            // juliDate as String,
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                      // const Text('Swiss Ephemeris', style: TextStyle(fontSize: 20)),
                      // const SizedBox(height: 10),
                      // Text(swissVersion, style: const TextStyle(fontSize: 16)),
                      // const SizedBox(height: 20),
                      // _buildPlanetDataTable(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // ),
        Expanded(
          flex: 1,
          child: Align(alignment: Alignment.center, child: HoroscopeView()),
          // child: HoroscopeChartApp(),
          // child: BirthChartPreview(),
        ),
        // Expanded(
        //   flex: 1,
        //   child: BirthChartPreview(),
        // ),
      ],
    );
    //     ]),
    //   ),
    // );
  }

  Widget _buildPlanetDataTable() {
    return Expanded(
      child: Scrollbar(
        thumbVisibility: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 🔥 Horizontal Scroll ပါစေမယ်
            child: Row(
              children: [
                DataTable(
                  dataRowMinHeight:
                      60, // 🔥 Row Height ကို 60px အနည်းဆုံးထားမယ်
                  dataRowMaxHeight:
                      80, // 🔥 Row Height ကို 80px အများဆုံးထားမယ်
                  columns: const [
                    DataColumn(
                      label: SelectableText("Planet",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.bold)), // 🔥 Header Font Size
                    ),
                    DataColumn(
                      label: SelectableText("Position",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  rows: planets.entries.map((planet) {
                    String planetName = planet.key;
                    double longitude = planet.value.longitude;
                    double latitude = planet.value.latitude;
                    double speed = planet.value.speedInLongitude;
                    return DataRow(
                      cells: [
                        DataCell(SelectableText(
                          planetName,
                          style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight
                                  .bold), // 🔥 Row Font Size ကို 12px ချုံ့မယ်
                        )),
                        DataCell(SelectableText(
                          "Long  ${convertToDMS(longitude)}\nLat  ${convertToDMS(latitude)}\nSpeed ${convertToDMS(speed)}",
                          style: TextStyle(fontSize: 14), // 🔥 Row Font Size
                        )),
                      ],
                    );
                  }).toList(),
                ),
                DataTable(
                  dataRowMinHeight:
                      60, // 🔥 Row Height ကို 60px အနည်းဆုံးထားမယ်
                  dataRowMaxHeight:
                      80, // 🔥 Row Height ကို 80px အများဆုံးထားမယ်
                  columns: const [
                    DataColumn(
                      label: SelectableText("House",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight.bold)), // 🔥 Header Font Size
                    ),
                    DataColumn(
                      label: SelectableText("Position",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  rows: houses.map((chart) {
                    String? chartName = chart.name;
                    double longitude = chart.position + 270;
                    if (longitude > 360) {
                      longitude -= 360;
                    }
                    // -ayanasa;
                    // double latitude = planet.value.latitude;
                    return DataRow(
                      cells: [
                        DataCell(SelectableText(
                          chartName!,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight
                                  .bold), // 🔥 Row Font Size ကို 12px ချုံ့မယ်
                        )),
                        DataCell(SelectableText(
                          convertToDMS(longitude),
                          style: TextStyle(fontSize: 14), // 🔥 Row Font Size
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
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
