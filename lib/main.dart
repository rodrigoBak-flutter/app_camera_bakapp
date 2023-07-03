import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


/*

CON ESTE FICHERO PUEDO CONSEGUIR SACAR UNA FOTO A DIFERENTES OBJETOS Y QUE ME LOS RECONOZCA, CON ESTO, DETERMINO CUAL ES EL CONTENIDO QUE 
ME QUIERO LLEVAR DE CADA UNA DE LAS FOTOS QUE SACO

*/

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _imagePath;
  @override
  void initState() {
    super.initState();
  }

  Future<void> getImageFromCamera() async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }
    if (!isCameraGranted) {
      // No tengo permiso para la cámara.
      return;
    }
    // Generar ruta de archivo para guardar
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
    try {
      //Asegúrarse de esperar la llamada para detectarEdge.
      bool success = await EdgeDetection.detectEdge(
        imagePath,
        canUseGallery: true,
        androidScanTitle: 'Scaneando', // use custom localizations for android
        androidCropTitle: 'CORTE DE LA IMAGEN',
        androidCropBlackWhiteTitle: 'HACERLA BLANCO Y NEGRO',
        androidCropReset: 'FORMATO ORIGINAL',
      );
      print("success: $success");
    } catch (e) {
      print(e);
    }
    // Si el widget se eliminó del árbol mientras la plataforma asíncrona
    // el mensaje estaba en vuelo, queremos descartar la respuesta en lugar de llamar
    // setState para actualizar nuestra apariencia inexistente.
    if (!mounted) return;
    setState(() {
      _imagePath = imagePath;
    });
  }

  Future<void> getImageFromGallery() async {
    // Generar ruta de archivo para guardar
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
    try {
      //Asegúrese de esperar la llamada para detectarEdgeFromGallery.
      bool success = await EdgeDetection.detectEdgeFromGallery(
        imagePath,
        androidCropTitle:
            'CORTE DE LA IMAGEN', // use custom localizations for android
        androidCropBlackWhiteTitle: 'HACERLA BLANCO Y NEGRO',
        androidCropReset: 'FORMATO ORIGINAL',
      );
      //Si todo va bien, me ensela lo que ve
      print("success: $success");
    } catch (e) {
      //Si algo sale mal, nos muetra el error
      print(e);
    }
    // Si el widget se eliminó del árbol mientras la plataforma asíncrona
    // el mensaje estaba en vuelo, queremos descartar la respuesta en lugar de llamar
    // setState para actualizar nuestra apariencia inexistente.
    if (!mounted) return;
    setState(() {
      _imagePath = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ejemplo de camara'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ElevatedButton(
                  //Funcion para ir a la camara
                  onPressed: getImageFromCamera,
                  child: const Text('Tomar foto'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  //Funcion para ir a la galeria
                  onPressed: getImageFromGallery,
                  child: const Text('Subir archivo'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Image Path:'),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                child: Text(
                  //Mostrar la ruta de la imagen en mi dispositivo
                  _imagePath.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              //Ver la imagen en mi dispositivo
              Visibility(
                visible: _imagePath != null,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.file(
                      File(_imagePath ?? ''),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
