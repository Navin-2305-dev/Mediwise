import 'package:flutter/material.dart';
import 'package:mediwise/Health%20Mobile%20App/models/schedule_model.dart';
import 'package:mediwise/Health%20Mobile%20App/utils/color.dart';
import 'package:iconsax/iconsax.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  String selectedOption = "Upcoming";

  // Function to Reschedule Appointment
  Future<void> rescheduleAppointment(int index) async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (startTime == null) return;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: startTime.replacing(
          hour: startTime.hour + 1), // Default 1-hour duration
    );

    if (endTime == null) return;

    setState(() {
      scheduleDoctors[index].date =
          "${newDate?.day}/${newDate?.month}/${newDate?.year}";
      scheduleDoctors[index].time =
          "${startTime.format(context)} - ${endTime.format(context)}";
    });
  }

  // Function to Cancel Appointment
  void cancelAppointment(int index) {
    setState(() {
      scheduleDoctors.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 25),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Schedule",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                  const SizedBox(width: 25),
                ],
              ),
              const SizedBox(height: 10),
              // Options Row
              SizedBox(
                height: 50,
                width: deviceWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildOption("Upcoming"),
                    buildOption("Complete"),
                    buildOption("Result"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Dynamic Content
              Expanded(child: buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOption(String option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: selectedOption == option ? kPrimaryColor : Colors.transparent,
        ),
        child: Text(
          option,
          style: TextStyle(
            color: selectedOption == option ? Colors.white : Colors.black38,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    if (selectedOption == "Upcoming") {
      return buildUpcoming();
    } else if (selectedOption == "Complete") {
      return buildComplete();
    } else if (selectedOption == "Result") {
      return buildResult();
    }
    return const SizedBox.shrink();
  }

  Widget buildUpcoming() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: scheduleDoctors.length,
      itemBuilder: (context, index) {
        final doctor = scheduleDoctors[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            width: double.infinity,
            height: 215,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: secondaryBgColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(doctor.profile),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            doctor.position,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black45),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    height: 35,
                    width: 290,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Icon(Iconsax.calendar_1, color: Colors.black54),
                        Text(doctor.date,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black45)),
                        const SizedBox(width: 10),
                        const Icon(Iconsax.clock, color: Colors.black54),
                        Text(doctor.time,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black45)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel Button
                      GestureDetector(
                        onTap: () => cancelAppointment(index),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: kPrimaryColor),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 5),
                            child: Text("Cancel",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: kPrimaryColor)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Reschedule Button
                      GestureDetector(
                        onTap: () => rescheduleAppointment(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            child: Text("Reschedule",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildComplete() =>
      const Center(child: Text("No completed appointments"));

  Widget buildResult() => const Center(child: Text("No results available"));
}
