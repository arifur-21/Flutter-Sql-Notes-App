
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sql_db/db_helper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'notes_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _titleController = TextEditingController();
  final  _ageController = TextEditingController() ;
  final _desController = TextEditingController();
  final _emailController = TextEditingController();

  DbHelper? dbHelper;
  late Future<List<NotesModel>> notesList;

  @override
  void initState() {
   dbHelper = DbHelper();
   loadData();
    super.initState();
  }

  loadData()async{
    notesList = dbHelper!.getNotesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: notesList,
              builder: (context, AsyncSnapshot<List<NotesModel>> snapshot){

           return ListView.builder(
               itemCount: snapshot.data!.length,
                 itemBuilder: (context, index){

                 if(snapshot.hasData){
                   return InkWell(
                     onTap: (){
                       dbHelper!.update(
                           NotesModel(
                               id:  snapshot.data![index].id!,
                               title: "Update Title",
                               age: 33,
                               des: "Update Description",
                               email: "update@gamil.com"
                       ));
                     },
                     child: Dismissible(
                       direction: DismissDirection.endToStart,
                       background: Container(
                         child: Icon(Icons.delete),
                         color: Colors.red,
                       ),
                       onDismissed: (DismissDirection direction){
                         setState(() {
                           dbHelper!.delete(snapshot.data![index].id!);
                           notesList = dbHelper!.getNotesList();
                           snapshot.data!.remove(snapshot.data![index]);
                         });
                       },

                       key: ValueKey<int>(snapshot.data![index].id!),
                       child: Card(
                         child: ListTile(
                           title: Text(snapshot.data![index].title.toString()),
                           subtitle: Text(snapshot.data![index].email.toString()),
                           trailing: Text(snapshot.data![index].age.toString()),
                         ),
                       ),
                     ),
                   );
                 }else{
                  return Container();
                 }


                 });

              },
              ),
            )
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context, builder: (BuildContext context){
                return SingleChildScrollView(
                  child: AlertDialog(
                    title: Text("Add Data"),
                    content: Text("Enter your data"),
                    actions: [
                      EditTextField(_emailController, "Enter your email", "email"),
                      EditTextField(_ageController, "Enter your age", "age"),
                      EditTextField(_titleController, "Enter your title", "title"),
                      EditTextField(_desController, "Enter your description", "description"),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ButtomWidget(onPress: (){Navigator.pop(context);}, title: "cancel"),
                          ButtomWidget(onPress: (){
                            dbHelper!.insert(
                              NotesModel(
                                  title: _titleController.text.toString(),
                                  age: 55,
                                  des: _desController.text.toString(),
                                  email: _emailController.text.toString())
                            ).then((value){

                              print("data added ${value.toString()}");

                              setState(() {
                                notesList = dbHelper!.getNotesList();
                              });
                            }).onError((error, stackTrace){
                              print("data error : ${error.toString()}");
                            });
                          },
                              title: "add"),

                        ],
                      )
                    ],
                  ),
                );
          });
        },
        child: Icon(Icons.add),

      ),
    );
  }
}

class EditTextField extends StatelessWidget {
  var title;
  var textHint;
  var textLable;


  EditTextField(this.title, this.textHint, this.textLable);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: title,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.deepOrange,
                        width: 2
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.black
                    )
                ),
                hintText: textHint,
                labelText: textLable,
            ),
          ),
        ),
      ],
    );
  }
}

class ButtomWidget extends StatelessWidget {

  final VoidCallback onPress;
  final String title;

  const ButtomWidget({Key? key, required this.onPress, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            onPressed: onPress,
            child: Text(title, style: TextStyle(fontSize: 20,),)),
      ],
    );
  }
}


