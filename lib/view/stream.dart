import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:lib5/encryption.dart';

import 'package:s5_demo_app/app.dart';

class StreamView extends StatefulWidget {
  const StreamView({super.key});

  @override
  State<StreamView> createState() => _StreamViewState();
}

class _StreamViewState extends State<StreamView> {
  @override
  void initState() {
    connect();
    super.initState();
  }

  final tsOffset = 1706913965000;

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  final ctrl = TextEditingController(
    text: 'example_key',
  );

  final chatCtrl = TextEditingController();

  StreamSubscription? sub;

  late Uint8List encryptionKey;
  late KeyPairEd25519 kp;

  void connect() async {
    print('connect');
    final id = s5.crypto.hashBlake3Sync(utf8.encode(ctrl.text));
    encryptionKey = s5.crypto.hashBlake3Sync(id);
    kp = await s5.crypto.newKeyPairEd25519(seed: id);

    sub = s5.api.streamSubscribe(kp.publicKey).listen((msg) async {
      messages.insert(0, (
        utf8.decode(
          await decryptMutableBytes(
            msg.data,
            encryptionKey,
            crypto: s5.crypto,
          ),
        ),
        msg.ts
      ));
      setState(() {});
    });
  }

  void disconnect() {
    print('disconnect');
    sub?.cancel();
    messages.clear();
  }

  bool canEdit = false;

  final messages = <(String, int)>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 12),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    canEdit = !canEdit;
                  });
                  if (!canEdit) {
                    connect();
                  } else {
                    disconnect();
                  }
                },
                child: Text(
                  canEdit ? 'Apply new Key' : 'Change Key',
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: TextField(
                  enabled: canEdit,
                  controller: ctrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Stream Key',
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: ListView.builder(
          itemCount: messages.length,
          reverse: true,
          itemBuilder: (context, index) {
            final msg = messages[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 4),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(msg.$1)),
                      Text(
                        DateTime.fromMillisecondsSinceEpoch(msg.$2 + tsOffset)
                            .toIso8601String()
                            .replaceFirst(
                              'T',
                              ' ',
                            ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            enabled: !canEdit,
            controller: chatCtrl,
            onSubmitted: (str) async {
              final ts = DateTime.now().millisecondsSinceEpoch - tsOffset;
              messages.insert(0, (str, ts));

              final msg = await SignedStreamMessage.create(
                kp: kp,
                data: await encryptMutableBytes(
                  utf8.encode(str),
                  encryptionKey,
                  crypto: s5.crypto,
                ),
                ts: ts,
                crypto: s5.crypto,
              );

              s5.api.streamPublish(msg);

              setState(() {});
              chatCtrl.clear();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Send a message...',
            ),
          ),
        ),
      ],
    );
  }
}
