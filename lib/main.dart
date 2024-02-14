import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController networkPathController = TextEditingController();

  final ImagePicker imgpicker = ImagePicker();
  String localImagePath = "";
  String nDecodedString = "";
  String lDecodedString = "";
  bool isDoneNetwork = false;
  bool isDoneLocal = false;

  localImageToBase64() async {
    try {
      var pickedFile = await imgpicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        localImagePath = pickedFile.path;
        print(localImagePath);


        File imagefile = File(localImagePath); //convert Path to File
        Uint8List imagebytes = await imagefile.readAsBytes(); //convert to bytes
        String base64string =
            base64.encode(imagebytes); //convert bytes to base64 string
        lDecodedString = base64string;
        print(base64string);



        setState(() {
          isDoneLocal = true;
        });
      } else {
        print("No image is selected.");
      }
    } catch (e) {
      print("error while picking file.");
    }
  }

  Future<String?> networkImageToBase64(String imageUrl) async {
    try {
      // Fetch the image data
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Encode the image bytes to base64
        final bytes = response.bodyBytes;
        final base64String = base64Encode(bytes);

        nDecodedString = base64String;
        setState(() {
          isDoneNetwork = true;
        });

        return base64String;
      } else {
        throw Exception('Failed to fetch image: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
      return null;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Image encoding to base64"),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: Column(children: [
                localImagePath != ""
                    ? Container(
                        width: double.infinity,
                        height: 200,
                        child: Image.file(
                          File(localImagePath),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        child: Text("No Image selected."),
                      ),

                //open button ----------------
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                    onPressed: () {
                      localImageToBase64();
                    },
                    child: Text("Choose from gallery")),

                lDecodedString != ""
                    ? SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Text(lDecodedString),
                )
                    : Text('Local decoded string goes here ..'),



                TextFormField(
                  controller: networkPathController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Paste your image link here'),
                ),
                ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                    onPressed: () {
                      networkImageToBase64(networkPathController.text);
                    },
                    child: Text('Convert network image')),
                Container(
                  height: 100,
                  child: isDoneNetwork
                      ? Text('network image converted to base64')
                      : Text('error occured'),
                ),
                SizedBox(height: 40),
                nDecodedString != ""
                    ? SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Text(nDecodedString),
                )
                    : Text('Network decoded string goes here ..'),

              ]),
            ),
          ],
        ),
      ),
    );
  }
}
