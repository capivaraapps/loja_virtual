import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  Map<String, dynamic> userData = Map();
  bool isLoading = false;

  static UserModel of(BuildContext context) => ScopedModel.of<UserModel>(context);

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _loadCurrentUser();
  }

  void signUp(Map<String, dynamic> data, String pass, VoidCallback onSuccess, VoidCallback onFail){
    isLoading = true;
    notifyListeners();

    _auth.createUserWithEmailAndPassword(email: data["email"], password: pass).then((result) async {
      firebaseUser = result.user;

      await _saveUserData(data);

      onSuccess();
      isLoading = false;
      notifyListeners();
    }).catchError((error) {
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  void signIn(String email, String pass, VoidCallback onSuccess, VoidCallback onFail) async {
    isLoading = true;
    notifyListeners();
    
    _auth.signInWithEmailAndPassword(email: email, password: pass).then((result) async {
      firebaseUser = result.user;

      await _loadCurrentUser();

      onSuccess();
      isLoading = false;
      notifyListeners();

    }).catchError((signInError) {
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  void recoverPassword(String email){
    _auth.sendPasswordResetEmail(email: email);
  }

  Future<Null> _saveUserData(Map<String, dynamic> data) {
    this.userData= data;
    Firestore.instance.collection("users").document(firebaseUser.uid).setData(data);
  }

  bool isLoggedIn(){
    return firebaseUser != null;
  }

  void signOut() async {
    await _auth.signOut();
    userData = Map();
    firebaseUser = null;
    notifyListeners();
  }

  Future<Null> _loadCurrentUser() async {
    if (firebaseUser == null) {
      firebaseUser = await _auth.currentUser();
    }
    if (firebaseUser != null) {
      if(userData["name"] == null) {
        DocumentSnapshot docUser = await Firestore
          .instance
          .collection("users")
          .document(firebaseUser.uid)
          .get();
        userData = docUser.data;
      }
    }
    notifyListeners();
  }
}