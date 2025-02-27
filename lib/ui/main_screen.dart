import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweph/sweph.dart';
import 'package:swiss_eph/bloc_lib/calculation/astrocalculation_bloc.dart';
import '/ui/panel_screen.dart';

class MainScreen extends StatefulWidget {
  final String appName;

  const MainScreen({required this.appName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double juliDate = 0.0;
  Map<String, CoordinatesWithSpeed> planetPositions = {};
  @override
  Widget build(BuildContext context) {
    // debugPrint('This is a debug message');
    return Scaffold(
      backgroundColor: Colors.blueGrey[100], // Main Screen Back Color
      // appBar: AppBar(
      //   backgroundColor: Colors.blue,
      //   centerTitle: true,
      //   title: Text(appName),
      // ),
      appBar: null,
      body: const Column(
        children: [
          Expanded(child: PanelScreen()),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 50.0,
        color: Colors.blueGrey,
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: SizedBox(
            height: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BlocConsumer<AstroCalculationBloc, AstroCalculationState>(
                //   listener: (context, state) {
                //     if (state is JulianDateConverted) {
                //       setState(() {
                //         juliDate = state.julianDate;
                //       });

                //       //juliDate = state.julianDate.toString();
                //       debugPrint('Julian Date: ${state.julianDate}');
                //       context
                //           .read<AstroCalculationBloc>()
                //           .add(CalculatePlanetsPosition(jd: juliDate));
                //     }
                //     if (state is PlanetsPositionCalculated) {
                //       setState(() {
                //         planetPositions = state.planetsPosition;
                //       });
                //       // debugPrint('Error: ${state..planetsPosition.entries}');
                //     }
                //   },
                //   builder: (context, state) {
                //     return _buildCalculatorPlanet(context, juliDate);
                //   },
                // ),
                BlocConsumer<AstroCalculationBloc, AstroCalculationState>(
                  listener: (context, state) {
                    if (state is JulianDateConverted) {
                      setState(() {
                        juliDate = state.julianDate;
                      });

                      //juliDate = state.julianDate.toString();
                      // debugPrint('Julian Date: ${state.julianDate}');
                      //context.read<AstroCalculationBloc>().add(
                      //    CalculatePlanetsPosition(jd: juliDate, et: true));
                    }
                    if (state is PlanetsPositionCalculated) {
                      setState(() {
                        planetPositions = state.planetsPosition;
                      });
                      // debugPrint('Error: ${state..planetsPosition}');
                    }
                    if (state is CompleteCalculation) {
                      setState(() {
                        juliDate = state.julianDate;
                        planetPositions = state.planetsPosition;
                      });
                      // debugPrint('Error: ${state..planetsPosition}');
                    }
                  },
                  builder: (context, state) {
                    return Text(
                      'julianDate : $juliDate',
                      style: TextStyle(color: Colors.white, fontSize: 11.0),
                    );
                  },
                ),

                // Text(
                //   'Planets Position: $planetPositions',
                //   style: TextStyle(color: Colors.white),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildCalculator(BuildContext contex) {
  return BlocBuilder<AstroCalculationBloc, AstroCalculationState>(
    builder: (context, state) {
      return TextButton.icon(
        icon: const Icon(
          Icons.calculate,
          color: Colors.white,
        ),
        label: const Text(
          'Julian Date',
          style: TextStyle(color: Colors.white, fontSize: 11.0),
        ),
        onPressed: () {
          // Navigator.pushNamed(context, '/calculator');
          // context.read<AstroCalculationBloc>().add(ConvertJulianDate(
          //     year: DateTime.now().year,
          //     month: DateTime.now().month,
          //     day: DateTime.now().day,
          //     hour: (DateTime.now().hour +
          //         DateTime.now().minute / 60 +
          //         DateTime.now().second / 3600),
          //     calendarType: CalendarType.SE_GREG_CAL,
          //     et: true));
        },
      );
    },
  );
}

Widget _buildCalculatorPlanet(BuildContext context, double juliDate) {
  return BlocBuilder<AstroCalculationBloc, AstroCalculationState>(
    builder: (context, state) {
      return TextButton.icon(
        icon: const Icon(
          Icons.calculate,
          color: Colors.white,
        ),
        label: const Text(
          'Planet Position',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          // Navigator.pushNamed(context, '/calculator');
          // context
          //     .read<AstroCalculationBloc>()
          //     .add(CalculatePlanetsPosition(jd: juliDate, et: true));
        },
      );
    },
  );
}
