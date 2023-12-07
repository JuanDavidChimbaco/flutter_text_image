import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey globalKey = GlobalKey();

  String temperatura = "25°C";
  String humedad = "60%";
  String viento = "10 m/s";
  String texto = "esto se mostrara como imagen";

  //aqui se hace la magia
  Future<ui.Image> convertirTextoAImagen(String texto) async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    return image;
  }

  //aqui se guarda la imagen como jpg (pero se puede guardar como otros formatos de imagen)
  Future<void> guardarImagen() async {
    ui.Image image = await convertirTextoAImagen(texto);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    List<int> pngBytes = byteData!.buffer.asUint8List();

    if (kDebugMode) {
      print(pngBytes);
    }
    // Obtener el directorio de almacenamiento
    final directorio = await getApplicationDocumentsDirectory();
    final ruta = '${directorio.path}/imagen_generada.png';

    // Guardar la imagen localmente
    File(ruta).writeAsBytesSync(pngBytes);

    if (kDebugMode) {
      print('Imagen guardada en: $ruta');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Texto a Imagen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RepaintBoundary(
              key: globalKey,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperatura: $temperatura',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      'Humedad: $humedad',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Text(
                      'Viento: $viento',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => guardarImagen(),
              child: Text('Guardar Imagen'),
            ),
          ],
        ),
      ),
    );
  }
}
