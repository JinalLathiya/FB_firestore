import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EMPData extends StatefulWidget {
  const EMPData({Key? key}) : super(key: key);

  @override
  State<EMPData> createState() => _EMPDataState();
}

class _EMPDataState extends State<EMPData> {
  final CollectionReference Emp =
      FirebaseFirestore.instance.collection('Employees');

  final GlobalKey<FormState> _addrecordskey = GlobalKey<FormState>();
  final GlobalKey<FormState> _updaterecordskey = GlobalKey<FormState>();

  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _agecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Employee Data"),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Addrecords();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: Emp.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['Name']),
                    subtitle: Text(documentSnapshot['Age'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _update(documentSnapshot)),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deletedata(documentSnapshot.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Addrecords([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _namecontroller,
                  decoration: const InputDecoration(
                    hintText: "Enter your name",
                      border: OutlineInputBorder(),
                      labelText: 'Name',),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _agecontroller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your age",
                    labelText: 'Age',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 240),
                  child: ElevatedButton(
                    child: const Text('Add'),
                    onPressed: () async {
                      final String name = _namecontroller.text;
                      final double? age = double.tryParse(_agecontroller.text);
                      if (age != null) {
                        await Emp.add({"Name": name, "Age": age});

                        _namecontroller.text = '';
                        _agecontroller.text = '';
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                )
              ],
            ),
          );
        });
  }

  deletedata(String productId) async {
    await Emp.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have successfully delete a record'),
      ),
    );
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _namecontroller.text = documentSnapshot['Name'];
      _agecontroller.text = documentSnapshot['Age'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: const  EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _namecontroller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                      labelText: 'Name',
                    hintText: "Enter your name"
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _agecontroller,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder() ,
                    labelText: 'Age',
                    hintText: "Enter your age"
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 240),
                  child: ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () async {
                      final String name = _namecontroller.text;
                      final double? age = double.tryParse(_agecontroller.text);
                      if (age != null) {
                        await Emp.doc(documentSnapshot!.id)
                            .update({"Name": name, "Age": age});
                        _namecontroller.text = '';
                        _agecontroller.text = '';
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                )
              ],
            ),
          );
        });
  }
}
