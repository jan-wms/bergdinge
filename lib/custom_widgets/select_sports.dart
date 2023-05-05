import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import '../data/data.dart';

Future<List<String>> selectSports(
    BuildContext context, List<String> selected) async {
  final GlobalKey<_SelectSportsState> k = GlobalKey();
  final SelectSports selectSports = SelectSports(
    key: k,
    selected: selected,
  );
  await CustomDialog.showCustomModal(
    context,
    selectSports,
    null,
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Fertig'),
    ),
  );
  return k.currentState!.selected;
}

class SelectSports extends StatefulWidget {
  final List<String> selected;

  const SelectSports({Key? key, required this.selected}) : super(key: key);

  @override
  State<SelectSports> createState() => _SelectSportsState();
}

class _SelectSportsState extends State<SelectSports> {
  late List<String> selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Sportarten'),
        Wrap(spacing: 5.0, children: [
          for (var sport in Data.sports)
            FilterChip(
              label: Text(sport),
              selected: selected.contains(sport),
              onSelected: (bool value) {
                setState(() {
                  if (value) {
                    if (!selected.contains(sport)) {
                      selected.add(sport);
                    }
                  } else {
                    selected.removeWhere((String s) {
                      return s == sport;
                    });
                  }
                });
              },
            )
        ]),
      ],
    );
  }
}