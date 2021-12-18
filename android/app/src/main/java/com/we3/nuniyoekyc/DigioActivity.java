package com.we3.nuniyoekyc;

import static android.content.ContentValues.TAG;
import androidx.appcompat.app.AppCompatActivity;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Toast;

import android.content.Intent;
import android.util.Log;
import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.digio.in.esign2sdk.Digio;
import com.digio.in.esign2sdk.DigioConfig;
import com.digio.in.esign2sdk.DigioEnvironment;
import com.digio.in.esign2sdk.DigioServiceMode;

public class DigioActivity extends AppCompatActivity implements com.digio.in.esign2sdk.DigioResponseListener{
    private static final String CHANNEL = "samples.flutter.dev/battery";

    //For Esign
    Digio digio = new Digio();
    DigioConfig digioConfig = new DigioConfig();
    String documentId = "";
    String phoneNumber = "";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_digio);
        Log.d(TAG, "OncRete");
        ///Get Document ID Here
        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            documentId = getIntent().getStringExtra("docID");
            phoneNumber = getIntent().getStringExtra("phoneNumber");
        }
        InvokeDigioEsign();
    }

    public void InvokeDigioEsign(){
        digioConfig.setLogo("https://www.mangalkeshav.com/assets/img/apple-touch-icon.png"); //Your company logo
        digioConfig.setEnvironment(DigioEnvironment.PRODUCTION);//Stage is sandbox
        digioConfig.setServiceMode(DigioServiceMode.OTP);//FP is fingerprint/OTP/IRIS

        try {
            Log.d(TAG, "Initiating Digio");
            digio.init(DigioActivity.this, digioConfig);
            Log.d(TAG, "Digio Initiated");
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            Log.d(TAG, "Started Esigning");
            digio.esign(documentId, phoneNumber,this);// this refers DigioResponseListener
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    // Callback listener functions
    public void onSigningSuccess(String documentId, String message){
        Toast.makeText(this, documentId+" signed successfully", Toast.LENGTH_SHORT).show();
        Log.d(TAG, documentId+"Signed Successfully");
        Log.d(TAG, "Starting Waiting Screen to check if Aadhars are same As we have successfully signed in");
        Intent intent = new Intent(this, MainActivity.class);
        intent.setAction(Intent.ACTION_RUN);
        intent.putExtra("route", "Esign");

        ///Request code is to IDentity what Results we want from another activity if the
        //Activity gives back multiple results.
        startActivity(intent);
        //finish();
    }

    public void onSigningFailure(String documentId, int code, String response){
        Toast.makeText(this, response, Toast.LENGTH_SHORT).show();
        Log.d(TAG, documentId+" Signing Failed");
        Log.d(TAG, response);
        Intent intent = new Intent(this, MainActivity.class);
        intent.setAction(Intent.ACTION_RUN);
        intent.putExtra("route", "EsignResponse");
        startActivity(intent);
        //finish();
    }

    @Override
    public void onPointerCaptureChanged(boolean hasCapture) {
        Log.d(TAG, documentId+"onPointerCaptureChanged Kya toh Bhi");
    }
}
