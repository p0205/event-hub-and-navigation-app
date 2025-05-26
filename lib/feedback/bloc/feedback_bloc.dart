import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/models/feedback.dart';
import 'package:event_hub_and_navigation_app/repositories/feedback_repository.dart';
import 'package:meta/meta.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FeedbackRepository feedbackRepository = FeedbackRepository();

  FeedbackBloc() : super(FeedbackInitialState()) {
    on<SubmitFeedbackEvent>(_submitFeedback);

    on<CheckUserFeedbackEvent>(_onCheckUserFeedback);
  }

  Future<void> _submitFeedback(
      SubmitFeedbackEvent event, Emitter<FeedbackState> emit) async {
    try {
      emit(FeedbackLoadingState());
      await feedbackRepository.addFeedback(event.eventId, event.feedback);
      emit(FeedbackSubmittedState());
    } catch (e) {
      emit(FeedbackErrorState(message: e.toString()));
    }
  }

  Future<void> _onCheckUserFeedback(
      CheckUserFeedbackEvent event,
      Emitter<FeedbackState> emit,
      ) async {
    try {
      emit(CheckFeedbackLoadingState());
      // Call your repository/service to check if feedback exists
      final hasFeedback = await feedbackRepository.checkUserFeedbackExists(
        eventId: event.eventId,
        userId: event.userId,
      );

      emit(FeedbackCheckState(hasFeedback: hasFeedback));
    } catch (e) {
      emit(FeedbackErrorState(message: 'Failed to check feedback status: ${e.toString()}'));
    }
  }

}
