import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/logic/app_cubit.dart';
import 'package:my_project/logic/app_state.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/widgets/app_btn.dart';
import 'package:my_project/widgets/parcel_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: Text(state.isOnline ? 'Smart Post' : 'Smart Post (Offline)'),
            backgroundColor: state.isOnline ? Colors.blue : Colors.orange,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<AppCubit>().getParcels(),
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AppCubit>().logout();
                  Navigator.pushAndRemoveUntil<void>(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false,
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
                  child: Text('My Parcels', style: TextStyle(fontSize: 18, 
                  fontWeight: FontWeight.bold)),
                ),
                _buildParcels(state),
                _iot(context, state),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParcels(AppState state) {
    if (state.isParcelsLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), 
      child: CircularProgressIndicator()));
    } else if (state.parcels.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), 
      child: Text('No parcels found')));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: state.parcels.length,
      itemBuilder: (ctx, i) => ParcelCard(
        state.parcels[i],
        onTap: () {},
        onDelete: () {},
      ),
    );
  }

  Widget _iot(BuildContext context, AppState state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: state.isBoxOpen ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text('Box Temp: ${state.boxTemp}°C', 
          style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold,
           fontSize: 18)),
          const SizedBox(height: 15),
          Icon(state.isBoxOpen ? Icons.lock_open : Icons.lock, size: 50, 
          color: state.isBoxOpen ? Colors.green : Colors.blue),
          const SizedBox(height: 10),
          Text(state.isBoxOpen ? 'OPEN' : 'LOCKED', 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          AppBtn(
            state.isBoxOpen ? 'Close Box' : 'Open Smart Box',
            () => context.read<AppCubit>().toggleBox(),
            c: state.isBoxOpen ? Colors.grey : Colors.green,
          ),
        ],
      ),
    );
  }
}
