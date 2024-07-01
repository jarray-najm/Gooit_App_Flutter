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

class ScanQRView extends StatefulWidget {
  const ScanQRView({super.key});

  @override
  State<ScanQRView> createState() => _ScanQRViewState();
}

class _ScanQRViewState extends State<ScanQRView> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final UserController _userController = UserController();

  bool _dataFetched = false;
  List<dynamic> _lines = [];
  dynamic _selectedLine; // To store the selected line for payment

  Future<void> _getData() async {
    const lineNumber = 13; // Replace with the desired line number
    LoadingScreen.instance().show(context: context, text: "Scanning QrCode...");

    try {
      final lines = await _userController.getLinesByNumber(lineNumber);
      print(lines);
      if (lines.isEmpty) {
        print('No lines found with the given number : invalid QrCode');
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();

        LoadingScreen.instance().show(context: context, text: "Invalid QrCode");
        await Future.delayed(const Duration(seconds: 1));
        LoadingScreen.instance().hide();
      } else {
        setState(() {
          _lines = lines;
          _dataFetched = true;
        });
        LoadingScreen.instance()
            .show(context: context, text: "Get data successfully");
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
  }

  Future<void> _deductPayment() async {
    LoadingScreen.instance()
        .show(context: context, text: "Checking payment ...");

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
            .show(context: context, text: "Adding trip ...");

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

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
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
              FittedBox(
                fit: BoxFit.contain,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      if (result != null)
                        Text(
                            'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                      else
                        const Text('Scan a Qrcode'),
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
                    ]),
              ),
              const SizedBox(height: 20), // Add some spacing between widgets
              _buildFetchedData(), // Display fetched data
              const SizedBox(height: 20), // Add some spacing between widgets
              ElevatedButton(
                onPressed: _deductPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.seedColor,
                  foregroundColor: AppColors.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Deduct Payment',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFetchedData() {
    if (!_dataFetched) {
      return const SizedBox(); // Display nothing if data is not fetched yet
    }
    if (_lines.isEmpty) {
      return const Text('No data available');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // To prevent scrolling inside Column
      itemCount: _lines.length,
      itemBuilder: (context, index) {
        final line = _lines[index];
        return ListTile(
          title: Text(line['line_name']),
          subtitle: Text('Line Number: ${line['line_number']}'),
          trailing: Text('Price: ${line['line_price']}'),
          onTap: () {
            setState(() {
              _selectedLine = line;
            });
          },
        );
      },
    );
  }

  Widget _buildQrView(BuildContext context) {
    // Use the MediaQuery to get the size of the screen and use that for the QR view size
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

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
}
