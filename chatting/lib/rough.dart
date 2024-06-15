// import 'package:chatting/chat_provider.dart';
// import 'package:chatting/signup_screen.dart';
// import 'package:chatting/widgets/chat_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});
  
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final _auth = FirebaseAuth.instance;
//   User? loggedInUser;
//   String searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     getCurrentUser();
//   }

//   void getCurrentUser() async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         setState(() {
//           loggedInUser = user;
//         });
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   void handleSearch(String query) {
//     setState(() {
//       searchQuery = query;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatProvider = Provider.of<ChatProvider>(context);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("Search Users"),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(10),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search Users...",
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: handleSearch,
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: searchQuery.isEmpty
//                   ? Stream.empty()
//                   : chatProvider.searchUsers(searchQuery),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 final users = snapshot.data!.docs;
//                 List<UserTile> userWidgets = [];

//                 for (var user in users) {
//                   final userData = user.data() as Map<String, dynamic>;
//                   if (userData['uid'] != loggedInUser!.uid) {
//                     final userWidget = UserTile(
//                       userId: userData['uid'],
//                       name: userData['name'],
//                       email: userData['email'],
//                       imageUrl: userData['imageUrl'],
//                     );
//                     userWidgets.add(userWidget);
//                   }
//                 }

//                 if (userWidgets.isEmpty) {
//                   return Center(child: Text('No users found.'));
//                 }

//                 return ListView(
//                   children: userWidgets,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class UserTile extends StatelessWidget {
//   final String userId;
//   final String name;
//   final String email;
//   final String imageUrl;

//   const UserTile({
//     super.key,
//     required this.userId,
//     required this.name,
//     required this.email,
//     required this.imageUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final chatProvider = Provider.of<ChatProvider>(context, listen: false);
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundImage: NetworkImage(imageUrl),
//       ),
//       title: Text(name),  // Corrected variable name
//       subtitle: Text(email),  // Corrected variable name
//       onTap: () async {
//         final chatId = await chatProvider.getChatroom(userId) ?? await chatProvider.createChatRoom(userId);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ChatScreen(
//               chatId: chatId,
//               receiverId: userId,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }





// SignUpScreen Corrected
// import 'dart:io';

// import 'package:chatting/auth_provider.dart';
// import 'package:chatting/login_screen.dart';
// import 'package:chatting/home_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';


// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => SignUpScreenState();
// }

// class SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passController = TextEditingController();
//     final TextEditingController _nameController = TextEditingController();
//    File? _image;
//    final _auth = FirebaseAuth.instance;
//    final _firestore =FirebaseFirestore.instance;
//    final _storage =FirebaseStorage.instance;
   
//    Future<void> _pickImage() async{
//     final pickedFile =
//     await ImagePicker().pickImage(source: ImageSource.gallery);
//     setState((){
//           if(pickedFile!=null){
//      _image =File(pickedFile.path);
//     }
//     });
//    }


  
//    Future<String> _uploadImage(File image) async{
//     final ref =_storage
//     .ref()
//     .child('user_images')
//     .child('${_auth.currentUser!.uid}.jpg');



//    await ref.putFile(image);
//     return  await ref.getDownloadURL();
//        }

   
//    Future<void> _signUp() async{
//    try{
//       UserCredential userCredential =await _auth
//       .createUserWithEmailAndPassword(
//         email: _emailController.text, password: _passController.text);
   
//    final imageUrl =await _uploadImage(_image!);
//    await _firestore.collection('users').doc(userCredential.user!.uid).set({
//     'uid':userCredential.user!.uid,
//   'name':_nameController.text,
//   'email': _emailController.text,
//   'imageUrl':imageUrl,

//    });

//   Fluttertoast.showToast(msg: "Sign Up Success");

//    Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (context) => HomeScreen(),

//     )
//    );


//    }
//    catch(e){
//     print(e);
//    }

//    }
 
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//    // final authProvider = Provider.of<Authprovider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Create Account"),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               InkWell(
//                 onTap: _pickImage,
//                 child: Container(
//                   height: 200,
//                   width: 200,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(),
//                   ),
//                   child: _image == null ? Center(
//                     child: Icon(Icons.camera_alt_rounded,
//                     size: 50,
//                     color:Color(0xFF3876FD),
//                     ),
//                   ): ClipRRect(
//                     borderRadius: BorderRadius.circular(100),
//                     child: Image.file(_image!,
//                     fit: BoxFit.cover,
//                     ),
//                   )
//                 ),
//               ),
//                 SizedBox(height: 30),

//               TextFormField(

//                 controller: _nameController,
//                 keyboardType: TextInputType.name,
//                 decoration: InputDecoration(
//                   labelText: "Name",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please enter your Name";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//                TextFormField(

//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: "Email",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please enter your Email";
//                   }
//                   return null;
//                 },
//               ),
           
//               SizedBox(height: 20),
//               TextFormField(
//                 controller: _passController,
//                  keyboardType: TextInputType.visiblePassword,
//                 decoration: InputDecoration(
//                   labelText: "Password",
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please enter your password";
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 50),

//               SizedBox(
//                 width:MediaQuery.of(context).size.width/1.5,
//                 height:55,
//                 child:ElevatedButton(
//                 onPressed: _signUp,

//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF3876FD),
//                   foregroundColor: Colors.white,
//                 ),


               
            
//               child: Text(
//                 "Create Account",
//                 style: TextStyle(
//                   fontSize: 18,
//                 ),

//               ),
//                 ),
//               ),

//               SizedBox(height: 20),
//               Text("OR"),
//               SizedBox(height: 20),
//               TextButton(onPressed: (){
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder:(context)=>LoginScreen(),
//                     ));
//               },
//               child:Text("Sign In",
//               style: TextStyle(
//                 color: Color(0xFF3876FD),
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//               ),

//               ),
              
              
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
