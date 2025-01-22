import 'package:car_manufac/car_mfr.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  Future<CarMfr?> getCarMfr() async {
    var url = "vpic.nhtsa.dot.gov";

    var uri = Uri.https(url, "/api/vehicles/getallmanufacturers", {"format": "json"});
    await Future.delayed(const Duration(seconds: 3));
    var response = await get(uri);

    if (response.statusCode == 200) {
      return carMfrFromJson(response.body);
    } else {
      print("Failed to fetch data: ${response.statusCode}");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
      ),
      body: FutureBuilder<CarMfr?>(
        future: getCarMfr(),
        builder: (BuildContext context, AsyncSnapshot<CarMfr?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            var results = snapshot.data!.results;

            if (results != null && results.isNotEmpty) {
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  var result = results[index];
                  return ListTile(
                    title: Text(result.mfrName ?? "Unknown Manufacturer"),
                    subtitle: Text(result.country ?? "Unknown Country"),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No manufacturers found."),
              );
            }
          } else {
            return const Center(
              child: Text("No data available."),
            );
          }
        },
      ),
    );
  }
}