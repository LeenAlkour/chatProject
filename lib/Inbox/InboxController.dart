import 'package:get/get.dart';
import 'package:testnoti/Service/Http.dart';

class InboxController extends GetxController {
  var isSearchMode = false.obs;
  var isSelectionMode = false.obs;
  Http httpReq = Http();
  var chats = <dynamic>[].obs;
  var chatsSearch = <dynamic>[].obs;
  Future<void> getChats() async {
    dynamic response;
    response=
    await httpReq.get("displayAllChats");
    if(response.isEmpty) {
      chats.value =[];
    }
    else{

      chats.value=response as List;
    }

  }
  Future<void> getSearchChats(var val) async {
    dynamic response;
    response=
    await httpReq.post("search", {'name': val});
    if(response.isEmpty) {
      chatsSearch.value =[];
    }
    else{

      chatsSearch.value=response as List;
    }
  }
  void toggleSearchMode() {
    isSearchMode.value = !isSearchMode.value;
  }

  void updateSelectionMode(bool isSelected) {
    isSelectionMode.value = isSelected;
  }
}
