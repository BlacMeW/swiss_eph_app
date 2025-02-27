import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sweph/sweph.dart';

import '../../bloc_lib/calculation/astrocalculation_bloc.dart';

// Define a public typedef for the callback
typedef DateSubmitCallback = void Function(
    int year,
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
    SwephFlag flags);

class DateEntryWidget extends StatefulWidget {
  final DateSubmitCallback onSubmit;

  const DateEntryWidget({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<DateEntryWidget> createState() => _DateEntryWidgetState();
}

class _DateEntryWidgetState extends State<DateEntryWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _yearController =
      TextEditingController(text: DateTime.now().year.toString());
  final TextEditingController _monthController =
      TextEditingController(text: DateTime.now().month.toString());
  final TextEditingController _dayController =
      TextEditingController(text: DateTime.now().day.toString());
  final TextEditingController _hourController =
      TextEditingController(text: DateTime.now().hour.toString());
  final TextEditingController _minController =
      TextEditingController(text: DateTime.now().minute.toString());
  final TextEditingController _secController =
      TextEditingController(text: DateTime.now().second.toString());
  // final TextEditingController _latDegController =
  //     TextEditingController(text: 16.0.toString());
  // final TextEditingController _latMinController =
  //     TextEditingController(text: 47.0.toString());
  // final TextEditingController _lonDegController =
  //     TextEditingController(text: 97.0.toString());
  // final TextEditingController _lonMinController =
  //     TextEditingController(text: 30.0.toString());
  // final TextEditingController _timeZoneController =
  // TextEditingController(text: 6.5.toString());

  final TextEditingController _latDegController =
      TextEditingController(text: 13.0.toString());
  final TextEditingController _latMinController =
      TextEditingController(text: 45.0.toString());
  final TextEditingController _lonDegController =
      TextEditingController(text: 100.0.toString());
  final TextEditingController _lonMinController =
      TextEditingController(text: 30.0.toString());
  final TextEditingController _timeZoneController =
      TextEditingController(text: 7.0.toString());

  bool _isUT = true; // Default to ET
  Hsys _houseSystem = Hsys.O;
  SiderealMode _siderealMode = SiderealMode.SE_SIDM_LAHIRI;
  SwephFlag _flags = SwephFlag.SEFLG_SIDEREAL;
  // SwephFlag _flags = SwephFlag.;

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minController.dispose();
    _secController.dispose();
    _latDegController.dispose();
    _latMinController.dispose();
    _lonDegController.dispose();
    _lonMinController.dispose();
    _timeZoneController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType keyboardType, String? Function(String?) validator) {
    return TextFormField(
      style: TextStyle(fontSize: 11.0),
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d*$')), // Only numbers & decimal point
      ],
    );
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final int year =
          int.tryParse(_yearController.text) ?? DateTime.now().year;
      final int month =
          int.tryParse(_monthController.text) ?? DateTime.now().month;
      final int day = int.tryParse(_dayController.text) ?? DateTime.now().day;
      final int hour = int.tryParse(_hourController.text) ?? 0;
      final int min = int.tryParse(_minController.text) ?? 0;
      final int sec = int.tryParse(_secController.text) ?? 0;

      final double latDeg = double.tryParse(_latDegController.text) ?? 0.0;
      final double latMin = double.tryParse(_latMinController.text) ?? 0.0;
      final double lonDeg = double.tryParse(_lonDegController.text) ?? 0.0;
      final double lonMin = double.tryParse(_lonMinController.text) ?? 0.0;
      final double timeZone = double.tryParse(_timeZoneController.text) ?? 0.0;

      context.read<AstroCalculationBloc>().add(
            AstroCalculation(
                year: year,
                month: month,
                day: day,
                hour: (hour + min / 60 + sec / 3600),
                calendarType: CalendarType.SE_GREG_CAL,
                timezone: timeZone,
                et: _isUT,
                latitude: latDeg + (latMin / 60.0),
                longitude: lonDeg + (lonMin / 60.0),
                houseSystem: _houseSystem,
                siderealMode: _siderealMode,
                flag: _flags | SwephFlag.SEFLG_SPEED3),
          );
      //debugPrint("Submit");
      widget.onSubmit(year, month, day, hour, min, sec, _isUT, latDeg, latMin,
          lonDeg, lonMin, timeZone, _houseSystem, _siderealMode, _flags);
    }
  }

  void _setCurrentDate() {
    DateTime now = DateTime.now();
    setState(() {
      _yearController.text = now.year.toString();
      _monthController.text = now.month.toString();
      _dayController.text = now.day.toString();
      _hourController.text = now.hour.toString();
      _minController.text = now.minute.toString();
      _secController.text = now.second.toString();
    });
    _submitData();

    // context.read<AstroCalculationBloc>().add(ConvertJulianDate(
    //       year: now.year,
    //       month: now.month,
    //       day: now.day,
    //       hour: now.hour + now.minute / 60 + now.second / 3600,
    //       calendarType: CalendarType.SE_GREG_CAL,
    //       et: _isUT,
    //     ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Year & Month Row
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          'Year',
                          _yearController,
                          TextInputType.number,
                          (value) => value!.isEmpty ? 'Enter year' : null)),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      style: TextStyle(fontSize: 12, color: Colors.black),

                      // isExpanded: true,
                      value: _monthController.text.isEmpty
                          ? null
                          : int.tryParse(_monthController.text),
                      items: List.generate(
                          12,
                          (index) => DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text(
                                    '${index + 1} - ${[
                                      'Jan',
                                      'Feb',
                                      'Mar',
                                      'Apr',
                                      'May',
                                      'Jun',
                                      'Jul',
                                      'Aug',
                                      'Sep',
                                      'Oct',
                                      'Nov',
                                      'Dec'
                                    ][index]}',
                                    style: TextStyle(fontSize: 11.0)),
                              )),
                      onChanged: (value) => setState(
                          () => _monthController.text = value.toString()),
                      decoration: InputDecoration(labelText: 'Month'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          'Day',
                          _dayController,
                          TextInputType.number,
                          (value) => value!.isEmpty ? 'Enter day' : null)),
                ],
              ),

              // Day & Hour Row
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          'Hour',
                          _hourController,
                          TextInputType.number,
                          (value) => value!.isEmpty ? 'Enter hour' : null)),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          'Min',
                          _minController,
                          TextInputType.number,
                          (value) => value!.isEmpty ? 'Enter minutes' : null)),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          'Sec',
                          _secController,
                          TextInputType.number,
                          (value) => value!.isEmpty ? 'Enter seconds' : null)),
                ],
              ),

              // Latitude & Longitude Input
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(
                          'Lat Deg',
                          _latDegController,
                          TextInputType.number,
                          (value) =>
                              value!.isEmpty ? 'Enter latitude degree' : null)),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          'Lat Min',
                          _latMinController,
                          TextInputType.number,
                          (value) =>
                              value!.isEmpty ? 'Enter latitude minute' : null)),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          'Lon Deg',
                          _lonDegController,
                          TextInputType.number,
                          (value) => value!.isEmpty
                              ? 'Enter longitude degree'
                              : null)),
                  SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(
                          'Lon Min',
                          _lonMinController,
                          TextInputType.number,
                          (value) => value!.isEmpty
                              ? 'Enter longitude minute'
                              : null)),
                ],
              ),

              Row(children: [
                Expanded(
                  flex: 1,
                  child: // Timezone Input
                      _buildTextField(
                          'TimeZone ',
                          _timeZoneController,
                          TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          (value) => value!.isEmpty ? 'timezone' : null),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: // UT / ET Selection
                      DropdownButtonFormField<bool>(
                    value: _isUT,
                    items: [
                      DropdownMenuItem(
                          value: false,
                          child: Text('Universal(UT)',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: true,
                          child: Text('Ephemeris(ET)',
                              style: TextStyle(fontSize: 11.0))),
                    ],
                    onChanged: (value) => setState(() => _isUT = value!),
                    decoration: InputDecoration(labelText: 'Time Type'),
                  ),
                ),
              ]),
              Row(children: [
                Expanded(
                  flex: 1,
                  child: // UT / ET Selection
                      DropdownButtonFormField<Hsys>(
                    value: _houseSystem,
                    items: [
                      DropdownMenuItem(
                          value: Hsys.B,
                          child: Text(' Alcabitus',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.Y,
                          child: Text('APC houses',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.X,
                          child: Text(
                              'Axial rotation system / Meridian system / Zariel',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.H,
                          child: Text('Azimuthal or horizontal system',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.C,
                          child: Text('Campanus',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.F,
                          child: Text('Carter "Poli-Equatorial"',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.A,
                          child: Text('Equal (cusp 1 is Ascendant)',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.E,
                          child: Text('Equal (cusp 1 is Ascendant)',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.D,
                          child: Text('Equal MC (cusp 10 is MC)',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.N,
                          child: Text('Equal/1=Aries',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.G,
                          child: Text('Gauquelin sector',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.I,
                          child: Text('Sunshine (Makransky, solution Treindl)',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.H,
                          child: Text('Azimuthal or horizontal system',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.K,
                          child:
                              Text('Koch', style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.U,
                          child: Text('Krusinski-Pisa-Goelzer',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.M,
                          child: Text('Morinus',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.P,
                          child: Text('Placidus',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.T,
                          child: Text('Polich/Page (topocentric system)',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.O,
                          child: Text('Porphyrius',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.L,
                          child: Text(
                              'Pullen SD (sinusoidal delta) – ex Neo-Porphyry',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.Q,
                          child: Text('ullen SR (sinusoidal ratio)',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.R,
                          child: Text('Regiomontanus',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.S,
                          child: Text('Sripati',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.V,
                          child: Text(
                              'Vehlow equal (Asc. in middle of house 1)',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: Hsys.W,
                          child: Text('Whole sign',
                              style: TextStyle(fontSize: 11.0))),
                    ],
                    onChanged: (value) => setState(() => _houseSystem = value!),
                    decoration: InputDecoration(labelText: 'House System'),
                  ),
                ),
              ]),
              Row(children: [
                Expanded(
                  flex: 1,
                  child: // UT / ET Selection
                      DropdownButtonFormField<SiderealMode>(
                    value: _siderealMode,
                    items: [
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_FAGAN_BRADLEY,
                          child: Text('SE_SIDM_FAGAN_BRADLEY',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_LAHIRI,
                          child: Text('SE_SIDM_LAHIRI',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_DELUCE,
                          child: Text('SE_SIDM_DELUCE',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_RAMAN,
                          child: Text('SE_SIDM_RAMAN',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_USHASHASHI,
                          child: Text('SE_SIDM_USHASHASHI',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_KRISHNAMURTI,
                          child: Text('SE_SIDM_KRISHNAMURTI',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_DJWHAL_KHUL,
                          child: Text('SE_SIDM_DJWHAL_KHUL',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_YUKTESHWAR,
                          child: Text('SE_SIDM_YUKTESHWAR',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_JN_BHASIN,
                          child: Text('SE_SIDM_JN_BHASIN',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_BABYL_KUGLER1,
                          child: Text('SE_SIDM_BABYL_KUGLER1',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_BABYL_KUGLER2,
                          child: Text('SE_SIDM_BABYL_KUGLER2',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_BABYL_KUGLER3,
                          child: Text('SE_SIDM_BABYL_KUGLER3',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_BABYL_HUBER,
                          child: Text('SE_SIDM_FAGAN_BRADLEY',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_BABYL_ETPSC,
                          child: Text('SE_SIDM_BABYL_ETPSC',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_ALDEBARAN_15TAU,
                          child: Text('SE_SIDM_ALDEBARAN_15TAU',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_HIPPARCHOS,
                          child: Text('SE_SIDM_HIPPARCHOS',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_SASSANIAN,
                          child: Text('SE_SIDM_SASSANIAN',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_GALCENT_0SAG,
                          child: Text('SE_SIDM_GALCENT_0SAG',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_J2000,
                          child: Text('SE_SIDM_J2000',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_J1900,
                          child: Text('SE_SIDM_J1900',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_B1950,
                          child: Text('SE_SIDM_B1950',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_SURYASIDDHANTA,
                          child: Text('SE_SIDM_SURYASIDDHANTA',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_SURYASIDDHANTA_MSUN,
                          child: Text('SE_SIDM_SURYASIDDHANTA_MSUN',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_ARYABHATA,
                          child: Text('SE_SIDM_ARYABHATA',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_ARYABHATA_MSUN,
                          child: Text('SE_SIDM_ARYABHATA_MSUN',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_SS_REVATI,
                          child: Text('SE_SIDM_SS_REVATI',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_SS_CITRA,
                          child: Text('SE_SIDM_SS_CITRA',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_TRUE_CITRA,
                          child: Text('SE_SIDM_TRUE_CITRA',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_TRUE_REVATI,
                          child: Text('SE_SIDM_TRUE_REVATI',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_TRUE_PUSHYA,
                          child: Text('SE_SIDM_TRUE_PUSHYA',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_GALCENT_RGILBRAND,
                          child: Text('SE_SIDM_GALCENT_RGILBRAND',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_GALEQU_IAU1958,
                          child: Text('SE_SIDM_GALEQU_IAU1958',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_GALEQU_TRUE,
                          child: Text('SE_SIDM_GALEQU_TRUE',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_GALEQU_MULA,
                          child: Text('SE_SIDM_GALEQU_MULA',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_GALALIGN_MARDYKS,
                          child: Text('SE_SIDM_GALALIGN_MARDYKS',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_TRUE_MULA,
                          child: Text('SE_SIDM_TRUE_MULA',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_GALCENT_MULA_WILHELM,
                          child: Text('SE_SIDM_GALCENT_MULA_WILHELM',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_ARYABHATA_522,
                          child: Text('SE_SIDM_ARYABHATA_522',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_BABYL_BRITTON,
                          child: Text('SE_SIDM_BABYL_BRITTON',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_TRUE_SHEORAN,
                          child: Text('SE_SIDM_TRUE_SHEORAN',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_GALCENT_COCHRANE,
                          child: Text('SE_SIDM_GALCENT_COCHRANE',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_GALEQU_FIORENZA,
                          child: Text('SE_SIDM_GALEQU_FIORENZA',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_VALENS_MOON,
                          child: Text('SE_SIDM_VALENS_MOON',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_LAHIRI_1940,
                          child: Text('SE_SIDM_LAHIRI_1940',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_LAHIRI_VP285,
                          child: Text('SE_SIDM_LAHIRI_VP285',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_KRISHNAMURTI_VP291,
                          child: Text('SE_SIDM_KRISHNAMURTI_VP291',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SiderealMode.SE_SIDM_LAHIRI_ICRC,
                          child: Text('SE_SIDM_LAHIRI_ICRC',
                              style: TextStyle(fontSize: 11.0))),
                    ],
                    onChanged: (value) =>
                        setState(() => _siderealMode = value!),
                    decoration: InputDecoration(labelText: 'Sidereal Mode'),
                  ),
                ),
              ]),
              SizedBox(height: 16),
              Row(children: [
                Expanded(
                  flex: 3,
                  child: // UT / ET Selection
                      DropdownButtonFormField<SwephFlag>(
                    value: _flags,
                    items: [
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_ASTROMETRIC,
                          child: Text('SEFLG_ASTROMETRIC',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_BARYCTR,
                          child: Text('SEFLG_BARYCTR',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_CENTER_BODY,
                          child: Text('SEFLG_CENTER_BODY',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_DPSIDEPS_1980,
                          child: Text('SEFLG_DPSIDEPS_1980',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_EQUATORIAL,
                          child: Text('SEFLG_EQUATORIAL',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_HELCTR,
                          child: Text('SEFLG_HELCTR',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_ICRS,
                          child: Text('SEFLG_ICRS',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_J2000,
                          child: Text('SEFLG_J2000',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_JPLEPH,
                          child: Text('SEFLG_JPLEPH',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_JPLHOR,
                          child: Text('SEFLG_JPLHOR',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_JPLHOR_APPROX,
                          child: Text('SEFLG_JPLHOR_APPROX',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_MOSEPH,
                          child: Text('SEFLG_MOSEPH',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_NOABERR,
                          child: Text('SEFLG_NOABERR',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_NOGDEFL,
                          child: Text('SEFLG_NOGDEFL',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_NONUT,
                          child: Text('SEFLG_NONUT',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_ORBEL_AA,
                          child: Text('SEFLG_ORBEL_AA',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_RADIANS,
                          child: Text('SEFLG_RADIANS',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_SIDEREAL,
                          child: Text('SEFLG_SIDEREAL',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_SWIEPH,
                          child: Text('SEFLG_SWIEPH',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_TOPOCTR,
                          child: Text('SEFLG_TOPOCTR',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_TROPICAL,
                          child: Text('SEFLG_TROPICAL',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_TRUEPOS,
                          child: Text('SEFLG_TRUEPOS',
                              style: TextStyle(fontSize: 11.0))),
                      DropdownMenuItem(
                          value: SwephFlag.SEFLG_XYZ,
                          child: Text('SEFLG_XYZ',
                              style: TextStyle(fontSize: 11.0))),
                    ],
                    onChanged: (value) => setState(() => _flags = value!),
                    decoration: InputDecoration(labelText: 'Sidereal Flag'),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Row(
                //     children: [
                //       Checkbox(
                //         semanticLabel: 'Speed',
                //         value: _isSpeed,
                //         onChanged: (bool? value) {
                //           setState(() {
                //             _isSpeed = value ?? false;
                //             // _flags = _flags & SwephFlag.SEFLG_SPEED;
                //             if (_isSpeed) {
                //               _flags = _flags | SwephFlag.SEFLG_SPEED;
                //             }
                //           });
                //         },
                //       ),
                //       Text('Speed'), // Label for Checkbox
                //     ],
                //   ),
                // ),
              ]),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                      onPressed: _setCurrentDate, child: Text('NOW')),
                  SizedBox(width: 16),
                  ElevatedButton(onPressed: _submitData, child: Text('Submit')),
                ],
              ),
            ]),
      ),
    );
  }
}



// enum Hsys {
//   B(66), // Alcabitus
//   Y(59), // APC houses
//   X(58), // Axial rotation system / Meridian system / Zariel
//   H(72), // Azimuthal or horizontal system
//   C(67), // Campanus
//   F(70), // Carter "Poli-Equatorial"
//   A(65), // Equal (cusp 1 is Ascendant)
//   E(69), // Equal (cusp 1 is Ascendant)
//   D(68), // Equal MC (cusp 10 is MC)
//   N(78), // Equal/1=Aries
//   G(71), // Gauquelin sector
//   //          Goelzer -> Krusinski
//   //          Horizontal system -> Azimuthal system
//   I(73), // Sunshine (Makransky, solution Treindl)
//   i(105), // Sunshine (Makransky, solution Makransky)
//   K(75), // Koch
//   U(85), // Krusinski-Pisa-Goelzer
//   //          Meridian system -> axial rotation
//   M(77), // Morinus
//   //          Neo-Porphyry -> Pullen SD
//   //          Pisa -> Krusinski
//   P(80), // Placidus
//   //          Poli-Equatorial -> Carter
//   T(84), // Polich/Page (topocentric system)
//   O(79), // Porphyrius
//   L(76), // Pullen SD (sinusoidal delta) – ex Neo-Porphyry
//   Q(81), // Pullen SR (sinusoidal ratio)
//   R(82), // Regiomontanus
//   S(83), // Sripati
//   //          Topocentric system -> Polich/Page
//   V(86), // Vehlow equal (Asc. in middle of house 1)
//   W(87); // Whole sign
//   //          Zariel -> Axial rotation system

//   const Hsys(this.value);
//   final int value;
// }