import '../data/database.dart';
import '../rust/models/tags.dart';

class TagRepository {
  final Database _db;

  TagRepository(this._db);

  Future<List<Tag>> listTags(String query) async {
    return (await _db.listTags(query));
  }

  Future<Tag> getTag(String id) async {
    return await _db.getTag(id);
  }

  Future<Tag> addTag(Tag tag) async {
    return await _db.postTag(tag);
  }

  Future<Tag> updateTag(String id, Tag tag) async {
    return await _db.putTag(id, tag);
  }

  Future<Tag> deleteTag(String id) async {
    return await _db.deleteTag(id);
  }
}
