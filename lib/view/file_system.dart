import 'dart:convert';

import 'package:s5_demo_app/app.dart';

class FileSystemView extends StatefulWidget {
  const FileSystemView({super.key});

  @override
  State<FileSystemView> createState() => _FileSystemViewState();
}

class _FileSystemViewState extends State<FileSystemView> {
  final ctrl = TextEditingController(
    text:
        'fs5://blxwr5xywkgik3epwaswsuz5wxnj2dk6bjsabvkvhltguitwqcgjcpei/archlinux',
  );
  @override
  void initState() {
    _loadDirectory();
    super.initState();
  }

  DirectoryMetadata? dir;

  void _loadDirectory() async {
    setState(() {
      dir = null;
    });
    dir = await s5.fs.listDirectory(ctrl.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 12),
          child: Row(
            children: [
              if (ctrl.text.substring(6).contains('/')) ...[
                IconButton(
                  onPressed: () {
                    ctrl.text = ctrl.text.substring(
                      0,
                      ctrl.text.length - ctrl.text.split('/').last.length - 1,
                    );
                    _loadDirectory();
                  },
                  icon: const Icon(Icons.arrow_upward),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
              Expanded(
                child: TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'FS5 URI',
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  _loadDirectory();
                },
                child: Text('Load'),
              ),
            ],
          ),
        ),
        dir == null
            ? const LinearProgressIndicator()
            : Expanded(
                child: ListView.builder(
                  itemCount: dir!.directories.length + dir!.files.length,
                  itemBuilder: (context, index) {
                    if (index < dir!.directories.length) {
                      final d = dir!.directories.values.toList()[index];
                      // TODO Show if encrypted
                      return ListTile(
                        leading: const Icon(Icons.folder_copy_outlined),
                        title: Text(d.name),
                        trailing: Text(
                          DateTime.fromMillisecondsSinceEpoch(d.created)
                              .toIso8601String(),
                        ),
                        onTap: () {
                          ctrl.text = '${ctrl.text}/${d.name}';
                          _loadDirectory();
                        },
                      );
                    }
                    final f = dir!.files.values
                        .toList()[index - dir!.directories.length];
                    return ListTile(
                      leading: const Icon(Icons.file_open_outlined),
                      title: Text(f.name),
                      trailing: Text(
                        DateTime.fromMillisecondsSinceEpoch(f.created)
                            .toIso8601String(),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('File Reference as JSON'),
                            content: SelectableText(
                              const JsonEncoder.withIndent('  ').convert(f),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
      ],
    );
  }
}
