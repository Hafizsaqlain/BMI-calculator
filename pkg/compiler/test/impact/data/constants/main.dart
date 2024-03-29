// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'lib.dart';
import 'lib.dart' deferred as defer;

/*member: main:static=[
  boolLiteral(0),
  boolLiteralDeferred(0),
  boolLiteralRef(0),
  doubleLiteral(0),
  doubleLiteralDeferred(0),
  doubleLiteralRef(0),
  instanceConstant(0),
  instanceConstantDeferred(0),
  instanceConstantRef(0),
  instantiation(0),
  instantiationDeferred(0),
  instantiationRef(0),
  intLiteral(0),
  intLiteralDeferred(0),
  intLiteralRef(0),
  listLiteral(0),
  listLiteralDeferred(0),
  listLiteralRef(0),
  mapLiteral(0),
  mapLiteralDeferred(0),
  mapLiteralRef(0),
  nullLiteral(0),
  nullLiteralDeferred(0),
  nullLiteralRef(0),
  setLiteral(0),
  setLiteralDeferred(0),
  setLiteralRef(0),
  staticTearOff(0),
  staticTearOffDeferred(0),
  staticTearOffRef(0),
  stringLiteral(0),
  stringLiteralDeferred(0),
  stringLiteralRef(0),
  stringMapLiteral(0),
  stringMapLiteralDeferred(0),
  stringMapLiteralRef(0),
  symbolLiteral(0),
  symbolLiteralDeferred(0),
  symbolLiteralRef(0),
  topLevelTearOff(0),
  topLevelTearOffDeferred(0),
  topLevelTearOffRef(0),
  typeLiteral(0),
  typeLiteralDeferred(0),
  typeLiteralRef(0)]*/
main() {
  nullLiteral();
  boolLiteral();
  intLiteral();
  doubleLiteral();
  stringLiteral();
  symbolLiteral();
  listLiteral();
  mapLiteral();
  stringMapLiteral();
  setLiteral();
  instanceConstant();
  typeLiteral();
  instantiation();
  topLevelTearOff();
  staticTearOff();

  nullLiteralRef();
  boolLiteralRef();
  intLiteralRef();
  doubleLiteralRef();
  stringLiteralRef();
  symbolLiteralRef();
  listLiteralRef();
  mapLiteralRef();
  stringMapLiteralRef();
  setLiteralRef();
  instanceConstantRef();
  typeLiteralRef();
  instantiationRef();
  topLevelTearOffRef();
  staticTearOffRef();

  nullLiteralDeferred();
  boolLiteralDeferred();
  intLiteralDeferred();
  doubleLiteralDeferred();
  stringLiteralDeferred();
  symbolLiteralDeferred();
  listLiteralDeferred();
  mapLiteralDeferred();
  stringMapLiteralDeferred();
  setLiteralDeferred();
  instanceConstantDeferred();
  typeLiteralDeferred();
  instantiationDeferred();
  topLevelTearOffDeferred();
  staticTearOffDeferred();
}

/*member: nullLiteral:type=[inst:JSNull]*/
nullLiteral() {
  const dynamic local = null;
  return local;
}

/*member: boolLiteral:type=[inst:JSBool]*/
boolLiteral() {
  const dynamic local = true;
  return local;
}

/*member: intLiteral:type=[
  inst:JSInt,
  inst:JSNumNotInt,
  inst:JSNumber,
  inst:JSPositiveInt,
  inst:JSUInt31,
  inst:JSUInt32]*/
intLiteral() {
  const dynamic local = 42;
  return local;
}

/*member: doubleLiteral:type=[
  inst:JSInt,
  inst:JSNumNotInt,
  inst:JSNumber,
  inst:JSPositiveInt,
  inst:JSUInt31,
  inst:JSUInt32]*/
doubleLiteral() {
  const dynamic local = 0.5;
  return local;
}

/*member: stringLiteral:type=[inst:JSString]*/
stringLiteral() {
  const dynamic local = "foo";
  return local;
}

/*member: symbolLiteral:
 static=[Symbol.(1)],
 type=[inst:Symbol]
*/
symbolLiteral() => #foo;

/*member: listLiteral:type=[
  inst:JSBool,
  inst:List<bool>]*/
listLiteral() => const [true, false];

/*member: mapLiteral:type=[
  inst:ConstantMap<dynamic,dynamic>,
  inst:ConstantStringMap<dynamic,dynamic>,
  inst:GeneralConstantMap<dynamic,dynamic>,
  inst:JSBool]*/
mapLiteral() => const {true: false};

/*member: stringMapLiteral:type=[
  inst:ConstantMap<dynamic,dynamic>,
  inst:ConstantStringMap<dynamic,dynamic>,
  inst:GeneralConstantMap<dynamic,dynamic>,
  inst:JSBool,
  inst:JSString]*/
stringMapLiteral() => const {'foo': false};

/*member: setLiteral:type=[
  inst:ConstantStringSet<dynamic>,
  inst:GeneralConstantSet<dynamic>,
  inst:JSBool]*/
setLiteral() => const {true, false};

/*member: instanceConstant:
 static=[
  Class.field2=BoolConstant(false),
  SuperClass.field1=BoolConstant(true)],
 type=[
  const:Class,
  inst:JSBool]
*/
instanceConstant() => const Class(true, false);

/*member: typeLiteral:
 static=[
  createRuntimeType(1),
  typeLiteral(1)],
 type=[
  inst:Type,
  inst:_Type,
  lit:String]
*/
typeLiteral() {
  const dynamic local = String;
  return local;
}

/*member: instantiation:
 static=[
  closureFunctionType(1),
  id,
  instantiate1(1),
  instantiatedGenericFunctionType(2)],
 type=[inst:Instantiation1<dynamic>]
*/
instantiation() {
  const int Function(int) local = id;
  return local;
}

/*member: topLevelTearOff:static=[topLevelMethod]*/
topLevelTearOff() {
  const dynamic local = topLevelMethod;
  return local;
}

/*member: staticTearOff:static=[Class.staticMethodField]*/
staticTearOff() {
  const dynamic local = Class.staticMethodField;
  return local;
}

/*member: nullLiteralRef:type=[inst:JSNull]*/
nullLiteralRef() => nullLiteralField;

/*member: boolLiteralRef:type=[inst:JSBool]*/
boolLiteralRef() => boolLiteralField;

/*member: intLiteralRef:type=[
  inst:JSInt,
  inst:JSNumNotInt,
  inst:JSNumber,
  inst:JSPositiveInt,
  inst:JSUInt31,
  inst:JSUInt32]*/
intLiteralRef() => intLiteralField;

/*member: doubleLiteralRef:type=[
  inst:JSInt,
  inst:JSNumNotInt,
  inst:JSNumber,
  inst:JSPositiveInt,
  inst:JSUInt31,
  inst:JSUInt32]*/
doubleLiteralRef() => doubleLiteralField;

/*member: stringLiteralRef:type=[inst:JSString]*/
stringLiteralRef() => stringLiteralField;

/*member: symbolLiteralRef:
 static=[Symbol.(1)],
 type=[inst:Symbol]
*/
symbolLiteralRef() => symbolLiteralField;

/*member: listLiteralRef:type=[
  inst:JSBool,
  inst:List<bool>]*/
listLiteralRef() => listLiteralField;

/*member: mapLiteralRef:type=[
  inst:ConstantMap<dynamic,dynamic>,
  inst:ConstantStringMap<dynamic,dynamic>,
  inst:GeneralConstantMap<dynamic,dynamic>,
  inst:JSBool]*/
mapLiteralRef() => mapLiteralField;

/*member: stringMapLiteralRef:type=[
  inst:ConstantMap<dynamic,dynamic>,
  inst:ConstantStringMap<dynamic,dynamic>,
  inst:GeneralConstantMap<dynamic,dynamic>,
  inst:JSBool,
  inst:JSString]*/
stringMapLiteralRef() => stringMapLiteralField;

/*member: setLiteralRef:type=[
  inst:ConstantStringSet<dynamic>,
  inst:GeneralConstantSet<dynamic>,
  inst:JSBool]*/
setLiteralRef() => setLiteralField;

/*member: instanceConstantRef:
 static=[
  Class.field2=BoolConstant(false),
  SuperClass.field1=BoolConstant(true)],
 type=[
  const:Class,
  inst:JSBool]
*/
instanceConstantRef() => instanceConstantField;

/*member: typeLiteralRef:
 static=[
  createRuntimeType(1),
  typeLiteral(1)],
 type=[
  inst:Type,
  inst:_Type,
  lit:String]
*/
typeLiteralRef() => typeLiteralField;

/*member: instantiationRef:
 static=[
  closureFunctionType(1),
  id,
  instantiate1(1),
  instantiatedGenericFunctionType(2)],
 type=[inst:Instantiation1<dynamic>]
*/
instantiationRef() => instantiationField;

/*member: topLevelTearOffRef:static=[topLevelMethod]*/
topLevelTearOffRef() => topLevelTearOffField;

/*member: staticTearOffRef:static=[Class.staticMethodField]*/
staticTearOffRef() => staticTearOffField;

/*member: nullLiteralDeferred:type=[inst:JSNull]*/
nullLiteralDeferred() => defer.nullLiteralField;

/*member: boolLiteralDeferred:type=[inst:JSBool]*/
boolLiteralDeferred() => defer.boolLiteralField;

/*member: intLiteralDeferred:type=[
  inst:JSInt,
  inst:JSNumNotInt,
  inst:JSNumber,
  inst:JSPositiveInt,
  inst:JSUInt31,
  inst:JSUInt32]*/
intLiteralDeferred() => defer.intLiteralField;

/*member: doubleLiteralDeferred:type=[
  inst:JSInt,
  inst:JSNumNotInt,
  inst:JSNumber,
  inst:JSPositiveInt,
  inst:JSUInt31,
  inst:JSUInt32]*/
doubleLiteralDeferred() => defer.doubleLiteralField;

/*member: stringLiteralDeferred:type=[inst:JSString]*/
stringLiteralDeferred() => defer.stringLiteralField;

// TODO(johnniwinther): Should we record that this is deferred?
/*member: symbolLiteralDeferred:
 static=[Symbol.(1)],
 type=[inst:Symbol]
*/
symbolLiteralDeferred() => defer.symbolLiteralField;

// TODO(johnniwinther): Should we record that this is deferred?
/*member: listLiteralDeferred:type=[
  inst:JSBool,
  inst:List<bool>]*/
listLiteralDeferred() => defer.listLiteralField;

// TODO(johnniwinther): Should we record that this is deferred?
/*member: mapLiteralDeferred:type=[
  inst:ConstantMap<dynamic,dynamic>,
  inst:ConstantStringMap<dynamic,dynamic>,
  inst:GeneralConstantMap<dynamic,dynamic>,
  inst:JSBool]*/
mapLiteralDeferred() => defer.mapLiteralField;

// TODO(johnniwinther): Should we record that this is deferred?
/*member: stringMapLiteralDeferred:type=[
  inst:ConstantMap<dynamic,dynamic>,
  inst:ConstantStringMap<dynamic,dynamic>,
  inst:GeneralConstantMap<dynamic,dynamic>,
  inst:JSBool,
  inst:JSString]*/
stringMapLiteralDeferred() => defer.stringMapLiteralField;

// TODO(johnniwinther): Should we record that this is deferred?
/*member: setLiteralDeferred:type=[
  inst:ConstantStringSet<dynamic>,
  inst:GeneralConstantSet<dynamic>,
  inst:JSBool]*/
setLiteralDeferred() => defer.setLiteralField;

/*member: instanceConstantDeferred:
 static=[
  Class.field2=BoolConstant(false),
  SuperClass.field1=BoolConstant(true)],
 type=[
  const:Class{defer},
  inst:JSBool]
*/
instanceConstantDeferred() => defer.instanceConstantField;

/*member: typeLiteralDeferred:
 static=[
  createRuntimeType(1),
  typeLiteral(1)],
 type=[
  inst:Type,
  inst:_Type,
  lit:String{defer}]
*/
typeLiteralDeferred() => defer.typeLiteralField;

/*member: instantiationDeferred:
 static=[
  closureFunctionType(1),
  id{defer},
  instantiate1(1),
  instantiatedGenericFunctionType(2)],
 type=[inst:Instantiation1<dynamic>]
*/
instantiationDeferred() => defer.instantiationField;

/*member: topLevelTearOffDeferred:static=[topLevelMethod{defer}]*/
topLevelTearOffDeferred() => defer.topLevelTearOffField;

/*member: staticTearOffDeferred:static=[Class.staticMethodField{defer}]*/
staticTearOffDeferred() => defer.staticTearOffField;
