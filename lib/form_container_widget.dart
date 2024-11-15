import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FormContainerWidget extends StatefulWidget {
  final TextEditingController controller;
  final Key? fieldkey;
  final bool? isPassword;
  final String? hintText;
  final String? labelText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType? inputType;

  const FormContainerWidget({
    Key? key,
    required this.controller,
    this.fieldkey,
    this.isPassword = false,
    this.hintText,
    this.labelText,
    this.onSaved,
    this.validator,
    this.onChanged,
    this.inputType,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
