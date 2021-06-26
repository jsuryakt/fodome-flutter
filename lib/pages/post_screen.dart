import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  dynamic doc;
  PostScreen({required this.doc});

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
          body: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              FullImage(imageURL: doc['mediaUrl'])));
                },
                child: Container(
                  child: Ink.image(
                    image: CachedNetworkImageProvider(doc['mediaUrl']),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class FullImage extends StatelessWidget {
  String imageURL;
  FullImage({required this.imageURL});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: CachedNetworkImage(
              imageUrl: imageURL,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
