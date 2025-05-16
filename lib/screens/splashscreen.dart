// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'main_page.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MainPage()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Theme.of(context).scaffoldBackgroundColor,
//       statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
//           ? Brightness.light
//           : Brightness.dark,
//     ));

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Bigger image
//             SizedBox(
//               width: 350, // Increased width
//               height: 350, // Increased height
//               child: Image.asset(
//                 'assets/icon/Adobe Express - file.png',
//                 fit: BoxFit.contain,
//               ),
//             ),
//             const SizedBox(height: 40),
//             CircularProgressIndicator(
//               color: Theme.of(context).colorScheme.primary,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Loading your library...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Theme.of(context)
//                         .textTheme
//                         .bodyLarge
//                         ?.color
//                         ?.withOpacity(0.8) ??
//                     Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).scaffoldBackgroundColor,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              height: 350,
              child: Image.asset(
                isDarkMode
                    ? 'assets/icon/2.png' // Dark mode image
                    : 'assets/icon/1.png', // Light mode image
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Loading your library...',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.8) ??
                    Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
