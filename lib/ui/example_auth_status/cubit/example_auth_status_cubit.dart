import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'example_auth_status_state.dart';

class ExampleAuthStatusCubit extends Cubit<ExampleAuthStatusState> {
  ExampleAuthStatusCubit() : super(ExampleAuthStatusInitial());
}
