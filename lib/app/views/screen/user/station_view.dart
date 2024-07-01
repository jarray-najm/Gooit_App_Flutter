import 'package:flutter/material.dart';
import 'package:goo_it/utils/common/text_style_ext.dart';
import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/app_colors.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/station_model.dart';

class StationView extends StatefulWidget {
  const StationView({super.key});

  @override
  _StationViewState createState() => _StationViewState();
}

class _StationViewState extends State<StationView> {
  final UserController _userController = UserController();
  List<Station> _stations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _filterController = TextEditingController();
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    try {
      List<Station> stations = await _userController.fetchStations();
      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStations = _stations.where((station) {
      final nameLower = station.nameStation.toLowerCase();
      final codeLower = station.codeStation.toLowerCase();
      final filterLower = _filterText.toLowerCase();
      return nameLower.contains(filterLower) || codeLower.contains(filterLower);
    }).toList();

    return Scaffold(
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
                    hintText: "Filter by station name or code",
                    prefixIcon: const Icon(Icons.search_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 1,
                              child: Text('Error: $_errorMessage'),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredStations.length,
                            itemBuilder: (context, index) {
                              final station = filteredStations[index];
                              return FadeInSlide(
                                duration: 1,
                                direction: FadeSlideDirection.btt,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 1,
                                  margin: const EdgeInsets.all(4),
                                  child: ListTile(
                                    leading: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
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
// xample icon
                                    title: Text(
                                      station.nameStation,
                                      style: context.tm?.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Code: ${station.codeStation}',
                                          style: context.tm?.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Address: ${station.addresseStation}',
                                          style: context.tm?.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
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
