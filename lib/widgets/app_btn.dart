import 'package:flutter/material.dart';

class AppBtn extends StatelessWidget {
  final String t;
  final VoidCallback o;
  final Color? c;
  const AppBtn(this.t, this.o, {super.key, this.c});
  @override
  Widget build(BuildContext bc) => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: c ?? Colors.blue[800],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: o,
      child: Text(
        t,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
