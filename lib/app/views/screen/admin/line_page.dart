import 'package:flutter/material.dart';

import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/app_colors.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/line_model.dart';
import '../../../models/station_model.dart';

class LinesView extends StatefulWidget {
  const LinesView({super.key});

  @override
  _LinesViewState createState() => _LinesViewState();
}

class _LinesViewState extends State<LinesView> {
  final AdminController _controller = AdminController();
  Future<List<Line>>? _futureLines;
  final TextEditingController _lineNameController = TextEditingController();
  final TextEditingController _lineNumberController = TextEditingController();
  final TextEditingController _linePriceController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();
  final formKey = GlobalKey<FormState>(); // GlobalKey for the form
  List<Station> _allStations = []; // List to hold all available stations
  List<Station> _selectedStations = []; // List to hold selected stations
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _fetchLines(); // Initiate fetching lines
    _fetchAllStations(); // Fetch all stations when widget initializes
  }

  Future<void> _fetchLines() async {
    try {
      List<Line> lines = await _controller.getAllLines();
      setState(() {
        _futureLines =
            Future.value(lines); // Update _futureLines with fetched lines
      });
    } catch (e) {
      // Handle error
      print('Failed to fetch lines: $e');
    }
  }

  Future<void> _fetchAllStations() async {
    try {
      List<Station> stations = await _controller.getAllStations();
      setState(() {
        _allStations = stations;
      });

      // Print or log each station as JSON
      // _allStations.forEach((station) {
      //   String stationJson = jsonEncode(
      //       station.toJson()); // Assuming Station has a toJson method
      //   print(stationJson);
      // });
    } catch (e) {
      // print('Failed to fetch stations: $e');
    }
  }

  Future<void> _showStationSelection(BuildContext context) async {
    List<Station> selectedStations = []; // Track selected stations separately

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Select Stations',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allStations.length,
                      itemBuilder: (context, index) {
                        final station = _allStations[index];
                        final isSelected = selectedStations.contains(station);

                        return CheckboxListTile(
                          title: Text(station.nameStation),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null && value) {
                                selectedStations.add(station);
                              } else {
                                selectedStations.remove(station);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context,
                              selectedStations); // Return selected stations
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    setState(() {
      _selectedStations.clear();
      _selectedStations.addAll(selectedStations);
    });
  }

  void _showAddLineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: const Text('Add New Line'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _lineNameController,
                    decoration: const InputDecoration(labelText: 'Line Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lineNumberController,
                    decoration: const InputDecoration(labelText: 'Line Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _linePriceController,
                    decoration: const InputDecoration(labelText: 'Line Price'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(labelText: 'Start Time'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a start time';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Selected Stations:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: _selectedStations.map((station) {
                      return Chip(
                        label: Text(station.nameStation),
                        onDeleted: () {
                          setState(() {
                            _selectedStations.remove(station);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            bottom: 0, left: 0, right: 0, top: 20),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(width: .2, color: Colors.white),
                          ),
                        ),
                        child: FilledButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              // Create a new Line object
                              Line newLine = Line(
                                id: 0, // Replace with actual logic for ID generation
                                lineName: _lineNameController.text,
                                lineNumber:
                                    int.parse(_lineNumberController.text),
                                linePrice:
                                    double.parse(_linePriceController.text),
                                startTime: _startTimeController.text,
                                lineStations: _selectedStations,
                              );

                              // Add the new line via your controller
                              try {
                                await _controller.addLine(newLine);
                                await _controller.getAllLines();
                                // Optionally update _futureLines to refresh the list
                                setState(() {
                                  _futureLines = _controller.getAllLines();
                                });
                                Navigator.of(context).pop(); // Close the dialog
                              } catch (e) {
                                print('Failed to add line: $e');
                                // Handle error
                              }
                            }
                          },
                          style: FilledButton.styleFrom(
                              fixedSize: const Size(double.infinity, 40),
                              backgroundColor: AppColors.seedColor),
                          child: const Text(
                            "Add Line",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.whiteColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        bottom: 0, left: 0, right: 0, top: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: .2, color: Colors.white),
                      ),
                    ),
                    child: FilledButton(
                      onPressed: () {
                        _showStationSelection(
                            context); // Open station selection modal
                      },
                      style: FilledButton.styleFrom(
                          fixedSize: const Size(double.infinity, 40),
                          backgroundColor: AppColors.seedColor),
                      child: const Text(
                        "Select Stations",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteLineDialog(Line line) async {
    try {
      bool? confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
                'Are you sure you want to delete line ${line.lineNumber}?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: .2, color: Colors.white),
                  ),
                ),
                child: FilledButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  style: FilledButton.styleFrom(
                      fixedSize: const Size(double.infinity, 40),
                      backgroundColor: AppColors.seedColor),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.whiteColor),
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (confirmDelete != null && confirmDelete) {
        await _controller.deleteLine(line.id); // Call the deleteLine method
        setState(() {
          // Optionally update your state or UI after deletion
          _futureLines = _controller
              .getAllLines(); // Assuming _futureLines is a Future<List<Line>>
        });
      }
    } catch (e) {
      print('Failed to delete line: $e');
      // Optionally, show an error dialog or handle the error in another way
    }
  }

  void _showEditLineDialog(BuildContext context, Line lineToEdit) async {
    // Initialize _selectedStations with existing stations of the lineToEdit
    _selectedStations = List.from(lineToEdit.lineStations);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: AlertDialog(
                  title: const Text('Edit Line'),
                  content: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _lineNameController
                            ..text = lineToEdit.lineName,
                          decoration:
                              const InputDecoration(labelText: 'Line Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _lineNumberController
                            ..text = lineToEdit.lineNumber.toString(),
                          decoration:
                              const InputDecoration(labelText: 'Line Number'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _linePriceController
                            ..text = lineToEdit.linePrice.toString(),
                          decoration:
                              const InputDecoration(labelText: 'Line Price'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _startTimeController
                            ..text = lineToEdit.startTime,
                          decoration:
                              const InputDecoration(labelText: 'Start Time'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a start time';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Selected Stations:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          children: _selectedStations.map((station) {
                            return Chip(
                              label: Text(station.nameStation),
                              onDeleted: () {
                                setState(() {
                                  _selectedStations.remove(station);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                  bottom: 0, left: 0, right: 0, top: 20),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      width: .2, color: Colors.white),
                                ),
                              ),
                              child: FilledButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    // Update the Line object with edited data
                                    Line updatedLine = Line(
                                      id: lineToEdit.id, // Ensure the ID is set
                                      lineName: _lineNameController.text,
                                      lineNumber:
                                          int.parse(_lineNumberController.text),
                                      linePrice: double.parse(
                                          _linePriceController.text),
                                      startTime: _startTimeController.text,
                                      lineStations: _selectedStations,
                                    );

                                    // Send the updated data to the backend
                                    try {
                                      await _controller.editLine(
                                          lineToEdit.id, updatedLine);
                                      await _controller.getAllLines();
                                      // Optionally update _futureLines to refresh the list
                                      _futureLines = _controller.getAllLines();
                                      await _fetchLines();
                                      setState(() {
                                        _futureLines =
                                            _controller.getAllLines();
                                      });
                                      Navigator.of(context).pop();
                                    } catch (e) {
                                      print('Failed to edit line: $e');
                                      // Handle error
                                    }
                                  }
                                },
                                style: FilledButton.styleFrom(
                                    fixedSize: const Size(double.infinity, 40),
                                    backgroundColor: AppColors.seedColor),
                                child: const Text(
                                  "Update Line",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.whiteColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              bottom: 0, left: 0, right: 0, top: 20),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(width: .2, color: Colors.white),
                            ),
                          ),
                          child: FilledButton(
                            onPressed: () async {
                              // Open station selection modal
                              _showStationSelection(context);
                            },
                            style: FilledButton.styleFrom(
                                fixedSize: const Size(double.infinity, 40),
                                backgroundColor: AppColors.seedColor),
                            child: const Text(
                              "Select Stations",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.whiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FadeInSlide(
        curve: Curves.bounceIn,
        duration: 1,
        direction: FadeSlideDirection.btt,
        child: FloatingActionButton(
          backgroundColor: AppColors.seedColor,
          onPressed: () {
            _showAddLineDialog(context);
          },
          child: const Icon(
            Icons.add,
            color: AppColors.whiteColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FadeInSlide(
                duration: 1,
                direction: FadeSlideDirection.ttb,
                child: TextFormField(
                  controller: _filterController,
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    setState(() {
                      _filterText = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.textFieldColor,
                    hintText: 'Filter by line name or number',
                    prefixIcon: const Icon(Icons.search_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Line>>(
                  future: _futureLines,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<Line>? lines = snapshot.data;
                      if (lines == null || lines.isEmpty) {
                        return Center(child: Text('No lines available.'));
                      }

                      List<Line> filteredLines = lines.where((line) {
                        return line.lineName
                                .toLowerCase()
                                .contains(_filterText) ||
                            line.lineNumber.toString().contains(_filterText);
                      }).toList();

                      return Padding(
                        padding: const EdgeInsets.all(0),
                        child: ListView.builder(
                          itemCount: filteredLines.length,
                          itemBuilder: (context, index) {
                            Line line = filteredLines[index];
                            return FadeInSlide(
                              duration: 1,
                              direction: FadeSlideDirection.btt,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Set the border radius here
                                ),
                                elevation: 1,
                                margin: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                // Add a bottom border with height 4 and color black
                                                border: const Border(
                                                  top: BorderSide(
                                                      color:
                                                          AppColors.seedColor),
                                                  left: BorderSide(
                                                      color:
                                                          AppColors.seedColor),
                                                  right: BorderSide(
                                                    color: AppColors.seedColor,
                                                  ),
                                                  bottom: BorderSide(
                                                      color:
                                                          AppColors.seedColor,
                                                      width: 4.0),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.route_rounded,
                                                  ),
                                                  Text(
                                                    ' ${line.lineNumber} ',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '  | ${line.lineName} ',
                                            ),
                                          ],
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Price: ${line.linePrice}',
                                            ),
                                            Text(
                                              'Start Time: ${line.startTime}',
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: FadeInSlide(
                                        duration: 1,
                                        direction: FadeSlideDirection.ltr,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                  ),
                                                  onPressed: () {
                                                    _showEditLineDialog(
                                                        context, line);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                  ),
                                                  onPressed: () {
                                                    _deleteLineDialog(line);
                                                    // Handle delete button
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ExpansionTile(
                                      shape:
                                          Border.all(color: Colors.transparent),
                                      collapsedBackgroundColor:
                                          AppColors.textFieldColor,
                                      title: const Text('Stations'),
                                      children:
                                          line.lineStations.map((station) {
                                        return FadeInSlide(
                                          duration: 1,
                                          direction: FadeSlideDirection.ltr,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  15.0), // Set the border radius here
                                            ),
                                            elevation: 1,
                                            child: ListTile(
                                              title: Text(station.nameStation),
                                              subtitle: Text(
                                                'Code: ${station.codeStation}\nAddress: ${station.addresseStation}',
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
