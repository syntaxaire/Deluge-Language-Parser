import 'package:DelugeDartParser/node.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:DelugeDartParser/parser.dart';

void main() {
  
  DelugeParserDefinition dg = DelugeParserDefinition();


  group('literal', () {
    
    test('BigInt', () {
      
      var parser = dg.build(start: dg.bigintLiteral);
      var result = parser.parse('1');

      expect(true, result.isSuccess);
      expect(1, (result.value as BigIntLiteral).value);

    });

    test('Decimal', () {
      
      var parser = dg.build(start: dg.decimalLiteral);
      var result = parser.parse('1.2');

      expect(true, result.isSuccess);
      expect(1.2, (result.value as DecimalLiteral).value);
    });


    test('mix decimal + int', (){

      var parser = dg.build(start: dg.arithmeticExpression);
      var result = parser.parse('1.2');

      expect(true, result.isSuccess);
      expect(1.2, (result.value as DecimalLiteral).value);
    });

    test('boolean', () {

      var parser = dg.build(start: dg.booleanLiteral);
      var result = parser.parse('true');

      expect(true, result.isSuccess);
      expect(true, (result.value as BooleanLiteral).value);
    });

    test('string', () {
      
      var parser = dg.build(start: dg.stringLiteral);
      var result = parser.parse('"Hello"');

      expect(true, result.isSuccess);
      expect('"Hello"', (result.value as StringLiteral).value);
    }, skip: 'TODO: yet to decide on string parser output');

  });

  group('arithmetic', () {
    var parser;
    setUp(() {
      parser = dg.build(start: dg.arithmeticExpression);
    });

    test('addition', () {
      var result = parser.parse('1+2');
      var exp = result.value as BinaryExpression;
      expect(BigIntLiteral, exp.left.runtimeType);
      expect('+', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType);
      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('addition-poly', () {
      var result = parser.parse('1+2+3+4');
      var exp = result.value as BinaryExpression;
      var left = exp.left as BinaryExpression;
      expect(BinaryExpression, exp.left.runtimeType);

      var left2 = left.left as BinaryExpression;
      expect(BigIntLiteral, left2.left.runtimeType); //1
      expect('+', left2.oopertor);
      expect(BigIntLiteral, left2.right.runtimeType); //2

      expect('+', left.oopertor);
      expect(BigIntLiteral, left.right.runtimeType); //3

      expect('+', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType); //4

      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('substraction', () {
      var result = parser.parse('1-2');
      var exp = result.value as BinaryExpression;
      expect(BigIntLiteral, exp.left.runtimeType);
      expect('-', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType);
      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('substraction-poly', () {
      var result = parser.parse('1+2-3+4');
      var exp = result.value as BinaryExpression;
      var left = exp.left as BinaryExpression;
      expect(BinaryExpression, exp.left.runtimeType);

      var left2 = left.left as BinaryExpression;
      expect(BigIntLiteral, left2.left.runtimeType); //1
      expect('+', left2.oopertor);
      expect(BigIntLiteral, left2.right.runtimeType); //2

      expect('-', left.oopertor);
      expect(BigIntLiteral, left.right.runtimeType); //3

      expect('+', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType); //4

      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('multiplication', () {
      var result = parser.parse('1*2');
      var exp = result.value as BinaryExpression;
      expect(BigIntLiteral, exp.left.runtimeType);
      expect('*', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType);
      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('multiplication-poly', () {
      var result = parser.parse('1+2*3-4');
      var exp = result.value as BinaryExpression;
      var left = exp.left as BinaryExpression;
      expect(BinaryExpression, exp.left.runtimeType);

      var left2 = left.left as BinaryExpression;
      expect(BigIntLiteral, left2.left.runtimeType); //1
      expect('+', left2.oopertor);
      expect(BigIntLiteral, left2.right.runtimeType); //2

      expect('*', left.oopertor);
      expect(BigIntLiteral, left.right.runtimeType); //3

      expect('-', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType); //4

      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('division', () {
      var result = parser.parse('1/2');
      var exp = result.value as BinaryExpression;
      expect(BigIntLiteral, exp.left.runtimeType);
      expect('/', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType);
      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('division-poly', () {
      var result = parser.parse('1+2/3-4');
      var exp = result.value as BinaryExpression;
      var left = exp.left as BinaryExpression;
      expect(BinaryExpression, exp.left.runtimeType);

      var left2 = left.left as BinaryExpression;
      expect(BigIntLiteral, left2.left.runtimeType); //1
      expect('+', left2.oopertor);
      expect(BigIntLiteral, left2.right.runtimeType); //2

      expect('/', left.oopertor);
      expect(BigIntLiteral, left.right.runtimeType); //3

      expect('-', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType); //4

      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('mod', () {
      var result = parser.parse('1%2');
      var exp = result.value as BinaryExpression;
      expect(BigIntLiteral, exp.left.runtimeType);
      expect('%', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType);
      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('mod-poly', () {
      var result = parser.parse('1%2/3-4');
      var exp = result.value as BinaryExpression;
      var left = exp.left as BinaryExpression;
      expect(BinaryExpression, exp.left.runtimeType);

      var left2 = left.left as BinaryExpression;
      expect(BigIntLiteral, left2.left.runtimeType); //1
      expect('%', left2.oopertor);
      expect(BigIntLiteral, left2.right.runtimeType); //2

      expect('/', left.oopertor);
      expect(BigIntLiteral, left.right.runtimeType); //3

      expect('-', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType); //4

      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });
    
    test('braces', () {
      var result = parser.parse('(1%2)');
      var exp = result.value as BinaryExpression;
      expect(BigIntLiteral, exp.left.runtimeType);
      expect('%', exp.oopertor);
      expect(BigIntLiteral, exp.right.runtimeType);
  
      expect(true, exp.extra['parentise'], reason: 'Checks whether parentise are in the tree');
      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

    test('braces-complex', () {
      var result = parser.parse('(1+2)/(3-4)%(5*6)');
      var exp = result.value as BinaryExpression;

      expect(BinaryExpression, exp.left.runtimeType);  // (1+2)/(3-4)
      expect('%', exp.oopertor);
      expect(BinaryExpression, exp.right.runtimeType); // (5+6)

      var left = exp.left as BinaryExpression;
      expect(BinaryExpression, left.left.runtimeType);
      expect('/', left.oopertor);
      expect(BinaryExpression, left.right.runtimeType);

      var leftLeft = left.left as BinaryExpression;
      expect(BigIntLiteral, leftLeft.left.runtimeType);  //1
      expect(1, (leftLeft.left as BigIntLiteral).value); 
      expect('+', leftLeft.oopertor);
      expect(BigIntLiteral, leftLeft.right.runtimeType); //2
      expect(2, (leftLeft.right as BigIntLiteral).value); 
      expect(true, leftLeft.extra['parentise'], reason: 'Checks whether parentise are in the tree');

      var leftRight = left.right as BinaryExpression;
      expect(BigIntLiteral, leftRight.left.runtimeType); //3
      expect(3, (leftRight.left as BigIntLiteral).value);
      expect('-', leftRight.oopertor);
      expect(BigIntLiteral, leftRight.right.runtimeType); //4
      expect(4, (leftRight.right as BigIntLiteral).value);
      expect(true, leftRight.extra['parentise'], reason: 'Checks whether parentise are in the tree');

      var right = exp.right as BinaryExpression;
      expect(BigIntLiteral, right.left.runtimeType); //5
      expect(5, (right.left as BigIntLiteral).value);
      expect('*', right.oopertor);
      expect(BigIntLiteral, right.right.runtimeType); //6
      expect(6, (right.right as BigIntLiteral).value);
      expect(true, right.extra['parentise'], reason: 'Checks whether parentise are in the tree');

      print('${exp.left}  ${exp.oopertor} ${exp.right}');
    });

  });

  group("call expression", (){

    Parser parser;
    setUp((){
      parser = dg.build(start: dg.callExpression);
    });

    test("normal", (){
      var result = parser.parse("map()");

      var callExp = result.value as CallExpression;
      expect(CallExpression, callExp.runtimeType);
      expect(Identifier, callExp.callee.runtimeType);
      expect('map', (callExp.callee as Identifier).name);

    });

    test("Int params", (){
      var result = parser.parse('map(1,2,3)');

      var callExp = result.value as CallExpression;
      expect(CallExpression, callExp.runtimeType);
      expect(Identifier, callExp.callee.runtimeType);
      expect('map', (callExp.callee as Identifier).name);

      expect(BigIntLiteral, callExp.arguments[0].runtimeType);  //type
      expect(1, (callExp.arguments[0] as BigIntLiteral).value); //1

      expect(BigIntLiteral, callExp.arguments[0].runtimeType);  //type
      expect(2, (callExp.arguments[1] as BigIntLiteral).value); //2
      
      expect(BigIntLiteral, callExp.arguments[0].runtimeType);  //type
      expect(3, (callExp.arguments[2] as BigIntLiteral).value); //3

    });

     test("all params", (){
      var result = parser.parse('map(1, 1.1, "hello", true)'); //  toString())');

      var callExp = result.value as CallExpression;
      expect(CallExpression, callExp.runtimeType);
      expect(Identifier, callExp.callee.runtimeType);
      expect('map', (callExp.callee as Identifier).name);

      expect(BigIntLiteral, callExp.arguments[0].runtimeType);  //type
      expect(1, (callExp.arguments[0] as BigIntLiteral).value); //1

      expect(DecimalLiteral, callExp.arguments[1].runtimeType);  //type
      expect(1.1, (callExp.arguments[1] as DecimalLiteral).value); //1.1
      
      expect(StringLiteral, callExp.arguments[2].runtimeType);  //type
      expect('hello'.split(''), (callExp.arguments[2] as StringLiteral).value); //hello

      expect(BooleanLiteral, callExp.arguments[3].runtimeType);  //type
      expect(true, (callExp.arguments[3] as BooleanLiteral).value); //true

      // expect(CallExpression, callExp.arguments[4].runtimeType);  //type
      // expect('toString', ((callExp.arguments[4] as CallExpression).callee as Identifier).name); //toString

    });

    test('nested call in call expression', () {
      
      var result = parser.parse('map(toString())');

      expect(true, false);
      expect(CallExpression, result.value.runtimeType);

    }, skip: "TODO: params testing");

    test('call+member', (){

      var result = parser.parse('a.b(1,2,3)');

      expect(CallExpression, result.value.runtimeType);
      var exp = (result.value as CallExpression).callee;
      expect(MemberExpression, exp.runtimeType);
      var mem = exp as MemberExpression;
      expect('a', (mem.object as Identifier).name);
      expect('b', (mem.propery as Identifier).name);
      
    });

  });

  group('member expression', (){

    Parser parser;
    setUp((){
      parser = dg.build(start: dg.memberExpression);
    });

    test('normal', () {
      var result = parser.parse('hello.length');
      var exp = result.value as MemberExpression;

      expect(MemberExpression, result.value.runtimeType);
      expect('hello', (exp.object as Identifier).name);
      expect('length', (exp.propery as Identifier).name);
    });


  });
}