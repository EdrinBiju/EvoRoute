import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Future<void> showCustomDialog(
  BuildContext context,
  String title,
  String subtitle,
  String imageURL,
) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      // Variables to handle pinch zoom
      double scale = 1.0;
      // double _previousScale = 1.0;

      return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: const Color.fromARGB(87, 0, 0, 0),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Space between dialog top and image top
                    const SizedBox(height: 15),
                    // Image at the top (covering 1/4th of the pop-up)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.2, // Adjusted height
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      FullScreenImageDialog(
                                    imageURL: imageURL,
                                    title: title,
                                    subtitle: subtitle,
                                  ),
                                ),
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: imageURL,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              imageBuilder: (context, imageProvider) =>
                                  Transform.scale(
                                scale: scale,
                                child: Image(
                                  image: imageProvider,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Padding for separation
                    const SizedBox(height: 10),
                    // Text widgets displaying string variables
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Padding for separation
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class FullScreenImageDialog extends StatelessWidget {
  final String imageURL;
  final String title;
  final String subtitle;

  const FullScreenImageDialog({
    super.key,
    required this.imageURL,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(); // Close the full screen dialog on tap
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: imageURL,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
