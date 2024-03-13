import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flame/components.dart';
import 'package:robo_combat/main.dart';
import 'package:robo_combat/player.dart';

class Server {
  final CollectionReference player = FirebaseFirestore.instance.collection('players');

  fetchData(int i, String field) async {
    try {
      DocumentSnapshot docSnapshot = await player.doc(i.toString()).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
        return data?[field];
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }
  fetchAllData() async {

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('players').get();

    List<Map<String, dynamic>> documents = [];

    querySnapshot.docs.forEach((doc) {
      documents.add(doc.data() as Map<String, dynamic>);
    });

    return documents;
  }


  Future<void> updatePlayerData(String playerId,String field,value) async {

    try {
      await player.doc(playerId).update({
        field : value
      });

    } catch (e) {
      print("Error updating data: $e");
    }
  }


}

List<Vector2> pos = [];

class Database {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

// Writing data
  add() {
    _database.child('users').push().set({
      'username': 'john_doe',
      'email': 'john@example.com',
    });
  }


  Future<void> read() async {
    final snapshot = await _database.child('users').orderByKey().once();
    final data = snapshot.snapshot.child('position');
    print(data.value);
    // Do something with the data...
  }
  void listenToData(List<Player> player) {


    for(int i = 1;i<=4;i++){
      String s = i.toString();

      // _database.child('$s/joined').orderByKey().onValue.listen((event) {
      //   final data = event.snapshot.value;
      //
      //   print('joined : $data');
      //   // Do something with the data...
      // });
      // _database.child('$s/ready').orderByKey().onValue.listen((event) {
      //   final data = event.snapshot.value;
      //   print('ready : $data');
      //   // Do something with the data...
      // });
      _database.child('$s/fire').orderByKey().onValue.listen((event) {
        final data = event.snapshot.value;
        player[i-1].fire= data is bool? data : false;
        print('fire : $data');
        // Do something with the data...
      });
      _database.child('$s/position').orderByKey().onValue.listen((event) {
        final data = event.snapshot.value;
        double x = 0;
        double y = 0;
        if(data is List){
          x = data[0]*1.0;
          y= data[1]*1.0;

          print(x);
          print(y);
          pos[i-1] = Vector2(x, y);
          print(pos[i-1]);
        }

        // Do something with the data...
      });

    }

  }

  Future<void> updateData(int player,String field , value) async {
    await _database.child(player.toString()).update({
      field : value
    });
  }
}





