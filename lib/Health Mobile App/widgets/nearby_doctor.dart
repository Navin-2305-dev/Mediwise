import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mediwise/Health%20Mobile%20App/models/doctor_model.dart';
import 'package:mediwise/Health%20Mobile%20App/widgets/doctor_page.dart';

class NearbyDoctor extends StatelessWidget {
  const NearbyDoctor({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(doctorsList.length, (index) {
        final doctor = doctorsList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Doc(doctor:doctor),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(doctor
                          .imageUrl), // Ensure images exist in assets folder
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      doctor.specialization,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow[700],
                          size: 18,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 6),
                          child: Text(
                            doctor.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                            "(${Random().nextInt(100) + 50} Reviews)"), // Random review count
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
