import 'dart:html';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

//today's date
DateTime today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
    DateTime.now().minute,
    DateTime.now().second);

_goToFBPage() async {
  const fb_url = 'https://www.facebook.com/Hunter-Anonymous-104189795564227';
  if (await canLaunch(fb_url)) {
    await launch(fb_url);
  } else {
    throw 'Could not launch $fb_url';
  }
}

_goToTWPage() async {
  const tw_url = 'https://twitter.com/HunterAnonymou4';
  if (await canLaunch(tw_url)) {
    await launch(tw_url);
  } else {
    throw 'Could not launch $tw_url';
  }
}

_goToINSPage() async {
  const ins_url = 'https://www.instagram.com/hunter_anonymous395/';
  if (await canLaunch(ins_url)) {
    await launch(ins_url);
  } else {
    throw 'Could not launch $ins_url';
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String post_text; //this is the user's post
  CollectionReference posts =
      FirebaseFirestore.instance.collection('posts'); //firebase instance

  final text = TextEditingController();

  void clearTextField() => text.clear();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //this creates an appbar at the top my page
          title: Text('Hunter Anonymous',
              style: TextStyle(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 55,
                  wordSpacing: 15)),
          actions: [
            Wrap(
              children: [
                IconButton(
                    onPressed: _goToFBPage,
                    icon: Icon(FontAwesome5.facebook,
                        color: Colors.deepPurple.shade400, size: 30),
                    splashRadius: 25),
                SizedBox(width: 25),
                IconButton(
                    onPressed: _goToTWPage,
                    icon: Icon(FontAwesome5.twitter,
                        color: Colors.deepPurple.shade400, size: 30),
                    splashRadius: 25),
                SizedBox(width: 25),
                IconButton(
                    onPressed: _goToINSPage,
                    icon: Icon(FontAwesome5.instagram,
                        color: Colors.deepPurple.shade400, size: 30),
                    splashRadius: 25),
                SizedBox(width: 15)
              ],
            ),
          ],
          // A gradient appbar background.
          flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                Colors.deepPurple.shade300,
                Colors.yellow.shade100,
              ]))),
          centerTitle: true,
          elevation: 0, //shadow below the appBar
          toolbarHeight: 75,
        ),
        body: ListView(
          children: [
            Card(
              child: Container(
                  width: 0.98 * MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      TextField(
                          controller: text,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onChanged: (value) {
                            post_text = value;
                          },
                          decoration: InputDecoration(
                              hintText: 'Enter Post',
                              hintStyle: TextStyle(
                                  color: Color.fromRGBO(97, 53, 153, 85),
                                  fontSize: 26),
                              contentPadding: EdgeInsets.only(left: 10, top: 15),
                              suffixIcon: IconButton( // An icon button for user to remove text from a text field.
                                padding: EdgeInsets.only(top: 15, right: 15),
                                onPressed: clearTextField,
                                icon: Icon(Icons.clear, size: 25, color: Colors.deepPurple)
                              ),
                              fillColor: Colors.deepPurple.shade100,
                              filled: true),
                          style: TextStyle(fontSize: 26),
                          cursorHeight: 26),
                      SizedBox(height: 5),
                      ElevatedButton(
                          // this is our submit button
                          onPressed: () async {
                            await posts.add({
                              'Date': today,
                              'Votes': 0,
                              'Text': post_text,
                            }).then((value) => print('post successful'));
                            clearTextField(); // Text will be removed from text field after pressing submission button.
                          },
                          child: Text('Submit Post',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  wordSpacing: 6)),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.deepPurple),
                              fixedSize: MaterialStateProperty.all(
                                  const Size(180, 40)))),
                    ],
                  ),
                  padding: EdgeInsets.only(bottom: 5)),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: posts.orderBy('Date', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.size,
                    itemBuilder: (context, index) {
                      String formatted_date = DateFormat()
                          .format(snapshot.data?.docs[index]['Date'].toDate());
                      return Card(
                        color: Colors.deepPurple.shade100,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                                color: Colors.deepPurple.shade200, width: 1)),
                        margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(snapshot.data?.docs[index]['Text'],
                                    style: TextStyle(
                                        fontSize: 20, wordSpacing: 3)),
                                Text(formatted_date,
                                    style: TextStyle(
                                        fontSize: 11, wordSpacing: 5)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            //Upvote Downvote
                            children: [
                              Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.green.shade400,
                                      ),
                                      child: Icon(Icons.arrow_upward_rounded)),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${snapshot.data?.docs[index]['Votes']}',
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.deepOrange.shade400,
                                      ),
                                      child:
                                          Icon(Icons.arrow_downward_rounded)),
                                ],
                              ),
                            ],
                          ),
                        ]),
                      );
                    },
                  );
                }),
          ],
        ),
        backgroundColor: Colors.deepPurple.shade50);
  }
}
