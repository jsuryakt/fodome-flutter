import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fodome/pages/home.dart';
import 'package:fodome/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  primary: Colors.deepOrangeAccent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.0),
  ),
);
late DateTime timestamp;
firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;
final ImagePicker _picker = ImagePicker();

class Upload extends StatefulWidget {
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController shelflifeController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  bool _validateTitle = false;
  bool _validateDescription = false;
  bool _validateQuantity = false;
  bool _validateShelflife = false;
  bool _validateLocation = false;

  var lat = 0.0;
  var long = 0.0;
  PickedFile? file;
  bool isUploading = false;
  String postId = Uuid().v4();
  var image;

  bool _isSnackbarActive = false;
  final ScrollController _scrollController = ScrollController();
  bool locPressed = false;

  handleTakePhoto() async {
    Navigator.pop(context);
    PickedFile? file = await _picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
      imageQuality: 20,
    );
    setState(() {
      this.file = file;
      if (file != null) {
        this.image = File(file.path);
      }
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    PickedFile? file = await _picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );
    setState(() {
      this.file = file;
      if (file != null) {
        this.image = File(file.path);
      }
    });
  }

  selectImage(parentContext) {
    setState(() {
      // file = null;
      isUploading = false;
      locationController.clear();
      titleController.clear();
      descriptionController.clear();
      quantityController.clear();
      shelflifeController.clear();
      // postId = Uuid().v4();
    });
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                  child: Text("Photo with Camera"), onPressed: handleTakePhoto),
              SimpleDialogOption(
                  child: Text("Image from Gallery"),
                  onPressed: handleChooseFromGallery),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  Widget buildSplashScreen() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height: 260.0),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              child: Text(
                "Upload Food Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              style: raisedButtonStyle,
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    File compressedFile = await FlutterNativeImage.compressImage(
      file!.path,
      quality: 20,
    );
    setState(() {
      image = compressedFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    firebase_storage.Reference ref = storage.ref().child('post_$postId.jpg');
    firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
    print('File Uploaded');
    var imageUrl = await (await uploadTask).ref.getDownloadURL();
    String url = imageUrl.toString();
    return url;
  }

  createPostInFirestore(
      {required String mediaUrl,
      String? location,
      String? title,
      String? description,
      String? quantity,
      String? shelfLife}) {
    setState(() {
      timestamp = DateTime.now();
    });
    postsRef.doc(currentUser!.id).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": currentUser!.id,
      "username": currentUser!.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
      "title": title,
      "shelfLife": shelfLife,
      "quantity": quantity,
    });

    timelineRef.doc(postId).set({
      "postId": postId,
      "ownerId": currentUser!.id,
      "username": currentUser!.username,
      "displayName": currentUser!.displayName,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "title": title,
      "shelfLife": shelfLife,
      "quantity": quantity,
      "isVerified": false,
      "latitude": lat,
      "longitude": long,
    });
  }

  handleSubmit() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
              ),
              height: 20.0,
              width: 20.0,
            ),
            Text("   Uploading...")
          ],
        ),
      ),
    );
    compressImage();
    String mediaUrl = await uploadImage(image);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      title: titleController.text,
      description: descriptionController.text,
      quantity: quantityController.text,
      shelfLife: shelflifeController.text,
    );

    setState(() {
      file = null;
      postId = Uuid().v4();
    });
  }

  handlePost() {
    setState(() {
      isUploading = true;
      titleController.text.trim().isEmpty
          ? _validateTitle = true
          : _validateTitle = false;
      descriptionController.text.trim().isEmpty
          ? _validateDescription = true
          : _validateDescription = false;
      quantityController.text.trim().isEmpty
          ? _validateQuantity = true
          : _validateQuantity = false;
      shelflifeController.text.trim().isEmpty
          ? _validateShelflife = true
          : _validateShelflife = false;
      locationController.text.trim().isEmpty
          ? _validateLocation = true
          : _validateLocation = false;
    });

    if (titleController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty &&
        quantityController.text.trim().isNotEmpty &&
        shelflifeController.text.trim().isNotEmpty &&
        locationController.text.trim().isNotEmpty) {
      _scrollController.animateTo(_scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
      handleSubmit();
    } else {
      setState(() {
        isUploading = false;
      });
      if (!_isSnackbarActive) {
        setState(() {
          _isSnackbarActive = true;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Fill all fields!")))
            .closed
            .then((SnackBarClosedReason reason) {
          // snackbar is now closed.
          setState(() {
            _isSnackbarActive = false;
          });
        });
      }
    }
  }

  Text labelText(text) {
    return Text(
      text,
      style: TextStyle(fontSize: 17.0),
    );
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              setState(() {
                _validateTitle = false;
                _validateDescription = false;
                _validateQuantity = false;
                _validateShelflife = false;
                _validateLocation = false;

                lat = 0.0;
                long = 0.0;

                locPressed = false;
                isUploading = false;
                locationController.clear();
                titleController.clear();
                descriptionController.clear();
                quantityController.clear();
                shelflifeController.clear();
              });
              clearImage();
            }),
        title: Text(
          "Post Details",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!isUploading) handlePost();
            },
            child: Text(
              isUploading ? "Please Wait" : "Post",
              style: TextStyle(
                color: Colors.deepPurple,
                fontFamily: "Spotify",
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          if (isUploading) linearProgress(),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(image),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          Container(
            margin: EdgeInsets.only(
              left: 9.0,
              right: 9.0,
              // bottom: 15.0,
            ),
            child: Card(
              elevation: 3.0,
              // shadowColor: Colors.grey[300],
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: labelText("Title:"),
                    title: Container(
                      width: 250.0,
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Enter a title...",
                          errorText:
                              _validateTitle ? 'Title Can\'t Be Empty' : null,
                          // border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: labelText("Description:"),
                    title: Container(
                      width: 250.0,
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Enter a description...",
                          errorText: _validateDescription
                              ? 'Description Can\'t Be Empty'
                              : null,
                          // border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: labelText("Quantity:"),
                    title: Container(
                      width: 250.0,
                      child: TextField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          hintText:
                              "Enter details about weight and quantity...",
                          errorText: _validateQuantity
                              ? 'Quantity Can\'t Be Empty'
                              : null,
                          // border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: labelText("Shelf Life:"),
                    title: Container(
                      width: 250.0,
                      child: TextField(
                        controller: shelflifeController,
                        decoration: InputDecoration(
                          hintText: "Best time to eat before expiry...",
                          errorText: _validateShelflife
                              ? 'Shelf Life Can\'t Be Empty'
                              : null,
                          // border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.location_pin,
                      color: Colors.deepOrangeAccent,
                      size: 35.0,
                    ),
                    title: Container(
                      child: TextField(
                        enabled: false,
                        controller: locationController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: locPressed
                              ? "Locating.."
                              : "Click below to get Location",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  if (_validateLocation)
                    Center(
                      child: Text(
                        "Location Can\'t Be Empty\nPlease enable Location and try again!",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrangeAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          locPressed = true;
                        });
                        FocusScope.of(context).requestFocus(new FocusNode());
                        getUserLocation();
                      },
                      child: Container(
                        width: 175.0,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.my_location),
                            Text(
                              "Use Current Location",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = position.latitude;
      long = position.longitude;
    });
    List<Placemark> placemarks = await GeocodingPlatform.instance
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    locationController.text = completeAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
