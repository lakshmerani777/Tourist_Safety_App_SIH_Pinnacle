import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/digital_id_service.dart';
import 'api_providers.dart';

class DigitalIdState {
  final DigitalIdData? data;
  final bool isLoading;
  final bool isIssuing;
  final String? error;

  const DigitalIdState({
    this.data,
    this.isLoading = false,
    this.isIssuing = false,
    this.error,
  });

  DigitalIdState copyWith({
    DigitalIdData? data,
    bool? isLoading,
    bool? isIssuing,
    String? error,
    bool clearError = false,
  }) =>
      DigitalIdState(
        data:      data      ?? this.data,
        isLoading: isLoading ?? this.isLoading,
        isIssuing: isIssuing ?? this.isIssuing,
        error:     clearError ? null : (error ?? this.error),
      );
}

class DigitalIdNotifier extends StateNotifier<DigitalIdState> {
  DigitalIdNotifier(this._ref) : super(const DigitalIdState());

  final Ref _ref;

  Future<void> fetchOrIssue() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final client = _ref.read(apiClientProvider);
      var data = await client.getDigitalId();
      if (data == null) {
        // No credential yet — try to issue one
        try {
          state = state.copyWith(isLoading: false, isIssuing: true);
          data = await client.issueDigitalId();
        } catch (issueErr) {
          final msg = issueErr.toString();
          if (msg.contains('Blockchain not configured') || msg.contains('503')) {
            state = state.copyWith(
              isLoading: false,
              isIssuing: false,
              error: 'Digital ID service is temporarily unavailable. Please try again later.',
            );
            return;
          }
          rethrow;
        }
      }
      state = state.copyWith(data: data, isLoading: false, isIssuing: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isIssuing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => fetchOrIssue();
}

final digitalIdProvider =
    StateNotifierProvider<DigitalIdNotifier, DigitalIdState>((ref) {
  return DigitalIdNotifier(ref);
});
