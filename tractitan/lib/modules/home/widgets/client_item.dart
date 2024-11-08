import 'package:flutter/material.dart';
import 'package:tractitan/modules/clients/pages/clients_page.dart';
import 'package:tractitan/modules/home/models/client_model.dart';

class ClientListItem extends StatelessWidget {
  final Client client;

  const ClientListItem({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 76,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2188FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientDetailsPage(
                    clientId: client.id,
                  ),
                ));
            print('Pressed: ${client.name}');
            print('Pressed: ${client.id}');
          },
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 10),
              child: Image.asset(
                "assets/icons/icon.png",
              ),
            ),
            Text(
              client.name,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ]),
        ),
      ),
    );
  }
}
