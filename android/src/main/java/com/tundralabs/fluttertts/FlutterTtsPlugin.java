package com.tundralabs.fluttertts;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.speech.tts.UtteranceProgressListener;
import android.speech.tts.Voice;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Map;
import android.os.Build.VERSION_CODES;
/** FlutterTtsPlugin */
public class FlutterTtsPlugin extends Activity implements MethodCallHandler {
  private final MethodChannel channel;
  private TextToSpeech tts;
  private final String tag = "TTS"; /* "com.google.android.tts"*/
  private final String googleTtsEngine = "com.indic.hear2read.tts";
  private final int REQ_CODE_SPEECH_INPUT = 100;
  String uuid;
  Bundle bundle;
  private Map<String, Integer> rangeStartEnd = new HashMap<>();
  private FlutterTtsPlugin(Context context, MethodChannel channel) {
    this.channel = channel;
    this.channel.setMethodCallHandler(this);
    bundle = new Bundle();
    tts = new TextToSpeech(context.getApplicationContext(), onInitListener, googleTtsEngine);
  }

  // @Override
  // protected void onActivityResult(int requestCode, int resultCode, Intent data) {
  //   if (requestCode == 0) {
  //     if (resultCode == TextToSpeech.Engine.CHECK_VOICE_DATA_PASS) {
  //     } else {
  //       Intent installIntent = new Intent();
  //       data.getDataString();
  //       installIntent.setAction(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA);
  //       startActivity(installIntent);
  //     }
  //   }
  // }
  private UtteranceProgressListener utteranceProgressListener = new UtteranceProgressListener() {
    @Override
    public void onStart(String utteranceId) {
      channel.invokeMethod("speak.onStart", true);
    }

    @Override
    public void onDone(String utteranceId) {
      channel.invokeMethod("speak.onComplete", true);
    }

    @Override
    @Deprecated
    public void onError(String utteranceId) {
      channel.invokeMethod("speak.onError", "Error from TextToSpeech");
    }

    @Override
    public void onError(String utteranceId, int errorCode) {
      channel.invokeMethod("speak.onError", "Error from TextToSpeech - " + errorCode);
    }
   
    @Override
    public void onRangeStart(String utteranceId, int start, int end, int frame) {
      rangeStartEnd.put("start", new Integer(start));
      rangeStartEnd.put("end", new Integer(end));
      rangeStartEnd.put("frame", new Integer(frame));
      channel.invokeMethod("speak.onRangeStart", rangeStartEnd);
    }};

  private TextToSpeech.OnInitListener onInitListener = new TextToSpeech.OnInitListener() {
    @Override
    public void onInit(int status) {
      if (status == TextToSpeech.SUCCESS) {
        tts.setOnUtteranceProgressListener(utteranceProgressListener);
        channel.invokeMethod("tts.init", true);
        try {
          Locale locale = Build.VERSION.SDK_INT >= Build.VERSION_CODES.M ? tts.getDefaultVoice().getLocale()
              : tts.getDefaultLanguage();
          if (isLanguageAvailable(locale)) {
            tts.setLanguage(locale);
          }
        } catch (NullPointerException | IllegalArgumentException e) {
          Log.d(tag, "getDefaultLocale: " + e.getMessage());
        }
      } else {
        Log.d(tag, "Failed to initialize TextToSpeech");
      }
    }};

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_tts");
    channel.setMethodCallHandler(new FlutterTtsPlugin(registrar.activeContext(), channel));
  }

  void setSpeechRate(float rate) {
    tts.setSpeechRate(rate);
  }

  Boolean isLanguageAvailable(Locale locale) {
    return tts.isLanguageAvailable(locale) > 0;
  }

  void setLanguage(String language, Result result) {
    Locale locale = Locale.forLanguageTag(language);
    if (isLanguageAvailable(locale)) {
      tts.setLanguage(locale);
      result.success(1);
    } else {
      result.success(0);
    }}

  void setVoice(String voice, Result result) {
    for (Voice ttsVoice : tts.getVoices()) {
      if (ttsVoice.getName().equals(voice)) {
        tts.setVoice(ttsVoice);
        result.success(1);
        return;
      }
    }
    Log.d(tag, "Voice name not found: " + voice);
    result.success(0);
  }

  void setVolume(float volume, Result result) {
    if (volume >= 0.0F && volume <= 1.0F) {
      bundle.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, volume);
      result.success(1);
    } else {
      Log.d(tag, "Invalid volume " + volume + " value - Range is from 0.0 to 1.0");
      result.success(0);
    }
  }

  void setPitch(float pitch, Result result) {
    if (pitch >= 0.5F && pitch <= 2.0F) {
      tts.setPitch(pitch);
      result.success(1);
    } else {
      Log.d(tag, "Invalid pitch " + pitch + " value - Range is from 0.5 to 2.0");
      result.success(0);
    }
  }

  void getVoices(Result result) {
    ArrayList<String> voices = new ArrayList<>();
    try {
      for (Voice voice : tts.getVoices()) {
        voices.add(voice.getName());
      }
      result.success(voices);
    } catch (NullPointerException e) {
      Log.d(tag, "getVoices: " + e.getMessage());
      result.success(null);
    }
  }

  void getLanguages(Result result) {
    ArrayList<String> locales = new ArrayList<>();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      // While this method was introduced in API level 21, it seems that it
      // has not been implemented in the speech service side until API Level 23.
      for (Locale locale : tts.getAvailableLanguages()) {
        locales.add(locale.toLanguageTag());
      }
    } else {
      for (Locale locale : Locale.getAvailableLocales()) {
        if (locale.getVariant().isEmpty() && isLanguageAvailable(locale)) {
          locales.add(locale.toLanguageTag());
        }
      }
    }
    result.success(locales);
  }

  void speak(String text) {
      uuid = UUID.randomUUID().toString();
      tts.speak(text, TextToSpeech.QUEUE_FLUSH, bundle, uuid);
  }
  void stop() {
    tts.stop();
  }
  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("speak")) {
      String text = call.arguments.toString();
      speak(text);
      result.success(1);
    } else if (call.method.equals("stop")) {
      stop();
      result.success(1);
    } else if (call.method.equals("setSpeechRate")) {
      String rate = call.arguments.toString();
      setSpeechRate(Float.parseFloat(rate));
      result.success(1);
    } else if (call.method.equals("setVolume")) {
      String volume = call.arguments.toString();
      setVolume(Float.parseFloat(volume), result);
    } else if (call.method.equals("setPitch")) {
      String pitch = call.arguments.toString();
      setPitch(Float.parseFloat(pitch), result);
    } else if (call.method.equals("setLanguage")) {
      String language = call.arguments.toString();
      setLanguage(language, result);
    } else if (call.method.equals("getLanguages")) {
      getLanguages(result);
    } else if (call.method.equals("getVoices")) {
      getVoices(result);
    } else if (call.method.equals("setVoice")) {
      String voice = call.arguments.toString();
      setVoice(voice, result);
    } else if (call.method.equals("isLanguageAvailable")) {
      String language = ((HashMap) call.arguments()).get("language").toString();
      Locale locale = Locale.forLanguageTag(language);
      result.success(isLanguageAvailable(locale));
    } else {
      result.notImplemented();
    }
  }
}
 
