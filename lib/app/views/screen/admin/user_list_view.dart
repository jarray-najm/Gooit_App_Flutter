import 'package:flutter/material.dart';
import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/app_colors.dart';
import '../../../controllers/admin_controller.dart';

import '../../../models/user_model.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  _UsersViewState createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final AdminController _controller = AdminController(); // Your controller
  late Future<List<User>> _futureUsers;
  final TextEditingController _filterController = TextEditingController();
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _futureUsers =
        _controller.getAllUsers(); // Replace with your method to fetch users
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
                    hintText: 'Filter by username or email',
                    prefixIcon: const Icon(Icons.search_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<User>>(
                  future: _futureUsers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    } else {
                      List<User>? users = snapshot.data;
                      List<User> filteredUsers = users!.where((user) {
                        return user.username
                                .toLowerCase()
                                .contains(_filterText) ||
                            user.email.toLowerCase().contains(_filterText);
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          User user = filteredUsers[index];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: FadeInSlide(
                              duration: 1,
                              direction: FadeSlideDirection.btt,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // Set the border radius here
                                ),
                                elevation: 1,
                                child: ExpansionTile(
                                  shape: Border.all(color: Colors.transparent),
                                  title: Text('Username: ${user.username}'),
                                  subtitle: Text('Email: ${user.email}'),
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        // Text('Balance:',
                                        //     style: TextStyle(
                                        //         fontSize: 16,
                                        //         fontWeight: FontWeight.bold)),
                                        if (user.balance != null)
                                          FadeInSlide(
                                            duration: 1,
                                            direction: FadeSlideDirection.btt,
                                            child: Card(
                                              color: AppColors.whiteColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    15.0), // Set the border radius here
                                              ),
                                              elevation: 1,
                                              child: ListTile(
                                                title: Text(
                                                    'Balance Amount: ${user.balance!.balanceAmount.toString()}TND'),
                                                subtitle: Text(
                                                    'Recharge Date: ${user.balance!.rechargeDate}'),
                                              ),
                                            ),
                                          )
                                        else
                                          const Text('No balance information'),
                                        const SizedBox(height: 10),
                                        FadeInSlide(
                                          duration: 1,
                                          direction: FadeSlideDirection.ltr,
                                          child: Card(
                                            color: AppColors.whiteColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  15.0), // Set the border radius here
                                            ),
                                            elevation: 1,
                                            child: ExpansionTile(
                                              shape: Border.all(
                                                  color: Colors.transparent),
                                              title: const Text('Trips',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              children: user.trips.map((trip) {
                                                return Card(
                                                  child: ListTile(
                                                    title: Text(
                                                        'Trip Name: ${trip.tripName}'),
                                                    subtitle: Text(
                                                        'Trip Number: ${trip.tripNumber.toString()}'),
                                                    onTap: () {
                                                      // Handle tap on trip
                                                    },
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        FadeInSlide(
                                          duration: 1,
                                          direction: FadeSlideDirection.ttb,
                                          child: Card(
                                            color: AppColors.whiteColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  15.0), // Set the border radius here
                                            ),
                                            elevation: 1,
                                            child: ExpansionTile(
                                              shape: Border.all(
                                                  color: Colors.transparent),
                                              title: const Text('Payments',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              children:
                                                  user.payments.map((payment) {
                                                return Card(
                                                  child: ListTile(
                                                    title: Text(
                                                        'Amount: ${payment.amount.toString()}TND'),
                                                    subtitle: Text(
                                                        'Payment Date: ${payment.paymentDate}'),
                                                    onTap: () {
                                                      // Handle tap on payment
                                                    },
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ],
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
    );
  }
}
