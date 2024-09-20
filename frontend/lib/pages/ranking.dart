// ignore_for_file: empty_catches

import 'package:flutter/material.dart';

import '../main.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final List<Icon> leadboardIcons = [
    const Icon(Icons.favorite),
    const Icon(Icons.post_add),
    const Icon(Icons.comment),
  ];

  String _selectedIndex = 'likes';
  int rankingToShow = 0;

  Map<String, int> position = {'likes': 0, 'posts': 1, 'comments': 2};
  List<String> positionList = ['likes', 'posts', 'comments'];

  bool requested = false;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (ranking.isNotEmpty) {
      requested = true;
      isLoading = false;
    }
    if (!requested) {
      requested = true;
      api.getRanking().then((value) {
        ranking = value;
        try {
          setState(() {
            isLoading = false;
          });
        } catch (e) {}
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
        actions: [
          DropdownButton<int>(
            value: position[_selectedIndex],
            onChanged: (index) {
              setState(() {
                _selectedIndex = positionList[index!];
              });
            },
            dropdownColor: Colors.blue,
            items: [
              DropdownMenuItem(
                value: 0,
                child: leadboardIcons[0],
              ),
              DropdownMenuItem(
                value: 1,
                child: leadboardIcons[1],
              ),
              DropdownMenuItem(
                value: 2,
                child: leadboardIcons[2],
              )
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () {
                return api.getRanking().then((value) {
                  ranking = value;
                  try {
                    setState(() {
                      isLoading = false;
                    });
                  } catch (e) {}
                });
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: ranking[_selectedIndex]!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Users with the most ',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              _selectedIndex,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ],
                        ));
                      }
                      int i = index - 1;

                      Map line = ranking[_selectedIndex]![i];

                      return Card(
                        color: line['username'] == user!.username
                            ? Colors.yellow
                            : null,
                        child: ListTile(
                          leading: Text((i + 1).toString()),
                          title: Text(
                            line['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            line[_selectedIndex].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ))),
    );
  }
}
