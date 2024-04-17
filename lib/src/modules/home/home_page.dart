import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:poc_compressao/src/modules/home/home_controller.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int files = 0;

  final controller = Injector.get<HomeController>();
  late OverlayEntry overlay = OverlayEntry(builder: (c) {
    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: Container(
            decoration:
                BoxDecoration(color: Colors.grey.shade200.withOpacity(0.01)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Watch(
                    (_) => Text(
                      controller.messages.value ?? "",
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                        fontStyle: FontStyle.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Watch((context) {
                    return CircularProgressIndicator(
                      strokeWidth: 5,
                      value: controller.sendProgress.value,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  });

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.images.listen(context, () {
      setState(() {});
    });
    controller.erros.listen(context, () {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("${controller.erros.value}")));
    });
    controller.loading.listen(context, () {
      if (controller.loading.value) {
        Overlay.of(context).insert(overlay);
      } else {
        overlay.remove();
      }
    });
    final sizeOf = MediaQuery.sizeOf(context);
    return Scaffold(
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
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: controller.images.value?.length,
                  itemBuilder: (context, index) {
                    if (controller.images.value != null) {
                      final imageList = Uint8List.fromList(
                          controller.images.value![index].base64Image);
                      return Card(
                        child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              fit: BoxFit.cover,
                              image: MemoryImage(
                                imageList,
                              ),
                            )),
                            child: SizedBox.expand(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Checkbox(
                                  onChanged: (val) {
                                    if (controller.images.value?[index] !=
                                        null) {
                                      var element = controller.images.value!
                                          .removeAt(index);
                                      element = element.copyWith(selected: val);
                                      controller.images.value = [
                                        element,
                                        ...controller.images.value ?? []
                                      ];
                                    }
                                  },
                                  value: controller
                                      .images.value?[index].isSelected,
                                ),
                              ),
                            )),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          await controller.sendImages();
                        },
                        child: const Text(
                          'ENVIAR',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            await Navigator.of(context).pushNamed('/camera');
                            await controller.init();
                          },
                          child: const Text(
                            'TIRAR FOTOS',
                          )),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DocumentBoxWidget extends StatelessWidget {
  final bool uploaded;
  final Widget icon;
  final String label;
  final int totalFiles;
  final VoidCallback? onTap;

  const DocumentBoxWidget(
      {super.key,
      this.onTap,
      required this.uploaded,
      required this.icon,
      required this.label,
      required this.totalFiles});

  @override
  Widget build(BuildContext context) {
    final totalFilesLabel = totalFiles > 0 ? '($totalFiles)' : '';
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: uploaded ? Colors.orange : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orangeAccent),
          ),
          child: Column(
            children: [
              Expanded(child: icon),
              Text(
                '$label $totalFilesLabel',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}