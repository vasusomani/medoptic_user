import 'package:flutter/material.dart';
import 'package:medoptic_user/view/screens/home/scanner_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1000))
        .then((value) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScannerScreen(),
            )));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: MediaQuery.sizeOf(context).width * 0.5,
              width: MediaQuery.sizeOf(context).width * 0.5,
            ),
            const SizedBox(height: 30),
            Text(
              "MedOptic",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: Text(
                "Beyond limitations, beyond dependence.",
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ],
        ),
      ),
      // bottomSheet: Padding(
      //   padding:
      //       EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.12),
      //   child: PrimaryButton(
      //     onPressed: () => Navigator.pushNamed(context, '/login'),
      //     text: "Continue",
      //     widget: Transform.rotate(
      //       angle: pi,
      //       child: SvgPicture.asset(
      //         'assets/icons/Arrow1.svg',
      //         height: 21,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
