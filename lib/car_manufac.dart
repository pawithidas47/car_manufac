import 'package:car_manufac/car_mfr.dart';
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
