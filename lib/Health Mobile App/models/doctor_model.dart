import 'dart:math';

class DoctorModel {
  final String name;
  final String specialization;
  final String imageUrl;
  final double rating;
  final String biography;
  final List<Map<String, String>> history;
  final List<Map<String, String>> appointments;

  DoctorModel({
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.rating,
    required this.biography,
    required this.history,
    required this.appointments,
  });
}

List<DoctorModel> generateDoctors() {
  final List<String> names = [
    "Dr. Bruce Banner", "Dr. Tony Stark", "Dr. Stephen Strange", "Dr. Jane Foster",
    "Dr. Hank Pym", "Dr. Carol Danvers", "Dr. Otto Octavius", "Dr. Victor Von Doom",
    "Dr. Reed Richards", "Dr. Charles Xavier"
  ];

  final List<String> specializations = [
    "General Surgery", "Cardiology", "Neurology", "Pediatrics", "Orthopedics",
    "Dermatology", "Oncology", "Psychiatry", "Endocrinology", "Radiology"
  ];

  final List<String> bios = List.generate(
    10,
    (index) => "Experienced in ${specializations[index]} with over ${Random().nextInt(10) + 5} years of expertise."
  );

  final List<String> images = List.generate(10, (index) => "assets/doctor/doc${(index + 1)%4}.png");

  return List.generate(10, (index) {
    return DoctorModel(
      name: names[index],
      specialization: specializations[index],
      imageUrl: images[index],
      rating: double.parse(((Random().nextDouble() * 2) + 3.0).toStringAsFixed(1)),
      biography: bios[index],
      history: [
        {'title': 'Medical Education', 'subtitle': 'University of ${specializations[index]}'},
        {'title': 'Residency', 'subtitle': '${Random().nextInt(5) + 2} years at a reputed hospital'},
      ],
      appointments: [
        {'day': 'Monday', 'date': 'June 15th'},
        {'day': 'Wednesday', 'date': 'June 17th'},
        {'day': 'Friday', 'date': 'June 19th'},
      ],
    );
  });
}

final List<DoctorModel> doctorsList = generateDoctors();