import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toys/models/user.dart';
import 'package:toys/services/datastore.dart';

abstract class BaseAuth {
  Future<User> signIn(String email, String password);
  Future<void> signUp(String email, String password, String username);
  Future<FirebaseUser> getCurrentUser();
  Future<void> signOut();
  Future<User> googleSignIn();
}

class Auth implements BaseAuth {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser = await _firebaseAuth.currentUser();
    return currentUser;
  }

  @override
  Future<User> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    DocumentSnapshot doc =
        await Firestore.instance.collection('users').document(user.uid).get();
    // User userDetails = User.fromFirestore(doc);
    User userDetails = User(
        username: doc.data['username'],
        userEmail: doc.data['userEmail'],
        uid: doc.data['uid']);
    return userDetails;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> googleSignOut() async {
    return await GoogleSignIn()
        .signOut()
        .then((onValue) => print("Signout Successfull"))
        .catchError((onError) => print(onError.message));
  }

  @override
  Future<void> signUp(String email, String password, String username) async {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((currentUser) {
      Datastore().addUserData(
        User(
            uid: currentUser.user.uid,
            username: username,
            userEmail: currentUser.user.email,
            loginType: "signup"),
      );
    }).catchError((onError) => print(onError));
  }

  Future<User> googleSignIn() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    AuthResult userDetails =
        await _firebaseAuth.signInWithCredential(credential);

    DocumentSnapshot doc = await Firestore.instance
        .collection("users")
        .document(userDetails.user.uid)
        .get();

    if (!doc.exists) {
      Datastore().addUserData(
        User(
            uid: userDetails.user.uid,
            username: userDetails.user.displayName,
            userEmail: userDetails.user.email,
            photoUrl: userDetails.user.photoUrl,
            role: 'user',
            loginType: 'google'),
      );
    }
    DocumentSnapshot snapshot = await Firestore.instance
        .collection("users")
        .document(userDetails.user.uid)
        .get();
    User details = User.fromFirestore(snapshot);
    return details;
  }
}
