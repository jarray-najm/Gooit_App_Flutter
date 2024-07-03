import 'package:flutter/material.dart';

import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/app_colors.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/station_model.dart';

class StationsView extends StatefulWidget {
  const StationsView({super.key});

  @override
  _StationsViewState createState() => _StationsViewState();
}

class _StationsViewState extends State<StationsView> {
  final AdminController _controller = AdminController();
  late Future<List<Station>> _futureStations;
  final TextEditingController _filterController = TextEditingController();
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _futureStations = _controller.getAllStations();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: FadeInSlide(
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
                      hintText: "Filter by station name or code",
                      prefixIcon: const Icon(Icons.search_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Station>>(
                  future: _futureStations,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<Station>? stations = snapshot.data;
                      List<Station> filteredStations =
                          stations!.where((station) {
                        return station.nameStation
                                .toLowerCase()
                                .contains(_filterText) ||
                            station.codeStation
                                .toLowerCase()
                                .contains(_filterText);
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredStations.length,
                        itemBuilder: (context, index) {
                          Station station = filteredStations[index];
                          return FadeInSlide(
                            duration: 1,
                            direction: FadeSlideDirection.btt,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15.0), // Set the border radius here
                              ),
                              elevation: 1,
                              child: ListTile(
                                leading: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    color: AppColors.seedColor,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.fmd_good_sharp,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ),
                                title: Text(station.nameStation),
                                subtitle: Text(
                                    'Code: ${station.codeStation}\nAddress: ${station.addresseStation}'),
                                trailing: FadeInSlide(
                                  duration: 1,
                                  direction: FadeSlideDirection.ltr,
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                        ),
                                        onPressed: () {
                                          _editStationDialog(station);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                        ),
                                        onPressed: () {
                                          _deleteStationDialog(station);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FadeInSlide(
        duration: 1,
        direction: FadeSlideDirection.btt,
        child: FloatingActionButton(
          backgroundColor: AppColors.seedColor,
          onPressed: () {
            _addStationDialog();
          },
          child: const Icon(
            Icons.add,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }

  // Dialogs for CRUD operations

  Future<void> _addStationDialog() async {
    try {
      Station? newStation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return _buildStationDialog(Station(
            nameStation: '',
            codeStation: '',
            addresseStation: '',
            id: 0,
          ));
        },
      );

      if (newStation != null) {
        await _controller.addStation(newStation);
        setState(() {
          _futureStations = _controller.getAllStations();
        });
      }
    } catch (e) {
      print('Failed to add station: $e');
      // Optionally, show an error dialog or handle the error in another way
    }
  }

  Future<void> _editStationDialog(Station station) async {
    try {
      Station? updatedStation = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return _buildStationDialog(station);
        },
      );

      if (updatedStation != null) {
        if (station.id != null) {
          await _controller.editStation(station.id!, updatedStation);
          setState(() {
            _futureStations = _controller.getAllStations();
          });
        } else {
          print('Cannot edit station without id.');
        }
      }
    } catch (e) {
      print('Failed to edit station: $e');
      // Optionally, show an error dialog or handle the error in another way
    }
  }

  Future<void> _deleteStationDialog(Station station) async {
    try {
      bool? confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content:
                Text('Are you sure you want to delete ${station.nameStation}?'),
            actions: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: .2, color: Colors.white),
                  ),
                ),
                child: TextButton(
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
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: .2, color: Colors.white),
                  ),
                ),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      fixedSize: const Size(double.infinity, 40),
                      backgroundColor: AppColors.seedColor),
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
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
        await _controller.deleteStation(station.id!);
        setState(() {
          _futureStations = _controller.getAllStations();
        });
      }
    } catch (e) {
      print('Failed to delete station: $e');
      // Optionally, show an error dialog or handle the error in another way
    }
  }

  Widget _buildStationDialog(Station station) {
    TextEditingController nameController =
        TextEditingController(text: station.nameStation);
    TextEditingController codeController =
        TextEditingController(text: station.codeStation);
    TextEditingController addressController =
        TextEditingController(text: station.addresseStation);

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: Text(station.id != null ? 'Edit Station' : 'Add Station'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onChanged: (value) {
                station.nameStation = value;
              },
            ),
            TextFormField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Code'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a code';
                }
                return null;
              },
              onChanged: (value) {
                station.codeStation = value;
              },
            ),
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
              onChanged: (value) {
                station.addresseStation = value;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: .2, color: Colors.white),
            ),
          ),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(station);
              }
            },
            style: FilledButton.styleFrom(
                fixedSize: const Size(double.infinity, 40),
                backgroundColor: AppColors.seedColor),
            child: const Text(
              "Save",
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: AppColors.whiteColor),
            ),
          ),
        ),
      ],
    );
  }
}
