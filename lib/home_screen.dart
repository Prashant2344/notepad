import 'package:flutter/material.dart';
import 'package:flutter_hive/models/notes_model.dart';
import 'package:hive/hive.dart';
import 'package:flutter_hive/boxes/boxes.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      // body: Column(
      //   children: [
      //     FutureBuilder(
      //         future: Hive.openBox('Prashant'),
      //         builder: (context,snapshot){
      //           return Column(
      //             children: [
      //               ListTile(
      //                 title: Text(snapshot.data!.get('name').toString()),
      //                 subtitle: Text(snapshot.data!.get('age').toString()),
      //                 trailing: IconButton(
      //                   onPressed: (){
      //                     snapshot.data!.put('name', 'Prashant Test');
      //                     setState(() {
      //                     });
      //                   },
      //                   icon: Icon(Icons.edit),
      //                 ),
      //               ),
      //             ],
      //           );
      //         }
      //     ),
      //   ],
      // ),

      body: ValueListenableBuilder<Box<NotesModel>>(
        valueListenable: Boxes.getData().listenable(),
        builder: (context, box, _){
          var data = box.values.toList().cast<NotesModel>();
          return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context,index){
                return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                data[index].title.toString(),
                                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              InkWell(
                                  onTap: (){
                                    delete(data[index]);
                                  },
                                  child: Icon(Icons.delete,color: Colors.red)
                              ),
                              SizedBox(width: 15),
                              InkWell(
                                  onTap: (){
                                    _editDialog(data[index],data[index].title.toString(),data[index].description.toString());
                                  },
                                  child: Icon(Icons.edit)
                              ),
                            ],
                          ),
                          Text(
                            data[index].description.toString(),
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    )
                );
              }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          _showMyDialog();
          // var box = await Hive.openBox('Prashant');
          //
          //
          // box.put('name', 'Prashant Silpakar');
          // box.put('age', 26);
          // box.put('details',{
          //   'pro' : 'developer',
          //   'exp' : 'five'
          // });
          // print(box.get('name'));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void delete(NotesModel notesModel) async{
    await notesModel.delete();
  }



  Future<void> _showMyDialog() async{
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Add Notes'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter Title',
                      border: OutlineInputBorder()
                    ),
                  ),
                  SizedBox(height: 50.0),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                        hintText: 'Enter Description',
                        border: OutlineInputBorder()
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, child: Text('Cancel')),
              TextButton(onPressed: () {
                final data = NotesModel(title: titleController.text, description: descriptionController.text);
                final box = Boxes.getData();
                box.add(data);
                data.save();

                titleController.clear();
                descriptionController.clear();
                Navigator.pop(context);
              }, child: Text('Add')),
            ],
          );
        }
    );
  }

  Future<void> _editDialog(NotesModel notesModel,String title,String description) async{
    titleController.text = title;
    descriptionController.text = description;
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Edit Notes'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                        hintText: 'Enter Title',
                        border: OutlineInputBorder()
                    ),
                  ),
                  SizedBox(height: 50.0),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                        hintText: 'Enter Description',
                        border: OutlineInputBorder()
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
              }, child: Text('Cancel')),
              TextButton(onPressed: () async {
                notesModel.title = titleController.text.toString();
                notesModel.description = descriptionController.text.toString();

                await notesModel.save();

                titleController.clear();
                descriptionController.clear();
                Navigator.pop(context);
              }, child: Text('Update')),
            ],
          );
        }
    );
  }
}
