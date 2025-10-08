
import 'package:get/get.dart';
import 'package:plex_user/services/domain/repository/repository_imports.dart';

Future<void> initializeRepositories() async {
  try{

    // Get.put(FileRepository());
    Get.put(AuthRepository());


    print('repository initialize');

  }catch(e){}
}