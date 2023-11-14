
import 'package:flutter/cupertino.dart';
import 'package:np_social/res/Resources.dart';
import 'package:np_social/res/dimentions/AppDimension.dart';

extension AppContext on BuildContext {
  Resources get resources => Resources.of(this);
}