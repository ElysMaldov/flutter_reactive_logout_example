import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'example_auth_status_event.dart';
part 'example_auth_status_state.dart';

class ExampleAuthStatusBloc
    extends Bloc<ExampleAuthStatusEvent, ExampleAuthStatusState> {
  ExampleAuthStatusBloc() : super(ExampleAuthStatusInitial()) {
    on<ExampleAuthStatusEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
