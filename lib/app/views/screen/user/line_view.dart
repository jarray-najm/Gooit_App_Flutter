import 'package:flutter/material.dart';
import 'package:goo_it/utils/common/text_style_ext.dart';

import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/app_colors.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/line_model.dart';

class LineView extends StatefulWidget {
  const LineView({super.key});

  @override
  State<LineView> createState() => _LineViewState();
}

class _LineViewState extends State<LineView> {
  final UserController _lineController = UserController();
  List<Line> _lines = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _filterController = TextEditingController();
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _fetchLines();
  }

  Future<void> _fetchLines() async {
    try {
      List<Line> lines = await _lineController.fetchLines();
      setState(() {
        _lines = lines;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
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
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _errorMessage.isNotEmpty
                              ? Center(child: Text('Error: $_errorMessage'))
                              : Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ListView.builder(
                                    itemCount: _lines
                                        .where((line) {
                                          return line.lineName
                                                  .toLowerCase()
                                                  .contains(_filterText) ||
                                              line.lineNumber
                                                  .toString()
                                                  .contains(_filterText);
                                        })
                                        .toList()
                                        .length,
                                    itemBuilder: (context, index) {
                                      final line = _lines.where((line) {
                                        return line.lineName
                                                .toLowerCase()
                                                .contains(_filterText) ||
                                            line.lineNumber
                                                .toString()
                                                .contains(_filterText);
                                      }).toList()[index];
                                      return FadeInSlide(
                                        duration: 1,
                                        direction: FadeSlideDirection.btt,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                15.0), // Set the border radius here
                                          ),
                                          elevation: 1,
                                          margin: const EdgeInsets.only(
                                            left: 4,
                                            right: 4,
                                            bottom: 4,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ListTile(
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          // Add a bottom border with height 4 and color black
                                                          border: const Border(
                                                            top: BorderSide(
                                                                color: Colors
                                                                    .black),
                                                            left: BorderSide(
                                                                color: Colors
                                                                    .black),
                                                            right: BorderSide(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            bottom: BorderSide(
                                                                color: Colors
                                                                    .black,
                                                                width: 4.0),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .route_rounded,
                                                            ),
                                                            Text(
                                                              ' ${line.lineNumber} ',
                                                              style: context.tm!
                                                                  .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        '  | ${line.lineName} ',
                                                        style: context.tm!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Start Time: ${line.startTime}',
                                                        style: context.tm!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                trailing: FadeInSlide(
                                                  duration: 1,
                                                  direction:
                                                      FadeSlideDirection.ltr,
                                                  child: Text(
                                                    'Price: ${line.linePrice}',
                                                    style: context.tm!.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              ExpansionTile(
                                                shape: Border.all(
                                                    color: Colors.transparent),
                                                collapsedBackgroundColor:
                                                    AppColors.textFieldColor,
                                                title: const Text('Stations'),
                                                children: line.lineStations
                                                    .map((station) {
                                                  return FadeInSlide(
                                                    duration: 1,
                                                    direction:
                                                        FadeSlideDirection.ltr,
                                                    child: Card(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                15.0), // Set the border radius here
                                                      ),
                                                      elevation: 1,
                                                      child: ListTile(
                                                        title: Text(station
                                                            .nameStation),
                                                        subtitle: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Code: ${station.codeStation}',
                                                            ),
                                                            Text(
                                                              'Address: ${station.addresseStation}',
                                                            ),
                                                          ],
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
                                ))
                ]))));
  }
}
