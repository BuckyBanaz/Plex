import 'package:get/get.dart';
import 'package:plex_user/modules/controllers/location/location_permission_controller.dart';
import 'package:plex_user/routes/appRoutes.dart';

import '../../../models/user_models.dart';
class UserAddressController extends GetxController {

  final RxList<AddressModel> savedAddresses = <AddressModel>[].obs;
  final LocationController location = Get.put(LocationController());
  final RxBool isFetchingLocation = false.obs;
  final RxString currentLocationAddress = 'fetching_location'.tr.obs;

  @override
  void onInit() {
    super.onInit();
    currentLocationAddress.bindStream(location.currentAddress.stream);
    loadDummyAddresses();
    fetchCurrentLocation();
  }

  void loadDummyAddresses() {
    savedAddresses.assignAll([
      AddressModel(
        id: 1,
        addressAs: 'home'.tr,
        address: 'Near happu ki dukan, Puthi Mangal Khan',
        locality: 'Puthi Mangal Khan',
        // phoneNumber: '+91-9812003854',
        isDefault: true,
        location: LocationModel(latitude: 28.99, longitude: 76.58),
      ),
      AddressModel(
        id: 2,
        addressAs: 'work'.tr,
        address: 'Near Bus stand, Near kiryana store, Puthinagal Khan, Hisar',
        locality: 'Puthinagal Khan, Hisar',
        // phoneNumber: '+91-8901414107',
        isDefault: false,
        location: LocationModel(latitude: 29.14, longitude: 75.72),
      ),
      AddressModel(
        id: 3,
        addressAs: 'other'.tr,
        address: 'Near happu ki dukan, Puthi Mangal Khan, India',
        locality: 'Puthi Mangal Khan, India',
        // phoneNumber: '+91-8901414107',
        isDefault: false,
        location: LocationModel(latitude: 28.99, longitude: 76.58),
      ),
    ]);
  }

  void fetchCurrentLocation() async {
    isFetchingLocation.value = true;
    currentLocationAddress.value = 'fetching_location'.tr;
    currentLocationAddress.value =
    'Puthi Mangal Khan, Hisar';
    isFetchingLocation.value = false;
  }


  void goToAddAddressScreen() {
    Get.toNamed(AppRoutes.addUserAddress);

  }

  void selectSavedAddress(AddressModel address) {
    Get.back();
    Get.snackbar(
      'address_selected'.tr,
      '${address.addressAs}: ${address.address}',
    );
  }

  void editAddress(AddressModel address) {
    Get.snackbar('Edit', 'Editing address: ${address.addressAs}');
  }

  void deleteAddress(AddressModel address) {
    savedAddresses.remove(address);
    Get.snackbar('Deleted', 'Address ${address.addressAs} removed');
  }
}
