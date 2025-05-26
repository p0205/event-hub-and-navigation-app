part of 'feedback_bloc.dart';

@immutable
sealed class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object> get props => [];
}

class SubmitFeedbackEvent extends FeedbackEvent {
  final Feedback feedback;
  final int eventId;

  const SubmitFeedbackEvent({required this.feedback, required this.eventId});

  @override
  List<Object> get props => [feedback, eventId];
}

class CheckUserFeedbackEvent extends FeedbackEvent {
  final int eventId;
  final int userId;

  const CheckUserFeedbackEvent({
    required this.eventId,
    required this.userId,
  });

  @override
  List<Object> get props => [eventId, userId];
}
