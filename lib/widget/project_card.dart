// import 'package:flutter/material.dart';
// import 'package:researchtool/api/project.dart';

// class ProjectCard extends StatelessWidget {
//   const ProjectCard({super.key, required this.name, required this.id});
//   final String name;
//   final int id;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: SizedBox(
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.circle_outlined,
//                         color: Colors.grey, size: 18),
//                     const SizedBox(
//                       width: 12,
//                     ),
//                     Text(
//                       name,
//                       style: const TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ],
//                 ),
//                 Positioned(
//                     right: 24,
//                     child: InkWell(
//                       onTap: () {
//                         ProjectAPI.deleteProject(id);
                        
//                       },
//                       child: const Icon(
//                         Icons.cancel,
//                         color: Colors.grey,
//                       ),
//                     ))
//               ],
//             ),
//             const Divider(
//               color: Colors.grey,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
