// import 'package:flutter/material.dart';

// class AktifitasRitaseCard extends StatefulWidget {
//   final String ritase;
//   final String statusRitase;
//   final String kmAkhirValue;
//   final String kmAwalValue;
//   final VoidCallback mulaiRitase;
//   final VoidCallback akhiriRitase;
//   final VoidCallback riwayatRitase;
//   final VoidCallback getLmbRitaseList;

//   AktifitasRitaseCard({
//     super.key,
//     required this.ritase,
//     required this.statusRitase,
//     required this.kmAkhirValue,
//     required this.kmAwalValue,
//     required this.mulaiRitase,
//     required this.akhiriRitase,
//     required this.riwayatRitase,
//     required this.getLmbRitaseList,
//   });

//   @override
//   State<AktifitasRitaseCard> createState() => _AktifitasRitaseCardState();
// }

// class _AktifitasRitaseCardState extends State<AktifitasRitaseCard> {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(10),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Aktifitas Ritase',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     height: 50,
//                     width: 220,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (widget.statusRitase == "0" ||
//                             widget.statusRitase == "1" ||
//                             widget.statusRitase == "3") {
//                           setState(() {
//                             final parsed = double.tryParse(widget.kmAkhirValue);
//                             if (parsed != null) {
//                               String stringValue = parsed.toString();
//                               stringValue = stringValue.replaceAll(
//                                 RegExp(r'\.?0+$'),
//                                 '',
//                               );
//                               widget.kmAkhirValue = stringValue;
//                             }
//                           });
//                           print('km akhir $widget.kmAkhirValue');
//                           widget.mulaiRitase();
//                         } else if (widget.statusRitase == "2") {
//                           setState(() {
//                             final parsed = double.tryParse(widget.kmAwalValue);
//                             if (parsed != null) {
//                               String stringValue = parsed.toString();
//                               stringValue = stringValue.replaceAll(
//                                 RegExp(r'\.?0+$'),
//                                 '',
//                               );
//                               widget.kmAwalValue = stringValue;
//                             }
//                           });
//                           print('km awal: $widget.kmAwalValue');
//                           widget.akhiriRitase();
//                         }
//                       },

//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             widget.statusRitase == "0" ||
//                                     widget.statusRitase == "1" ||
//                                     widget.statusRitase == "3"
//                                 ? const Color(0xFF1A447F)
//                                 : widget.statusRitase == "2"
//                                 ? Colors.orange
//                                 : Colors.grey,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.statusRitase == "0" ||
//                                   widget.statusRitase == "1" ||
//                                   widget.statusRitase == "3"
//                               ? 'Mulai Ritase - ${widget.ritase}'
//                               : widget.statusRitase == "2"
//                               ? 'Akhiri Ritase - ${widget.ritase}'
//                               : 'Ritase',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Riwayat Ritase
//                   GestureDetector(
//                     onTap: () async {
//                       widget.getLmbRitaseList();
//                       widget.riwayatRitase();
//                     },
//                     child: Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF10A19D),
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: const Center(
//                         child: Icon(Icons.menu, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
