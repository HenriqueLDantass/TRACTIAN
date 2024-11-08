import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tractitan/modules/clients/models/assets_model.dart';
import 'dart:convert';
import 'package:tractitan/modules/clients/models/locations_model.dart';

class ClientDetailsPage extends StatefulWidget {
  final String clientId;

  const ClientDetailsPage({Key? key, required this.clientId}) : super(key: key);

  @override
  _ClientDetailsPageState createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  late Future<List<Location>> locations;
  late Future<List<Asset>> assets;

  String locationFilter = "";
  String assetFilter = "";

  @override
  void initState() {
    super.initState();
    locations = fetchLocations(widget.clientId, locationFilter);
    assets = fetchAssets(widget.clientId, assetFilter);
  }

  Future<List<Location>> fetchLocations(String companyId, String filter) async {
    final response = await http.get(Uri.parse(
        'https://fake-api.tractian.com/companies/$companyId/locations'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data
          .map((location) => Location(
                id: location['id'],
                name: location['name'],
                parentId: location['parentId'],
              ))
          .where((location) => location.name
              .toLowerCase()
              .contains(filter.toLowerCase())) // Filtro
          .toList();
    } else {
      throw Exception('Failed to load locations');
    }
  }

  Future<List<Asset>> fetchAssets(String companyId, String filter) async {
    final response = await http.get(
        Uri.parse('https://fake-api.tractian.com/companies/$companyId/assets'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data
          .map((asset) => Asset(
                id: asset['id'],
                name: asset['name'],
                locationId: asset['locationId'],
                parentId: asset['parentId'],
                sensorType: asset['sensorType'],
                status: asset['status'],
              ))
          .where((asset) =>
              asset.name.toLowerCase().contains(filter.toLowerCase())) // Filtro
          .toList();
    } else {
      throw Exception('Failed to load assets');
    }
  }

  void onSearchChanged(String value) {
    setState(() {
      locationFilter = value;
      assetFilter = value;
      locations = fetchLocations(widget.clientId, locationFilter);
      assets = fetchAssets(widget.clientId, assetFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF17192D),
        title: Image.asset("assets/images/LOGO-TRACTIAN.png", height: 40),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de pesquisa
            TextFormField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                labelText: "Buscar Ativo ou local",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: Text("SENSOR DE ENERGIA"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: Text("CRITICO"),
                ),
              ],
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: Future.wait([locations, assets]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found'));
                } else {
                  final List<Location> locationsData = snapshot.data![0];
                  final List<Asset> assetsData = snapshot.data![1];
                  final tree = buildTree(locationsData, assetsData);

                  return Expanded(
                    child: ListView(
                      children: tree
                          .map((location) => buildLocationTile(location))
                          .toList(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

List<Location> buildTree(List<Location> locations, List<Asset> assets) {
  Map<String, Location> locationMap = {
    for (var location in locations) location.id: location
  };
  Map<String, Asset> assetMap = {for (var asset in assets) asset.id: asset};

  for (var asset in assets) {
    if (asset.parentId != null && assetMap.containsKey(asset.parentId)) {
      assetMap[asset.parentId]!.subAssets.add(asset);
    } else if (asset.locationId != null &&
        locationMap.containsKey(asset.locationId)) {
      locationMap[asset.locationId]!.assets.add(asset);
    }
  }

  for (var location in locations) {
    if (location.parentId != null &&
        locationMap.containsKey(location.parentId)) {
      locationMap[location.parentId]!.subLocations.add(location);
    }
  }

  return locationMap.values
      .where((location) => location.parentId == null)
      .toList();
}

Widget buildLocationTile(Location location) {
  return ExpansionTile(
    tilePadding: const EdgeInsets.only(left: 0),
    controlAffinity: ListTileControlAffinity.leading,
    title: Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: Colors.blue,
        ),
        Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    ),
    children: [
      ...location.assets.map((asset) => buildAssetTile(asset)),
      ...location.subLocations.map((subLoc) => buildLocationTile(subLoc)),
    ],
  );
}

Widget buildAssetTile(Asset asset) {
  return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ExpansionTile(
        controlAffinity: ListTileControlAffinity.leading,
        tilePadding: const EdgeInsets.only(left: 20),
        title: Row(
          children: [
            Image.asset(
              "assets/icons/Vector.png",
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8),
            Text(asset.name),
          ],
        ),
        children: [
          ...asset.subAssets.map((subAsset) => buildSubAssetTile(subAsset)),
        ],
      ));
}

Widget buildSubAssetTile(Asset subAsset) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Padding(
      padding: const EdgeInsets.only(left: 50.0),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            "assets/icons/Codepen.png",
            width: 30,
            height: 30,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(subAsset.name)),
            subAsset.status != "alert"
                ? Image.asset("assets/icons/bolt.png")
                : Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.red),
                  )
          ],
        ),
      ),
    ),
  );
}
