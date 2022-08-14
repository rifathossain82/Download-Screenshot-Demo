import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {


  ScreenshotController controller = ScreenshotController();
  bool isLoading = false;
  final Dio dio = Dio();
  double progress = 0.0;
  String url = 'https://thumbs.dreamstime.com/b/environment-earth-day-hands-trees-growing-seedlings-bokeh-green-background-female-hand-holding-tree-nature-field-gra-130247647.jpg';

  Future<bool> saveVideo(String url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await requestPermission(Permission.storage)) {
          directory = (await getExternalStorageDirectory())!;
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/DSDApp";
          directory = Directory(newPath);
        } else {
          return false;
        }
      }
      else {
        if (await requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        }
        else {
          return false;
        }
      }

      File saveFile = File(directory.path + "/$fileName");

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
              setState(() {
                progress = value1 / value2;
              });
            });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }

      return false;

    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> saveScreenshot(Uint8List bytes, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await requestPermission(Permission.storage)) {
          directory = (await getExternalStorageDirectory())!;
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/DSDApp";
          directory = Directory(newPath);
        } else {
          return false;
        }
      }
      else {
        if (await requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        }
        else {
          return false;
        }
      }

      File saveFile = File(directory.path + "/$fileName");

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await ImageGallerySaver.saveImage(bytes, name: fileName);
        return true;
      }

      return false;

    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> requestPermission(Permission permission)async{
    if(await permission.isGranted){
      return true;
    }
    else{
      var result = await permission.request();
      if(result == PermissionStatus.granted){
        return true;
      }
      else{
        return false;
      }
    }
  }

  download()async{
    setState(() {
      isLoading = true;
    });

    bool downloaded = await saveVideo(
        url,
        "tree.jpg");
    if(downloaded){
      print("File Downloaded");
    }
    else{
      print("File Downloaded Failed");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download & Screenshot Demo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading ?
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
          ),
        ),
      )
          :
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildImage(),
            SizedBox(height: 16,),
            FlatButton.icon(
              onPressed: (){
                download();
              },
              icon: Icon(Icons.download),
              label: Text('Download'),
            ),
            FlatButton.icon(
              onPressed: ()async{
                await [Permission.storage].request();
                final image = await controller.captureFromWidget(buildImage());
                final result = await ImageGallerySaver.saveImage(image, name: 'ss5');
                print(result['filePath']);
              },
              icon: Icon(Icons.screenshot),
              label: Text('Screenshot'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImage(){
    return Container(
      height: 200,
      width: 320,
      child: Image.network(url, fit: BoxFit.cover,),
    );
  }
}
