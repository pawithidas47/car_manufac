import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  // ฟังก์ชันดึงข้อมูลจาก API
  Future<CarMfr?> getCarMfr() async {
    var url = "vpic.nhtsa.dot.gov";  // URL สำหรับ API

    // การสร้าง URI สำหรับการเข้าถึง API
    var uri = Uri.https(url, "/api/vehicles/getallmanufacturers", {"format": "json"});
    await Future.delayed(const Duration(seconds: 3));  // เลียนแบบการดีเลย์
    var response = await get(uri);  // ส่งคำขอ GET ไปยัง API

    if (response.statusCode == 200) {
      return carMfrFromJson(response.body);  // ถ้า API ส่งข้อมูลมา เราจะแปลงข้อมูลเป็น CarMfr
    } else {
      print("Failed to fetch data: ${response.statusCode}");
      return null;  // ถ้าไม่สำเร็จ ให้คืนค่า null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),  // ชื่อแถบด้านบน
      ),
      body: FutureBuilder<CarMfr?>(
        future: getCarMfr(),  // ดึงข้อมูลจาก API
        builder: (BuildContext context, AsyncSnapshot<CarMfr?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),  // แสดงวงกลมหมุนขณะรอดึงข้อมูล
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),  // ถ้ามีข้อผิดพลาดแสดงข้อความ
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            var results = snapshot.data!.results;

            if (results != null && results.isNotEmpty) {
              return ListView.builder(
                itemCount: results.length,  // จำนวนแถวใน ListView
                itemBuilder: (context, index) {
                  var result = results[index];  // ข้อมูลที่ได้จากผลลัพธ์

                  return ListTile(
                    title: Text(result.mfrName ?? "Unknown Manufacturer"),  // แสดงชื่อผู้ผลิต
                    subtitle: Text(result.country ?? "Unknown Country"),  // แสดงประเทศผู้ผลิต
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No manufacturers found."),  // ถ้าไม่มีข้อมูลผู้ผลิต
              );
            }
          } else {
            return const Center(
              child: Text("No data available."),  // ถ้าไม่มีข้อมูล
            );
          }
        },
      ),
    );
  }
}

// ฟังก์ชันที่ใช้ในการแปลง JSON เป็น Object
CarMfr carMfrFromJson(String str) => CarMfr.fromJson(json.decode(str));

String carMfrToJson(CarMfr data) => json.encode(data.toJson());

class CarMfr {
  int? count;
  String? message;
  dynamic searchCriteria;
  List<Result>? results;

  CarMfr({
    this.count,
    this.message,
    this.searchCriteria,
    this.results,
  });

  factory CarMfr.fromJson(Map<String, dynamic> json) => CarMfr(
    count: json["Count"],
    message: json["Message"],
    searchCriteria: json["SearchCriteria"],
    results: json["Results"] == null ? [] : List<Result>.from(json["Results"]!.map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Count": count,
    "Message": message,
    "SearchCriteria": searchCriteria,
    "Results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
  };
}

class Result {
  String? country;
  String? mfrCommonName;
  int? mfrId;
  String? mfrName;
  List<VehicleType>? vehicleTypes;

  Result({
    this.country,
    this.mfrCommonName,
    this.mfrId,
    this.mfrName,
    this.vehicleTypes,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    country: json["Country"],
    mfrCommonName: json["Mfr_CommonName"],
    mfrId: json["Mfr_ID"],
    mfrName: json["Mfr_Name"],
    vehicleTypes: json["VehicleTypes"] == null ? [] : List<VehicleType>.from(json["VehicleTypes"]!.map((x) => VehicleType.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Country": country,
    "Mfr_CommonName": mfrCommonName,
    "Mfr_ID": mfrId,
    "Mfr_Name": mfrName,
    "VehicleTypes": vehicleTypes == null ? [] : List<dynamic>.from(vehicleTypes!.map((x) => x.toJson())),
  };
}

class VehicleType {
  bool? isPrimary;
  Name? name;

  VehicleType({
    this.isPrimary,
    this.name,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) => VehicleType(
    isPrimary: json["IsPrimary"],
    name: nameValues.map[json["Name"]]!,
  );

  Map<String, dynamic> toJson() => {
    "IsPrimary": isPrimary,
    "Name": nameValues.reverse[name],
  };
}

enum Name {
  BUS,
  INCOMPLETE_VEHICLE,
  LOW_SPEED_VEHICLE_LSV,
  MOTORCYCLE,
  MULTIPURPOSE_PASSENGER_VEHICLE_MPV,
  OFF_ROAD_VEHICLE,
  PASSENGER_CAR,
  TRAILER,
  TRUCK
}

final nameValues = EnumValues({
  "Bus": Name.BUS,
  "Incomplete Vehicle": Name.INCOMPLETE_VEHICLE,
  "Low Speed Vehicle (LSV)": Name.LOW_SPEED_VEHICLE_LSV,
  "Motorcycle": Name.MOTORCYCLE,
  "Multipurpose Passenger Vehicle (MPV)": Name.MULTIPURPOSE_PASSENGER_VEHICLE_MPV,
  "Off Road Vehicle": Name.OFF_ROAD_VEHICLE,
  "Passenger Car": Name.PASSENGER_CAR,
  "Trailer": Name.TRAILER,
  "Truck": Name.TRUCK
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
      reverseMap = map.map((k, v) => MapEntry(v, k));
      return reverseMap;
  }
}
