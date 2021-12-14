import 'package:collection/collection.dart';
import '/src/osm_elements/osm_element_type.dart';

/**
 * A base class for the three basic OSM elements [OSMNode], [OSMWay] and [OSMRelation].
 */
abstract class OSMElement {

  /**
   * A [Map] containing all OSM Tags of this element.
   *
   * Each OSM Tag contains and represents one key value pair.
   */
  final Map<String, String> tags;

  /**
   * The unique identifier of this element.
   *
   * This id is generated by the OSM Server.
   * You shouldn't set or alter the [id] on your own.
   * An [id] <= [0] is invalid. For this implementation a value of [0] will be assigned to all elements by default.
   * This indicates that the element hasn't been uploaded to the server yet.
   */
  int id;

  /**
   * The version number of this element.
   *
   * This number is generated by the OSM Server and indicates the number of changes/iterations this element has been undergone.
   * You shouldn't set or alter the [version] number on your own.
   * A [version] <= [0] is invalid. For this implementation a value of [0] will be assigned to all elements by default.
   * This indicates that the element hasn't been uploaded to the server yet.
   */
  int version;


  OSMElement({
    Map<String, String>? tags,
    int? id,
    int? version
  }) :
  this.tags = tags ?? <String, String>{},
  this.id = id ?? 0,
  this.version = version ?? 0;


  /**
   * A getter for the type of this element.
   *
   * This returns one of the three basic OSM element types defined in [OSMElementType].
   */
  OSMElementType get type;


  /**
   * A function to construct the XML body [String] of this element.
   *
   * This will serialize tags and child elements of this element to XML.
   */
  String bodyToXML() {
    var xmlString = '';
    tags.forEach((key, value) => xmlString +='<tag k="$key" v="$value"/>');
    return xmlString;
  }


  @override
  int get hashCode =>
    id.hashCode ^
    version.hashCode ^
    // do not use nodeIds.hashCode since the hasCodes may differ even if the values are equal.
    // see https://api.flutter.dev/flutter/dart-core/Object/hashCode.html
    // "The default hash code implemented by Object represents only the identity of the object,"
    Object.hashAll(tags.keys) ^
    Object.hashAll(tags.values);


  /**
   * Elements are considered equal if their properties match.
   */
  @override
  bool operator == (o) =>
    o is OSMElement &&
    id == o.id &&
    version == o.version &&
    MapEquality().equals(tags, o.tags);
}