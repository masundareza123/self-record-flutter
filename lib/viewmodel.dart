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
  ScrollController controller = ScrollController();
  String? long;
  String? lat;
  String? address;

  TextEditingController descriptionController = TextEditingController();

  void initData() {
    checkCameraPermission();
    checkLocationPermission();
  }

  void initHome() {

  }
  Future<bool> checkCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else if (status == PermissionStatus.denied) {
      status;
      return false;
    } else if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return true;
  }

  Future<bool> checkLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else if (status == PermissionStatus.denied) {
      status;
      return false;
    } else if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return true;
  }

  Future<void> capturePicture() async {
    await checkLocationPermission();
    await checkCameraPermission();
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      final userLocation = await getLocation();
      print(userLocation);
      long = userLocation?.longitude.toString() ?? '-';
      lat = userLocation?.latitude.toString() ?? '-';
      address = userLocation?.address.toString() ?? '-';
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
      Placemark place = placemarks[0];
      String address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}.${place.postalCode}';


      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
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
    print('save');
  }

  Future<List<Report>> loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString(storageName) ?? '';
    if (jsonString.isNotEmpty) {
      List<Map<String, dynamic>> maps =
          List<Map<String, dynamic>>.from(jsonDecode(jsonString));
      List<Report> reports = maps.map((map) => Report.fromMap(map)).toList();
      return reports
      ;
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
