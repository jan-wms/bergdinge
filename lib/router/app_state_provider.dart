import 'package:bergdinge/firebase/firebase_data_providers.dart';
import 'package:bergdinge/firebase/firebase_auth.dart';
import 'package:bergdinge/models/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStateProvider = AsyncNotifierProvider<_AppStateNotifier, AppState>(() {
  return _AppStateNotifier();
});

class _AppStateNotifier extends AsyncNotifier<AppState> {
  @override
  Future<AppState> build() async {
    final authState = await ref.watch(authStateChangesProvider.future);

    if (authState == null) {
      return AppState.unauthenticated;
    }

    if(state.value == AppState.loading) {
      return AppState.loading;
    }

    final userData = await ref.watch(userDataStreamProvider.future);

    final isSetupCompleted = userData['isSetupCompleted'] ?? false;

    if (!isSetupCompleted) {
      return AppState.needsSetup;
    }

    return AppState.ready;
  }

  void setLoading() {
    state = const AsyncData(AppState.loading);
  }
}
