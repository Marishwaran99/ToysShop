import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toys/models/user.dart';
import 'package:toys/pages/view_image.dart';
import 'package:toys/services/auth.dart';
import 'package:toys/services/datastore.dart';
import 'package:toys/styles/custom.dart';
import 'package:toys/widgets/appbar.dart';
import 'package:toys/widgets/customLoading.dart';
import 'package:toys/widgets/widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart';

class EditPage extends StatefulWidget {
  User details;
  EditPage({this.details});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  String pincode;
  bool _loading = false;
  String _confirmPassword,
      _newPassword,
      _username,
      _currentPassword,
      errorMessage,
      successMessage;
  List<String> _locations = [
    'Rajasthan',
    'Punjab',
    'Tamil Nadu',
    'Kerala',
    'Maharashtra'
  ]; // Option 2

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _image;

  User currentUser;

  getCurrentUserInfo() async {
    setState(() {
      _loading = true;
    });
    FirebaseUser user = await Auth().getCurrentUser();

    DocumentSnapshot doc =
        await Firestore.instance.collection('users').document(user.uid).get();

    User details = User.fromFirestore(doc);
    print(details.address);
    setState(() {
      currentUser = details;
    });
    // print(currentUser.loginType);
    setState(() {
      _loading = false;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Update Profile Photo"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: () => handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child: Text("Image in gallery"),
                onPressed: () => handleChooseFromGallery(context),
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  handleTakePhoto(BuildContext context) async {
    Navigator.pop(context);
    var file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      _image = file;
      print(_image);
    });
    if (_image != null) {
      cropImageAndCompress(context);
    }
  }

  handleChooseFromGallery(BuildContext context) async {
    Navigator.pop(context);
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = file;
      print(_image);
    });
    if (_image != null) {
      // cropImageAndCompress(context);
      handleUploadPicture(context);
    }
  }

  cropImageAndCompress(BuildContext context) async {
    File croppedImage = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    print("Crop Size:${_image.lengthSync()}");

    // File result = await FlutterImageCompress.compressAndGetFile(
    //     croppedImage.path, _image.path,
    //     quality: 88);
    String image;
    var result = await FlutterImageCompress.compressAndGetFile(
      croppedImage.path,
      image,
      quality: 88,
      rotate: 180,
    );

    print(croppedImage.lengthSync());
    print(result.lengthSync());

    print(result.path);
    // handleUploadPicture(context);
  }

  handleUploadPicture(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    _deleteImageFromFirestorage();
    String photoUrl = await uploadImage();
    Firestore.instance
        .collection('users')
        .document(currentUser.uid)
        .updateData({"photoUrl": photoUrl}).then((onValue) {
      buildSuccessDialog("Profile Picture Update Successfull!", context);
    }).catchError((onError) {
      buildErrorDialog(onError.message, context);
    });
    getCurrentUserInfo();
    setState(() {
      _loading = false;
    });
  }

  Future<String> uploadImage() async {
    String fileName = basename(_image.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  _deleteImageFromFirestorage() async {
    var fileUrl = Uri.decodeFull(basename(currentUser.photoUrl))
        .replaceAll(new RegExp(r'(\?alt).*'), '');
    // print(fileUrl);
    var downloadUrl =
        FirebaseStorage.instance.ref().child(fileUrl).getName();
    if (downloadUrl != null) {
      FirebaseStorage.instance
          .ref()
          .child(fileUrl)
          .delete()
          .then((value) {})
          .catchError((onError) {
        print(onError.message);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _loading = true;
    });
    getCurrentUserInfo();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
  String _selectedLocation = currentUser.state == '' ? '' : currentUser.state.toString() ;
    TextEditingController userNameController =
        TextEditingController(text: currentUser.username);

    TextEditingController addressController =
        TextEditingController(text: currentUser.address);
    TextEditingController cityController =
        TextEditingController(text: currentUser.city);
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController changePasswordController = TextEditingController();
    TextEditingController confirmChangePasswordController =
        TextEditingController();
    TextEditingController stateController =
        TextEditingController(text: currentUser.state);
    TextEditingController pincodeController = TextEditingController(
        text: currentUser.pincode.toString() == null
            ? ''
            : currentUser.pincode.toString());

    Widget _buildUsername() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Username",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'yourname'),
              controller: userNameController,
              validator: (value) =>
                  value.isEmpty ? 'Username can\'t be empty' : null,
              onSaved: (value) => _username = value.trim(),
            ),
          )
        ],
      );
    }

    Widget _buildAddress() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Address",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter your Adress'),
              controller: addressController,
              validator: (value) =>
                  value.isEmpty ? 'Address is Required' : null,
            ),
          )
        ],
      );
    }

    Widget _buildCity() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "City",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter your city'),
              controller: cityController,
              validator: (value) => value.isEmpty ? 'city is Required' : null,
            ),
          )
        ],
      );
    }

    Widget _buildState() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: stateController,
          decoration: InputDecoration(labelText: "Enter your State"),
          validator: (String value) {
            if (value.isEmpty) {
              return 'State is Required';
            }
            return null;
          },
          onSaved: (String value) {
            _username = value;
          },
        ),
      );
    }

    Widget _buildPincode() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Pincode",
            style: Custom().inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              maxLines: 1,
              style: Custom().inputTextStyle,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter your Pincode'),
              controller: pincodeController,
              validator: (value) =>
                  value.isEmpty ? 'Pincode is Required' : null,
            ),
          )
        ],
      );
    }

    Widget _buildCurrentPassword() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: currentPasswordController,
          decoration: InputDecoration(
            labelText: 'Current Password',
          ),
          keyboardType: TextInputType.visiblePassword,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Password is Required';
            }
            if (value.length < 6) {
              return 'Your password needs to be atleast 6 character';
            }

            return null;
          },
          onSaved: (String value) {
            _currentPassword = value;
          },
          obscureText: true,
        ),
      );
    }

    Widget _buildChangePassword() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: changePasswordController,
          decoration: InputDecoration(
            labelText: 'New Password',
          ),
          keyboardType: TextInputType.visiblePassword,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Password is Required';
            }
            if (value.length < 6) {
              return 'Your password needs to be atleast 6 character';
            }

            return null;
          },
          onSaved: (String value) {
            _newPassword = value;
          },
          obscureText: true,
        ),
      );
    }

    Widget _buildConfirmChangePassword() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: confirmChangePasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
          ),
          keyboardType: TextInputType.visiblePassword,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Password is Required';
            }
            if (value.length < 6) {
              return 'Your password needs to be atleast 6 character';
            }

            return null;
          },
          onSaved: (String value) {
            _confirmPassword = value;
          },
          obscureText: true,
        ),
      );
    }

    Future<void> _updateUsername() async {
      print(userNameController.text);
      print(widget.details.uid);
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        try {
          await Firestore.instance
              .collection("users")
              .document(widget.details.uid)
              .updateData({"displayName": userNameController.text}).then(
                  (result) {});
          successMessage = "Username Updated Successfully!";
          buildSuccessDialog(successMessage, context);
          getCurrentUserInfo();
        } catch (e) {
          print(e.message);
        }
      }
    }

    Future<void> _updateLocation() async {
      try {
        String status = await Datastore().updateUserLocation(
            widget.details.uid,
            addressController.text,
            cityController.text,
            _selectedLocation,
            pincodeController.text);
        successMessage = "Location Updated Successfully!";
        buildSuccessDialog(successMessage, context);
        getCurrentUserInfo();
      } catch (e) {
        print(e.message);
      }
    }

    Future<void> _updatePassword() async {
      try {
        AuthResult check = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: currentUser.userEmail,
                password: currentPasswordController.text);
        // print("Provider: ${check.}");
        if (check.user.getIdToken() != null) {
          if (changePasswordController.text ==
              confirmChangePasswordController.text) {
            FirebaseUser user = await FirebaseAuth.instance.currentUser();
            user
                .updatePassword(changePasswordController.text)
                .catchError((error) {
              errorMessage = "Password can't be changed" + error.toString();
              buildErrorDialog(errorMessage, context);
            });
            successMessage = "Password Updated Successfully!";
            buildSuccessDialog(successMessage, context);
          } else {
            errorMessage = "Confirm Password Does not match!";
            buildErrorDialog(errorMessage, context);
          }
        }
      } catch (error) {
        switch (error.code) {
          case "ERROR_WRONG_PASSWORD":
            errorMessage = "Your Current password is wrong.";
            buildErrorDialog(errorMessage, context);
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage = "Too many requests. Try again later.";
            buildErrorDialog(errorMessage, context);
            break;
          default:
            errorMessage = "An undefined Error happened.";
            buildErrorDialog(errorMessage, context);
        }
      }
    }

    Future<void> _deleteProfilePhoto() async {
      try {
        _deleteImageFromFirestorage();
        await Firestore.instance
            .collection("users")
            .document(widget.details.uid)
            .updateData({"photoUrl": ""}).then((result) {});
        getCurrentUserInfo();
        buildSuccessDialog("Profile Photo Deleted Successfully!", context);
      } catch (e) {
        print(e.message);
      }
    }

    return Scaffold(
      appBar: MyAppBar(
        text: "Toys",
        back: true,
      ),
      body: _loading
          ? circularProgress(context)
          : Container(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                children: <Widget>[
                  buildText("Edit Profile", Colors.black54),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        buildText("Profile Picture", Colors.black),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ViewImage(
                                              image: currentUser.photoUrl,
                                            )));
                              },
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white,
                                backgroundImage: currentUser.photoUrl == ""
                                    ? AssetImage(
                                        'assets/images/unknown-user.png')
                                    : CachedNetworkImageProvider(
                                        currentUser.photoUrl),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            buildRaisedButton("Upload New Picture",
                                Colors.black, Colors.white, () {
                              selectImage(context);
                            }),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              child: widget.details.photoUrl == ""
                                  ? Text("")
                                  : buildRaisedButton(
                                      "Delete", Colors.white, Colors.black, () {
                                      _deleteProfilePhoto();
                                    }),
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        // buildText("Username", Colors.black87),
                        SizedBox(height: 10),
                        _buildUsername(),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            buildRaisedButton(
                                "Save Changes", Colors.black, Colors.white, () {
                              _updateUsername();
                            }),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  buildText("Location", Colors.black54),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // buildText("Address", Colors.black),
                        SizedBox(height: 10),
                        _buildAddress(),
                        SizedBox(height: 20),
                        // buildText("City", Colors.black),
                        SizedBox(height: 10),
                        _buildCity(),
                        SizedBox(height: 10),
                        _buildPincode(),
                        SizedBox(height: 20),
                        Text(
                          "State",
                          style: Custom().inputLabelTextStyle,
                        ),
                        SizedBox(height: 10),
                        DropdownButton(
                          hint:  _selectedLocation == ''
                                  ? Text(_selectedLocation.toString())
                                  : Text('Please choose a location'),
                          value: _selectedLocation,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedLocation = newValue;
                            });
                          },
                          items: _locations.map((location) {
                            return DropdownMenuItem(
                              child: new Text(location),
                              value: location,
                            );
                          }).toList(),
                        ),
                        // _buildState(),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            buildRaisedButton(
                                "Save Changes", Colors.black, Colors.white, () {
                              _updateLocation();
                            }),
                          ],
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  currentUser.loginType == 'google'
                      ? Text("")
                      : SizedBox(height: 20),
                  currentUser.loginType == 'google'
                      ? Text("")
                      : buildText("Change Password", Colors.black54),
                  currentUser.loginType == 'google'
                      ? Text("")
                      : SizedBox(height: 10),
                  currentUser.loginType == 'google'
                      ? Text("")
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              buildText("Current Password", Colors.black),
                              SizedBox(height: 10),
                              _buildCurrentPassword(),
                              SizedBox(height: 20),
                              buildText("New Password", Colors.black),
                              SizedBox(height: 10),
                              _buildChangePassword(),
                              SizedBox(height: 10),
                              buildText("Confirm Password", Colors.black),
                              SizedBox(height: 10),
                              _buildConfirmChangePassword(),
                              SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  buildRaisedButton("Save Changes",
                                      Colors.black, Colors.white, () {
                                    _updatePassword();
                                  }),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Text buildText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
          letterSpacing: 1,
          fontSize: 20,
          color: color,
          fontWeight: FontWeight.bold),
    );
  }
}
