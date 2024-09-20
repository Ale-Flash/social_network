// ignore_for_file: empty_catches

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../main.dart';
import './global.dart';
import './profile.dart';
import './mypost.dart';
import './ranking.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        vsync: this,
        length: 4,
        initialIndex: 1,
        animationDuration: const Duration(milliseconds: 200));
    _tabController.addListener(_handleTabSelection);
  }

  final List<Widget> _screens = [
    const ProfilePage(),
    const GlobalPage(),
    const MyPostsPage(),
    const RankingPage(),
  ];

  _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  bool requestedProfile = false;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (!requestedProfile) {
      requestedProfile = true;
      api.getProfile().then((value) {
        user = value;
      });
    }
    return WillPopScope(
        onWillPop: () async => false,
        child: RefreshIndicator(
            onRefresh: () {
              return api.getProfile().then((value) {
                user = value;
              });
            },
            child: Scaffold(
              body: TabBarView(
                controller: _tabController,
                children: _screens,
              ),
              bottomNavigationBar: Container(
                decoration:
                    BoxDecoration(color: const Color(0xFF548DC7), boxShadow: [
                  BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
                ]),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 8),
                    child: GNav(
                        gap: 8,
                        activeColor: Colors.white,
                        iconSize: 24,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        duration: const Duration(milliseconds: 200),
                        tabBackgroundColor: const Color(0xFF004081),
                        tabs: const [
                          GButton(
                            icon: Icons.account_circle,
                            text: 'Profile',
                          ),
                          GButton(
                            icon: Icons.blur_circular,
                            text: 'Global',
                          ),
                          GButton(
                            icon: Icons.assignment_ind,
                            text: 'My Posts',
                          ),
                          GButton(
                            icon: Icons.format_list_numbered_rtl,
                            text: 'Ranking',
                          ),
                        ],
                        selectedIndex: _currentIndex,
                        onTabChange: (index) {
                          setState(() {
                            _tabController.index = index;
                          });
                        }),
                  ),
                ),
              ),
            )));
  }
}
