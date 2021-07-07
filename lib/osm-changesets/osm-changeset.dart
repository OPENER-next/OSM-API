import '/osm-user/osm-user.dart';
import 'osm-comment.dart';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';

// temporary workaround untill xml library is updated
extension TempGetChildElements on XmlNode {
  Iterable<XmlElement> get childElements {
    return children.whereType<XmlElement>();
  }
}

/**
 * A container class for an OSM changeset.
 */
class OSMChangeset {

  /**
   * The unique identifier of this changeset.
   *
   * This id is generated by the OSM Server.
   * You shouldn't set the [id] on your own.
   */
  final int id;

  /**
   * A [Map] containing all OSM Tags of this changeset.
   *
   * Each OSM Tag contains and represents one key value pair.
   */
  final Map<String, String> tags;

  /**
   * An optional [List] of [OSMComment]s containing the discussion of this changeset.
   *
   * The [discussion] property is null if the discussion wasn't requested from the server, otherwise it's a [List] of zero ore more items.
   */
  final List<OSMComment>? discussion;


  OSMChangeset({
    required this.id,
    required this.tags,
    this.discussion
  });


  /**
   * A factory method for constructing an [OSMChangeset] from an XML [String].
   */
  static OSMChangeset fromXMLString(String xmlString) {
    var xmlDoc = XmlDocument.parse(xmlString);
    var changesetElement = xmlDoc.findAllElements('changeset').first;
    return fromXMLElement(changesetElement);
  }


  /**
   * A factory method for constructing an [OSMChangeset] object from an [XmlElement].
   */
  static OSMChangeset fromXMLElement(XmlElement changesetElement) {
     // get and parse id to integer
    var idValue = changesetElement.getAttribute('id');
    var id = idValue != null ? int.tryParse(idValue) : null;

    if (id == null) throw('TODO ERROR cannot parse changeset id from element');

    var tags = <String, String>{};
    changesetElement.findElements('tag').forEach((tag) {
      var k = tag.getAttribute('k');
      var v = tag.getAttribute('v');

      if (k != null && v != null) {
        tags[k] = v;
      }
    });

    List<OSMComment>? comments;
    var discussionElement = changesetElement.getElement('discussion');

    if (discussionElement != null) {
      comments = [];

      discussionElement.childElements.forEach((comment) {
        var date = comment.getAttribute('date');
        var uid = comment.getAttribute('uid');
        var userName = comment.getAttribute('user');
        var textElement = comment.getElement('text');

        if (date != null && uid != null && userName != null && textElement != null) {
          comments!.add(OSMComment(
            DateTime.parse(date),
            OSMUser(int.parse(uid), userName),
            textElement.text
          ));
        }
      });
    }

    return OSMChangeset(id: id, tags: tags, discussion: comments);
  }


  @override
  String toString() {
    return '$runtimeType - id: $id; tags: $tags; discussion: $discussion';
  }


  @override
  int get hashCode =>
    id.hashCode ^
    tags.hashCode ^
    discussion.hashCode;


  @override
  bool operator == (o) =>
    identical(this, o) ||
    o is OSMChangeset &&
    runtimeType == o.runtimeType &&
    id == o.id &&
    MapEquality().equals(tags, o.tags) &&
    ListEquality().equals(discussion, o.discussion);
}