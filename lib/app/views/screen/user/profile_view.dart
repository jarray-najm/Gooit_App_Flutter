import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goo_it/utils/common/text_style_ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/animations/fade_in_slide.dart';
import '../../../../utils/common/app_colors.dart';
import '../../../../utils/common/loading_overlay.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserController _userController = UserController();
  User? _user;
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userID = prefs.getInt('userID');
      if (userID != null) {
        User user = await _userController.fetchUser(userID);
        setState(() {
          _user = user;
          _isLoading = false;
        });
      } else {
        throw Exception('User ID not found');
      }
    } catch (e) {
      // setState(() {
      //   _isLoading = false;
      //   _errorMessage = e.toString();
      // });
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final goRouter = GoRouter.of(context);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userID = prefs.getInt('userID');
      print(userID);
      if (userID != null) {
        await _userController.deleteUserProfile(userID);
        await prefs.clear();
        goRouter.go("/signIn");
      } else {
        throw Exception('User ID not found in SharedPreferences');
      }
    } catch (e) {
      setState(() {
        print(e);
        // _errorMessage = 'Failed to delete account: $e';
      });
    }
  }

  Future<void> _logout() async {
    final goRouter = GoRouter.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    goRouter.go("/signIn");
  }

  Future<void> _rechargeBalance(int amount) async {
    LoadingScreen.instance()
        .show(context: context, text: "checking Recharge...");

    try {
      await _userController.rechargeBalance(amount);
      await Future.delayed(const Duration(seconds: 1));
      LoadingScreen.instance()
          .show(context: context, text: "recharge Successfully");
      await Future.delayed(const Duration(seconds: 1));
      LoadingScreen.instance().hide();
      // Fetch the updated user data
      _fetchUser();
      // Navigator.of(context).pop();
    } catch (e) {
      LoadingScreen.instance().hide();

      LoadingScreen.instance()
          .show(context: context, text: 'recharge Failed: $e');
      await Future.delayed(const Duration(seconds: 1));
      LoadingScreen.instance().hide();

      // _errorMessage = 'Failed to recharge balance: $e';
      print(e);
    }
  }

  void _showRechargeDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recharge Balance'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'Card Number'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'Expiry Date'),
                ),
                const TextField(
                  decoration: InputDecoration(labelText: 'CVV'),
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Amount cannot be empty';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Invalid number';
                    }
                    // You can add more complex validation logic here if needed
                    return null; // Return null if the input is valid
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // If the form is valid, proceed with recharge
                  await _rechargeBalance(
                      int.parse(amountController.text.trim()));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Recharge'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Profile'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.logout),
      //       onPressed: _logout,
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text('Error: $_errorMessage'))
                : _user != null
                    ? SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildUserInfo(context),
                              const SizedBox(height: 16),
                              _buildActionsPay(context),
                              const SizedBox(height: 16),
                              _buildTripsInfo(),
                              const SizedBox(height: 8),
                              _buildPaymentsInfo(),
                            ],
                          ),
                        ),
                      )
                    : const Center(child: Text('No user data')),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return FadeInSlide(
        duration: 1,
        direction: FadeSlideDirection.btt,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: const DecorationImage(
                image: AssetImage("assets/images/card2bg.jpg"),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your Balance TND',
                  style: context.hm!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_user!.balance?.balanceAmount.toStringAsFixed(2)}',
                      style: context.hl!.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  _user!.username,
                  style: context.tl!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  _user!.email,
                  style: context.tl!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildActionsPay(BuildContext context) {
    return FadeInSlide(
      duration: 1,
      direction: FadeSlideDirection.btt,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: FilledButton(
                onPressed: _showRechargeDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1e8b06),
                  fixedSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Recharge Balance",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, "Log Out", _logout,
                  color: AppColors.seedColor),
              _buildActionButton(context, "Delete Account", _deleteAccount,
                  color: const Color(0xFFF44336)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, VoidCallback onPressed,
      {Color? color}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          fixedSize: const Size(double.infinity, 50),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w900, color: AppColors.whiteColor),
        ),
      ),
    );
  }

  Widget _buildTripsInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FadeInSlide(
          duration: 1,
          direction: FadeSlideDirection.btt,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(15.0), // Set the border radius here
            ),
            elevation: 0,
            child: FadeInSlide(
              duration: 1,
              direction: FadeSlideDirection.btt,
              child: ExpansionTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(
                        color: Colors.transparent) // Set the border radius here
                    ),
                title: const Row(
                  children: [
                    Text('Trips',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                children: [
                  ..._user!.trips.map((trip) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              15.0), // Set the border radius here
                        ),
                        elevation: 0,
                        child: FadeInSlide(
                          duration: 1,
                          direction: FadeSlideDirection.btt,
                          child: Card(
                            elevation: .5,
                            child: ExpansionTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: const BorderSide(
                                      color: Colors
                                          .transparent) // Set the border radius here
                                  ),
                              title:
                                  Text('${trip.tripName} (${trip.tripNumber})'),
                              subtitle: Text(
                                  'Price: ${trip.tripPrice}\nStart Time: ${trip.startTime}'),
                              children: trip.tripStations.map((station) {
                                return FadeInSlide(
                                  duration: 1,
                                  direction: FadeSlideDirection.ltr,
                                  child: Card(
                                    elevation: 3,
                                    child: ListTile(
                                      title: Text(station.nameStation),
                                      subtitle: Text(
                                          'Code: ${station.codeStation}\nAddress: ${station.addresseStation}'),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsInfo() {
    return FadeInSlide(
      duration: 1,
      direction: FadeSlideDirection.btt,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(
                color: Colors.transparent) // Set the border radius here
            ),
        elevation: 0,
        child: ExpansionTile(
          shape: Border.all(color: Colors.transparent),
          title: const Text(
            'Payments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: _user!.payments.map((payment) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 3,
              child: ListTile(
                title: Text('Amount: ${payment.amount ?? 0}'),
                subtitle: Text('Date: ${payment.paymentDate}'),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
