import 'package:flutter/material.dart';

class ParcelCard extends StatelessWidget {
  final String n;
  const ParcelCard(this.n, {super.key});

  @override
  Widget build(BuildContext c) => Card(
    elevation: 2, 
    margin: const EdgeInsets.only(bottom: 12, left: 5, right: 5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue[50], 
        borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.inventory_2, color: Colors.blue[700]),
      ),
      title: Text(n, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
    ),
  );
}
