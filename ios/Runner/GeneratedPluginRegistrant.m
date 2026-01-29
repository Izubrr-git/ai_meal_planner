//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<appmetrica_plugin/AMAFAppMetricaPlugin.h>)
#import <appmetrica_plugin/AMAFAppMetricaPlugin.h>
#else
@import appmetrica_plugin;
#endif

#if __has_include(<appsflyer_sdk/AppsflyerSdkPlugin.h>)
#import <appsflyer_sdk/AppsflyerSdkPlugin.h>
#else
@import appsflyer_sdk;
#endif

#if __has_include(<firebase_analytics/FirebaseAnalyticsPlugin.h>)
#import <firebase_analytics/FirebaseAnalyticsPlugin.h>
#else
@import firebase_analytics;
#endif

#if __has_include(<firebase_core/FLTFirebaseCorePlugin.h>)
#import <firebase_core/FLTFirebaseCorePlugin.h>
#else
@import firebase_core;
#endif

#if __has_include(<google_mobile_ads/FLTGoogleMobileAdsPlugin.h>)
#import <google_mobile_ads/FLTGoogleMobileAdsPlugin.h>
#else
@import google_mobile_ads;
#endif

#if __has_include(<share_plus/FPPSharePlusPlugin.h>)
#import <share_plus/FPPSharePlusPlugin.h>
#else
@import share_plus;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<unity_levelplay_mediation/LevelPlayMediationPlugin.h>)
#import <unity_levelplay_mediation/LevelPlayMediationPlugin.h>
#else
@import unity_levelplay_mediation;
#endif

#if __has_include(<webview_flutter_wkwebview/WebViewFlutterPlugin.h>)
#import <webview_flutter_wkwebview/WebViewFlutterPlugin.h>
#else
@import webview_flutter_wkwebview;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [AMAFAppMetricaPlugin registerWithRegistrar:[registry registrarForPlugin:@"AMAFAppMetricaPlugin"]];
  [AppsflyerSdkPlugin registerWithRegistrar:[registry registrarForPlugin:@"AppsflyerSdkPlugin"]];
  [FirebaseAnalyticsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FirebaseAnalyticsPlugin"]];
  [FLTFirebaseCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTFirebaseCorePlugin"]];
  [FLTGoogleMobileAdsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTGoogleMobileAdsPlugin"]];
  [FPPSharePlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FPPSharePlusPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [LevelPlayMediationPlugin registerWithRegistrar:[registry registrarForPlugin:@"LevelPlayMediationPlugin"]];
  [WebViewFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"WebViewFlutterPlugin"]];
}

@end
