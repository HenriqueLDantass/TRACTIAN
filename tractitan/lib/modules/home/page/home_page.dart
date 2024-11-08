import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tractitan/modules/home/models/client_model.dart';
import 'package:tractitan/modules/home/widgets/client_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Client>> clients;

  @override
  void initState() {
    super.initState();
    clients = fetchClients();
  }

  Future<List<Client>> fetchClients() async {
    final response =
        await http.get(Uri.parse('https://fake-api.tractian.com/companies'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF17192D),
        title: Image.asset("assets/images/LOGO-TRACTIAN.png"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Client>>(
        future: clients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clients found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final client = snapshot.data![index];
                return ClientListItem(client: client);
              },
            );
          }
        },
      ),
    );
  }
}
