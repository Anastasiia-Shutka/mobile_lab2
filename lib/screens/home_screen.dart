import 'package:flutter/material.dart';
import 'package:my_project/logic/auth_provider.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/widgets/app_btn.dart';
import 'package:my_project/widgets/parcel_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<String>> _parcelsFuture;
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(auth.isOnline ? 'Smart Post' : 'Smart Post (Offline)'),
        backgroundColor: auth.isOnline ? Colors.blue : Colors.orange,
        actions: [
          // 1. Оновити
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final freshParcels = auth.getParcels();
              setState(() {
                _parcelsFuture = freshParcels;
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushAndRemoveUntil<void>(
                context,
                MaterialPageRoute<void>(builder: (context) => 
                const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'My Parcels',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<List<String>>(
              future: _parcelsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Error loading parcels'),
                    ),
                  );
                }

                final parcels = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: parcels.length,
                  itemBuilder: (ctx, i) => ParcelCard(
                    parcels[i],
                    onTap: () {},
                    onDelete: () {},
                  ),
                );
              },
            ),
            _iot(auth),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _parcelsFuture = context.read<AuthProvider>().getParcels();
  }

  Widget _iot(AuthProvider auth) {
    return Container(
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
          Text(
            'Box Temp: ${auth.boxTemp}°C',
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
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
