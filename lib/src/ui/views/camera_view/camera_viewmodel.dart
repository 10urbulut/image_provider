import 'package:adv_camera/adv_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_provider/src/app/enums.dart';
import 'package:image_provider/src/models/image_export.dart';
import 'package:image_provider/src/services/path_service.dart';
import 'package:image_provider/src/services/permission_services.dart';
import 'package:image_provider/src/utils/compress_image.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraViewModel with ChangeNotifier {
  AdvCameraController? _controller;

  ImageExport? _imageExport;

  FlashType? _flashType;

  String? _lastImage;

  bool _viewDidLoad = false;
  bool get viewDidLoad => _viewDidLoad;

  final _permissionService = PermissionServices();
  final _pathService = PathService();

  String? _imageSavePath;

  bool _hasCameraPermission = false;

  AdvCameraController? get controller => this._controller;
  FlashType? get flashType => this._flashType;
  String? get lastImage => this._lastImage;
  bool get hasCameraPermission => this._hasCameraPermission;

  Future<void> getData() async {
    await Future.delayed(Duration(milliseconds: 200));
    this._flashType = FlashType.auto;
    this._imageExport = ImageExport.camera();
    this._imageSavePath = await this._pathService.getImagePath();
    await requestCameraPermission();
    _viewDidLoad = true;
    notifyListeners();
  }

  Future<void> requestCameraPermission() async {
    final permissionStatus = await this._permissionService.getCameraRequest();
    this._hasCameraPermission = permissionStatus;
  }

  Future<void> setCameraController(AdvCameraController value) async {
    this._controller = value;
    if (_imageSavePath != null)
      await this._controller!.setSavePath(this._imageSavePath!);
  }

  Future<void> captureImage() async {
    await HapticFeedback.mediumImpact();
    await _controller?.captureImage();
  }

  Future<void> onCapture(String path) async {
    this._lastImage = path;
    final byteData = await getImageCompressed(RepositoryType.Camera, path);
    this._imageExport!.images!.add(byteData);
    notifyListeners();
  }

  void setFlashMode(FlashType value) async {
    this._flashType = value;
    await this._controller?.setFlashType(value);
    notifyListeners();
  }

  void returnData(BuildContext context) async {
    await this.disposeCamera();
    Navigator.pop(context, this._imageExport);
  }

  Future<void> disposeCamera() async {
    await this._controller?.turnOffCamera();
  }
}
