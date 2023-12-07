import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:organiser/database.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ModifyEntityPage extends StatefulWidget {
  const ModifyEntityPage({super.key});

  @override
  State<ModifyEntityPage> createState() => _ModifyEntityPageState();
}

class _ModifyEntityPageState extends State<ModifyEntityPage> {
  EntityProperties entityProperties = EntityProperties(
    name: "",
    description: "",
    tags: [],
    bookmarked: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      EntityProperties? entity = ModalRoute.of(context)!.settings.arguments as EntityProperties?;
      if (entity != null) {
        setState(() {
          entityProperties = entity;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entityProperties.entityID == null ? "New Entity" : "Edit Entity"),
        // Star icon to favourite the current entity:
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                entityProperties.bookmarked = !entityProperties.bookmarked;
              });
            },
            icon: Icon(entityProperties.bookmarked ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Form to fill in the details of the new entity:
          // - Name
          // - Description
          // - Image (optional)
          // - Parent/Container (reference to another entity) (optional)
          // - Tags (optional: can be empty)
          // - QRID (optional: can be empty, can be scanned by QR code scanner on ScannerPage)
          children: [
            // Name
            TextField(
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "What's the name of your entity?",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                entityProperties.name = value;
                onUpdateEntity();
              },
              controller: TextEditingController(text: entityProperties.name),
              autofocus: true,
            ),
            const SizedBox(height: 16.0),
            // Description
            TextField(
              decoration: const InputDecoration(
                labelText: "Description",
                hintText: "Describe your entity...",
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              onChanged: (value) {
                entityProperties.description = value;
                onUpdateEntity();
              },
              controller: TextEditingController(text: entityProperties.description),
            ),
            const SizedBox(height: 16.0),
            // QRID
            Builder(
              builder: (context) {
                if (entityProperties.qrid == null) {
                  return ElevatedButton(
                    onPressed: () {
                      scanQRCode();
                    },
                    child: const Text("Scan QR Code"),
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QrImageView(
                        data: entityProperties.qrid!,
                        size: 100,
                        padding: const EdgeInsets.all(0),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          entityProperties.qrid!,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              scanQRCode();
                            },
                            child: const Text("Scan QR Code"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                entityProperties.qrid = null;
                              });
                            },
                            child: const Text("Clear QR Code"),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16.0),
            // Image
            Builder(
              builder: (context) {
                if (entityProperties.image == null) {
                  return ElevatedButton(
                    onPressed: () {
                      pickImageOrTakePhoto("Add Image");
                    },
                    child: const Text("Add Image"),
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.file(
                        entityProperties.image!,
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              pickImageOrTakePhoto("Change Image");
                            },
                            child: const Text("Change Image"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                entityProperties.image = null;
                              });
                            },
                            child: const Text("Remove Image"),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.save),
      //   onPressed: () {
      //     // Go back to the previous page, and pass the entityProperties back to it:
      //     Navigator.pop(context, entityProperties);
      //   },
      // ),
      // if entityID is not null, also show a delete button:
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (entityProperties.entityID != null)
            FloatingActionButton(
              heroTag: "secondaryFloatingActionButton",
              child: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Delete Entity"),
                      content: const Text("Are you sure you want to delete this entity?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await delete(entityProperties.entityID!);
                          },
                          child: const Text("Delete"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          if (entityProperties.entityID != null) const SizedBox(height: 16.0),
          FloatingActionButton(
            heroTag: "mainFloatingActionButton",
            child: const Icon(Icons.save),
            onPressed: () {
              // Go back to the previous page, and pass the entityProperties back to it:
              save();
            },
          ),
        ],
      ),
    );
  }

  void onUpdateEntity() {
    // Do nothing for now
  }

  void pickImageOrTakePhoto(String title) => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            contentPadding: const EdgeInsets.all(8),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Pick Image from Gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    takePhoto();
                  },
                ),
              ],
            ),
          );
        },
      );

  void pickImageFromGallery() async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        entityProperties.image = File(pickedImage.path);
      });
    }
  }

  void takePhoto() async {
    final XFile? takenPhoto = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (takenPhoto != null) {
      setState(() {
        entityProperties.image = File(takenPhoto.path);
      });
    }
  }

  void scanQRCode() async {
    // Push '/scanner' and use the QRID returned from it:
    Navigator.pushNamed(context, '/scanner').then((qrid) {
      if (qrid != null) {
        setState(
          () {
            entityProperties.qrid = qrid as String;
          },
        );
      }
    });
  }

  Future<void> save() async {
    Navigator.pop(context);
    await entityProperties.insertOrUpdate();
  }

  Future<bool> delete(int entityID) async {
    Navigator.pop(context);
    return await entityProperties.delete();
  }
}
