import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    controller.images.listen(context, () {
      setState(() {});
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
                child: Builder(builder: (context) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: controller.images.value?.length,
                    itemBuilder: (context, index) {
                      if (controller.images.value != null) {
                        return Card(
                          child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(
                                  base64Decode(controller
                                      .images.value![index].base64Image),
                                ),
                              )),
                              child: SizedBox.expand(
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Checkbox(
                                    onChanged: (val) {},
                                    value: false,
                                  ),
                                ),
                              )),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }),
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
                        onPressed: () {},
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
                            final image = await Navigator.of(context)
                                .pushNamed('/camera');
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
