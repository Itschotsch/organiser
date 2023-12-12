import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:organiser/database.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EntityPage extends StatefulWidget {
  const EntityPage({super.key});

  @override
  State<EntityPage> createState() => _EntityPageState();
}

class _EntityPageState extends State<EntityPage> {
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
        title: const Text("Entity"),
        // Star icon to favourite the current entity:
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                entityProperties.bookmarked = !entityProperties.bookmarked;
                entityProperties.insertOrUpdate();
              });
            },
            icon: Icon(entityProperties.bookmarked ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Form to fill in the details of the new entity:
            // - Name
            // - Description
            // - Image (optional)
            // - Parent/Container (reference to another entity) (optional)
            // - Tags (optional: can be empty)
            // - QRID (optional: can be empty, can be scanned by QR code scanner on ScannerPage)
            children: [
              // Name
              // TextField(
              //   decoration: const InputDecoration(
              //     labelText: "Name",
              //     hintText: "What's the name of your entity?",
              //     border: OutlineInputBorder(),
              //   ),
              //   onChanged: (value) {
              //     entityProperties.name = value;
              //     onUpdateEntity();
              //   },
              //   controller: TextEditingController(text: entityProperties.name),
              //   autofocus: true,
              // ),
              Text(
                entityProperties.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              // Description
              // TextField(
              //   decoration: const InputDecoration(
              //     labelText: "Description",
              //     hintText: "Describe your entity...",
              //     border: OutlineInputBorder(),
              //   ),
              //   maxLines: null,
              //   keyboardType: TextInputType.multiline,
              //   onChanged: (value) {
              //     entityProperties.description = value;
              //     onUpdateEntity();
              //   },
              //   controller: TextEditingController(text: entityProperties.description),
              // ),
              // Text(
              //   entityProperties.description,
              //   style: Theme.of(context).textTheme.bodyLarge,
              // ),
              Builder(builder: (context) {
                if (entityProperties.description.isEmpty) {
                  // If the description is empty, display a cursive and transparent "No description" text:
                  return Opacity(
                    opacity: 0.5,
                    child: Text(
                      "No description",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  );
                } else {
                  return Text(
                    entityProperties.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                }
              }),
              const SizedBox(height: 16.0),
              // QRID
              // Builder(
              //   builder: (context) {
              //     if (entityProperties.qrid == null) {
              //       return ElevatedButton(
              //         onPressed: () {
              //           scanQRCode();
              //         },
              //         child: const Text("Scan QR Code"),
              //       );
              //     } else {
              //       return Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           QrImageView(
              //             data: entityProperties.qrid!,
              //             size: 100,
              //             padding: const EdgeInsets.all(0),
              //           ),
              //           const SizedBox(width: 16.0),
              //           Expanded(
              //             child: Text(
              //               entityProperties.qrid!,
              //               style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontStyle: FontStyle.italic),
              //               textAlign: TextAlign.center,
              //               overflow: TextOverflow.ellipsis,
              //               maxLines: 4,
              //             ),
              //           ),
              //           const SizedBox(width: 16.0),
              //           Column(
              //             children: [
              //               ElevatedButton(
              //                 onPressed: () {
              //                   scanQRCode();
              //                 },
              //                 child: const Text("Scan QR Code"),
              //               ),
              //               ElevatedButton(
              //                 onPressed: () {
              //                   setState(() {
              //                     entityProperties.qrid = null;
              //                   });
              //                 },
              //                 child: const Text("Clear QR Code"),
              //               ),
              //             ],
              //           ),
              //         ],
              //       );
              //     }
              //   },
              // ),
              Builder(
                builder: (context) {
                  List<Widget> row = [];
                  if (entityProperties.qrid != null) {
                    row += [
                      QrImageView(
                        data: entityProperties.qrid!,
                        size: 100,
                        padding: const EdgeInsets.all(0),
                      ),
                    ];
                  }
                  if (entityProperties.image != null) {
                    row += [
                      Image.memory(
                        entityProperties.image!,
                        width: 100,
                        height: 100,
                      ),
                    ];
                  }
                  if (row.isEmpty) {
                    return const SizedBox();
                  }
                  // insert spacer between images
                  row.map((e) => [e, const SizedBox(width: 16.0)]).expand((e) => e).toList().removeLast();
                  return Row(
                    mainAxisAlignment: row.length == 1 ? MainAxisAlignment.center : MainAxisAlignment.spaceAround,
                    children: row,
                  );
                },
              ),
              // Image
              // Builder(
              //   builder: (context) {
              //     if (entityProperties.image == null) {
              //       return ElevatedButton(
              //         onPressed: () {
              //           pickImageOrTakePhoto("Add Image");
              //         },
              //         child: const Text("Add Image"),
              //       );
              //     } else {
              //       return Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Image.memory(
              //             entityProperties.image!,
              //             width: 100,
              //             height: 100,
              //           ),
              //           const SizedBox(width: 16.0),
              //           Column(
              //             children: [
              //               ElevatedButton(
              //                 onPressed: () {
              //                   pickImageOrTakePhoto("Change Image");
              //                 },
              //                 child: const Text("Change Image"),
              //               ),
              //               ElevatedButton(
              //                 onPressed: () {
              //                   setState(() {
              //                     entityProperties.image = null;
              //                   });
              //                 },
              //                 child: const Text("Remove Image"),
              //               ),
              //             ],
              //           ),
              //         ],
              //       );
              //     }
              //   },
              // ),

              // const SizedBox(height: 16.0),
              // // Tags
              // Builder(
              //   builder: (context) {
              //     List<Widget> widgets = [];

              //     for (var tag in entityProperties.tags) {
              //       widgets.add(
              //         Chip(
              //           label: Text(tag),
              //           onDeleted: () {
              //             setState(() {
              //               entityProperties.tags.remove(tag);
              //             });
              //           },
              //         ),
              //       );
              //     }

              //     widgets.add(
              //       ElevatedButton(
              //         onPressed: () async {
              //           // Push '/tags' and use the tags returned from it:
              //           Navigator.pushNamed(context, "/tags", arguments: entityProperties.tags).then((tags) {
              //             if (tags != null) {
              //               setState(() {
              //                 entityProperties.tags = tags as List<String>;
              //               });
              //             }
              //           });
              //         },
              //         child: const Text("Add Tags"),
              //       ),
              //     );

              //     return Wrap(
              //       spacing: 8.0,
              //       runSpacing: 8.0,
              //       children: widgets,
              //     );
              //   },
              // ),
              const SizedBox(height: 16.0),
              // Tags:
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: entityProperties.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                  );
                }).toList(),
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
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     if (entityProperties.entityID != null)
      //       FloatingActionButton(
      //         heroTag: "secondaryFloatingActionButton",
      //         child: const Icon(Icons.delete),
      //         onPressed: () {
      //           showDialog(
      //             context: context,
      //             builder: (context) {
      //               return AlertDialog(
      //                 title: const Text("Delete Entity"),
      //                 content: const Text("Are you sure you want to delete this entity?"),
      //                 actions: [
      //                   TextButton(
      //                     onPressed: () {
      //                       Navigator.pop(context); // Close the dialog
      //                     },
      //                     child: const Text("Cancel"),
      //                   ),
      //                   TextButton(
      //                     onPressed: () async {
      //                       Navigator.pop(context); // Close the dialog
      //                       await delete(entityProperties.entityID!);
      //                     },
      //                     child: const Text("Delete"),
      //                   ),
      //                 ],
      //               );
      //             },
      //           );
      //         },
      //       ),
      //     if (entityProperties.entityID != null) const SizedBox(height: 16.0),
      //     FloatingActionButton(
      //       heroTag: "mainFloatingActionButton",
      //       child: const Icon(Icons.save),
      //       onPressed: () {
      //         // Go back to the previous page, and pass the entityProperties back to it:
      //         save();
      //       },
      //     ),
      //   ],
      // ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () {
          Navigator.pushNamed(context, '/modify-entity', arguments: entityProperties).then((entityPropertiesOrEntityID) {
            // If entityPropertiesOrEntityID is an EntityProperties, then it was updated. If it is an int, then it was deleted.
            if (entityPropertiesOrEntityID is EntityProperties) {
              setState(() {
                entityProperties = entityPropertiesOrEntityID;
              });
            } else if (entityPropertiesOrEntityID is int) {
              Navigator.pop(context, entityPropertiesOrEntityID);
            }
          });
        },
      ),
    );
  }

  void onUpdateEntity() {
    // Do nothing for now
  }

  // void pickImageOrTakePhoto(String title) => showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text(title),
  //           contentPadding: const EdgeInsets.all(8),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               ListTile(
  //                 leading: const Icon(Icons.photo),
  //                 title: const Text("Pick Image from Gallery"),
  //                 onTap: () {
  //                   Navigator.pop(context); // Close the dialog
  //                   pickImageFromGallery();
  //                 },
  //               ),
  //               ListTile(
  //                 leading: const Icon(Icons.camera_alt),
  //                 title: const Text("Take Photo"),
  //                 onTap: () {
  //                   Navigator.pop(context); // Close the dialog
  //                   takePhoto();
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     );

  // void pickImageFromGallery() async {
  //   try {
  //     final XFile? pickedImage = await ImagePicker().pickImage(
  //       source: ImageSource.gallery,
  //     );
  //     if (pickedImage != null) {
  //       setState(() {
  //         entityProperties.image = File(pickedImage.path).readAsBytesSync();
  //       });
  //     }
  //   } catch (e) {
  //     // Do nothing
  //     // This is probably because the user denied access to the gallery.
  //   }
  // }

  // void takePhoto() async {
  //   try {
  //     final XFile? takenPhoto = await ImagePicker().pickImage(
  //       source: ImageSource.camera,
  //     );
  //     if (takenPhoto != null) {
  //       setState(() {
  //         entityProperties.image = File(takenPhoto.path).readAsBytesSync();
  //       });
  //     }
  //   } catch (e) {
  //     // Do nothing
  //     // This is probably because the user denied access to the camera.
  //   }
  // }

  // void scanQRCode() async {
  //   // Push '/scanner' and use the QRID returned from it:
  //   Navigator.pushNamed(context, '/scanner').then((qrid) {
  //     if (qrid != null) {
  //       setState(
  //         () {
  //           entityProperties.qrid = qrid as String;
  //         },
  //       );
  //     }
  //   });
  // }

  // Future<void> save() async {
  //   await entityProperties.insertOrUpdate().then((entityID) {
  //     Navigator.pop(context, entityID);
  //   });
  // }

  // Future<bool> delete(int entityID) async {
  //   return await entityProperties.delete().then((success) {
  //     if (success) {
  //       Navigator.pop(context, entityID);
  //     }
  //     return success;
  //   });
  // }
}
