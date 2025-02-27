// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';

// class StorageServices with ChangeNotifier{
//   //firebase storage
// final frebaseStorage = FirebaseStorage.instance;

  
//  // ages are stored in firebase as download URLs
//   List<String>_imageUrls = [];
  

//   //loading status

//   bool _isLoading = false;

//   //uploading 
  
//   bool _isUploading = false; 


//   /*

//   GETTERS

//   */

//   List<String> get imageUrls => _imageUrls;
//   bool get  isLoading => _isLoading;
//   bool get  isUploading => _isUploading;


//    /*

//   READ IMAGES

//   */

//   Future<void> fetchImages() async{
//     _isLoading = true;

//     //get the list under the directory
//     final ListResult result = await frebaseStorage.ref('uploaded_images/').listAll();

//     //get the download url for each images
//     final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

//     //uploading url
//     _imageUrls = urls;

//     //loading finished
//     _isLoading = false;

//     //uploading UI
//     notifyListeners();
//   }
  

//    /*

//   DELETE IMAGES

//   */

//   Future<void>deleteImages(String imageUrl) async{
//     try{
//       _imageUrls.remove(imageUrl);

//       final String path = extractPathFromUrl(imageUrl);
//       await frebaseStorage.ref(path).delete();
//     }
//     catch(e){
//       print("Error deleting image:$e");
//     }
//     notifyListeners();
//   }

//   String extractPathFromUrl(String url){
//     Uri uri = Uri.parse(url);

//     String encodedpath = uri.pathSegments.last;
//     return Uri.decodeComponent(encodedpath);

//   }

//    /*

//   UPLOAD IMAGES

//   */
  
// }