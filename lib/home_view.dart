import 'dart:io';

import 'package:flutter/material.dart';
import 'package:self_record/add_view.dart';
import 'package:stacked/stacked.dart';

import 'viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ViewModel>.reactive(
      viewModelBuilder: () => ViewModel(),
      onViewModelReady: (model) => model.initData(),
      builder: (context, model, child) =>
          Scaffold(
            appBar: AppBar(
              title: Text('List Report'),
            ),
            body: FutureBuilder<List<Report>>(
              future: model.loadReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Display a loading indicator while the data is being loaded.
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final reports = snapshot.data;
                  if (reports == null) {
                    return Text('No reports available.');
                  } else {
                    return ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return ListTile(
                          leading: report.imagePath != null
                              ? Image.file(File(report.imagePath!))
                              : Icon(Icons.image), // Display an image or icon if available
                          title: Text(report.dateTime ?? 'No date'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location: ${report.latitude}, ${report.longitude}'),
                              Text('Address: ${report.address ?? 'N/A'}'),
                              Text('Description: ${report.description ?? 'No description'}'),
                            ],
                          ),
                          // You can add more widgets here to display additional report details if needed.
                        );
                      },
                    );
                  }
                }
              },
            ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Navigate to the new page
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddView(),
                  ));
                },
                child: Icon(Icons.add),
              ),
          ),);
  }
}
