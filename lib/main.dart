import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:image/image.dart' as img;
// import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey globalKey = GlobalKey();

  String temperatura = "25°C";
  String humedad = "60%";
  String viento = "10 m/s";
  String texto = "esto se mostrara como imagen";

  ///aqui se hace la magia: lo que el hace es convertir el contenido visual de los widgets en una imagen.
  ///en este caso tengo 4 variables pero solo me va a generear dos, por que son las unicas que estoy
  ///pintando en el widget.
  Future<ui.Image> convertirTextoAImagen(String texto) async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    return image;
  }

  //aqui se guarda la imagen como jpg (pero se puede guardar como otros formatos de imagen)
  Future<void> guardarImagen() async {
    // await checkAndRequestPermissions();

    ui.Image image = await convertirTextoAImagen(texto);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    List<int> pngBytes = byteData!.buffer.asUint8List();

    //muestra la imgen en bloques de bytes (no es importante)
    if (kDebugMode) {
      print(pngBytes);
    }

    // Obtener el directorio de almacenamiento externo
    final carpetaSeleccionada = await FilePicker.platform.getDirectoryPath();

    if (kDebugMode) {
      print(carpetaSeleccionada);
    }

    // Crear una carpeta personalizada (por ejemplo, "lectura") si no existe
    final carpetaApp = Directory(path.join(carpetaSeleccionada!, 'lectura'));
    if (!await carpetaApp.exists()) {
      await carpetaApp.create(recursive: true);
    }

    // Guardar la imagen en la carpeta personalizada
    final ruta = path.join(carpetaApp.path, 'imagen_generada.png');
    File(ruta).writeAsBytesSync(pngBytes);

    // Guardar la imagen localmente
    File(ruta).writeAsBytesSync(pngBytes);

    if (kDebugMode) {
      print('Imagen guardada en: $ruta');
    }
  }

  // //permisos
  // Future<void> checkAndRequestPermissions() async {
  //   if (await Permission.storage.request().isGranted) {
  //     // Los permisos ya fueron concedidos
  //   } else {
  //     // Los permisos aún no se han concedido, solicítalos
  //     Map<Permission, PermissionStatus> status = await [
  //       Permission.storage,
  //     ].request();

  //     if (status[Permission.storage] != PermissionStatus.granted) {
  //       // ignore: use_build_context_synchronously
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('Permiso necesario'),
  //           content: const Text(
  //               'La aplicación necesita permisos de almacenamiento para guardar la imagen.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Texto a Imagen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RepaintBoundary(
              key: globalKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperatura: $temperatura',
                      style: const TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      'Humedad: $humedad',
                      style: const TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => guardarImagen(),
              // onPressed: () {
              //   Share.share("compartir");
              // },
              // child: const Icon(Icons.share),
              child: const Text('Seleccionar Carpeta y Guardar Imagen'),
            ),
          ],
        ),
      ),
    );
  }
}
