import 'atomic_state/atom.dart';
import 'atomic_state/auth_state.dart';

final authState = Atom<AuthState>(Initial());
final keyboardOpened = Atom<bool>(false);
