import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart';
import 'package:infinity_scroll_with_bloc/comments/widget/comments_list_item.dart';
import 'package:stream_transform/stream_transform.dart';

part 'comments_event.dart';
part 'comments_state.dart';

const postLimit = 10;
const throttleDuration = Duration(milliseconds: 200);

EventTransformer<E> throttleDropable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final Client httpClient;

  CommentsBloc({required this.httpClient}) : super(const CommentsState()) {
    on<CommentsFetched>(
      _commentsFetched,
      transformer: throttleDropable(throttleDuration),
    );
  }

  Future<List<Comments>> _fetchComments([int startIndex = 1]) async {
    print('Request Index: $startIndex');
    final result = await httpClient.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/comments?_start=${startIndex}&_limit=${postLimit}'));
    if (result.statusCode == 200) {
      final body = json.decode(result.body) as List;

      return body
          .map((e) => Comments(
                id: e['id'] as int,
                email: e['email'] as String,
                body: e['body'] as String,
              ))
          .toList();
    }
    throw Exception('error fetching comments.');
  }

  Future<void> _commentsFetched(
      CommentsFetched event, Emitter<CommentsState> emit) async {
    if (state.hasReachedMax) return;

    try {
      if (state.status == CommentsStatus.initial) {
        final comments = await _fetchComments();
        return emit(state.copyWith(
          status: CommentsStatus.success,
          comments: comments,
          hasReachedMax: false,
        ));
      }

      final comments = await _fetchComments(state.comments.length);
      emit(comments.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: CommentsStatus.success,
              comments: List.of(state.comments)..addAll(comments),
              hasReachedMax: false,
            ));
    } catch (e) {
      emit(state.copyWith(status: CommentsStatus.failure));
    }
  }
}
