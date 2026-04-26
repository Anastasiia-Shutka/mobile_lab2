import 'package:my_project/domain/models/user.dart';

class AppState {
  final User? user;
  final bool isLoading;
  final bool isOnline;
  final String boxTemp;
  final bool isBoxOpen;
  final List<String> parcels;
  final bool isParcelsLoading;

  AppState({
    this.user,
    this.isLoading = true,
    this.isOnline = true,
    this.boxTemp = '--',
    this.isBoxOpen = false,
    this.parcels = const [],
    this.isParcelsLoading = false,
  });

  AppState copyWith({
    User? user, bool? isLoading, bool? isOnline, String? boxTemp, 
    bool? isBoxOpen, List<String>? parcels, bool? isParcelsLoading,
  }) {
    return AppState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      boxTemp: boxTemp ?? this.boxTemp,
      isBoxOpen: isBoxOpen ?? this.isBoxOpen,
      parcels: parcels ?? this.parcels,
      isParcelsLoading: isParcelsLoading ?? this.isParcelsLoading,
    );
  }
}
