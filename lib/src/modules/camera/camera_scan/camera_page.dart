import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
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
    var list = Injector.get<List<CameraDescription>>();
    description = list.first;
    cameraController =
        CameraController(description, controller.selectedResulution.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sizeOf = MediaQuery.sizeOf(context);
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
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
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
                Text(
                  '${controller.selectedResulution.value.name.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Watch((context) {
                      return RotatedBox(
                        quarterTurns: -1,
                        child: Slider(
                            min: 0,
                            max: ResolutionPreset.values.length - 1 / 1.0,
                            divisions: ResolutionPreset.values.length - 1,
                            label: controller.selectedResulution.value.name,
                            value:
                                controller.selectedResulution.value.index / 1.0,
                            onChanged: (val) {
                              if (val >= 0 &&
                                  val < ResolutionPreset.values.length) {
                                final value = val.toInt();
                                controller.selectedResulution.value =
                                    ResolutionPreset.values[value];
                                setState(() {
                                  cameraController = CameraController(
                                      description,
                                      controller.selectedResulution.value);
                                });
                              }
                            }),
                      );
                    }),
                    Spacer(),
                    Watch((context) {
                      return FutureBuilder(
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
                      );
                    }),
                  ],
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
                        onPressed: controller.isTakingPicture.value
                            ? null
                            : () async {
                                if (controller.isTakingPicture.value) return;
                                try {
                                  controller.isTakingPicture.value = true;
                                  final nav = Navigator.of(context);
                                  final foto =
                                      await cameraController.takePicture();
                                  controller.isTakingPicture.value = false;
                                  nav.pushNamed('/camera/confirm',
                                      arguments: foto);
                                } on Exception catch (e, s) {
                                  controller.isTakingPicture.value = false;
                                  log("Taking picture error",
                                      error: e, stackTrace: s);
                                }
                              },
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
  }
}
