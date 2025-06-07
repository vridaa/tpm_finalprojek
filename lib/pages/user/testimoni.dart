import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';

class ComponentHelp extends StatelessWidget {
  final List<String> textList;

  const ComponentHelp({super.key, required this.textList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: textList.map((text) => _text(text)).toList(),
    );
  }

  Widget _text(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}

final Map<String, String> vridaProfile = {
  'instagram': 'vridaa_',
  'name': 'vrida Pusparani',
  'nim': '123220082',
  'image': 'assets/images/rani.jpg',
};

class KritikContent extends StatelessWidget {
  const KritikContent({super.key});

  static const List<String> textList = [
    "Saya kira bikin stress",
    "ternyata memang ^^"
  ];

  @override
  Widget build(BuildContext context) => const ComponentHelp(textList: textList);
}

class SaranContent extends StatelessWidget {
  const SaranContent({super.key});

  static const List<String> textList = [
    "Waktunya panjangin pak, kelas yang dapet bapak gacuma satu :((((((",
    "Semoga saya dapet A.",
  ];

  @override
  Widget build(BuildContext context) => const ComponentHelp(textList: textList);
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const headerStyle = TextStyle(
    color: Color(0xffffffff),
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const contentStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(vridaProfile['image']!),
            ),
            const SizedBox(height: 16),
            Text(
              vridaProfile['name']!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'NIM: ${vridaProfile['nim']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email_outlined, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  '@${vridaProfile['instagram']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 246, 246),
      appBar: AppBar(title: const Text('Testimonial')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              _buildProfileCard(),
              Accordion(
                headerBackgroundColor: const Color(0xff9A87B6),
                contentBackgroundColor: Colors.white,
                contentBorderColor: const Color(0xff9A87B6),
                contentBorderWidth: 3,
                contentHorizontalPadding: 20,
                contentVerticalPadding: 20,
                scaleWhenAnimating: false,
                headerBorderRadius: 6,
                headerPadding: const EdgeInsets.all(18),
                sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                sectionClosingHapticFeedback: SectionHapticFeedback.light,
                children: [
                  AccordionSection(
                    leftIcon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                    header: const Text('Ungkapan', style: headerStyle),
                    content: const Column(children: [KritikContent()]),
                  ),
                  AccordionSection(
                    leftIcon: const Icon(Icons.mail, color: Colors.redAccent),
                    header: const Text('Pesan', style: headerStyle),
                    content: const Column(children: [SaranContent()]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}