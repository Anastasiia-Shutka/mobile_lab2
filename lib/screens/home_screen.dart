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

  final List<String> _parcels = [
    'Parcel #001 - In Hub',
    'Parcel #002 - Delivery',
    'Parcel #003 - Arrived',
  ];

  final _controller = TextEditingController();

  void _addParcel() {
    _controller.clear();
    // ДОДАНО <void> ТУТ:
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Parcel'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                setState(() => _parcels.add(_controller.text.trim()));
                _controller.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editParcel(int index) {
    _controller.text = _parcels[index];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Parcel'),
        content: TextField(controller: _controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                setState(() => _parcels[index] = _controller.text.trim());
                _controller.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Smart Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: _addParcel,
            tooltip: 'Add New Parcel',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _list()),
                const VerticalDivider(width: 1),
                SizedBox(width: 350, child: _iot()),
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
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _parcels.length,
      itemBuilder: (context, index) {
        return ParcelCard(
          _parcels[index],
          onTap: () => _editParcel(index),
          onDelete: () => setState(() => _parcels.removeAt(index)),
        );
      },
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
