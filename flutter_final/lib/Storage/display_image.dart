import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DisplayImagesScreen extends StatefulWidget {
  @override
  _DisplayImagesScreenState createState() => _DisplayImagesScreenState();
}

class _DisplayImagesScreenState extends State<DisplayImagesScreen> {
  late Future<List<String>> imageUrls;

  @override
  void initState() {
    super.initState();
    imageUrls = fetchImages();
  }

  Future<List<String>> fetchImages() async {
    List<String> urls = [];
    final ListResult result = await FirebaseStorage.instance.ref().child("images").listAll();
    for (var ref in result.items) {
      String url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Images")),
      body: FutureBuilder<List<String>>(
        future: imageUrls,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Image.network(snapshot.data![index], height: 200);
            },
          );
        },
      ),
    );
  }
}
