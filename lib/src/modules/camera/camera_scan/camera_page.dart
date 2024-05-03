import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:poc_compressao/src/modules/camera/camera_controller.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController cameraController;

  final controller = Injector.get<CameraPageController>();
  late CameraDescription description;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    var list = Injector.get<List<CameraDescription>>();
    description = list.first;
    cameraController =
        CameraController(description, controller.selectedResulution.value);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeOf = MediaQuery.sizeOf(context);
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.landscape) {
        return FutureBuilder(
          future: cameraController.initialize(),
          builder: (context, snapshot) {
            switch (snapshot) {
              case AsyncSnapshot(
                  connectionState:
                      ConnectionState.waiting || ConnectionState.active
                ):
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              case AsyncSnapshot(connectionState: ConnectionState.done):
                if (cameraController.value.isInitialized) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: sizeOf.width,
                          child: CameraPreview(
                            cameraController,
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              strokeWidth: 4,
                              strokeCap: StrokeCap.square,
                              color: Colors.orange,
                              radius: const Radius.circular(16),
                              dashPattern: const [1, 10, 1, 3],
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          margin: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () async => takePicture(context),
                            child: const SizedBox.shrink(),
                          ),
                        ),
                      )
                    ],
                  );
                }
            }
            return const Center(
              child: Text('Erro ao carregar câmera'),
            );
          },
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera Page'),
        ),
        body: Scaffold(
          appBar: AppBar(
            toolbarHeight: 10,
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 1),
              padding: const EdgeInsets.all(40),
              width: sizeOf.width * .9,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                border: Border(
                    top: BorderSide(), left: BorderSide(), right: BorderSide()),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const Text(
                    'TIRAR A FOTO AGORA',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Posicione o documento dentro do quadro abaixo e presione o botão para tirar a foto',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Spacer(),
                  FutureBuilder(
                    future: cameraController.initialize(),
                    builder: (context, snapshot) {
                      switch (snapshot) {
                        case AsyncSnapshot(
                            connectionState: ConnectionState.waiting ||
                                ConnectionState.active
                          ):
                          return const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        case AsyncSnapshot(
                            connectionState: ConnectionState.done
                          ):
                          if (cameraController.value.isInitialized) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: sizeOf.width * .5,
                                child: CameraPreview(
                                  cameraController,
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    strokeWidth: 4,
                                    strokeCap: StrokeCap.square,
                                    color: Colors.orange,
                                    radius: const Radius.circular(16),
                                    dashPattern: const [1, 10, 1, 3],
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ),
                            );
                          }
                      }
                      return const Center(
                        child: Text('Erro ao carregar câmera'),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  SizedBox(
                    width: sizeOf.width * .8,
                    height: 48,
                    child: Watch(
                      (context) {
                        return ElevatedButton(
                          onPressed: () async => takePicture(context),
                          child: controller.isTakingPicture.value
                              ? const CircularProgressIndicator()
                              : const Text('TIRAR FOTO'),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> takePicture(BuildContext context) async {
    if (controller.isTakingPicture.value) return;
    try {
      controller.isTakingPicture.value = true;
      final nav = Navigator.of(context);
      final foto = await cameraController.takePicture();
      controller.isTakingPicture.set(false);
      nav.pushNamed('/camera/confirm', arguments: foto);
    } on Exception catch (e, s) {
      log("Taking picture error", error: e, stackTrace: s);
    }
  }
}
