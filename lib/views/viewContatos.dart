import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterappwhatsappcb/RouteGenerator.dart';
import 'package:flutterappwhatsappcb/model/usuario.dart';
import 'package:flutterappwhatsappcb/model/usuarioFireBase.dart';

class abaContatos extends StatefulWidget {
  @override
  _abaContatosState createState() => _abaContatosState();
}

class _abaContatosState extends State<abaContatos> {

  Usuario usuario = UserFirebase.fireLogged;

  Future<List<Usuario>> _recuperarContatos() async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot =
    await db.collection("usuarios").getDocuments();

    List<Usuario> listaUsuarios = List();
    for (DocumentSnapshot item in querySnapshot.documents) {

      var dados = item.data;
      if( dados["email"] == this.usuario.email ) continue;

      Usuario usuario = Usuario();
      usuario.uidUser = item.documentID;
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.urlImagemPerfil = dados["urlImagemPerfil"];

      listaUsuarios.add(usuario);
    }

    return listaUsuarios;
  }



  @override
  void initState() {
    super.initState();
    UserFirebase.recuperaDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, indice) {
                  List<Usuario> listaItens = snapshot.data;
                  Usuario usuario = listaItens[indice];
                  print("O destinatario contatos? "+usuario.uidUser);

                  return ListTile(
                    onTap: (){
                      Navigator.pushNamed(context,
                          RouteGenerator.ROTA_MSGS,
                      arguments: usuario);
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: usuario.urlImagemPerfil != null
                            ? NetworkImage(usuario.urlImagemPerfil)
                            : null),
                    title: Text(
                      usuario.nome,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                });
            break;
        }
      },
    );
  }
}
