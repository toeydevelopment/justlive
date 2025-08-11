import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Justlive PoC',
      home: WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final TextEditingController _textController = TextEditingController(text: '''<!--
Sample Facebook Live embed HTML. Replace video URL or video_id.
<div id="fb-root"></div>
<script async defer crossorigin="anonymous" src="https://connect.facebook.net/en_US/sdk.js#xfbml=1&version=v17.0"></script>
<div class="fb-video" data-href="https://www.facebook.com/facebook/videos/10153231379946729/" data-width="500" data-show-text="false"></div>
-->''');

  InAppWebViewController? _controller;
  String? _error;

  final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    allowsPictureInPictureMediaPlayback: true,
  );

  void _loadHtml() {
    final html = _textController.text;
    _controller?.loadHtmlString(html);
  }

  void _loadUrl() {
    final url = _textController.text.trim();
    if (url.isNotEmpty) {
      _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Justlive PoC')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste Facebook embed HTML or URL',
              ),
              minLines: 3,
              maxLines: 5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _loadHtml,
                child: const Text('Load HTML'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _loadUrl,
                child: const Text('Load URL'),
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialSettings: _settings,
                  initialData: InAppWebViewInitialData(data: '<html></html>'),
                  onWebViewCreated: (controller) async {
                    _controller = controller;
                    await CookieManager.instance()
                        .setAcceptThirdPartyCookies(controller, true);
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    debugPrint('console: ${consoleMessage.message}');
                  },
                  onEnterFullscreen: (controller) {
                    SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky);
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);
                  },
                  onExitFullscreen: (controller) {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                    ]);
                  },
                  onLoadError: (controller, url, code, message) {
                    setState(() => _error = 'Error: $message');
                  },
                  onLoadHttpError: (controller, url, statusCode, description) {
                    setState(() => _error = 'HTTP error: $statusCode');
                  },
                ),
                if (_error != null)
                  Center(
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

