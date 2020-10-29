import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menbarc/widgets/customRoundedButton.dart';

class dosingRatesPage extends StatefulWidget {
  @override
  State createState() {
    return _dosingRatesPageState();
  }
}

enum Pump { BM515, BM210 }

class _dosingRatesPageState extends State<dosingRatesPage> {
  Pump _pump = Pump.BM515;

  TextEditingController oreDeliveryEditorController;
  FocusNode oreDeliveryEditorEditorFocusNode;

  _dosingRatesPageState() {
    if (oreDeliveryEditorController == null) {
      oreDeliveryEditorController = TextEditingController();
    }
    if (oreDeliveryEditorEditorFocusNode == null) {
      oreDeliveryEditorEditorFocusNode = FocusNode();
      oreDeliveryEditorEditorFocusNode.addListener(() {
        if (oreDeliveryEditorEditorFocusNode.hasFocus)
          oreDeliveryEditorController.text = "";
      });
    }
  }

  int calculateDosingRate(double oreDelivery, double constant) {
    return (((oreDelivery * constant) / 60) * 1000).round();
  }

  _calculate() {
    if (oreDeliveryEditorController.text.isNotEmpty) {
      oreDeliveryEditorEditorFocusNode.unfocus();
      String dosing_rate = "";
      double oreDeliveryRate = double.parse(oreDeliveryEditorController.text);
      switch (_pump) {
        case Pump.BM515:
          dosing_rate = calculateDosingRate(oreDeliveryRate, 0.06).toString();
          break;
        case Pump.BM210:
          dosing_rate = calculateDosingRate(oreDeliveryRate, 0.01).toString();
          break;
        default:
          Fluttertoast.showToast(
              msg: "Please select a pump",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Theme.of(context).errorColor,
              textColor: Colors.white,
              fontSize: 16.0);
          return;
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Dosing rate"),
              content: Text(
                dosing_rate + " ml/minute",
                style: TextStyle(fontSize: 20),
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: dosing_rate + " ml/min"));
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
          msg: "Please enter ore delivery in Tons/Hour",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Theme.of(context).errorColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Column(
                  children: [
                    RadioListTile<Pump>(
                      title: const Text('BM515'),
                      value: Pump.BM515,
                      groupValue: _pump,
                      onChanged: (Pump value) {
                        setState(() {
                          _pump = value;
                        });
                      },
                    ),
                    RadioListTile<Pump>(
                      title: const Text('BM210'),
                      value: Pump.BM210,
                      groupValue: _pump,
                      onChanged: (Pump value) {
                        setState(() {
                          _pump = value;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Ore delivery: ",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              focusNode: oreDeliveryEditorEditorFocusNode,
                              controller: oreDeliveryEditorController,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                              onSubmitted: (s) {},
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: "Ore delivery Tons/Hour",
                                  border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
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
              ))
        ],
      )),
    );
  }
}
