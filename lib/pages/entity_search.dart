import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:tuple/tuple.dart';

import '../database.dart';
import 'home_page.dart';

class EntitySearchDelegate extends SearchDelegate<EntityProperties?> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          // Clear the search query:
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // Close the search delegate and return to the previous screen:
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Search for entities with the query:
    return FutureBuilder(
      future: OrganisationDatabase.queryEntitiesBySearch(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<EntityProperties> entities = snapshot.data as List<EntityProperties>;
          return ListView.builder(
            itemCount: entities.length,
            itemBuilder: (context, index) {
              return HomePage.buildEntityListTile(context, entities[index], () {
                // setState(() {});
              });
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Search for entities with the query:
    return FutureBuilder(
      future: OrganisationDatabase.queryEntitiesBySearch(query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<EntityProperties> entities = snapshot.data as List<EntityProperties>;
          return ListView.builder(
            itemCount: entities.length,
            itemBuilder: (context, index) {
              EntityProperties entity = entities[index];
              return HomePage.buildEntityListTile(context, entity, () {
                // setState(() {});
              });
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class EntitySearch {
  static List<EntityProperties> sortByRelevance(List<EntityProperties> entities, String query) {
    final List<Tuple2<EntityProperties, double>> entitiesWithRelevance = entities.map((entity) {
      double relevance = 0;
      relevance += entity.name.similarityTo(query);
      relevance += entity.description.similarityTo(query) * 0.8;
      relevance += entity.tags.join(",").similarityTo(query) * 0.6;
      relevance += entity.bookmarked ? 0.3 : 0;
      relevance += 1.0 / (DateTime.now().difference(entity.modifiedOn!).inDays + 1) * 0.2;
      return Tuple2(entity, relevance);
    }).toList();
    entitiesWithRelevance.sort((a, b) => b.item2.compareTo(a.item2));
    return entitiesWithRelevance.map((e) => e.item1).toList();
  }
}
