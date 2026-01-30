import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

class AppSignals {
  final _log = Logger('AppSignals');

  final _logoutSignalSubject = PublishSubject<Null>();
  Stream<Null> get logoutSignalStream => _logoutSignalSubject.stream;

  Future<void> emitLogoutSignal() async {
    _log.info('Emitting logout signal');
    _logoutSignalSubject.add(null);
    _log.info('Logout signal emitted');
  }
}
