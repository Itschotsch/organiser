import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:organiser/database.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum ModifyEntityPageReturnValue {
  delete,
}

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
          // copy
          entityProperties = entity.copy();
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
        child: SingleChildScrollView(
          child: Column(
            // Form to fill in the details of the new entity:
            // - Name
            // - Description
            // - Image (optional)
            // - Parent/Container (reference to another entity) (optional)
            // - Tags (optional: can be empty)
            // - QRID (optional: can be empty, can be scanned by QR code scanner on ScannerPage)
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Image.memory(
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
              const SizedBox(height: 16.0),
              // Tags
              Builder(
                builder: (context) {
                  List<Widget> widgets = [];

                  for (var tag in entityProperties.tags) {
                    widgets.add(
                      Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            entityProperties.tags.remove(tag);
                          });
                        },
                      ),
                    );
                  }

                  widgets.add(
                    ElevatedButton(
                      onPressed: () async {
                        // Push '/tags' and use the tags returned from it:
                        Navigator.pushNamed(context, "/tags", arguments: entityProperties.tags).then((tags) {
                          print("Returned tags: $tags"); // DEBUG
                          if (tags != null) {
                            setState(() {
                              entityProperties.tags = tags as List<String>;
                            });
                          }
                        });
                      },
                      child: const Text("Add Tags"),
                    ),
                  );

                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widgets,
                  );
                },
              ),
            ],
          ),
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
                            Navigator.pop(context); // Close the dialog
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // Close the dialog
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
                    Navigator.pop(context); // Close the dialog
                    pickImageFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take Photo"),
                  onTap: () {
                    Navigator.pop(context); // Close the dialog
                    takePhoto();
                  },
                ),
              ],
            ),
          );
        },
      );

  void pickImageFromGallery() async {
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        setState(() {
          entityProperties.image = File(pickedImage.path).readAsBytesSync();
        });
      }
    } catch (e) {
      // Do nothing
      // This is probably because the user denied access to the gallery.
    }
  }

  void takePhoto() async {
    try {
      final XFile? takenPhoto = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (takenPhoto != null) {
        setState(() {
          entityProperties.image = File(takenPhoto.path).readAsBytesSync();
        });
      }
    } catch (e) {
      // Do nothing
      // This is probably because the user denied access to the camera.
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
    await entityProperties.insertOrUpdate().then((entityID) {
      // Navigator.pop(context, entityID);
      // Navigator.pushNamed(context, '/entity', arguments: entityProperties);
      if (entityProperties.entityID == null) {
        // A new entity was created, so go to the EntityPage:
        Navigator.pushNamed(context, '/entity', arguments: entityProperties).then((value) {
          setState(() {});
        });
      } else {
        // An existing entity was updated, so go back to the previous page:
        Navigator.pop(context, entityProperties);
      }
    });
  }

  Future<bool> delete(int entityID) async {
    return await entityProperties.delete().then((success) {
      if (success) {
        Navigator.pop(context, entityID);
      }
      return success;
    });
  }
}
