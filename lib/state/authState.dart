import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/common/locator.dart';
import '/helper/enum.dart';
import '/helper/shared_prefrence_helper.dart';
import '/helper/utility.dart';
import '/model/note.dart';
import '/state/appState.dart';
import 'package:path/path.dart' as path;
import '../model/user.dart';

class AuthState extends AppStates {
  AuthStatus authStatus = authStatus.NOT_DETERMINED;
  bool isSignInWithGoogle =false;
  User?user;
  late String userId;
  final FirebaseAuth _firebaseAuth= FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn= GoogleSignIn();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  db.Query? _profileQuery;
  late AuthState authRepository;
  UserModel? _userModel;
  NoteModel? _noteModel;
  UserModel? get userModel => _userModel;
  NoteModel> get noteModel => _noteModel;

  UserModel? get profileUserModel =>_userModel;

  void logoutCallback() async{
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId=import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parallels/common/locator.dart';
import 'package:parallels/helper/enum.dart';
import 'package:parallels/helper/shared_prefrence_helper.dart';
import 'package:parallels/helper/utility.dart';
import 'package:parallels/model/note.dart';
import 'package:parallels/state/appState.dart';
import 'package:path/path.dart' as path;
import '../model/user.dart';

class AuthState extends AppStates {
  authStatus = AuthStatus.NOT_LOGGED_IN;
  userId='';
  _userModel= null;
  user= null;
  _profileQuery!.onValue.drain();
  _profileQuery=null;
  if(isSignInWithGoogle){
    _googleSignIn.signOut();
    Utility.logEvent('google_logout',parameter:{});
    isSignInWithGoogle=false;
  }
  _firebaseAuth.signOut();
  notifyListeners();
  await getIt<SharedPreferencesHelper>().clearPreferemcesValues();
}

void openSignUpPage(){
  authStatus= AuthStatus.NOT_LOGGED_IN;
  userId= '';
  notifyListeners();
}

void databaseInit(){
  try{
    if(_profileQuery== null){
      _profileQuery = kDatabase.child('profile').child(user!.uid);
      _profileQuery!.onValue.listen((_onProfileChanged);
      _profileQuery!.onChildChanged.listen(_onProfileUpdated);
    }
  }catch(error){
    cprint(error,errorIn:'databaseInit');
  }
}
  
  //verify user's credential for login
  Future<String?>signIn(String email,String password,BuildContext context,
  {required GlobalKey<ScaffoldState>scaffoldKey}) async{
    try{
      isBusy=true;
      var result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
        user= result.user;
        userId = user!.uid;
        return user!.uid;
    } on FirebaseException catch(error){
      if(error.code =='Email address not found'){
        Utility.customSnackBar(scaffoldKey,'User not found',context);
      }else{
        Utility.customSnackBar(scaffoldKey,error.message??'Something went wrong',context);
      }
      cprint(error,errorIn:'signIn');
      return null;
    }catch(error){
      Utility.customSnackBar(scaffoldKey.error.toString(),context);
      cprint(error,errorIn:'signin');
      return null;
    }finally{
      isBusy=false;
    }
  }

  Future<User?> handleGoogleSignIn() async{
    try{
      kAnalytics.logLogin(loginMethod:'google_login');
      final GoogleSignInAccount? googleUser= await _googleSignIn.signIn();
      if(googleUser ==null){
        throw Exception('Google login cancelled by user');
      }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider().credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    user= (await _firebaseAuth.signInWithCredential(credential)).user;
    authStatus= AuthStatus.LOGGED_IN;
    userId= user!.uid;
    isSignInWithGoogle=true;
    createUserFromGoogleSignIn(user!);
    notifyListeners();
    return user;
  } on PlatformException catch(error){
    user = null;
    authStatus= AuthStatus.NOT_LOGGED_IN;
    cprint(error,errorIn:'handleGoogleSignIn');
    return null;
  } on Exception catch(error){
    user= null;
    authStatus = AuthStatus.NOT_LOGGED_IN;
    cprint(error,errorIn:'handleGoogleSignIn');
    return null;
  }catch(error){
    user= null;
    authStatus= AuthStatus.NOT_LOGGED_IN;
    cprint(error,errorIn:'handleGoogleSignIn');
    return null;
  }
  }

  void createUserFromGoogleSignIn(User user){
    var diff = DateTime.now().difference(user.metadata.creationTime!);
    if(diff <const Duration(seconds: 15)){
      userModel model= userModel(
        profilePic:user.photoURL!,
        displayName:user.displayName!,
        key:user.uid,
      );
      createUser(model,newUser:true);
    }else{
      cprint('Last login at:${user.metadata.lastSignInTime}');
    }
  }

  Future<String?>signUp(userModel userModel,BuildContext context,
  {required GlobalKey<ScaffoldState>scaffoldKey,required String password}) async{
    try{
      isBusy=true;
      var result = await _firebaseAuth.createUserWithEmailAndPassword(email: userModel.email!, 
      password: password,
      );
      user= result.user;
      authStatus =AuthStatus.LOGGED_IN;
      kAnalytics.logSignUp(signUpMethod:'register');
      result.user!.updateDisplayName(
        userModel.displayName,
        );
        result.user!.updatePhotoURL(user.profilePic);
    _userModel= userModel;
    _userModel!.key = user!.uid;
    _userModel!.userId = user!.uid;
    createUser(_userModel!,newUser:true);
    return user!.uid;
    }catch(error){
      isBusy=false;
      cprint(error,errorIn:'signUp');
      Utility.customSnackBar(scaffoldKey,error.toString(),context);
      return null;
    }
  }
   /// `Create` and `Update` user
  /// IF `newUser` is true new user is created
  /// Else existing user will update with new values
  void createUser(UserModel user, {bool newUser = false}) {
    if (newUser) {
      // Create username by the combination of name and id
kAnalytics.logEvent(name:'create_newUser');
user.createAt= DateTime.now().toUtc().toString();
    }
  
  kDatabase.child('profile').child(user.userId!).set(user.toJson());
  _userModel= user;
  isBusy=false;
  }

  Future<User?> getCurrentUser() async{
    try{
      isBusy=true;
      Utility.logEvent('get_currentUser',parmeter:{});
    }
  }