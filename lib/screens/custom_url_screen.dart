import 'package:flutter/material.dart';
import 'package:video_player_demo/player/video_player.dart';

class CustomURLScreen extends StatefulWidget {
  const CustomURLScreen({Key? key}) : super(key: key);

  @override
  State<CustomURLScreen> createState() => _CustomURLScreenState();
}

class _CustomURLScreenState extends State<CustomURLScreen> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom URL'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                      'This video player is currently accepting and playing the URLs from the below-mentioned sites:'),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                      '🔘 YouTube, Vimeo, Google Cloud, Amazon S3 Bucket, Random site video, etc.'),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                      'If the video URL has a null value / empty string / does not have a valid video link, then the video player screen will pop back to the previous screen and show the error message with the respective reason.'),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                      'For example, If Amazon S3 has a private bucket with restricted URL policies applied, in this case, the video player screen will pop back to the previous screen and show the error message in the snack bar.'),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                      'Note: This player has a configuration to play video after the initialization. You will not be able to see the thumbnail at the initial duration. If you want to see the video thumbnail, then pause the video and set the seek-bar slider at 00:00.'),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                      'Fun fact, you can pass any valid URL (for example, https://www.google.com/). Until & unless, If it is a valid URL address, it will open and play a video. Otherwise, it will pop back and show what went wrong.'),
                  const SizedBox(
                    height: 50,
                  ),
                  form(),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              label: const Text(
                  'URL of YouTube / Vimeo / Google Cloud / Amazon S3 Bucket / Random site'),
              labelStyle: TextStyle(
                fontSize: Theme.of(context).textTheme.bodyText2?.fontSize,
              ),
              errorMaxLines: 5,
            ),
            validator: (value) {
              bool isValidateURL =
                  Uri.tryParse(value ?? '')?.hasAbsolutePath ?? false;
              if (value == null || value.isEmpty || isValidateURL == false) {
                return "Please enter the valid URL. It must start with either the http or https scheme with an absolute path (starting with /). The best way to do it is by directly pasting the sharable link.";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();

              if (_formKey.currentState?.validate() ?? false) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AllInOneVideoPlayer(
                        url: _controller.value.text,
                      );
                    },
                  ),
                );
              }
            },
            child: const Text('Play'),
          ),
        ],
      ),
    );
  }
}
