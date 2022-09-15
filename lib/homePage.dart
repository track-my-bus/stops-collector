// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => LocationState();
}

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

class LocationState extends State<Location> {
  final controller = TextEditingController();
  final _networkConnectivity = Connectivity();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Stops registering app')),
        body: Center(
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the name of the stop',
                ),
              ),
              TextButton(
                // ignore: duplicate_ignore
                onPressed: () async {
                  ConnectivityResult result =
                      await _networkConnectivity.checkConnectivity();

                  final position =
                      await _geolocatorPlatform.getCurrentPosition();
                  final name = controller.text;

                  // ignore: use_build_context_synchronously

                  if (await confirm(context)) {
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Name cannot be empty')));
                    } else {
                      final data = await addLocation(
                          name: name,
                          lat: position.latitude.toString(),
                          long: position.longitude.toString());

                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Success')));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Canceled')));
                  }
                  ;
                },
                // ignore: sort_child_properties_last
                child: const Text(
                  'Submit',
                ),
              )
            ],
          ),
        ));
  }
}

Future addLocation({String? name, String? lat, String? long}) async {
  final json = await [
    {
      "name": name,
      "lat": lat,
      "long": long,
    }
  ];

  final value = await FirebaseFirestore.instance
      .collection('Locations')
      .doc('Stopdata')
      .update({"data": FieldValue.arrayUnion(json)});
  return value;
}
