import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImpersonatedBusinessNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setBusinessId(String? id) {
    state = id;
  }
}

final impersonatedBusinessIdProvider =
    NotifierProvider<ImpersonatedBusinessNotifier, String?>(
      ImpersonatedBusinessNotifier.new,
    );
