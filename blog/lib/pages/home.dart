import 'dart:html';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
    DateTime.now().minute,
    DateTime.now().second);

_goToFBPage() async {
  const url = 'https://www.facebook.com/Hunter-Anonymous-104189795564227';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //today's date
  late String post_text; //this is the user's post
  CollectionReference posts =
      FirebaseFirestore.instance.collection('posts'); //firebase instance
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //this creates an appbar at the top my page
          title: Text(
            'Hunter Anonymous',
            style: TextStyle(
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 55,
                wordSpacing: 15)),
          actions: [
            IconButton(onPressed: _goToFBPage, 
              icon: Icon(Icons.facebook, 
                color: Colors.deepPurple.shade400,
                size: 35),
              splashRadius: 25),
          ],
          // A gradient appbar background.
          flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                Colors.purple.shade300,
                Colors.yellow.shade100,
              ]))),
          centerTitle: true,
          elevation: 0, //shadow below the appBar
          toolbarHeight: 75,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Container(
                  width: 0.98 * MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (value) {
                          post_text = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Post',
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(97, 53, 153, 85),
                            fontSize: 26
                          ),
                          contentPadding: EdgeInsets.only(left: 10),
                          fillColor: Colors.deepPurple.shade100,
                          filled: true),
                        style: TextStyle(
                          fontSize: 26)),
                      SizedBox(height: 5),
                      ElevatedButton(
                          // this is our submit button
                          onPressed: () async {
                            await posts.add({
                              'Date': today,
                              'Downvotes': 0,
                              'Text': post_text,
                              'Upvotes': 0
                            }).then((value) => print('post successful'));
                          },
                          child: Text(
                            'Submit Post',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              wordSpacing: 6)),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                            fixedSize: MaterialStateProperty.all(const Size(180, 40))
                          )),
                    ],
                  ),
                  padding: EdgeInsets.only(bottom: 5)
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: posts.orderBy('Upvotes').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.size,
                      itemBuilder: (context, index) {
                        String formatted_date = DateFormat()
                            .format(snapshot.data?.docs[index]['Date'].toDate());
                        return Card(
                          child: Row(
                              // mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Text(snapshot.data?.docs[index]['Text'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        wordSpacing: 3
                                      )),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        formatted_date,
                                        style: TextStyle(
                                          fontSize: 18,
                                          wordSpacing: 5
                                        )),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {},
                                            child: Icon(Icons.thumb_up)),
                                        Text(
                                            '${snapshot.data?.docs[index]['Upvotes']}',
                                            style: TextStyle(
                                              fontSize: 18)),
                                        SizedBox(width: 15),
                                        ElevatedButton(
                                            onPressed: () {},
                                            child: Icon(Icons.thumb_down)),
                                        Text(
                                            '${snapshot.data?.docs[index]['Downvotes']}',
                                            style: TextStyle(
                                              fontSize: 18)),
                                      ],
                                    )
                                  ],
                                ),
                              ]),
                              color: Colors.deepPurple.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.deepPurple.shade200, width: 1)),
                              margin: EdgeInsets.fromLTRB(15, 5, 15, 5)
                        );
                      },
                    );
                  }),
            ],
        )),backgroundColor: Colors.deepPurple.shade50);
  }
}
