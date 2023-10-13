import 'package:flutter/material.dart';
import 'package:self_record/viewmodel.dart';
import 'package:stacked/stacked.dart';

class AddView extends StatefulWidget {
  const AddView({Key? key}) : super(key: key);

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ViewModel>.reactive(
        viewModelBuilder: () => ViewModel(),
        builder: (context, model, child) => Scaffold(
              appBar: AppBar(
                title: Text('Add Report'),
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(16.0),
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        await model.capturePicture();
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: model.imagePath == null
                            ? Center(
                                child: Text(
                                  'Tap',
                                ),
                              )
                            : Image.file(model.capturedImage!),
                      ),
                    ),
                    Visibility(
                      visible: model.imagePath == null ? true : false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Longitude',
                          ),
                          Text(
                            model.long!,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: model.imagePath == null ? true : false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Latitude',
                          ),
                          Text(
                            model.lat!,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: model.imagePath == null ? true : false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Address Line',
                          ),
                          Text(
                            model.address!,
                          ),
                        ],
                      ),
                    ),
                    // Add widgets for date time picker and description here
                    MaterialButton(
                      child: Text('Save'),
                      onPressed: () {
                        model.addReport();
                      },
                    ),
                  ],
                ),
              ),
            ));
  }
}
