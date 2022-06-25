import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:infinity_scroll_with_bloc/comments/bloc/comments_bloc.dart';
import 'package:infinity_scroll_with_bloc/comments/widget/bottom_loader.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Infinity Scroll'),
      ),
      body: BlocProvider<CommentsBloc>(
        create: (context) =>
            CommentsBloc(httpClient: Client())..add(CommentsFetched()),
        child: const CommentsContent(),
      ),
    );
  }
}

class CommentsContent extends StatefulWidget {
  const CommentsContent({Key? key}) : super(key: key);

  @override
  State<CommentsContent> createState() => _CommentsContentState();
}

class _CommentsContentState extends State<CommentsContent> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentsBloc, CommentsState>(
      builder: (context, state) {
        switch (state.status) {
          case CommentsStatus.failure:
            return const Center(
              child: Text('Failed to fetch comments'),
            );
          case CommentsStatus.success:
            if (state.comments.isEmpty) {
              return const Center(
                child: Text('No comments'),
              );
            }

            return ListView.builder(
              itemCount: state.hasReachedMax
                  ? state.comments.length
                  : state.comments.length + 1,
              itemBuilder: (context, index) {
                return index >= state.comments.length
                    ? const BottomLoader()
                    : Card(
                        child: ListTile(
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.comments[index].email),
                              const SizedBox(height: 10),
                              Text(state.comments[index].body),
                            ],
                          ),
                        ),
                      );
              },
              controller: _scrollController,
            );

          default:
            return const Center(
              child: CircularProgressIndicator(),
            );
        }
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<CommentsBloc>().add(CommentsFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
