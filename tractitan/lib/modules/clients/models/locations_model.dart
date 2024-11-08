import 'package:tractitan/modules/clients/models/assets_model.dart';

class Location {
  String id;
  String name;
  String? parentId;
  List<Asset> assets;
  List<Location> subLocations;

  Location({
    required this.id,
    required this.name,
    this.parentId,
    List<Location>? subLocations,
    List<Asset>? assets,
  })  : subLocations = subLocations ?? [],
        assets = assets ?? [];
}
