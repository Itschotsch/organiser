import 'package:flutter/material.dart';
import '../database.dart';
import 'entity_search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  static Widget buildEntityListTile(BuildContext context, EntityProperties entity, Function() setState) {
    return ListTile(
      key: ValueKey(entity.entityID.toString()),
      title: Text(
        entity.name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Builder(builder: (context) {
        if (entity.description.isEmpty) {
          // If the description is empty, display a cursive and transparent "No description" text:
          return Opacity(
            opacity: 0.5,
            child: Text(
              "No description",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          );
        } else {
          return Text(
            entity.description,
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
      }),
      leading: entity.image == null
          ? Container(
              width: 50,
              height: 50,
              color: Theme.of(context).colorScheme.primary,
            )
          : Image.memory(
              entity.image!,
              width: 50,
              height: 50,
            ),
      trailing: entity.bookmarked ? const Icon(Icons.star) : null,
      onTap: () {
        Navigator.pushNamed(context, '/entity', arguments: entity).then((value) {
          setState();
        });
      },
    );
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Turn app bar into a search bar:
              showSearch(
                context: context,
                delegate: EntitySearchDelegate(),
              ).then((value) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      // Display a list of all the entities in the database:
      // OrganisationDatabase.getNumberOfEntities() and OrganisationDatabase.getEntities()
      body: FutureBuilder(
        future: Future.wait([
          OrganisationDatabase.getNumberOfEntities(),
          OrganisationDatabase.queryAllEntities(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int numberOfEntities = snapshot.data![0] as int;
            List<EntityProperties> entities = snapshot.data![1] as List<EntityProperties>;
            return ListView.builder(
              itemCount: numberOfEntities,
              itemBuilder: (BuildContext context, int index) {
                EntityProperties entity = entities[index];
                return HomePage.buildEntityListTile(context, entity, () {
                  setState(() {});
                });
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "secondaryFloatingActionButton",
            onPressed: () {
              Navigator.pushNamed(context, '/scanner').then(
                (qrid) async {
                  if (qrid != null) {
                    // A QR code was scanned, so go to the ModifyEntityPage:
                    OrganisationDatabase.queryEntityByQRID(qrid as String).then(
                      (EntityProperties? entity) {
                        if (entity == null) {
                          // Toast
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("No entity with QRID $qrid found.\nCreating new entity..."),
                            ),
                          );
                          Navigator.pushNamed(context, '/modify-entity', arguments: null).then((value) {
                            setState(() {});
                          });
                        } else {
                          Navigator.pushNamed(context, '/entity', arguments: entity).then((value) {
                            setState(() {});
                          });
                        }
                      },
                    );
                  }
                },
              );
            },
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "mainFloatingActionButton",
            onPressed: () {
              Navigator.pushNamed(context, '/modify-entity', arguments: null).then((value) {
                setState(() {});
              });
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
