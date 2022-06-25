import 'package:equatable/equatable.dart';

class Comments extends Equatable {
  final int id;
  final String email;
  final String body;

  const Comments({required this.id, required this.email, required this.body});

  @override
  List<Object?> get props => [
        id,
        email,
        body,
      ];
}
