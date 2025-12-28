class ChatEndpoint{
  static const String baseLink = "/api/chatbot";
  // endpoint tao chat
  static const String CreateChat="$baseLink/chat";
  // endpoint tao session
  static const String CreateChatSession="$baseLink/sessions";
  //endpoint Lấy danh sách tất cả chat sessions của user /sessions/{user_id}
  static const String GetSessionUser="$baseLink/sessions";
  //Lấy lịch sử chat trong một session /sessions/{session_id}/messages
  static const String GetSessionId1="$baseLink/sessions";
  static const String GetSessionId2="messages";
  //Đổi tên session /sessions/{session_id}
  static const String UpdateSessionTitle="$baseLink/sessions";
  //Xóa session và toàn bộ messages /sessions/{session_id}
  static const String DeleteSession='$baseLink/sessions';
  //tạo document
  static const String CreateDocument='$baseLink/documents';
  //lấy tất cả document giới hạn 100
  static const String GetAllDocument='$baseLink/documents';
  //lấy chi tiết 1 document "/documents/{document_id}"
  static const String GetByDocument='$baseLink/documents';
  //     Tìm kiếm documents theo từ khóa
  static const String SearchDocument='$baseLink/documents/search/keyword';
  //Cập nhật document /documents/{document_id
  static const String UpdateDocument="$baseLink/documents";
  //Xóa document /documents/{document_id}
  static const String DeleteDocument="$baseLink/documents";
}