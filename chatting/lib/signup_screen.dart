import 'dart:io';

import 'package:chatting/home_screen.dart';
import 'package:chatting/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadImage(File image) async {
    final ref = _storage.ref().child('user_images').child('${_auth.currentUser!.uid}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passController.text,
        );

        final imageUrl = await _uploadImage(_image!);
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'imageUrl': imageUrl,
        });

        Fluttertoast.showToast(msg: "Sign Up Success");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        Fluttertoast.showToast(msg: "Sign Up Failed: $e");
        print(e);
      }
    } else {
      Fluttertoast.showToast(msg: "Please fill in all fields and select an image.");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if the user is new
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        // Save user details to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': googleUser.displayName,
          'email': googleUser.email,
          'imageUrl': googleUser.photoUrl,
        });
      }

      Fluttertoast.showToast(msg: "Sign In with Google Success");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Sign In with Google Failed: $e");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Account"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(),
                  ),
                  child: _image == null
                      ? Center(
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 50,
                            color: Color(0xFF3876FD),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your Name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your Email";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
              ),
              SizedBox(height: 50),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 55,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3876FD),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("OR"),
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: Icon(Icons.g_translate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  label: Text(
                    "Sign In with Google",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    color: Color(0xFF3876FD),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
