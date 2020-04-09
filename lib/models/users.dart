// class User{
//   int _id;
//   String _username;
//   String _email;
//   String _photoUrl;
//   String _password;
//   String _date;
//   String _bio;

//   User(this._username, this._email, this._password, this._date, [this._bio]);

//   User.withId(this._id, this._username, this._email, this._password, this._date, [this._bio]);

//   int get id => _id;
//   String get username => _username;
//   String get email => _email;
//   String get photoUrl => _photoUrl;
//   String get password => _password;
//   String get date => _date; 
//   String get bio => _bio;

//   set bio(String newBio){
//     if(newBio.length <= 255){
//       this._bio = newBio;
//     }
//   }

//   set username(String newUsername){
//     this._username = newUsername;
//   }

//   set email(String newEmail){
//     this._email = newEmail;
//   }

//   set password(String newpassword){
//     this._password = newpassword;
//   }

//   set date(String newdate){
//     this._date = newdate;
//   }

//   Map<String, dynamic> toMap(){
//     var map = Map<String, dynamic>();

//     if(id != null){
//       map['id'] = _id;
//     }
//     map['username'] = _username;
//     map['email'] = _email;
//     map['photoUrl'] = _photoUrl;
//     map['password'] = _password;
//     map['date'] = _date;
//     map['bio'] = _bio;

//     return map;
//   }

//   User.fromMapObject(Map<String, dynamic> map){
//     this._id = map['id'];
//     this._username = map['username'];
//     this._email = map['email'];
//     this._photoUrl = map['photoUrl'];
//     this._password = map['password'];
//     this._date = map['date'];
//     this._bio = map['bio'];
//   }



// }

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio
  });

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      bio: doc['bio'],
      id: doc['id'],
      username: doc['username'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],  
    );
  }
}