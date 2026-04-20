import 'package:get/get.dart';
import '../services/permission_service.dart';

class PermissionController extends GetxController {
  final PermissionService _service = PermissionService();

  var isLoading = true.obs;
  var isGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  Future<void> checkPermission() async {
    isLoading.value = true;

    final result = await _service.ensureUsagePermission();

    isGranted.value = result;
    isLoading.value = false;
  }

  Future<void> requestPermission() async {
    isLoading.value = true;

    final result = await _service.ensureUsagePermission();

    isGranted.value = result;
    isLoading.value = false;
  }
}
