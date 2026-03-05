import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../firebase/firebase_auth.dart';
import '../../utilities/copy_to_clipboard.dart';

class Attribution extends StatelessWidget {
  final String version;
  final double spacing;

  const Attribution({super.key, required this.version, required this.spacing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('bergdinge.de'),
            trailing: Icon(Icons.launch_rounded),
            onTap: () async {
              final Uri url = Uri.parse('https://bergdinge.de/');
              launchUrl(url).then((didLaunch) {
                if (didLaunch == false && context.mounted) {
                  copyToClipboard(
                      context: context, value: 'https://bergdinge.de/');
                }
              });
            },
          ),
          ListTile(
            title: Text('info@bergdinge.de'),
            trailing: Icon(Icons.mail_outline_rounded),
            onTap: () async {
              String? encodeQueryParameters(Map<String, String> params) {
                return params.entries
                    .map((MapEntry<String, String> e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                    .join('&');
              }

              final Uri uri = Uri(
                scheme: 'mailto',
                path: 'info@bergdinge.de',
                query: encodeQueryParameters(<String, String>{
                  'subject': 'Bergdinge',
                }),
              );

              launchUrl(uri).then((didLaunch) {
                if (didLaunch == false && context.mounted) {
                  copyToClipboard(context: context, value: 'info@bergdinge.de');
                }
              });
            },
          ),
          ListTile(
            title: Text('UID kopieren'),
            onTap: () {
              copyToClipboard(
                  context: context,
                  value: Auth().user?.uid ?? 'uid not provided');
            },
            trailing: Icon(Icons.copy_rounded),
          ),
          Padding(padding: EdgeInsets.only(top: spacing)),
          ListTile(
              title: Text('Images designed by Freepik'),
              trailing: Icon(Icons.launch_rounded),
              onTap: () async {
                final Uri url = Uri.parse('https://freepik.com/');
                launchUrl(url).then((didLaunch) {
                  if (didLaunch == false && context.mounted) {
                    copyToClipboard(
                        context: context, value: 'https://freepik.com/');
                  }
                });
              }),
          ListTile(
            title: Text('Lizenzen'),
            trailing: Icon(Icons.arrow_forward_rounded),
            onTap: () => showLicensePage(
                context: context,
                applicationName: 'Bergdinge',
                applicationVersion: version,
                useRootNavigator: true),
          ),
        ],
      ),
    );
  }
}