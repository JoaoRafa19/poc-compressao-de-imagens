import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController cameraController;

  bool isTakingPicture = false;

  @override
  void initState() {
    var list = Injector.get<List<CameraDescription>>();
    cameraController =
        CameraController((list.first), ResolutionPreset.ultraHigh);
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
                FutureBuilder(
                  future: cameraController.initialize(),
                  builder: (context, snapshot) {
                    switch (snapshot) {
                      case AsyncSnapshot(
                          connectionState:
                              ConnectionState.waiting || ConnectionState.active
                        ):
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case AsyncSnapshot(connectionState: ConnectionState.done):
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
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final nav = Navigator.of(context);
                        final foto = await cameraController.takePicture();
                        nav.pushNamed('/camera/confirm', arguments: foto);
                      } on Exception catch (e) {
                        print(e);
                      }
                    },
                    child: const Text('TIRAR FOTO'),
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
