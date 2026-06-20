import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/presensi_provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final presensiProvider = Provider.of<PresensiProvider>(context, listen: false);
    final weeklySchedules = presensiProvider.getWeeklySchedules();
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2980B9),
        title: const Text(
          'Kalender Akademik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: days.length,
        itemBuilder: (context, index) {
          String day = days[index];
          List<Map<String, dynamic>> schedules = weeklySchedules[day] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (schedules.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
                  child: Text(
                    'Tidak ada jadwal kuliah.',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              ...schedules.map((schedule) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2980B9).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_rounded, color: Color(0xFF2980B9)),
                    ),
                    title: Text(
                      schedule['nama'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            '${schedule['jamMulai']} - ${schedule['jamSelesai']}',
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16), // Jarak antar hari
            ],
          );
        },
      ),
    );
  }
}
