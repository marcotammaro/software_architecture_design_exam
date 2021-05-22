import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/models/message.dart';
import 'events/messages_event.dart';

class MessagesBloc extends Bloc<MessagesEvent, List<Message>> {
  MessagesBloc() : super([]);

  @override
  Stream<List<Message>> mapEventToState(MessagesEvent event) async* {
    switch (event.type) {
      case MessagesEventType.add:
        List<Message> newState = List.from(state);
        newState.add(event.message);
        yield newState;
        break;
      case MessagesEventType.delete:
        yield state;
        break;
      default:
        addError(Exception('unsupported event'));
    }
  }
}
