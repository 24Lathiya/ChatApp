import 'dart:io';

import 'package:chat_app/admob/app_lifecycle_reflector.dart';
import 'package:chat_app/admob/app_open_ad_manager.dart';
import 'package:chat_app/controllers/login_controller.dart';
import 'package:chat_app/helper/theme_provider.dart';
import 'package:chat_app/helper/user_preferences.dart';
import 'package:chat_app/pages/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UserPreferences.preferences = await SharedPreferences.getInstance();
  if (kIsWeb) {
    //initialise fire base for web
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDFMSGgLMiyETdRREvN9lAUIEnVppp5ZbQ",
            // authDomain: "chatapp-cc237.firebaseapp.com",
            projectId: "chatapp-cc237",
            // storageBucket: "chatapp-cc237.appspot.com",
            messagingSenderId: "632567862739",
            appId: "1:632567862739:web:aa2a3c63b3493b8d3ccb26"));
  } else {
    //initialise fire base for android/ios
    await Firebase.initializeApp();
  }
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

const int maxFailedLoadAttempts = 3;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd? _bannerAd;
  bool _bannerIsLoaded = false;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  late AppLifecycleReactor _appLifecycleReactor;
  @override
  void initState() {
    super.initState();

    AppOpenAdManager appOpenAdManager = AppOpenAdManager()..loadAd();
    _appLifecycleReactor =
        AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();

    _loadBannerAd();
    _createInterstitialAd();
    _createRewardedAd();
    _createRewardedInterstitialAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint(
              '$ad loaded: ${ad.responseInfo?.mediationAdapterClassName}');
          setState(() {
            _bannerIsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) =>
            debugPrint('$ad failed to load: ${error.message}'),
      ),
      request: AdRequest(nonPersonalizedAds: true),
    )..load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/1033173712'
            : 'ca-app-pub-3940256099942544/4411468910',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/5224354917'
            : 'ca-app-pub-3940256099942544/1712485313',
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedAd = null;
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-3940256099942544/5354046379'
            : 'ca-app-pub-3940256099942544/6978759866',
        request: request,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
            }
          },
        ));
  }

  void _showRewardedInterstitialAd() {
    if (_rewardedInterstitialAd == null) {
      print('Warning: attempt to show rewarded interstitial before loaded.');
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedInterstitialAd = null;
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        UserPreferences.preferences!.getBool("dark_theme") == null
            ? false
            : UserPreferences.preferences!.getBool("dark_theme")!;
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => LoginController(),
            child: SignUpPage(),
          ),
          ChangeNotifierProvider(
              create: (context) => ThemeProvider(isDarkMode: isDarkMode))
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return GetMaterialApp(
              title: 'Chat App',
              debugShowCheckedModeBanner: false,

              /*theme: ThemeData(
              primarySwatch: Colors.red,
              useMaterial3: true,
              brightness: useLightMode ? Brightness.light : Brightness.dark),*/
              themeMode: isDarkMode ? ThemeMode.light : ThemeMode.dark,
              theme: themeProvider.getTheme,
              /*home: UserPreferences.preferences!.getBool("is_login") == null
                  ? SignUpPage()
                  : UserPreferences.preferences!.getBool("is_login")!
                      ? MainPage() */ /*MainPageWidget()*/ /*
                      : LoginPage(),*/
              home: Builder(builder: (BuildContext context) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('AdMob Plugin example app'),
                    actions: <Widget>[
                      PopupMenuButton<String>(
                        onSelected: (String result) {
                          switch (result) {
                            case 'InterstitialAd':
                              _showInterstitialAd();
                              break;
                            case 'RewardedAd':
                              _showRewardedAd();
                              break;
                            case 'RewardedInterstitialAd':
                              _showRewardedInterstitialAd();
                              break;
                            /*    case 'Fluid':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FluidExample()),
                              );
                              break;
                            case 'Inline adaptive':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        InlineAdaptiveExample()),
                              );
                              break;
                            case 'Anchored adaptive':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AnchoredAdaptiveExample()),
                              );
                              break;*/
                            default:
                              throw AssertionError(
                                  'unexpected button: $result');
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'InterstitialAd',
                            child: Text('InterstitialAd'),
                          ),
                          PopupMenuItem<String>(
                            value: 'RewardedAd',
                            child: Text('RewardedAd'),
                          ),
                          PopupMenuItem<String>(
                            value: 'RewardedInterstitialAd',
                            child: Text('RewardedInterstitialAd'),
                          ),
                          /* PopupMenuItem<String>(
                            value: 'Fluid',
                            child: Text('Fluid'),
                          ),
                          PopupMenuItem<String>(
                            value: 'Inline adaptive',
                            child: Text('Inline adaptive'),
                          ),
                          PopupMenuItem<String>(
                            value: 'Anchored adaptive',
                            child: Text('Anchored adaptive'),
                          ),*/
                        ],
                      ),
                    ],
                  ),
                  bottomNavigationBar: _bannerIsLoaded && _bannerAd != null
                      ? Container(
                          alignment: Alignment.center,
                          height: _bannerAd!.size.height.toDouble(),
                          // width: _bannerAd!.size.width.toDouble(),
                          width: MediaQuery.of(context).size.width,
                          child: AdWidget(ad: _bannerAd!),
                        )
                      : Center(child: Text('ad is not loaded')),
                );
              }),
            );
          },
        ));
  }
}
