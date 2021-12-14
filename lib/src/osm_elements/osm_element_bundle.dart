import 'dart:core';
import '/src/osm_elements/osm_element.dart';
import '/src/osm_elements/osm_node.dart';
import '/src/osm_elements/osm_way.dart';
import '/src/osm_elements/osm_relation.dart';

// helper function for null safety
// https://github.com/dart-lang/sdk/issues/42947
extension IterableExtension<E> on Iterable<E> {
  E? findFirst(bool Function(E) test) {}
}

/**
 * A container class for multiple OSM elements of different types.
 * This provides also some helper functions to deal with the data more easily.
 */
class OSMElementBundle {

  final nodes =  <OSMNode>{};

  final ways = <OSMWay>{};

  final relations = <OSMRelation>{};


  /**
   * Returns an iterable of all [OSMElement]s in this bundle.
   * This can be used to easily iterate over [nodes], [ways] and [relations] in one loop.
   */
  Iterable<OSMElement> get elements sync* {
    yield* nodes;
    yield* ways;
    yield* relations;
  }


  /**
   * This takes an iterable of [OSMElement]s and puts each element in its dedicated [nodes], [ways] or [relations] list.
   */
  OSMElementBundle(Iterable<OSMElement> elements) {
    for (var element in elements) {
      switch (element.runtimeType) {
        case OSMNode:
          nodes.add(element as OSMNode);
        break;
        case OSMWay:
          ways.add(element as OSMWay);
        break;
        case OSMRelation:
          relations.add(element as OSMRelation);
        break;
      }
    }
  }


  /**
   * A function to get all [OSMNode]s from the current [OSMElementBundle] that are contained in the given [OSMWay].
   */
  Iterable<OSMNode> getNodesFromWay(OSMWay way) sync* {
    for (var nodeId in way.nodeIds) {
      // skip nodes that do not have a valid id yet
      if (nodeId == 0) continue;

      var node = nodes.findFirst((node) => node.id == nodeId);
      if (node != null) {
        yield node;
      }
    }
  }


  /**
   * A function to get all [OSMNode]s from the current [OSMElementBundle] that are contained in the given [OSMRelation].
   */
  Iterable<OSMNode> getNodesFromRelation(OSMRelation relation) {
    return _getElementFromRelation(nodes, relation);
  }


  /**
   * A function to get all [OSMWay]s from the current [OSMElementBundle] that are contained in the given [OSMRelation].
   */
  Iterable<OSMWay> getWaysFromRelation(OSMRelation relation) {
    return _getElementFromRelation(ways, relation);
  }


  /**
   * A function to get all [OSMRelation]s from the current [OSMElementBundle] that are contained in the given [OSMRelation].
   */
  Iterable<OSMRelation> getRelationsFromRelation(OSMRelation relation) {
    return _getElementFromRelation<OSMRelation>(relations, relation);
  }



  Iterable<T> _getElementFromRelation<T extends OSMElement>(elementList, relation) sync* {
    for (var member in relation.members) {
      // skip elements that do not have a valid id yet
      if (member.ref == 0) continue;

      T? element = elementList.findFirst((element) => element.id == member.ref);
      if (element != null) {
        yield element;
      }
    }
  }
}