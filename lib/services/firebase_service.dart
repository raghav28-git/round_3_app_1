import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/infrastructure_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'infrastructure_assets';

  Stream<List<InfrastructureAsset>> getAssets() {
    return _db.collection(collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => InfrastructureAsset.fromFirestore(doc)).toList());
  }

  Future<InfrastructureAsset?> getAsset(String id) async {
    var doc = await _db.collection(collection).doc(id).get();
    return doc.exists ? InfrastructureAsset.fromFirestore(doc) : null;
  }

  Future<void> addAsset(InfrastructureAsset asset) async {
    await _db.collection(collection).add(asset.toMap());
  }

  Future<void> updateAsset(String id, InfrastructureAsset asset) async {
    await _db.collection(collection).doc(id).update(asset.toMap());
  }

  Future<void> deleteAsset(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  Stream<List<InfrastructureAsset>> searchAssets(String query) {
    return _db.collection(collection).snapshots().map((snapshot) {
      var assets = snapshot.docs.map((doc) => InfrastructureAsset.fromFirestore(doc)).toList();
      return assets.where((asset) =>
          asset.name.toLowerCase().contains(query.toLowerCase()) ||
          asset.location.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  Stream<List<InfrastructureAsset>> filterAssets({String? type, String? status}) {
    Query query = _db.collection(collection);
    if (type != null && type.isNotEmpty) query = query.where('type', isEqualTo: type);
    if (status != null && status.isNotEmpty) query = query.where('status', isEqualTo: status);
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => InfrastructureAsset.fromFirestore(doc)).toList());
  }
}
