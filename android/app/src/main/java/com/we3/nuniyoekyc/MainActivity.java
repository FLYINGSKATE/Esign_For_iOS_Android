package com.we3.nuniyoekyc;

import android.app.Activity;
import android.content.Intent;
import static android.content.ContentValues.TAG;
import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.util.Log;


public class MainActivity extends FlutterActivity{
    private static final String CHANNEL = "samples.flutter.dev/battery";

    boolean esignSuccessfull = false;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            // TODO
                            if (call.method.equals("esignThisDocument")) {
                                ///Getting the Doc Id From Flutter
                                String docID = call.argument("docID");
                                String phoneNumber = call.argument("phoneNumber");
                                Intent intent = new Intent(this, DigioActivity.class);
                                intent.putExtra("docID",docID);
                                intent.putExtra("phoneNumber",phoneNumber);
                                Log.d(TAG, "Started Digio Activity to get Result");
                                ///Request code is to Identity what Results we want from another activity if the
                                //Activity gives back multiple results.
                                startActivity(intent);
                                ///Maybe have to implement Something Here!
                                Log.d(TAG, "Don know if we waited!");
                                result.success(esignSuccessfull);
                                //finish();
                            }
                            else {
                                result.notImplemented();
                                //finish();
                            }
                        }
                );
    }
}
