import 'package:flutter/material.dart';

class DisplayAuthProvider extends StatelessWidget {
  final String? email;
  final String authProvider;

  const DisplayAuthProvider({super.key, this.email, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: (authProvider == 'apple.com') ? Colors.black : Colors.white,
        boxShadow: (authProvider == 'apple.com')
            ? null
            : [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (authProvider == 'apple.com')
              ? const Icon(
            IconData(0xf02d8, fontFamily: 'MaterialIcons'),
            size: 30,
            color: Colors.white,
          )
              : SizedBox(
              width: 30,
              height: 30,
              child: Image.asset('assets/google.png')),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                email ??
                    ((authProvider == 'apple.com')
                        ? 'Mit Apple angemeldet'
                        : 'Über Google angemeldet'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: (authProvider == 'apple.com')
                      ? Colors.white
                      : Colors.black54,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
