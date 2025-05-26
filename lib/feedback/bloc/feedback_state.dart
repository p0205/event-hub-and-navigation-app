part of 'feedback_bloc.dart';

sealed class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object> get props => [];
}

final class FeedbackInitialState extends FeedbackState {}

final class FeedbackLoadingState extends FeedbackState {}

final class FeedbackSubmittedState extends FeedbackState {}

final class FeedbackErrorState extends FeedbackState {
  final String message;

  const FeedbackErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class FeedbackCheckState extends FeedbackState {
  final bool hasFeedback;

  const FeedbackCheckState({required this.hasFeedback});

  @override
  List<Object> get props => [hasFeedback];
}

final class CheckFeedbackLoadingState extends FeedbackState {}