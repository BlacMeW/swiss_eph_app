import 'package:sweph/sweph.dart';
import 'web_helper.dart' if (dart.library.ffi) 'io_helper.dart';
import 'package:flutter/services.dart';

class MySwissLib {
  List<HeavenlyBody> planetIDs = [
    HeavenlyBody.SE_SUN, // Sun
    HeavenlyBody.SE_MOON, // Moon
    HeavenlyBody.SE_MERCURY, // Mercury
    HeavenlyBody.SE_VENUS, // Venus
    HeavenlyBody.SE_MARS, // Mars
    HeavenlyBody.SE_JUPITER, // Jupiter
    HeavenlyBody.SE_SATURN, // Saturn
    HeavenlyBody.SE_URANUS, // Uranus
    HeavenlyBody.SE_NEPTUNE, // Neptune
    HeavenlyBody.SE_PLUTO, // Pluto
  ];
  // Constructor to initialize Sweph with asset files
  MySwissLib();

  // Method to load the necessary assets for Sweph
  Future<void> initSwephData() async {
    // List of assets to load for Sweph initialization
    List<String> epheAssets = [
      'packages/sweph/assets/ephe/seas_18.se1', // For house calculation
      'packages/sweph/assets/ephe/sefstars.txt', // For star positions
      'packages/sweph/assets/ephe/seasnam.txt', // For asteroid names
    ];

    // Initialize Sweph with the provided assets and loader
    await initSweph(epheAssets);
  }

  // Load asset from a specific path
  Future<Uint8List> loadAsset(String assetPath) async {
    try {
      // Load asset as bytes using the Flutter asset loader
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      throw Exception('Error loading asset: $assetPath, $e');
    }
  }

  // Future<String> getMoonPosition() async {
  //   try {
  //     final jd = Sweph.swe_julday(
  //         2022, 6, 29, (2 + 52 / 60), CalendarType.`SE_GREG_CAL);
  //     final pos =
  //         Sweph.swe_calc_ut(jd, HeavenlyBody.SE_MOON, SwephFlag.SEFLG_SWIEPH);
  //     return 'lat=${pos.latitude.toStringAsFixed(3)} lon=${pos.longitude.toStringAsFixed(3)}';
  //   } catch (e) {
  //     return 'Error calculating moon position: $e';
  //   }
  // }

  // Function to calculate the position of a celestial object (e.g., Sun, Moon)
  // Updated getPlanetPosition function
  Future<String> getPlanetPosition(HeavenlyBody planetID, double jd) async {
    try {
      // Example: Calculate the Julian date for the specific date/time
      // final jd = Sweph.swe_julday(2025, 2, 22, 12.0, CalendarType.SE_GREG_CAL);
      // Using the Sweph.swe_calc_ut() method to calculate planet's position
      final position = Sweph.swe_calc_ut(jd, planetID, SwephFlag.SEFLG_SWIEPH);

      return 'Latitude: ${position.latitude.toStringAsFixed(3)},\n'
          'Longitude: ${position.longitude.toStringAsFixed(3)}';
    } catch (e) {
      return 'Error calculating planet position: $e';
    }
  }

  Future<CoordinatesWithSpeed?> getPlanetPositionDouble(
      HeavenlyBody planetID,
      double jd,
      bool et,
      SiderealMode mode,
      SiderealModeFlag flag,
      SwephFlag swephflag) async {
    try {
      // Example: Calculate the Julian date for the specific date/time
      // final jd = Sweph.swe_julday(2025, 2, 22, 12.0, CalendarType.SE_GREG_CAL);
      // Using the Sweph.swe_calc_ut() method to calculate planet's position

      Sweph.swe_set_sid_mode(mode, flag, 0, 0);

      if (!et) {
        final position = Sweph.swe_calc(jd, planetID, swephflag);
        return position;
      } else {
        final deltaT = Sweph.swe_deltat(jd);
        final jdEt = jd + deltaT;

        final position = Sweph.swe_calc(jdEt, planetID, swephflag);
        return position;
      }
    } catch (e) {
      return null;
    }
  }

  // Function to get the star position (e.g., Rohini star position)
  Future<String> getStarPosition(String starName, double jd) async {
    try {
      // final jd = Sweph.swe_julday(2025, 2, 22, 12.0, CalendarType.SE_GREG_CAL);
      final star = Sweph.swe_fixstar2_ut(starName, jd, SwephFlag.SEFLG_SWIEPH);
      return 'Distance of $starName: ${star.coordinates.distance.toStringAsFixed(3)} AU';
    } catch (e) {
      return 'Error calculating star position: $e';
    }
  }

  // Function to get the name of an asteroid
  Future<String> getAsteroidName(int asteroidIndex) async {
    try {
      return Sweph.swe_get_planet_name(
          HeavenlyBody.SE_AST_OFFSET + asteroidIndex);
    } catch (e) {
      return 'Error fetching asteroid name: $e';
    }
  }

  // Function to get house system cusp data
  Future<String> getHouseSystemCusps(double jd) async {
    try {
      // final julday =
      // Sweph.swe_julday(2025, 2, 22, 12.0, CalendarType.SE_GREG_CAL);
      final houseCusps = Sweph.swe_houses(jd, 25.0, 81.0, Hsys.P);
      return 'House Cusps: ${houseCusps.cusps.toString()}';
    } catch (e) {
      return 'Error fetching house cusps: $e';
    }
  }

  Future<String> getVersion() async {
    try {
      return Sweph.swe_version();
    } catch (e) {
      return 'Error fetching version: $e';
    }
  }
}
