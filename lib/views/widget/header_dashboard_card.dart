import 'package:flutter/material.dart';

class HeaderDashboardCard extends StatefulWidget {
  final String nmUser;
  final String versionName;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  const HeaderDashboardCard({
    Key? key,
    required this.nmUser,
    required this.versionName,
    required this.onRefresh,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<HeaderDashboardCard> createState() => _HeaderDashboardCardState();
}

class _HeaderDashboardCardState extends State<HeaderDashboardCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromARGB(255, 68, 124, 194),
            Color.fromARGB(255, 40, 101, 170),
            Color.fromARGB(255, 1, 43, 80),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 40,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/ic_logo_damri_light.png', width: 90),
                const SizedBox(height: 20),
                Text(
                  "Halo, ${widget.nmUser}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Lets improve your performance every day',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                ),
                IconButton(
                  onPressed: widget.onRefresh,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Text(
                  'v${widget.versionName}',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
