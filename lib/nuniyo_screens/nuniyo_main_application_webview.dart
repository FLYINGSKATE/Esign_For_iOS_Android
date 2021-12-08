import 'package:flutter/material.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:webviewx/webviewx.dart';

class MainApplication_WebView extends StatefulWidget {
  const MainApplication_WebView({Key? key}) : super(key: key);

  @override
  _MainApplication_WebViewState createState() => _MainApplication_WebViewState();

}

class _MainApplication_WebViewState extends State<MainApplication_WebView> {

  late WebViewXController webviewController;
  String webURL = "https://webdev.tecxlabs.com/";

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    initializeWebView();
  }

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetHelper().NuniyoAppBar(),
      body: WebViewX(
        key: const ValueKey('webviewx'),
        initialContent: '<h2>Please Wait.......</h2>',
        initialSourceType: SourceType.html,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        onWebViewCreated: (controller) {webviewController = controller;initializeWebView();},
        onPageStarted: (src) =>
            debugPrint('A new page has started loading: $src\n'),
        onPageFinished: (src) =>
            debugPrint('The page has finished loading: $src\n'),
        jsContent: const {
          EmbeddedJsContent(
            js: "function testPlatformIndependentMethod() { console.log('Hi from JS') }",
          ),
          EmbeddedJsContent(
            webJs:
            "function testPlatformSpecificMethod(msg) { TestDartCallback('Web callback says: ' + msg) }",
            mobileJs:
            "function testPlatformSpecificMethod(msg) { TestDartCallback.postMessage('Mobile callback says: ' + msg) }",
          ),
        },
        dartCallBacks: {
          DartCallback(
            name: 'TestDartCallback',
            callBack: (msg) => print(msg.toString()),
          )
        },
        webSpecificParams: const WebSpecificParams(
          printDebugInfo: true,
        ),
        mobileSpecificParams: const MobileSpecificParams(
          androidEnableHybridComposition: true,
        ),
        navigationDelegate: (navigation) {
          debugPrint(navigation.content.sourceType.toString());
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  Future<void> initializeWebView() async {
    await webviewController.loadContent(
      '$webURL',
      SourceType.url,
    );
  }

}
