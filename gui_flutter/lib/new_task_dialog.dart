import 'package:antdesign_icons/antdesign_icons.dart';
import 'package:ensety_windows_test/providers/jobs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewTaskDialog extends StatefulWidget {
  const NewTaskDialog({Key? key}) : super(key: key);

  @override
  State<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends State<NewTaskDialog> {
  List<String> jobTypeItems = ['Regular', 'Manual'];
  List<String> jobFrequencyItems = [
    'Everyday',
    'Every two days',
    'Every week',
    'Every month'
  ];
  List<String> encryptionItems = ['None'];
  List<String> fileCompressionItems = ['None'];
  String jobTypeDropdownValue = 'Regular';
  String jobFrequencyDropdownValue = 'Everyday';
  String encryptionDropdownValue = 'None';
  String fileCompressionDropdownValue = 'None';

  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, String> _taskData = {
    'name': '',
    'description': '',
    'type': '',
  };

  List<String> _files = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result == null) return;
    for (PlatformFile file in result.files) {
      _files.add(file.path!);
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    Provider.of<Jobs>(context, listen: false).addNewTask(
      Task(
          id: Uuid().v4(),
          name: _taskData['name']!,
          description: _taskData['description']!,
          type: _taskData['type']!,
          nextLaunch: DateTime.now(),
          tags: []),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 500,
        width: 500,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(AntIcons.closeOutlined),
                      ),
                    ],
                  ),
                  InputTitle(
                      '${AppLocalizations.of(context)!.taskNameColumn}:'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Empty task name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _taskData['name'] = value!;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  InputTitle(
                      '${AppLocalizations.of(context)!.taskDescriptionColumn}:'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) {
                        _taskData['description'] = value!;
                      },
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InputTitle(
                      '${AppLocalizations.of(context)!.taskTagsColumn}:'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InputTitle(
                          '${AppLocalizations.of(context)!.taskTypeColumn}:'),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 150,
                        height: 35,
                        child: DropdownButtonFormField(
                          value: jobTypeDropdownValue,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onSaved: (val) {
                            _taskData['type'] = val! as String;
                          },
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: jobTypeItems.map((String item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              jobTypeDropdownValue = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InputTitle(
                          '${AppLocalizations.of(context)!.backupFrequencyLabel}:'),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 200,
                        height: 35,
                        child: DropdownButtonFormField(
                          value: jobFrequencyDropdownValue,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: jobFrequencyItems.map((String item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              jobFrequencyDropdownValue = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InputTitle('Selected files:'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _pickFile();
                    },
                    child: const Text(
                      'Add new',
                      style: TextStyle(color: Colors.blue),
                    ),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                  ),
                  if (_files.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemBuilder: (ctx, i) {
                          return Text(_files[i]);
                        },
                        itemCount: _files.length,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InputTitle(
                          '${AppLocalizations.of(context)!.backupEncryptionLabel}:'),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 200,
                        height: 35,
                        child: DropdownButtonFormField(
                          value: encryptionDropdownValue,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: encryptionItems.map((String item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              encryptionDropdownValue = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InputTitle(
                          '${AppLocalizations.of(context)!.backupFileCompressionLabel}:'),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 200,
                        height: 35,
                        child: DropdownButtonFormField(
                          value: fileCompressionDropdownValue,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: fileCompressionItems.map((String item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              fileCompressionDropdownValue = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _submit,
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          backgroundColor:
                              const Color.fromRGBO(24, 144, 255, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InputTitle extends StatelessWidget {
  final String title;

  InputTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
      ),
    );
  }
}
