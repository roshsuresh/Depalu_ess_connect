 import 'dart:async';
 import 'dart:collection';
import 'dart:developer';
 import 'dart:io';
 import 'dart:isolate';
 import 'dart:ui';
 import 'package:flutter/material.dart';
 import 'package:flutter_downloader/flutter_downloader.dart';
 import 'package:permission_handler/permission_handler.dart';
 import 'package:shared_preferences/shared_preferences.dart';
 import 'package:flutter_inappwebview/flutter_inappwebview.dart';
 import 'package:path_provider/path_provider.dart';
 import 'package:url_launcher/url_launcher.dart';



class LoginPageWeb extends StatefulWidget {
  @override
  _LoginPageWebState createState() =>
      new _LoginPageWebState();
}

class _LoginPageWebState extends State<LoginPageWeb> {
  final GlobalKey webViewKey = GlobalKey();
  final ReceivePort _port = ReceivePort();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(

        useOnDownloadStart: true,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  String baseUrl="";
  final urlController = TextEditingController();


  Future<String> session() async {
         SharedPreferences prefs = await SharedPreferences.getInstance();

         return baseUrl = (prefs.getString("baseUrl"))!;
       }


  @override
  void initState() {
    Permission.storage.request();
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){ });
    });
    FlutterDownloader.registerCallback(downloadCallback);

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }


  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  void _download(String url) async {
    final status = await Permission.storage.request();

    if(status.isGranted) {
      final externalDir = await getExternalStorageDirectory();

      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: externalDir!.path,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );
    } else {
      print('Permission Denied');
    }
  }
  Future<bool> _onWillPop() async {
         return (await showDialog(
        context: context,
          builder: (context) => new AlertDialog(
             title: new Text('Are you sure?'),
             content: new Text('Do you want to exit'),
             actions: <Widget>[
               TextButton(
                 onPressed: () => Navigator.of(context).pop(false),
                 child: new Text('No',style: TextStyle(fontSize: 18),),
              ),
              TextButton(
                 onPressed: () => Navigator.of(context).pop(true),
                 child: new Text('Yes',style: TextStyle(fontSize: 18),),
               ),
             ],
           ),
         )) ?? false;
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        //drawer: myDrawer(context: context),
        body: WillPopScope(
          onWillPop: _onWillPop,
          child: SafeArea(
              child: Column(children: <Widget>[

                Expanded(
                  child: Stack(
                    children: [
                    FutureBuilder(
                     future: session(),
                                   builder: (context, snap) {
                                     return snap.hasData ?
                                     InAppWebView(
                                       key: webViewKey,
                                       // contextMenu: contextMenu,
                                       initialUrlRequest:
                                       URLRequest(url: Uri.parse(
                                           'https://$baseUrl.eschoolweb.org/login')),
                                       // initialFile: "assets/index.html",
                                       initialUserScripts: UnmodifiableListView<
                                           UserScript>([]),
                                       initialOptions: options,
                                       pullToRefreshController: pullToRefreshController,
                                       onWebViewCreated: (controller) {
                                         webViewController = controller;
                                       },
                                       onLoadStart: (controller, url) {
                                         setState(() {
                                           this.url = url.toString();
                                           urlController.text = this.url;
                                         });
                                       },
                                       androidOnPermissionRequest:
                                           (controller, origin, resources) async {
                                         return PermissionRequestResponse(
                                             resources: resources,
                                             action: PermissionRequestResponseAction
                                                 .GRANT);
                                       },
                                       shouldOverrideUrlLoading:
                                           (controller, navigationAction) async {
                                         var uri = navigationAction.request.url!;

                                         if (![
                                           "http",
                                           "https",
                                           "file",
                                           "chrome",
                                           "data",
                                           "javascript",
                                           "about"
                                         ].contains(uri.scheme)) {
                                           if (await canLaunch(url)) {
                                             // Launch the App
                                             await launch(
                                               url,
                                             );
                                             // and cancel the request
                                             return NavigationActionPolicy.CANCEL;
                                           }
                                         }

                                         return NavigationActionPolicy.ALLOW;
                                       },


                                       onDownloadStart: (controller, url,) async {
                                         final String _url_files = "$url";
                                         void _launchURL_files() async =>
                                             await canLaunch(_url_files)
                                                 ? await launch(_url_files)
                                                 : throw 'Could not launch $_url_files';
                                         _launchURL_files();
                                         await FlutterDownloader.enqueue(
                                             url: _url_files,
                                             savedDir: (await getExternalStorageDirectory())!
                                                 .path,
                                             openFileFromNotification: true,
                                             saveInPublicStorage: true,
                                             showNotification: true);
                                       },


                                       onLoadStop: (controller, url) async {
                                         if (baseUrl.contains('/recon?')) {
                                           var html = await controller
                                               .evaluateJavascript(
                                               source: "window.document.getElementsByTagName('html')[0].outerHTML;");

                                           log(html);
                                         }
                                       },
                                       onLoadError: (controller, url, code,
                                           message) {
                                         pullToRefreshController.endRefreshing();
                                       },
                                       onProgressChanged: (controller, progress) {
                                         if (progress == 100) {
                                           pullToRefreshController
                                               .endRefreshing();
                                         }
                                         setState(() {
                                           this.progress = progress / 100;
                                           urlController.text = this.url;
                                         });
                                       },
                                       onUpdateVisitedHistory: (controller, url,
                                           androidIsReload) {
                                         setState(() {
                                           this.url = url.toString();
                                           urlController.text = this.url;
                                         });
                                       },
                                       onConsoleMessage: (controller,
                                           consoleMessage) {
                                         print(consoleMessage);
                                       },

                                     ) :

                                     Container(
                                         child: const Center(
                                           child: CircularProgressIndicator(),
                                         )
                                     );
                                   }
                    ),

                    ],
                  ),

                ),

                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      child: Icon(Icons.arrow_back),
                      onPressed: () {
                        webViewController?.goBack();
                      },
                    ),
                    ElevatedButton(
                      child: Icon(Icons.arrow_forward),
                      onPressed: () {
                        webViewController?.goForward();
                      },
                    ),
                    ElevatedButton(
                      child: Icon(Icons.refresh),
                      onPressed: () {
                        webViewController?.reload();
                      },
                    ),

                  ],
                ),
              ]
              )
          ),
        ),

    );
  }
}



 // class LoginPageWeb extends StatefulWidget {
 //   const LoginPageWeb({Key? key}) : super(key: key);
 //
 //   @override
 //   _LoginPageWebState createState() => new _LoginPageWebState();
 // }
 //
 // class _LoginPageWebState extends State<LoginPageWeb> {
 //
 //
 //   final GlobalKey webViewKey = GlobalKey();
 //   late StreamSubscription<String> _onWebViewUrlChanged;
 //   String baseUrl = "";
 //   String schoolId = "";
 //   ReceivePort _port = ReceivePort();
 //   InAppWebViewController? webViewController;
 //
 //
 //  Future<String> session() async {
 //     SharedPreferences prefs = await SharedPreferences.getInstance();
 //
 //     return baseUrl = (prefs.getString("baseUrl"))!;
 //   }
 //   InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
 //       crossPlatform: InAppWebViewOptions(
 //         useOnDownloadStart: true,
 //         useShouldOverrideUrlLoading: true,
 //         mediaPlaybackRequiresUserGesture: false,
 //       ),
 //       android: AndroidInAppWebViewOptions(
 //         useHybridComposition: true,
 //         domStorageEnabled: true,
 //       ),
 //       ios: IOSInAppWebViewOptions(
 //         allowsInlineMediaPlayback: true,
 //       ));
 //   late PullToRefreshController pullToRefreshController;
 // String url = "";
 //   double progress = 0;
 //  final urlController = TextEditingController();
 //
 //   @override
 //   void initState() {
 //     Permission.storage.request();
 //     super.initState();
 //     IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
 //     _port.listen((dynamic data) {
 //       String id = data[0];
 //       DownloadTaskStatus status = data[1];
 //       int progress = data[2];
 //       setState((){ });
 //     });
 // //FlutterDownloader.registerCallback(downloadCallback);
 //
 //     pullToRefreshController = PullToRefreshController(
 //       options: PullToRefreshOptions(
 //         color: Colors.blue,
 //       ),
 //       onRefresh: () async {
 //         if (Platform.isAndroid) {
 //           webViewController?.reload();
 //         } else if (Platform.isIOS) {
 //           webViewController?.loadUrl(
 //               urlRequest: URLRequest(url: await webViewController?.getUrl()));
 //         }
 //       },
 //     );
 //   }
 //
 //   @override
 //   void dispose() {
 //     IsolateNameServer.removePortNameMapping('downloader_send_port');
 //     super.dispose();
 //
 //   }
 //
 //
 //   Future<bool> _onWillPop() async {
 //     return (await showDialog(
 //       context: context,
 //       builder: (context) => new AlertDialog(
 //         title: new Text('Are you sure?'),
 //         content: new Text('Do you want to exit'),
 //         actions: <Widget>[
 //           TextButton(
 //             onPressed: () => Navigator.of(context).pop(false),
 //             child: new Text('No',style: TextStyle(fontSize: 18),),
 //           ),
 //          TextButton(
 //             onPressed: () => Navigator.of(context).pop(true),
 //             child: new Text('Yes',style: TextStyle(fontSize: 18),),
 //           ),
 //         ],
 //       ),
 //     )) ?? false;
 //   }
 //
 //   @override
 //   Widget build(BuildContext context) {
 //     return WillPopScope(
 //       onWillPop: _onWillPop,
 //       child: Scaffold(
 //
 //         body: SafeArea(
 //            child:
 //             FutureBuilder(
 //                future: session(),
 //                 builder: (context, snap) {
 //                  return snap.hasData ?
 //                   InAppWebView(
 //                     key: webViewKey,
 //                     initialUrlRequest:
 //                     URLRequest(url: Uri.parse(
 //                         'https://$baseUrl.esstestonline.in/login')),
 //                     initialOptions: options,
 //                     pullToRefreshController: pullToRefreshController,
 //                     onWebViewCreated: (controller) {
 //                       webViewController = controller;
 //                     },
 //                     onDownloadStart: (controller, url) async {
 //                       Directory? tempDir = await getExternalStorageDirectory();
 //                       print("onDownload $url");
 //                       await FlutterDownloader.enqueue(
 //                         url: "$url",
 //                         savedDir: tempDir!.path,
 //                         showNotification: true,
 //                         openFileFromNotification: true,
 //                         saveInPublicStorage: true,
 //                       );
 //                     },
 //                     onLoadStart: (controller, url) {
 //                       setState(() {
 //                         this.url = url.toString();
 //                        urlController.text = this.url;
 //                       });
 //                     },
 //                     androidOnPermissionRequest: (controller, origin,
 //                         resources) async {
 //                       return PermissionRequestResponse(
 //                           resources: resources,
 //                           action: PermissionRequestResponseAction.GRANT);
 //                     },
 //                     shouldOverrideUrlLoading: (controller,
 //                         navigationAction) async {
 //                       var uri = navigationAction.request.url!;
 //
 //                       if (![ "http", "https", "file", "chrome",
 //                         "data", "javascript", "about"].contains(
 //                           uri.scheme)) {
 //                         if (await canLaunch(url)) {
 //
 //                           // Launch the App
 //                           await launch(
 //                            url,
 //                           );
 //                          // and cancel the request
 //                           return NavigationActionPolicy.CANCEL;
 //                         }
 //                       }
 //
 //                      return NavigationActionPolicy.ALLOW;
 //                     },
 //                     onLoadStop: (controller, url) async {
 //                       pullToRefreshController.endRefreshing();
 //                       setState(() {
 //                         this.url = url.toString();
 //                         urlController.text = this.url;
 //                      });
 //                     },
 //                       // onDownloadStartRequest: (controller, url)async{
 //                       //   final taskId = await FlutterDownloader.enqueue(
 //                       //     url: this.url,
 //                       //     savedDir: (await getExternalStorageDirectory())!.path,
 //                       //     showNotification: true, // show download progress in status bar (for Android)
 //                       //     openFileFromNotification: true,
 //                       //    saveInPublicStorage: true//
 //                       //
 //                      //
 //                       //     // click on notification to open downloaded file (for Android)
 //                       //   );
 //                       //
 //                       // } ,
 //                     onLoadError: (controller, url, code, message) {
 //                       pullToRefreshController.endRefreshing();
 //                     },
 //                     onProgressChanged: (controller, progress) {
 //                       if (progress == 100) {
 //                         pullToRefreshController.endRefreshing();
 //                       }
 //                       setState(() {
 //                         this.progress = progress / 100;
 //                         urlController.text = this.url;
 //                       });
 //                     },
 //                     onUpdateVisitedHistory: (controller, url,
 //                         androidIsReload) {
 //                      setState(() {
 //                         this.url = url.toString();
 //                         urlController.text = this.url;
 //                       });
 //                     },
 //                    onConsoleMessage: (controller, consoleMessage) {
 //                       print(consoleMessage);
 //                     },
 //                   ):
 //                   Container(
 //                       child: Center(
 //                         child: CircularProgressIndicator(),
 //                       )
 //                   );
 //                 }
 //
 //             )
 //         ),
 //
 //
 //       ),
 //     );
 //   }
 // }




