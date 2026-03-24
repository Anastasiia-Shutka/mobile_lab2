import 'package:flutter/material.dart';
import 'package:my_project/widgets/app_btn.dart';
import 'package:my_project/widgets/parcel_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Smart Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          )
        ],
      ),

      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Expanded(child: _list()),
                const VerticalDivider(width: 1), 
                SizedBox(
                  width: 350,
                  child: _iot(),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(child: _list()),
                _iot(), 
              ],
            ),
    );
  }

  Widget _list() {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        const ParcelCard('Parcel #001 - In Hub'),
        const ParcelCard('Parcel #002 - Delivery'),
        const ParcelCard('Parcel #003 - Arrived'),
      ],
    );
  }

  Widget _iot() {
    return Container(
      height: 220, 
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isOpen ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isOpen ? Icons.lock_open : Icons.lock,
            size: 50,
            color: _isOpen ? Colors.green : Colors.blue,
          ),
          const SizedBox(height: 10),
          Text(
            _isOpen ? 'OPEN' : 'LOCKED',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 15),
          AppBtn(
            _isOpen ? 'Close Box' : 'Open Smart Box',
            () => setState(() => _isOpen = !_isOpen),
            c: _isOpen ? Colors.grey : Colors.green,
          ),
        ],
      ),
    );
  }
}
