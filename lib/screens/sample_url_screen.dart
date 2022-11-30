import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player_demo/model/model.dart';
import 'package:video_player_demo/player/video_player.dart';
import 'package:video_player_demo/screens/custom_url_screen.dart';
import 'package:video_player_demo/singleton/sound_singleton.dart';

class SampleURLScreen extends StatefulWidget {
  const SampleURLScreen({Key? key}) : super(key: key);

  @override
  State<SampleURLScreen> createState() => _SampleURLScreenState();
}

class _SampleURLScreenState extends State<SampleURLScreen> {
  ModelClass object = ModelClass();

  @override
  void initState() {
    super.initState();
    readJson();
  }

  Future<void> readJson() async {
    await Future.delayed(const Duration(seconds: 1));
    final String response = await rootBundle.loadString('assets/videos.json');
    final data = await json.decode(response);
    object = ModelClass.fromJson(data);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample videos'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.dashboard_customize_outlined),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const CustomURLScreen();
              },
            ),
          );
        },
        label: const Text('Custom URL'),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: object.videos.isEmpty
              ? const Center(
                  child: CupertinoActivityIndicator(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: object.videos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        leading: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100.0),
                          ),
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: object.videos[index].thumb,
                            imageErrorBuilder: (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return Image(
                                image: MemoryImage(kTransparentImage),
                              );
                            },
                            placeholderErrorBuilder: (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return Image(
                                image: MemoryImage(kTransparentImage),
                              );
                            },
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(object.videos[index].title),
                        subtitle: Row(
                          children: [
                            Text(object.videos[index].subtitle),
                            const SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              onTap: () {
                                _showMyDialog(
                                  description: object.videos[index].description,
                                );
                              },
                              borderRadius: const BorderRadius.all(
                                Radius.circular(100.0),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                          ),
                        ),
                        dense: true,
                        onLongPress: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Just tap it, don't hold it."),
                            ),
                          );
                          await SoundSingleton().myPlay();
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AllInOneVideoPlayer(
                                  url: object.videos[index].sources.first
                                      .toString(),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog({
    required String description,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Description'),
          content: SingleChildScrollView(
            child: Text(description),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
