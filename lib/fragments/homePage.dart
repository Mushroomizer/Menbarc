import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menbarc/tools/constants.dart';
import 'package:menbarc/tools/functions.dart';
import 'package:menbarc/widgets/customRoundedButton.dart';

class homePage extends StatefulWidget {
  homePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  double defaultPressure = 6;
  TextEditingController pressureEditorController;
  FocusNode pressureEditorFocusNode;

  LinkedHashMap<String, int> _nozzles = new LinkedHashMap<String, int>();

  void _dialogueResult(String nozzleType) {
    print('you selected $nozzleType');
    Navigator.pop(context);
    _updateNozzleAmount(nozzleType, 1);
  }

  void _updateNozzleAmount(String nozzleType, int amount) {
    setState(() {
      if (_nozzles.containsKey(nozzleType) &&
          _nozzles[nozzleType] <= 0 &&
          amount < 0) {
        _nozzles.remove(nozzleType);
        return;
      }
      _nozzles.update(nozzleType, (v) => v + amount, ifAbsent: () => 1);
    });
  }

  void _showAlert() {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text('Add nozzle'),
              content: _getNozzleTypeOptions(),
            ));
  }

  void _addNozzle() {
    _showAlert();
  }

  Widget _getNozzleTypeOptions() {
    List<Widget> widgets = new List<Widget>();
    for (var nozzleType in getNozzleTypes()) {
      widgets.add(new FlatButton(
          onPressed: () {
            _dialogueResult(nozzleType);
          },
          child: new Text("GPM " + nozzleType)));
    }
    ListView list = new ListView(
      children: widgets,
    );
    return list;
  }

  _calculate() {
    if (_nozzles.isNotEmpty) {
      String water_consumption = calculateWaterConsumption();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Water consumption"),
              content: Text(
                water_consumption,
                style: TextStyle(fontSize: 20),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: water_consumption));
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(
                          msg: "Copied to clipboard",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
                    child: Text(
                      "Copy",
                    )),
                FlatButton(
                  child: Text(
                    "Okay",
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              elevation: 5,
            );
          });
    } else {
      Fluttertoast.showToast(
          msg: "Add a nozzle first",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Theme.of(context).errorColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  // Formula:
  // Q2 = (Q1/(P1/P2))*60
  // Where …
  // Q1 = see below constants
  // Q2 = Answer in Liters/Hr
  // P1 = 3Pwr
  // P2 = (Selected pressure)Pwr
  //
  // Constants:
  // Pwr = 0.5 (to the power of)
  String calculateWaterConsumption() {
    pressureEditorController.text = pressureEditorController.text;
    double consumption = 0;

    for (var nozzleType in _nozzles.keys) {
      int amount = _nozzles[nozzleType];
      if (amount <= 0) continue;
      double Q2, Q1, P1, P2;
      Q1 = getNozzleFlowPerMinuteAt3Bar(nozzleType);
      P1 = pow(3, 0.5);
      P2 = pow(double.parse(pressureEditorController.text), 0.5);
      Q2 = (Q1 / (P1 / P2)) * amount;
      print("Nozzle: " + nozzleType + " flow per hour: " + Q2.toString());
      consumption += Q2;
    }

    consumption *= 60;
    // if (consumption.toString().contains(".")){
    //   consumption = double.parse(consumption.toStringAsFixed(2));
    // }
    print("consumption: " + consumption.toString());

    pressureEditorFocusNode.unfocus();
    return '''${consumption.truncate().toString()} Lt/Hr''';
  }

  @override
  Widget build(BuildContext context) {
    if (pressureEditorController == null)
      pressureEditorController =
          TextEditingController(text: defaultPressure.toString());
    if (pressureEditorFocusNode == null) {
      pressureEditorFocusNode = FocusNode();
      pressureEditorFocusNode.addListener(() {
        if (pressureEditorFocusNode.hasFocus) {
          pressureEditorController.clear();
        } else {
          if (pressureEditorController.text.isEmpty) {
            pressureEditorController.text = defaultPressure.toString();
          }
        }
      });
    }
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Pressure: ",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      focusNode: pressureEditorFocusNode,
                      controller: pressureEditorController,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                      onSubmitted: (s) {
                        try {
                          calculateWaterConsumption();
                        } catch (e, stacktrace) {
                          debugPrint(stacktrace.toString());
                          pressureEditorController.clear();
                        }
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: "Pressure at manifold",
                          border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: getNozzleListItems(),
              ),
            ),
            FlatButton(
                height: 50,
                minWidth: double.infinity,
                onPressed: _calculate,
                color: Theme.of(context).accentColor,
                child: Text(
                  "Calculate",
                  style: TextStyle(color: Colors.white),
                )),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: _addNozzle,
          tooltip: 'Add Nozzle',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  List<Widget> getNozzleListItems() {
    List<Widget> widgets = new List<Widget>();
    if (_nozzles.isNotEmpty) {
      widgets.add(FlatButton(
          height: 50,
          minWidth: double.infinity,
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => new AlertDialog(
                      title: new Text('Are you sure?'),
                      content: new Text(
                        "This action will remove all nozzles from the list",
                      ),
                      actions: <Widget>[
                        new FlatButton(
                            onPressed: () {
                              setState(() {
                                _nozzles.clear();
                                Navigator.pop(context);
                              });
                            },
                            child: new Text('yes', style: TextStyle(color: Theme.of(context).primaryColor),)),
                        new FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: new Text('no', style: TextStyle(color: Theme.of(context).errorColor),)),
                      ],
                    ));
          },
          color: Theme.of(context).errorColor,
          child: Text(
            "Clear",
            style: TextStyle(color: Colors.white),
          )));
    }
    for (var nozzleType in _nozzles.keys) {
      widgets.add(createNozzleListItemWidget(nozzleType, _nozzles[nozzleType]));
    }
    if (widgets.isEmpty)
      widgets.add(Container(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText1,
              children: [
                TextSpan(text: 'Press '),
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Icon(Icons.add),
                  ),
                ),
                TextSpan(text: ' to add a nozzle'),
              ],
            ),
          ),
        ),
      ));

    widgets.add(Padding(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
    ));

    return widgets;
  }

  Widget createNozzleListItemWidget(String nozzleType, int amount) {
    Text textWidget = Text(
      "Amount: " + amount.toString(),
    );
    if (amount <= 0) {
      textWidget = Text(
        "Amount: " + amount.toString(),
        style: TextStyle(color: Colors.red),
      );
    }
    return Dismissible(
      key: Key(nozzleType),
      background: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.red,
        alignment: Alignment.center,
        child: Text(
          "Delete",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
      onDismissed: (direction) {
        // Remove the item from the data source.
        Fluttertoast.showToast(
          msg: _nozzles[nozzleType].toString() +
              " GPM " +
              nozzleType +
              " removed",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        setState(() {
          _nozzles.remove(nozzleType);
        });
      },
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              "GPM " + nozzleType,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 7,
            child: Row(
              children: <Widget>[
                customRoundedButton(
                    Icon(
                      Icons.remove,
                      color: Colors.red,
                      size: 15.0,
                    ), () {
                  _updateNozzleAmount(nozzleType, -1);
                }),
                textWidget,
                customRoundedButton(
                    Icon(
                      Icons.add,
                      color: Colors.green,
                      size: 15.0,
                    ), () {
                  _updateNozzleAmount(nozzleType, 1);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
