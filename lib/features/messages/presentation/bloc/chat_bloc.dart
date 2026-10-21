import 'package:bloc/bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../data/models/chat_message.dart';
import '../../data/repositories/messages_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required MessagesRepository repository, int? currentUserId})
    : _repository = repository,
      super(ChatState(currentUserId: currentUserId)) {
    on<ChatLoadRequested>(_onLoadRequested);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMessageCleared>(_onMessageCleared);
  }

  final MessagesRepository _repository;

  Future<void> _onLoadRequested(
    ChatLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessage: true));

    try {
      final currentUserId =
          state.currentUserId ?? await _repository.getCurrentUserId();
      final messages = await _repository.getMessages(
        friendId: event.friendId,
        currentUserId: currentUserId,
      );

      emit(
        state.copyWith(
          currentUserId: currentUserId,
          messages: messages,
          isLoading: false,
        ),
      );
    } catch (_) {
      // Preserve the original behaviour: show sample messages when the
      // endpoint is unreachable or the session has expired.
      emit(
        state.copyWith(
          messages: _sampleMessages(event.isArabic),
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    final optimistic = ChatMessage(
      text: text,
      isMe: true,
      time: DateTime.now(),
      isRead: false,
    );

    emit(
      state.copyWith(
        messages: [optimistic, ...state.messages],
        isSending: true,
        clearMessage: true,
      ),
    );

    try {
      await _repository.sendMessage(friendId: event.friendId, message: text);

      emit(
        state.copyWith(
          messages: state.messages
              .map(
                (message) => identical(message, optimistic)
                    ? message.copyWith(isRead: true)
                    : message,
              )
              .toList(),
          isSending: false,
          message: event.isArabic ? 'تم إرسال الرسالة' : 'Message sent',
          isSuccess: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isSending: false,
          message: error.message,
          isSuccess: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSending: false,
          message: event.isArabic
              ? 'فشل إرسال الرسالة'
              : 'Failed to send message',
          isSuccess: false,
        ),
      );
    }
  }

  void _onMessageCleared(ChatMessageCleared event, Emitter<ChatState> emit) {
    emit(state.copyWith(clearMessage: true));
  }

  List<ChatMessage> _sampleMessages(bool isArabic) {
    return [
      ChatMessage(
        text: isArabic ? 'تفاعل ▲ مع رسالتك' : 'Reacted ▲ to your message',
        isMe: false,
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      ChatMessage(
        text: '🟡❤❤️',
        isMe: true,
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      ChatMessage(
        text: isArabic ? 'آخر حية في الكرتون' : 'Last snake in the cartoon',
        isMe: true,
        time: DateTime.now().subtract(const Duration(days: 7)),
        isRead: true,
      ),
      ChatMessage(
        text: isArabic
            ? 'أنا عبود الجيشي على TikTok'
            : 'I am Aboud Al-Jayshi on TikTok',
        isMe: false,
        time: DateTime.now().subtract(const Duration(days: 13)),
        isRead: true,
      ),
      ChatMessage(
        text: 'Instant Invoicing with QuickBooks',
        isMe: false,
        time: DateTime.now().subtract(const Duration(days: 20)),
        isRead: true,
      ),
      ChatMessage(
        text: isArabic
            ? 'حلو جدا وفقك الله استمر'
            : 'Very nice, may God help you continue',
        isMe: false,
        time: DateTime.now().subtract(const Duration(days: 23)),
        isRead: true,
      ),
      ChatMessage(
        text: 'https://protfilo-na.netlify.app/',
        isMe: true,
        time: DateTime.now().subtract(const Duration(days: 23)),
        isRead: true,
      ),
      ChatMessage(
        text: isArabic ? 'تم إرسال مرفق' : 'You sent an attachment',
        isMe: true,
        time: DateTime.now().subtract(const Duration(days: 24)),
        isRead: true,
      ),
    ];
  }
}
