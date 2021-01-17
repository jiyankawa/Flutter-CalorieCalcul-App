import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculateur de Calories',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Calculateur de Calories'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int calorieBase;
  int calorieAvecActivite;
  int radioSelectionnee;
  double poids;
  double age;
  bool genre = false;
  double taille = 170.0;

  Map mapActivite = {
    0: "Faible",
    1: "Modéré",
    2: "Forte"
  };

  @override
  Widget build(BuildContext context) {

    return new GestureDetector(
      onTap: (() => FocusScope.of(context).requestFocus(new FocusNode())),
      child: new Scaffold(
        appBar: AppBar(
          backgroundColor: setColor(),
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          padding:EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              padding(),
              customText("Remplissez tous les champs pour obtenir votre besoin journalier en calories."),
              padding(),
              new Card(
                elevation: 10.0,
                child: new Column(
                  children: <Widget>[
                    padding(),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        customText("Femme", color: Colors.yellow[800]),
                        new Switch(
                            value: genre,
                            inactiveTrackColor: Colors.yellow[800],
                            activeTrackColor: Colors.red[700],
                            onChanged: (bool b){
                              setState(() {
                                genre = b;
                              });
                            }
                        ),
                        customText("Homme", color:Colors.red[700]),
                      ],
                    ),
                    new RaisedButton(
                        color: setColor(),
                        child: (
                            customText(
                                (age == null)? "appuyez pour entrer votre âge" : "Vous avez ${age.toInt()} ans",
                                color: Colors.white
                            )
                        ),
                        onPressed: () => montrerPicker()
                    ),
                    padding(),
                    customText("Votre taille est de : ${taille.toInt()} centimètres.", color: setColor()
                    ),
                    padding(),
                    new Slider(
                      value: taille,
                      onChanged: (double d) {
                        setState(() {
                          taille = d;
                        });
                      },
                      max: 215.0,
                      min: 100.0,
                      activeColor: setColor(),
                      inactiveColor: Colors.grey[100],
                    ),
                    padding(),
                    new TextField(
                      keyboardType: TextInputType.number,
                      cursorColor: setColor(),
                      onChanged: (String string){
                        setState(() {
                          poids = double.tryParse(string);
                        });
                      },
                      decoration: new InputDecoration(
                        labelText: "Entrez votre poids en kilos.",

                      ),
                    ),
                    padding(),
                    customText("Quelle est votre activité sportive ?", color: setColor()),
                    padding(),
                    rowRadio(),
                    padding(),
                  ],
                ),
              ),
              padding(),
              new RaisedButton(
                color: setColor(),
                child: customText("Calculer", color: Colors.white),
                onPressed: calculerCal,
              ),
            ],
          ),
        ),
      ),
    );

  }

  Padding padding() {
    return new Padding(padding: EdgeInsets.only(top : 20.0));
  }

  Future<Null> montrerPicker() async {
    DateTime choix = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(1900),
        lastDate: new DateTime.now(),
        initialDatePickerMode: DatePickerMode.year
    );
    if(choix!= null) {
      var difference = new DateTime.now().difference(choix);
      var jours = difference.inDays;
      var ans = (jours/365.25);
      setState(() {
        age = ans;
      });
    }
  }


  Color setColor(){
    if(genre){
      return Colors.red[700];
    } else {
      return Colors.yellow[800];
    }
  }

  Text customText(String data, {color: Colors.black, fontSize: 15.0}) {
    return new Text(
        data,
        textAlign: TextAlign.center,
        style: new TextStyle(
            color: color,
            fontSize: fontSize
        )
    );
  }

  Row rowRadio(){
    List<Widget> l = [];
    mapActivite.forEach((key, value) {
      Column colonne = new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Radio(
              activeColor: setColor(),
              value: key,
              groupValue: radioSelectionnee,
              onChanged:(Object i) {
                setState(() {
                  radioSelectionnee = i;
                });
              }
          ),
          customText(value,color: setColor())
        ],
      );
      l.add(colonne);
    });
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: l,
    );
  }

  void calculerCal(){
    if(age != null && poids != null && radioSelectionnee != null){
      if(genre){
        calorieBase = (66.4730 + (13.7516 * poids) + (5.0033 * taille) - (6.7550 * age)).toInt();
      } else {
        calorieBase = (655.0955 + (9.5634 * poids) + (1.8496 * taille) - (4.6756 * age)).toInt();
      }

      switch(radioSelectionnee) {
        case 0:
          calorieAvecActivite = (calorieBase * 1.2).toInt(); break;
        case 1:
          calorieAvecActivite = (calorieBase * 1.5).toInt(); break;
        case 2:
          calorieAvecActivite = (calorieBase * 1.8).toInt(); break;
        default : calorieAvecActivite = calorieBase; break;
      }

      setState(() {
        dialogue();
      });

    } else {
      alerte();
    }
  }

  Future<Null> dialogue() async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext buildContext) {
          return SimpleDialog(
            title: customText("Votre besoin en calories", color: setColor()),
            contentPadding: EdgeInsets.all(15.0),
            children: [
              padding(),
              customText("Votre besoin de base est de : $calorieBase"),
              padding(),
              customText("Votre besoin avec activité sportive est de : $calorieAvecActivite"),
              padding(),
              new RaisedButton(
                  onPressed: () {
                    Navigator.pop(buildContext);
                  },
                child: customText("OK", color: Colors.white),
                color: setColor(),
              )
            ],
          );
        }
    );
  }

  Future<Null> alerte() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
builder: (BuildContext buildContext) {
        return new AlertDialog(
          backgroundColor: Colors.red[800],
          title: customText("Erreur", color: Colors.white),
          content: customText("Tous les champs ne sont pas remplis.", color: Colors.white),
          actions: [
            new FlatButton(
                onPressed: () {Navigator.pop(buildContext);},
                child: customText("OK", color: Colors.white)
            )
          ],
        );
}
        
    );
  }

}
