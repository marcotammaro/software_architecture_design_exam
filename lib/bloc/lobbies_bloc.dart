import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forat/models/lobby.dart';
import 'events/lobbies_event.dart';

class LobbiesBloc extends Bloc<LobbiesEvent, List<Lobby>> {
  LobbiesBloc() : super([]);

  @override
  Stream<List<Lobby>> mapEventToState(LobbiesEvent event) async* {
    switch (event.type) {
      case LobbiesEventType.add:
        List<Lobby> newState = List.from(state);
        newState.add(event.lobby);
        newState.sort((a, b) {
          if (a.lastMessage == null || b.lastMessage == null) return 0;
          return a.lastMessage.dateTime.compareTo(b.lastMessage.dateTime);
        });

        yield newState.reversed.toList();
        break;
      case LobbiesEventType.delete:
        // TODO
        yield state;
        break;
      case LobbiesEventType.deleteAll:
        yield [];
        break;
      default:
        addError(Exception('unsupported event'));
    }
  }
}
