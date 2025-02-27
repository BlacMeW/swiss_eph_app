import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweph/sweph.dart';

// import 'package:swiss_eph/lib/flutter-birth-chart/src/chart/chart_data.dart';
import '../../swiss_lib/myswiss_lib.dart';

class ChartHouse {
  ChartHouse({
    required this.position,
    this.name,
  });

  final double position;
  final String? name;
}

class ChartPlanet {
  ChartPlanet({
    required this.position,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.sign,
    this.name,
  });

  final double position;
  final double latitude;
  final double longitude;
  final double speed;
  final String sign;
  final String? name;
}

// Event
abstract class AstroCalculationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ConvertJulianDate extends AstroCalculationEvent {
  final int day, month, year;
  final double hour;
  final CalendarType calendarType;
  final double timeZone;
  final bool et;

  ConvertJulianDate({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.calendarType,
    required this.timeZone,
    required this.et,
  });

  @override
  List<Object> get props =>
      [year, month, day, hour, calendarType, timeZone, et];
}

class CalculatePlanetsPosition extends AstroCalculationEvent {
  final double jd;
  final bool et;
  CalculatePlanetsPosition({required this.jd, required this.et});

  @override
  List<Object> get props => [jd, et];
}

class HouseCalculation extends AstroCalculationEvent {
  final double jd;
  // final HouseCuspData houseCuspData;
  final double latitude;
  final double longitude;
  final Hsys houseSystem;

  HouseCalculation(
      {
      // required this.houseCuspData,
      required this.latitude,
      required this.longitude,
      required this.houseSystem,
      required this.jd});

  @override
  List<Object> get props => [latitude, longitude, houseSystem, jd];
}

class AstroCalculation extends AstroCalculationEvent {
  final int day, month, year;
  final double hour;
  final CalendarType calendarType;
  final double timezone;
  final bool et;
  // final HouseCuspData houseCuspData;
  final double latitude;
  final double longitude;
  final Hsys houseSystem;
  final SiderealMode siderealMode;
  final SwephFlag flag;

  AstroCalculation(
      {required this.year,
      required this.month,
      required this.day,
      required this.hour,
      required this.calendarType,
      required this.timezone,
      required this.et,
      required this.latitude,
      required this.longitude,
      required this.houseSystem,
      required this.siderealMode,
      required this.flag});

  @override
  List<Object> get props => [
        year,
        month,
        day,
        hour,
        calendarType,
        timezone,
        et,
        latitude,
        longitude,
        houseSystem,
        siderealMode,
        flag
      ];
}

// State
abstract class AstroCalculationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AstroCalculationInitial extends AstroCalculationState {}

class JulianDateConverted extends AstroCalculationState {
  final double julianDate;
  final bool et;

  JulianDateConverted({required this.julianDate, required this.et});

  @override
  List<Object> get props => [julianDate, et];
}

class PlanetsPositionCalculated extends AstroCalculationState {
  final Map<String, CoordinatesWithSpeed> planetsPosition;
  final List<ChartPlanet> planets;
  final double julianDate;

  PlanetsPositionCalculated(
      {required this.planetsPosition,
      required this.planets,
      required this.julianDate});

  @override
  List<Object> get props => [planetsPosition, planets, julianDate];
}

class HouseCalculated extends AstroCalculationState {
  final HouseCuspData houseCuspData;
  final List<ChartHouse> houses;
  final double julianDate;

  HouseCalculated(
      {required this.houseCuspData,
      required this.houses,
      required this.julianDate});

  @override
  List<Object> get props => [houseCuspData, houses, julianDate];
}

class CompleteCalculation extends AstroCalculationState {
  final Map<String, CoordinatesWithSpeed> planetsPosition;
  final List<ChartPlanet> planets;
  final HouseCuspData houseCuspData;
  final List<ChartHouse> houses;
  final double julianDate;
  final double ayanasa;

  CompleteCalculation(
      {required this.planetsPosition,
      required this.planets,
      required this.houseCuspData,
      required this.houses,
      required this.julianDate,
      required this.ayanasa});

  @override
  List<Object> get props =>
      [planetsPosition, planets, houseCuspData, houses, julianDate, ayanasa];
}

class AstroCalculationError extends AstroCalculationState {
  final String message;

  AstroCalculationError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class AstroCalculationBloc
    extends Bloc<AstroCalculationEvent, AstroCalculationState> {
  AstroCalculationBloc() : super(AstroCalculationInitial()) {
    on<ConvertJulianDate>((event, emit) {
      try {
        final jd = Sweph.swe_julday(
          event.year,
          event.month,
          event.day,
          event.hour - event.timeZone,
          event.calendarType,
        );
        // debugPrint("Julian Date: $jd   ${event.et}");

        emit(JulianDateConverted(julianDate: jd, et: event.et));
        // CalculatePlanetsPosition(jd: jd, et: event.et);
      } catch (e) {
        emit(
            AstroCalculationError(message: "Error converting Julian date: $e"));
      }
    });

    on<CalculatePlanetsPosition>((event, emit) async {
      try {
        final Map<HeavenlyBody, String> planetsName = {
          HeavenlyBody.SE_SUN: "☀️", // Sun
          HeavenlyBody.SE_MOON: "🌙", // Moon
          HeavenlyBody.SE_MERCURY: "☿️", // Mercury
          HeavenlyBody.SE_VENUS: "♀️", // Venus
          HeavenlyBody.SE_MARS: "♂️", // Mars
          HeavenlyBody.SE_JUPITER: "♃", // Jupiter
          HeavenlyBody.SE_SATURN: "♄", // Saturn
          HeavenlyBody.SE_URANUS: "♅", // Uranus
          HeavenlyBody.SE_NEPTUNE: "♆", // Neptune
          HeavenlyBody.SE_PLUTO: "♇", // Pluto
        };
        List<HeavenlyBody> planetIDs = [
          HeavenlyBody.SE_SUN,
          HeavenlyBody.SE_MOON,
          HeavenlyBody.SE_MERCURY,
          HeavenlyBody.SE_VENUS,
          HeavenlyBody.SE_MARS,
          HeavenlyBody.SE_JUPITER,
          HeavenlyBody.SE_SATURN,
          HeavenlyBody.SE_URANUS,
          HeavenlyBody.SE_NEPTUNE,
          HeavenlyBody.SE_PLUTO
        ];
        // Load the planet positions dynamically
        Map<String, CoordinatesWithSpeed> updatedPlanetPositions = {};
        List<ChartPlanet> planetsC = [];
        MySwissLib swissLib = MySwissLib();
        for (HeavenlyBody id in planetIDs) {
          CoordinatesWithSpeed? angle = await swissLib.getPlanetPositionDouble(
              id,
              event.jd,
              event.et,
              SiderealMode.SE_SIDM_LAHIRI,
              SiderealModeFlag.SE_SIDBIT_SSY_PLANE,
              SwephFlag.SEFLG_SIDEREAL |
                  SwephFlag.SEFLG_SPEED); // Get the planet's position
          String planetName = planetsName[id] ?? '';
          // debugPrint("Planet: $planetName, Angle: $angle");

          planetsC.add(ChartPlanet(
              name: planetName,
              position: angle!.longitude,
              latitude: angle.latitude,
              longitude: angle.longitude,
              speed: angle.speedInLongitude,
              sign: planetName));

          // debugPrint("Planet: $planetName, Angle: $angle");

          updatedPlanetPositions[planetName] =
              angle; // Add planet name and angle to the map
        }
        // debugPrint("Planets =>  ${planetsC[0].name} $updatedPlanetPositions");
        // debugPrint("Planets Position Calculated: $updatedPlanetPositions");
        emit(PlanetsPositionCalculated(
            planetsPosition: updatedPlanetPositions,
            planets: planetsC,
            julianDate: event.jd));
      } catch (e) {
        emit(AstroCalculationError(
            message: "Error calculating planet positions: $e"));
      }
    });

    on<HouseCalculation>((event, emit) async {
      List<ChartHouse> housesCalc = [];
      try {
        HouseCuspData houseCuspData = Sweph.swe_houses(
          event.jd,
          event.longitude,
          event.latitude,
          event.houseSystem,
        );
        final List<String> HousesName = [
          "House 1",
          "House 2",
          "House 3",
          "House 4",
          "House 5",
          "House 6",
          "House 7",
          "House 8",
          "House 9",
          "House 10",
          "House 11",
          "House 12"
        ];
        // debugPrint("House Cusp Data: $houseCuspData");
        for (int i = 0; i < 12; i++) {
          housesCalc.add(ChartHouse(
              name: HousesName[i],
              // position: 210.0 - houseCuspData.cusps[i]
              position: houseCuspData.cusps[i]));
          // debugPrint(
          // "House: ${HousesName[i]}, Angle: ${houseCuspData.cusps[i]}");
        }

        emit(HouseCalculated(
            houseCuspData: houseCuspData,
            houses: housesCalc,
            julianDate: event.jd));
      } catch (e) {
        emit(
            AstroCalculationError(message: "Error calculating house cusp: $e"));
      }
    });

    on<AstroCalculation>((event, emit) async {
      // debugPrint("Submit AstroCalculation");
      Sweph.swe_set_sid_mode(
          event.siderealMode, SiderealModeFlag.SE_SIDBIT_NONE, 0, 0);
      List<ChartHouse> housesCalc = [];
      HouseCuspData houseCuspData = HouseCuspData([], []);

      final jd = Sweph.swe_julday(
        event.year,
        event.month,
        event.day,
        event.hour - event.timezone, // - event.timezone,
        event.calendarType,
      );
      try {
        final Map<HeavenlyBody, String> planetsName = {
          HeavenlyBody.SE_SUN: "☀️", // Sun
          HeavenlyBody.SE_MOON: "🌙", // Moon
          HeavenlyBody.SE_MERCURY: "☿️", // Mercury
          HeavenlyBody.SE_VENUS: "♀️", // Venus
          HeavenlyBody.SE_MARS: "♂️", // Mars
          HeavenlyBody.SE_JUPITER: "♃", // Jupiter
          HeavenlyBody.SE_SATURN: "♄", // Saturn
          HeavenlyBody.SE_URANUS: "♅", // Uranus
          HeavenlyBody.SE_NEPTUNE: "♆", // Neptune
          HeavenlyBody.SE_PLUTO: "♇", // Pluto
        };
        List<HeavenlyBody> planetIDs = [
          HeavenlyBody.SE_SUN,
          HeavenlyBody.SE_MOON,
          HeavenlyBody.SE_MERCURY,
          HeavenlyBody.SE_VENUS,
          HeavenlyBody.SE_MARS,
          HeavenlyBody.SE_JUPITER,
          HeavenlyBody.SE_SATURN,
          HeavenlyBody.SE_URANUS,
          HeavenlyBody.SE_NEPTUNE,
          HeavenlyBody.SE_PLUTO
        ];
        Map<String, CoordinatesWithSpeed> updatedPlanetPositions = {};
        List<ChartPlanet> planetsC = [];
        MySwissLib swissLib = MySwissLib();
        await swissLib.initSwephData();
        for (HeavenlyBody id in planetIDs) {
          CoordinatesWithSpeed? angle = await swissLib.getPlanetPositionDouble(
              id,
              jd,
              event.et,
              event.siderealMode,
              SiderealModeFlag.SE_SIDBIT_NONE,
              event.flag); // Get the planet's position

          String planetName = planetsName[id] ?? '';
          // debugPrint("Planet: $planetName, Angle: $angle");

          double angleC = angle!.longitude;
          // double angleC = angle!.longitude;
          if (angleC < 0) {
            angleC = angleC + 360.0;
          } else if (angleC > 360) {
            angleC = angleC - 360.0;
          }
          planetsC.add(ChartPlanet(
              name: planetName,
              position: angleC,
              latitude: angle.latitude,
              longitude: angle.longitude,
              speed: angle.speedInLongitude,
              sign: planetName));

          // debugPrint("Planet: $planetName, Angle: $angle");

          updatedPlanetPositions[planetName] =
              angle; // Add planet name and angle to the map
        }
        // debugPrint("Submit AstroCalculation Finished");
        // Sweph.swe_houses_armc(armc, geoLat, eps, hSys)
        // Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI_VP285,
        //     SiderealModeFlag.SE_SIDBIT_USER_UT, 0, 0);
        Sweph.swe_set_sid_mode(
            event.siderealMode, SiderealModeFlag.SE_SIDBIT_NONE, 0, 0);
        // HouseCuspData houseCuspData = Sweph.swe_houses(
        //   jd,
        //   event.longitude,
        //   event.latitude,
        //   event.houseSystem,
        // );

        // HouseCuspData houseCuspData = Sweph.swe_houses_ex2(
        //   Sweph.swe_julday(event.year, event.month, event.day, event.hour,
        //       event.calendarType),
        //   SwephFlag.SEFLG_SIDEREAL,
        //   30,
        //   60,
        //   Hsys.O,
        // );
        houseCuspData = Sweph.swe_houses_ex2(
          Sweph.swe_julday(event.year, event.month, event.day,
              event.hour - event.timezone, event.calendarType),
          event.flag,
          event.latitude,
          event.longitude,
          event.houseSystem,
        );
        // debugPrint("Hour ${event.hour - event.timezone}");
        // HouseCuspData houseCuspData = Sweph.swe_houses(
        //   Sweph.swe_julday(event.year, event.month, event.day, event.hour,
        //       event.calendarType),
        //   // SwephFlag.SEFLG_SIDEREAL,
        //   30,
        //   60,
        //   Hsys.P,
        // );

        final List<String> HousesName = [
          "",
          "House 1",
          "House 2",
          "House 3",
          "House 4",
          "House 5",
          "House 6",
          "House 7",
          "House 8",
          "House 9",
          "House 10",
          "House 11",
          "House 12"
        ];
        // debugPrint(
        // "House Cusp Data: $houseCuspData ${houseCuspData.cusps.length}");
        double angle = 0.0;
        double ayanasa = Sweph.swe_get_ayanamsa(jd);

        // debugPrint("House: ${HousesName[i]}, Angle: $angle");
        housesCalc.clear();
        for (int i = 1; i < 13; i++) {
          // angle = 210.0 - houseCuspData.cusps[i];
          angle = houseCuspData.cusps[i];
          //-ayanasa;
          // -ayanasa;
          if (angle < 0) {
            angle = angle + 360.0;
          } else if (angle > 360) {
            angle = angle - 360.0;
          }
          housesCalc.add(ChartHouse(name: HousesName[i], position: angle));
          // debugPrint(
          // "House: ${HousesName[i]}, Angle: ${houseCuspData.cusps[i]}");
        }
        // for (int i = 0; i < 12; i++) {}

        // debugPrint("Submit AstroCalculation Finished");
        // debugPrint("Submit AstroCalculation Finished");
        emit(CompleteCalculation(
          planetsPosition: updatedPlanetPositions,
          planets: planetsC,
          houseCuspData: houseCuspData,
          houses: housesCalc,
          julianDate: jd,
          ayanasa: ayanasa,
        ));
        // debugPrint("CompleteCalculation");
        // emit(JulianDateConverted(julianDate: jd, et: event.et));
        // // debugPrint("JulianDateConverted");
        // emit(PlanetsPositionCalculated(
        //     planetsPosition: updatedPlanetPositions,
        //     planets: planetsC,
        //     julianDate: jd));
        // // debugPrint("PlanetsPositionCalculated");
        // emit(HouseCalculated(
        //     houseCuspData: houseCuspData, houses: housesCalc, julianDate: jd));
        // debugPrint("HouseCalculated");
      } catch (e) {
        emit(
            AstroCalculationError(message: "Error calculating house cusp: $e"));
      }
    });
  }

  String planetName(int planetId) {
    switch (planetId) {
      case HeavenlyBody.SE_SUN:
        return "Sun";
      case HeavenlyBody.SE_MOON:
        return "Moon";
      case HeavenlyBody.SE_MERCURY:
        return "Mercury";
      case HeavenlyBody.SE_VENUS:
        return "Venus";
      case HeavenlyBody.SE_MARS:
        return "Mars";
      case HeavenlyBody.SE_JUPITER:
        return "Jupiter";
      case HeavenlyBody.SE_SATURN:
        return "Saturn";
      case HeavenlyBody.SE_URANUS:
        return "Uranus";
      case HeavenlyBody.SE_NEPTUNE:
        return "Neptune";
      case HeavenlyBody.SE_PLUTO:
        return "Pluto";
      default:
        return "Unknown";
    }
  }
}
