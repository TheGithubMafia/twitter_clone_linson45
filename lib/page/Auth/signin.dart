import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customLoader.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  final VoidCallback loginCallback;

  const SignIn({Key key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  CustomLoader loader;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // _emailController.text = 'sonu.sharma@kritivity.com';
    // _passwordController.text = '1234567';
    loader = CustomLoader();
    super.initState();
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 150),
              _entryFeild('Enter email', controller: _emailController),
              _entryFeild('Enter password',
                  controller: _passwordController, isPassword: true),
              _emailLoginButton(context),
              SizedBox(
                height: 20,
              ),
              _labelButton('Forget password?', onPressed: () {
                Navigator.of(context).pushNamed('/ForgetPasswordPage');
              }),
              Divider(),
              _googleLoginButton(context),
              SizedBox(height: 100),
            ],
          )),
    );
  }

  Widget _entryFeild(String hint,
      {TextEditingController controller, bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(color: Colors.blue)),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _labelButton(String title, {Function onPressed}) {
    return FlatButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      splashColor: Colors.grey.shade200,
      child: Text(
        title,
        style: TextStyle(
            color: TwitterColor.dodgetBlue, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _emailLoginButton(BuildContext context) {
    return Container(
      width: fullWidth(context),
      margin: EdgeInsets.symmetric(vertical: 35),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: TwitterColor.dodgetBlue,
        onPressed: _emailLogin,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: TitleText('Email Login', color: Colors.white),
      ),
    );
  }

  Widget _googleLoginButton(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              onPressed: _googleLogin,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'assets/images/google_logo.png',
                    height: 20,
                    width: 20,
                  ),
                  SizedBox(width: 10),
                  TitleText(
                    'Continue with Google',
                    color: Colors.black54,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  void _emailLogin() {
    var state = Provider.of<AuthState>(context,listen: false);
    if (state.isbusy) {
      return;
    }
    loader.showLoader(context);
    var isValid = validateCredentials(
        _scaffoldKey, _emailController.text, _passwordController.text);
    if (isValid) {
      state
          .signIn(_emailController.text, _passwordController.text,
              scaffoldKey: _scaffoldKey)
          .then((status) {
        if (state.user != null) {
          loader.hideLoader();
          Navigator.pop(context);
          widget.loginCallback();
        } else {
          cprint('Unable to login', errorIn: '_emailLoginButton');
          loader.hideLoader();
        }
      });
    } else {
      loader.hideLoader();
    }
  }

  void _googleLogin() {
    var state = Provider.of<AuthState>(context,listen: false);
    if (state.isbusy) {
      return;
    }
    loader.showLoader(context);
    state.handleGoogleSignIn().then((status) {
      // print(status)
      if (state.user != null) {
        loader.hideLoader();
        Navigator.pop(context);
        widget.loginCallback();
      } else {
        loader.hideLoader();
        cprint('Unable to login', errorIn: '_googleLoginButton');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: customText('Sign in',
            context: context, style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
}
