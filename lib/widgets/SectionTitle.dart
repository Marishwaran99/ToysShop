import 'package:flutter/cupertino.dart';
import 'package:toys/styles/custom.dart';

class SectionTitle extends StatelessWidget {
  final title;
  final Custom custom = Custom();
  SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16),
      child: Text(title, style: custom.titleTextStyle,),
    );
  }
}