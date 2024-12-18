import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:medoptic_user/Constants/colors.dart';
import 'package:medoptic_user/services/helper_functions/time.dart';
import 'package:medoptic_user/services/helper_functions/tts_message.dart';
import 'package:medoptic_user/services/api_services/medtag_api.dart';
import 'package:medoptic_user/services/helper_functions/toast_util.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:translator/translator.dart';
import '../../../model/medtag_model.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  FlutterTts flutterTts = FlutterTts();
  bool isPaused = false;
  bool isSpeaking = false; // New variable to track speaking state
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void initState() {
    test();
    flutterTts.setPitch(1);
    flutterTts.setVolume(1);
    flutterTts.setSpeechRate(0.5);
    super.initState();
  }

  Future<void> test() async {
    List<dynamic> langs = await flutterTts.getLanguages;
    debugPrint(langs.toString());
  }

  Map<String, String> getLanguage() {
    final String defaultLocale =
        Platform.localeName; // Returns locale string in the form 'en_US'
    final List<String> localeParts = defaultLocale.split('_');

    String lang = localeParts.isNotEmpty ? localeParts.first : 'en';
    String country = localeParts.length > 1 ? localeParts.last : 'US';

    return {
      'lang': lang, // Returns locale string in the form 'en'
      'code': "$lang-$country", // Returns locale string in the form 'en-US'
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan MedTag',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white)),
        backgroundColor: CustomColors.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () async {
              if (isSpeaking) {
                // If TTS is speaking, stop it
                await ttsSpeakStop();
              } else {
                // If TTS is not speaking, start it
                String data =
                    "Aspirin: 100mg once daily. Take with food. Prescribed by Dr. Smith on 2024-04-27 for John Doe. Expiry: 2024-05-27. Refill: Check with your doctor.";
                await ttsSpeakStart(data);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                isSpeaking ? Icons.stop : Icons.settings,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isPaused,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  // formatsAllowed: [BarcodeFormat.],
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: CustomColors.primaryColor,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 300,
                  ),
                ),
                Positioned(
                  bottom: 35,
                  left: 25,
                  child: _scannerButton(
                    onPressed: () {
                      controller?.flipCamera();
                    },
                    child: Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.width * 0.09,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 35,
                  right: 25,
                  child: _scannerButton(
                    onPressed: () async {
                      bool? flashStatus = await controller?.getFlashStatus();
                      await controller?.toggleFlash();
                      setState(() {});
                    },
                    child: FutureBuilder(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        return Icon(
                          (snapshot.data == true)
                              ? Icons.flash_off
                              : Icons.flash_on,
                          size: MediaQuery.of(context).size.width * 0.09,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPaused)
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: IconButton(
                  onPressed: () async {
                    await ttsSpeakStop();
                  },
                  icon: Icon(Icons.pause_circle,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.width * 0.7)),
            ),
        ],
      ),
    );
  }

  Widget _scannerButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(CustomColors.contrastColor2),
          padding: MaterialStateProperty.all(
            const EdgeInsets.all(15),
          ),
          shape: MaterialStateProperty.all(
            const CircleBorder(
              side: BorderSide(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
        ),
        onPressed: onPressed,
        child: child);
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    if (isPaused) {
      await controller.pauseCamera();
    } else {
      controller.scannedDataStream.listen((scanData) async {
        setState(() {
          result = scanData;
        });
        if (isPaused) {
          return;
        }
        await controller.pauseCamera();
        debugPrint(result!.code);
        try {
          final Map<String, dynamic> response =
              await MedTagApi().getMedTag(medTagId: result!.code!);
          debugPrint("API Response: $response");
          MedTag medTag = MedTag.fromJson(response["data"]);
          String ttsMessage = getTTSMessage(medTag);
          await ttsSpeakStart(ttsMessage);
        } catch (e) {
          debugPrint(e.toString());
          ToastWidget.bottomToast(e.toString());
          rethrow;
        }
        await controller.resumeCamera();
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Updated ttsSpeakStart function with translation
  Future<void> ttsSpeakStart(String text) async {
    debugPrint("Original Text: $text");

    setState(() {
      isPaused = true;
      isSpeaking = true;
    });

    // Set up error and completion handlers
    flutterTts.setErrorHandler((msg) {
      debugPrint("Flutter TTS Error: $msg");
      setState(() {
        isPaused = false;
        isSpeaking = false;
      });
    });

    flutterTts.setCompletionHandler(() {
      debugPrint("Flutter TTS Completed");
      setState(() {
        isPaused = false;
        isSpeaking = false;
      });
    });

    // Retrieve the device's language settings
    Map<String, String> langObject = getLanguage();
    String lang = langObject['lang']!;
    String code = langObject['code']!;
    debugPrint("Device Language: $lang, Code: $code");

    // Check if the device language is supported by Flutter TTS
    bool isLanguageAvailable = await flutterTts.isLanguageAvailable(lang);
    if (!isLanguageAvailable) {
      debugPrint("Language '$lang' not available. Switching to English.");
      lang = "en";
      code = "en-US"; // Use a standard English locale
    }

    debugPrint("Selected Language for TTS: $lang, Code: $code");

    // Translate the text to the device's language
    String translatedText = await translate(text, lang);
    debugPrint("Translated Text: $translatedText");

    // Set the TTS language
    await flutterTts.setLanguage(code);

    // Speak the translated text
    await flutterTts.speak(translatedText);
  }

  Future<void> ttsSpeakStop() async {
    setState(() {
      isPaused = false;
      isSpeaking = false;
    });
    await flutterTts.stop();
  }

  // Translation function
  Future<String> translate(String input, String code) async {
    final GoogleTranslator translator = GoogleTranslator();
    try {
      Translation translation = await translator.translate(input, to: code);
      String translatedText = translation.text;
      debugPrint("Translation ($code): $translatedText");
      return translatedText;
    } catch (e) {
      debugPrint("Translation Error: $e");
      // Fallback to original text if translation fails
      return input;
    }
  }
}
