import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

part 'chat_api.g.dart';

@RestApi()
abstract class ChatApi {
  factory ChatApi(Dio dio, {String baseUrl}) = _ChatApi;

  @POST("/chat/rooms")
  Future<String> createChatRoom(@Field("customerName") String customerName);

  @POST("/chat/rooms/{roomId}/messages")
  Future<void> sendMessage(
      @Path("roomId") String roomId,
      @Body() Map<String, dynamic> messageData,
      );

  @GET("/chat/rooms/{roomId}/messages")
  Future<List<ChatMessage>> getMessages(@Path("roomId") String roomId);

  @GET("/chat/rooms/{roomId}")
  Future<ChatRoom> getChatRoom(@Path("roomId") String roomId);

  @PATCH("/chat/rooms/{roomId}/read")
  Future<void> markMessagesAsRead(@Path("roomId") String roomId);

  @PATCH("/chat/rooms/{roomId}/mark-read")
  Future<ChatRoom> markRoomAsRead(@Path("roomId") String roomId);

  @GET("/chat/rooms/staff")
  Future<List<ChatRoom>> getStaffChatRooms();

  // New endpoints aligned with backend
  @GET("/chat/rooms/staff/{staffId}")
  Future<List<ChatRoom>> getStaffRoomsByStaffId(@Path("staffId") String staffId);

  @GET("/chat/rooms/staff/unassigned")
  Future<List<ChatRoom>> getUnassignedRooms();

  @GET("/chat/rooms/customer/{customerId}")
  Future<ChatRoom> getCustomerChatRoom(@Path("customerId") String customerId);

  @PATCH("/chat/rooms/{roomId}/assign")
  Future<void> assignStaff(@Path("roomId") String roomId);

  @PATCH("/chat/rooms/{roomId}/close")
  Future<void> closeChatRoom(@Path("roomId") String roomId);

  @DELETE("/chat/rooms/{roomId}/messages/{messageId}")
  Future<void> deleteMessage(@Path("roomId") String roomId, @Path("messageId") String messageId);

  @DELETE("/chat/rooms/{roomId}")
  Future<void> deleteChatRoom(@Path("roomId") String roomId);
}