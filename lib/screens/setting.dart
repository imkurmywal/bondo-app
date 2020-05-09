import 'package:bondo/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:bondo/config/size_config.dart';
import 'package:language_pickers/language_pickers.dart';
import 'package:language_pickers/languages.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Language _selectedDropdownLanguage =
  LanguagePickerUtils.getLanguageByIsoCode('ko');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){AppRoutes.pop(context);
          },

          child: Icon(
          Icons.arrow_back_ios
          ,color: Colors.black, ),
        ),
    title: Text('Settings',style: TextStyle(color: Colors.black,fontSize: 20),),

    ),
    body: Container(
    width: SizeConfig.screenWidth,
    height: SizeConfig.screenHeight,
    margin: EdgeInsets.symmetric(horizontal: 10),
    child: Column(
    children: [
      SizedBox(
        height: SizeConfig.blockSizeVertical*5,
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [BoxShadow(
            spreadRadius: 1,
            blurRadius: 1,
            color: Colors.grey.withOpacity(0.4)
          )],
        ),
        height: 50,
        width: SizeConfig.screenWidth,
        child: Row(


          children: [
            SizedBox(
              width: SizeConfig.blockSizeVertical*2,
            ),
            Text('Language',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w700),),
            SizedBox(
              width: SizeConfig.blockSizeVertical*6,
            ),
            LanguagePickerDropdown(
              initialValue: 'ko',
              itemBuilder: _buildDropdownItem,
              onValuePicked: (Language language) {
                _selectedDropdownLanguage = language;
             },
            ),
          ],
        ),
      ),
      ]
    )
    )
    );
  }
  Widget _buildDropdownItem(Language language) {
    return Text("${language.name} ");
  }

}

