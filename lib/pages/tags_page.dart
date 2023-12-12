import 'package:flutter/material.dart';
import 'package:organiser/database.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  late Future<List<String>> allTagsFuture;
  List<String>? allTags;
  late List<String> currentTags;

  @override
  void initState() {
    super.initState();
    allTagsFuture = OrganisationDatabase.queryAllTags();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      currentTags = ((ModalRoute.of(context)?.settings.arguments ?? []) as List<String>).toList();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tags"),
      ),
      body: FutureBuilder(
        future: allTagsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            // Set the union of allTags and currentTags to allTags.
            allTags ??= snapshot.data as List<String>;
            allTags = allTags!.toSet().union(currentTags.toSet()).toList();

            // Display a list of all the tags in the database.
            // Tags are selectable, selected tags have a trailing checkmark.
            // Once the user is done selecting tags, they can press the "Done" button.
            return Expanded(
              child: ListView.builder(
                itemCount: allTags!.length,
                itemBuilder: (context, index) {
                  String tag = allTags![index];
                  return ListTile(
                    title: Text(tag),
                    trailing: currentTags.contains(tag) ? const Icon(Icons.check) : null,
                    onTap: () {
                      if (currentTags.contains(tag)) {
                        currentTags.remove(tag);
                      } else {
                        currentTags.add(tag);
                      }
                      setState(() {});
                    },
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "secondaryFloatingActionButton",
            child: const Icon(Icons.add),
            onPressed: () {
              // Prompt the user to enter a new tag.
              showDialog(
                context: context,
                builder: (context) {
                  String newTag = "";
                  return AlertDialog(
                    title: const Text("New Tag"),
                    content: TextField(
                      decoration: const InputDecoration(
                        labelText: "Tag",
                      ),
                      onChanged: (value) {
                        newTag = value.trim();
                      },
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: const Text("Add"),
                        onPressed: () {
                          // Add the new tag to allTags and currentTags.
                          Navigator.pop(context);
                          setState(() {
                            allTags = [...allTags ?? [], newTag];
                            currentTags = [...currentTags, newTag];
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "primaryFloatingActionButton",
            child: const Icon(Icons.done),
            onPressed: () {
              print("Returning tags: $currentTags"); // DEBUG
              Navigator.pop(context, currentTags);
            },
          ),
        ],
      ),
    );
  }
}
