import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  dynamic doc;
  PostScreen({required this.doc});

  Widget title(title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 30.0,
          fontFamily: "Spotify",
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget description(description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 20.0,
          fontFamily: "Spotify",
          // fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget photo(context, photoURL) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) =>
                    FullImage(imageURL: doc['mediaUrl'])));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: photoURL,
          height: 275,
          width: 400,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => Icon(Icons.error),
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_rounded),
            ),
            title: Text("Post Details"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                photo(context, doc['mediaUrl']),
                title(doc['title']),
                description(doc['description']),
              ],
            ),
          )),
    );
  }
}

class FullImage extends StatelessWidget {
  String imageURL;
  FullImage({required this.imageURL});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        body: Center(
          child: Hero(
            tag: 'imageHero',
            child: CachedNetworkImage(
              imageUrl: imageURL,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
