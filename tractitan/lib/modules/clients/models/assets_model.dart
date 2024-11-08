import 'package:tractitan/modules/clients/models/components_model.dart';

class Asset {
  String id;
  String name;
  String? locationId;
  String? parentId;
  String? sensorType;
  String? status;
  List<Component> components;
  List<Asset> subAssets;

  Asset({
    required this.id,
    required this.name,
    this.locationId,
    this.parentId,
    this.sensorType,
    this.status,
    List<Component>? components,
    List<Asset>? subAssets,
  })  : components = components ?? [],
        subAssets = subAssets ?? [];
}
