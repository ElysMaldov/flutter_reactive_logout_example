import 'package:rxdart/rxdart.dart';

/// Stores [PublishSubject] that acts as signals for listeners to trigger something
/// without worrying about the value.
class AppSignalsService {
  final _logoutController = PublishSubject();
  Stream<void> get logoutSignal => _logoutController.stream;
}
