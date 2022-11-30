import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pod_player/pod_player.dart';
import 'package:rxdart/subjects.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player_demo/singleton/navigation_singleton.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AllInOneVideoPlayer extends StatefulWidget {
  final String url;

  const AllInOneVideoPlayer({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<AllInOneVideoPlayer> createState() => _AllInOneVideoPlayerState();
}

class _AllInOneVideoPlayerState extends State<AllInOneVideoPlayer> {
  late PodPlayerController _podVideoPlayerController;
  String dataSource = "";
  final fileSubject = BehaviorSubject<File>();
  Function(File) get fileFunction => fileSubject.sink.add;
  RegExp youTubeRegex = RegExp(
    r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$',
  );
  RegExp vimeoRegex = RegExp(
    r'^(?:http|https)?:?\/?\/?(?:www\.)?(?:player\.)?vimeo\.com\/(?:channels\/(?:\w+\/)?|groups\/(?:[^\/]*)\/videos\/|video\/|)(\d+)(?:|\/\?)',
  );

  @override
  void initState() {
    super.initState();
    dataSource = widget.url;
    log('Provided URL: $dataSource');
    validateURL();
    podVideoPlayerControllerInit();
    whileEntering();
    fileFunction(File(""));
    if (podVideoPlayerType() == PodVideoPlayerType.network) {
      generateThumbnailForNetwork();
    }
  }

  @override
  void dispose() {
    whileExiting();
    _podVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).orientation == Orientation.landscape
          ? null
          : AppBar(),
      body: Center(
        child: StreamBuilder(
          stream: fileSubject.stream,
          builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
            return PodVideoPlayer(
              controller: _podVideoPlayerController,
              videoThumbnail: DecorationImage(
                onError: (exception, stackTrace) {
                  log('PodVideoPlayer videoThumbnail onError: ${exception.toString()}');
                  log('PodVideoPlayer videoThumbnail stackTrace: ${stackTrace.toString()}');
                },
                image: imageProviderFunction(),
                fit: BoxFit.cover,
              ),
              onVideoError: () {
                whileExiting();
                return const Center(
                  child: Icon(Icons.error),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void validateURL() {
    bool isValidateURL = Uri.tryParse(dataSource)?.hasAbsolutePath ?? false;
    if (isValidateURL == false) {
      WidgetsBinding.instance.endOfFrame.then(
        (_) {
          return errorAndExit(error: "Unable to parse provided URL");
        },
      );
    }
    return;
  }

  void podVideoPlayerControllerInit() {
    _podVideoPlayerController = PodPlayerController(
      playVideoFrom: playVideoFrom(),
      podPlayerConfig: const PodPlayerConfig(autoPlay: true),
    );
    return;
  }

  void whileEntering() {
    if (_podVideoPlayerController.isInitialised == false) {
      initialisePlayerController();
    }
    if (_podVideoPlayerController.isFullScreen == false) {
      _podVideoPlayerController.enableFullScreen();
    }
    return;
  }

  Future<void> initialisePlayerController() async {
    try {
      await _podVideoPlayerController.initialise();
    } catch (e) {
      errorAndExit(error: "Unable to initialise provided URL: ${e.toString()}");
    }
    return Future.value();
  }

  PlayVideoFrom playVideoFrom() {
    if (youTubeRegex.hasMatch(dataSource)) {
      return PlayVideoFrom.youtube(dataSource);
    } else if (vimeoRegex.hasMatch(dataSource)) {
      return PlayVideoFrom.vimeo(Uri.parse(dataSource).pathSegments.last);
    } else {
      return PlayVideoFrom.network(dataSource);
    }
  }

  PodVideoPlayerType podVideoPlayerType() {
    if (youTubeRegex.hasMatch(dataSource)) {
      return PodVideoPlayerType.youtube;
    } else if (vimeoRegex.hasMatch(dataSource)) {
      return PodVideoPlayerType.vimeo;
    } else {
      return PodVideoPlayerType.network;
    }
  }

  void whileExiting() {
    if (_podVideoPlayerController.isVideoPlaying == true) {
      _podVideoPlayerController.pause();
    }
    if (_podVideoPlayerController.isFullScreen == true) {
      _podVideoPlayerController.disableFullScreen(context);
    }
    return;
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>
      errorAndExit({
    required String error,
  }) async {
    Navigator.pop(Singleton().navigatorStateKey.currentContext!);
    return ScaffoldMessenger.of(Singleton().navigatorStateKey.currentContext!)
        .showSnackBar(
      SnackBar(
        content: Text(error),
      ),
    );
  }

  Future<File> generateThumbnailForNetwork() async {
    String data = "";
    try {
      data = await VideoThumbnail.thumbnailFile(
            video: dataSource,
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: ImageFormat.WEBP,
            quality: 50,
            maxHeight:
                MediaQuery.of(Singleton().navigatorStateKey.currentContext!)
                    .size
                    .height
                    .toInt(),
            maxWidth:
                MediaQuery.of(Singleton().navigatorStateKey.currentContext!)
                    .size
                    .width
                    .toInt(),
          ) ??
          "";
    } catch (e) {
      log('Unable to fetch thumbnail : ${e.toString()}');
    }
    return Future.value(File(data));
  }

  ImageProvider<Object> imageProviderFunction() {
    if (podVideoPlayerType() == PodVideoPlayerType.youtube) {
      return NetworkImage(getYoutubeThumbnail());
    } else if (podVideoPlayerType() == PodVideoPlayerType.vimeo) {
      return NetworkImage(getVimeoThumbnail());
    } else {
      if (fileSubject.value.path == "") {
        return MemoryImage(kTransparentImage);
      } else {
        return FileImage(File(fileSubject.value.path));
      }
    }
  }

  String getYoutubeThumbnail() {
    return "https://img.youtube.com/vi/${Uri.parse(dataSource).queryParameters['v']}/0.jpg";
  }

  String getVimeoThumbnail() {
    return "https://vumbnail.com/${Uri.parse(dataSource).pathSegments.last}.jpg";
  }
}
