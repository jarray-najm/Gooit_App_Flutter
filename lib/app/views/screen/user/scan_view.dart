import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/common/app_colors.dart';
import '../../../../utils/common/loading_overlay.dart';
import '../../../controllers/user_controller.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  final UserController _userController = UserController();
//! ----------------------------------------------------------------
//! ----------------------------------------------------------------
//! ----------------------------------------------------------------
  bool _dataFetched = false;
  List<dynamic> _lines = [];
  dynamic _selectedLine; // To store the selected line for payment

  Future<void> _getData() async {
    if (result?.code != null) {
      int lineNumber = int.parse(
          result!.code!); // Safe parsing as we ensured result.code is not null
      print(result!.code!);
      print(result!.code);
      print(result!.code);

      LoadingScreen.instance()
          .show(context: context, text: "scanning QrCode...");

      try {
        final lines = await _userController.getLinesByNumber(lineNumber);
        print(lines);
        if (lines.isEmpty) {
          print('No lines found with the given number: invalid QrCode');
          await Future.delayed(const Duration(seconds: 1));
          LoadingScreen.instance().hide();

          LoadingScreen.instance()
              .show(context: context, text: "invalid QrCode");
          await Future.delayed(const Duration(seconds: 1));
          LoadingScreen.instance().hide();
        } else {
          setState(() {
            _lines = lines;
            _dataFetched = true;
          });
          LoadingScreen.instance()
              .show(context: context, text: "data fetched successfully");
          await Future.delayed(const Duration(milliseconds: 250));
          LoadingScreen.instance().hide();
        }
      } catch (error) {
        setState(() {
          _dataFetched = false;
        });
        print('Error: $error');
        print('Failed to fetch lines.');
      }
    } else {
      // Handle the case where result.code is null
      print('Error: result.code is null');
      LoadingScreen.instance().show(context: context, text: "invalid QrCode");
      await Future.delayed(const Duration(seconds: 1));
      LoadingScreen.instance().hide();
    }
  }

  Future<void> _deductPayment() async {
    LoadingScreen.instance()
        .show(context: context, text: "checking payment ...");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('userID');
    if (userID == null) {
      print('User ID not found in SharedPreferences');
      return; // Exit function early or handle differently as per your app's logic
    }

    try {
      double totalAmount = 0.0;

      // Calculate total amount from _lines
      for (var line in _lines) {
        totalAmount += line['line_price'].toDouble();
      }

      // Call UserController to deduct payment
      final response = await _userController.deductPayment(userID, totalAmount);
      await Future.delayed(const Duration(seconds: 1));

      // Parse the response JSON
      final jsonResponse = json.decode(response);

      // Check if there's an error field
      if (jsonResponse.containsKey('error')) {
        print('Insufficient balance');
        LoadingScreen.instance().hide();
        LoadingScreen.instance()
            .show(context: context, text: "Insufficient balance");
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();
        // Optionally update UI or show error message
      } else if (jsonResponse.containsKey('message') &&
          jsonResponse['message'] ==
              'Payment deducted and recorded successfully!') {
        LoadingScreen.instance().hide();
        LoadingScreen.instance().show(
            context: context,
            text: "Payment deducted and recorded successfully!");
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();
        LoadingScreen.instance()
            .show(context: context, text: "adding trip ...");

        await _addTrips();
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();
        LoadingScreen.instance()
            .show(context: context, text: "Adding successfully");
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();
        // Optionally update UI or show success message
      } else {
        print('Unknown response: $response');
        LoadingScreen.instance().hide();
        LoadingScreen.instance().show(context: context, text: response);
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();
        // Handle unexpected response
      }
    } catch (error) {
      LoadingScreen.instance().hide();
      LoadingScreen.instance().show(context: context, text: "$error");
      await Future.delayed(const Duration(seconds: 1));
      LoadingScreen.instance().hide();
    }
  }

  Future<void> _addTrips() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('userID');

    if (userID == null) {
      // Handle case where userID is null
      print('User ID not found in SharedPreferences');
      return; // Exit function early or handle differently as per your app's logic
    }

    try {
      for (var line in _lines) {
        // Example: Convert line_stations_json to List<Map<String, dynamic>>
        List<Map<String, dynamic>> tripStations =
            List<Map<String, dynamic>>.from(
          line['line_stations_json'] ?? [],
        );

        // Example of adding a trip for the current line
        await _userController.addTrips(
          userId: userID,
          tripName:
              line['line_name'], // Use line details to populate trip details
          tripNumber: line['line_number'],
          tripPrice: line['line_price'].toDouble(),
          startTime: line['start_time'],
          tripStationsJson: tripStations,
        );

        // Optionally handle success for each trip added
        print('Trip added successfully for Line ID: ${line['id']}');
      }

      // Optionally handle overall success after all trips are added
      print('All trips added successfully');
      // Optionally update UI or show success message
    } catch (error) {
      // Handle error
      print('Error adding trips: $error');
      // Optionally show error message
    }
  }

//! ----------------------------------------------------------------
//! ----------------------------------------------------------------
//! ----------------------------------------------------------------
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Widget _buildQrView(BuildContext context) {
    // Use the MediaQuery to get the size of the screen and use that for the QR view size
    var scanArea = (MediaQuery.of(context).size.width < 300 ||
            MediaQuery.of(context).size.height < 300)
        ? 150.0
        : 250.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        // Handle the scanned data here
        _getData(); // Call your API to get the data
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

//! ----------------------------------------------------------------
//! ----------------------------------------------------------------
//! ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    padding: EdgeInsets.all(20.0),
                    margin: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      height:
                          300, // Define a fixed height for the QRView container
                      child: _buildQrView(context),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Icon(Icons.flashlight_on);
                            },
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Icon(Icons.cameraswitch);
                              } else {
                                return const Text('loading');
                              }
                            },
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          child: Icon(Icons.pause_rounded)),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          child: Icon(Icons.play_arrow)),
                    )
                  ],
                ),
                if (result != null)
                  Text(
                      'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                else
                  const Text('Scan a Qrcode'),
                IconButton(
                  icon: const Icon(Icons.qr_code_2),
                  iconSize: 150,
                  onPressed: () {
                    // Action for icon button press if needed
                  },
                ),
                const Text("Data Of QrCode: "),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .95,
                  child: FilledButton(
                    onPressed: _getData,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.seedColor,
                      fixedSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Get Data",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.whiteColor),
                    ),
                  ),
                ),
                if (_dataFetched)
                  ..._lines.map((line) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              15.0), // Set the border radius here
                        ),
                        elevation: 1,
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                  '${line['line_number']} | ${line['line_name']}'),
                              subtitle: Text('Price: ${line['line_price']}'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Start Time: ${line['start_time']}'),
                                  const SizedBox(height: 8),
                                  const Text('Stations:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  ...line['line_stations_json']
                                      .map<Widget>((station) {
                                    return ListTile(
                                      title: Text(station['nameStation']),
                                      subtitle: Text(
                                          'Code: ${station['codeStation']}\nAddress: ${station['addresseStation']}'),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: FilledButton(
                                onPressed: () {
                                  _deductPayment();
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.seedColor,
                                  fixedSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  "Go To Payment",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.whiteColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
