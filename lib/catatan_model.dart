import 'package:latlong2/latlong.dart';
import 'database_helper.dart';

class CatatanModel {
  int? id;
  LatLng position;
  String note;
  String address;
  String type;

  CatatanModel({
    this.id,
    required this.position,
    required this.note,
    required this.address,
    required this.type,
  });
}
