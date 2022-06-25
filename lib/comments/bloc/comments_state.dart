part of 'comments_bloc.dart';

enum CommentsStatus { initial, success, failure }

class CommentsState extends Equatable {
  final CommentsStatus status;
  final List<Comments> comments;
  final bool hasReachedMax;

  const CommentsState({
    this.status = CommentsStatus.initial,
    this.comments = const <Comments>[],
    this.hasReachedMax = false,
  });

  CommentsState copyWith({
    CommentsStatus? status,
    List<Comments>? comments,
    bool? hasReachedMax,
  }) =>
      CommentsState(
        status: status ?? this.status,
        comments: comments ?? this.comments,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      );

  @override
  String toString() {
    return 'CommentsState{status: $status, hasReachedMax: $hasReachedMax, comments: ${comments.length}}';
  }

  @override
  List<Object> get props => [status, comments, hasReachedMax];
}
