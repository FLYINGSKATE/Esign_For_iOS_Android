package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    flutterEngine.getPlugins().add(new io.flutter.plugins.camera.CameraPlugin());
    flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin());
      it.nplace.downloadspathprovider.DownloadsPathProviderPlugin.registerWith(shimPluginRegistry.registrarFor("it.nplace.downloadspathprovider.DownloadsPathProviderPlugin"));
    flutterEngine.getPlugins().add(new com.mr.flutter.plugin.filepicker.FilePickerPlugin());
    flutterEngine.getPlugins().add(new com.example.flutterimagecompress.FlutterImageCompressPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin());
    flutterEngine.getPlugins().add(new io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin());
      com.aloisdeniel.geocoder.GeocoderPlugin.registerWith(shimPluginRegistry.registrarFor("com.aloisdeniel.geocoder.GeocoderPlugin"));
    flutterEngine.getPlugins().add(new com.baseflow.geolocator.GeolocatorPlugin());
    flutterEngine.getPlugins().add(new vn.hunghd.flutter.plugins.imagecropper.ImageCropperPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.imagepicker.ImagePickerPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.localauth.LocalAuthPlugin());
    flutterEngine.getPlugins().add(new com.crazecoder.openfile.OpenFilePlugin());
    flutterEngine.getPlugins().add(new ru.surfstudio.otp_autofill.OTPPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
    flutterEngine.getPlugins().add(new com.razorpay.razorpay_flutter.RazorpayFlutterPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
      flutter.moum.sim_info.SimInfoPlugin.registerWith(shimPluginRegistry.registrarFor("flutter.moum.sim_info.SimInfoPlugin"));
    flutterEngine.getPlugins().add(new com.syncfusion.flutter.pdfviewer.SyncfusionFlutterPdfViewerPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.urllauncher.UrlLauncherPlugin());
    flutterEngine.getPlugins().add(new com.example.video_compress.VideoCompressPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.videoplayer.VideoPlayerPlugin());
    flutterEngine.getPlugins().add(new io.flutter.plugins.webviewflutter.WebViewFlutterPlugin());
  }
}
