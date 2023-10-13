import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewModel extends ChangeNotifier {
  File? capturedImage;
  String? imagePath;
  String storageName = "reports";
  String? long;
  String? lat;
  String? address;

  TextEditingController descriptionController = TextEditingController();

  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return status.isGranted;
    } else {
      openAppSettings();
      return status.isDenied;
    }
  }

  Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      return status.isGranted;
    } else {
      openAppSettings();
      return status.isDenied;
    }
  }

  Future<void> capturePicture() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      imagePath = image.path;
      capturedImage = File(image.path);
      notifyListeners();
    }
  }

  Future<LocationData?> getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: placemarks.isNotEmpty ? placemarks[0].thoroughfare : 'N/A',
      );
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  String getCurrentDateTime() {
    DateTime currentDateTime = DateTime.now();
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(currentDateTime);
    return formattedDateTime;
  }

  Future<void> addReport() async {
    final userLocation = await getLocation();
    String long = userLocation?.longitude.toString() ?? '-';
    String lat = userLocation?.latitude.toString() ?? '-';
    String address = userLocation?.address.toString() ?? '-';
    List<Report> reports = await loadReports();
    reports.add(Report(
        address: address,
        longitude: long,
        latitude: lat,
        description: descriptionController.text,
        dateTime: getCurrentDateTime(),
        imagePath: imagePath));
    await saveReports(reports);
  }

  Future<void> saveReports(List<Report> reports) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> maps =
        reports.map((report) => report.toMap()).toList();
    String jsonString = jsonEncode(maps);
    prefs.setString(storageName, jsonString);
  }

  Future<List<Report>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString(storageName) ?? '';
    if (jsonString.isNotEmpty) {
      List<Map<String, dynamic>> maps =
          List<Map<String, dynamic>>.from(jsonDecode(jsonString));
      List<Report> reports = maps.map((map) => Report.fromMap(map)).toList();
      return reports;
    } else {
      return [];
    }
  }
}

class LocationData {
  double? latitude;
  double? longitude;
  String? address;

  LocationData({
    this.latitude,
    this.longitude,
    this.address,
  });
}

class Report {
  String? imagePath;
  String? longitude;
  String? latitude;
  String? address;
  String? dateTime;
  String? description;

  Report(
      {this.imagePath,
      this.longitude,
      this.latitude,
      this.address,
      this.dateTime,
      this.description});

  // Convert a Report to a Map
  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'longitude': longitude,
      'latitude': latitude,
      'address': address,
      'dateTime': dateTime,
      'description': description,
    };
  }

  // Convert a Map to a Report
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      imagePath: map['imagePath'],
      longitude: map['longitude'],
      latitude: map['latitude'],
      address: map['address'],
      dateTime: map['dateTime'],
      description: map['description'],
    );
  }
}
