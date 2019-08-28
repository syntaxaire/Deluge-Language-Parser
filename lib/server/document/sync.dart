import 'dart:async';

import 'package:DelugeDartParser/node.dart';
import 'package:DelugeDartParser/server/messaging/diagnostics.dart';
import 'package:DelugeDartParser/server/validation/validation.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'dart:io';
import 'package:DelugeDartParser/parser.dart';
import 'package:just_debounce_it/just_debounce_it.dart';
import 'package:petitparser/petitparser.dart';
import 'package:tuple/tuple.dart';
import '../messaging/message.dart';
import 'package:quiver/collection.dart';

//magic number 😏😏
const Duration updateTime = Duration(milliseconds: 250);
const int maxFiles = 10;

class Sync {
  static Peer _peer;
  static LinkedLruHashMap<Uri, List> openFiles = LinkedLruHashMap<Uri, List>(maximumSize: maxFiles);
  static LinkedLruHashMap<Uri, List> newLineTokens = LinkedLruHashMap<Uri, List>(maximumSize: maxFiles);
  static Map documentation = Map();

  //TODO: Make the debounce robust
  static parseFile(Uri uri, String data) {
    
    //String extraText = """\n a.get();""";
    //String fullText = data + extraText;
    var result = DelugeParser().parse(data);
    if(result.isSuccess) {
      openFiles[uri] = result.value;
      var validations = Validation.Validate(result.value, uri);
      Diagnostics.publishDiagnostics(uri, validations);
      newLineTokens[uri] = Token.newlineParser().token().matchesSkipping(data);
    }
    else {
      openFiles.remove(uri);
    }

    Diagnostics.publishParserStatus(result.isSuccess);


  
  }



  static register(Peer peer) {
    _peer = peer;

    _peer.registerMethod('textDocument/didOpen', onOpenDocument);
    _peer.registerMethod('textDocument/didChange', onChangeDocument);
    _peer.registerMethod('textDocument/didSave', onSaveDocument);
    _peer.registerMethod('textDocument/didClose', onCloseDocument);
  }

  static onOpenDocument(params) {
    var document = TextDocumentItem.fromJson(params['textDocument']);
    parseFile(document.uri, document.text);
  }

  static onChangeDocument(params) {
    var changeDoc =  DidChangeTextDocumentParams.fromJsonFull(params);
    Debounce.duration(updateTime, parseFile, [changeDoc.textDocumentIdentifier.uri,changeDoc.contentChanges.first.text]);
  
   }

  static onSaveDocument(params) {
    var doc = DidSaveTextDocumentParams.fromJson(params);
    Message.sendMessageNotif(MessageType.info, 'Saved doc');
  }

  static onCloseDocument(params) {
    var id = TextDocumentIdentifier.fromJson(params['textDocument']);
    openFiles.remove(id.uri);
    //Message.sendMessageNotif(MessageType.info, 'closed doc ${id.uri}');
  }
}



class DidSaveTextDocumentParams {
  TextDocumentIdentifier textDocument;
  String text;

  DidSaveTextDocumentParams.fromJson(params) {
    textDocument = TextDocumentIdentifier.fromJson(params['textDocument']);
    text = params['text'].asStringOr('');
  }
}

class TextDocumentIdentifier {
  Uri uri;
  TextDocumentIdentifier({this.uri});
  TextDocumentIdentifier.fromJson(params) : this(uri: params['uri'].asUri);
  
  Map toJson() => {'uri': uri};
}

class DidChangeTextDocumentParams {
  VersionedTextDocumentIdentifier textDocument;
  List<TextDocumentContentChangeEvent> contentChanges;
  TextDocumentIdentifier textDocumentIdentifier;

  //TODO: wont work, generate error
  DidChangeTextDocumentParams.fromJson(params) {
    textDocument =
        VersionedTextDocumentIdentifier.fromJson(params['textDocument']);
    var contentList = params['contentChanges'].asList;
    contentChanges = List.generate(
        contentList.length, (_) => TextDocumentContentChangeEvent.fromJson(_));
  }

  DidChangeTextDocumentParams.fromJsonFull(params) {
    this.textDocumentIdentifier =
        TextDocumentIdentifier.fromJson(params['textDocument']);
    var contentList = params['contentChanges'].asList;
    this.contentChanges = [ TextDocumentContentChangeEvent.fromJson(contentList[0]) ];
  }
}

class VersionedTextDocumentIdentifier {
  int version;

  VersionedTextDocumentIdentifier.fromJson(params) {
    version = params['version'].asInt;
  }
}

class TextDocumentContentChangeEvent {
  Range range;
  int rangeLength; //optional
  String text;

  TextDocumentContentChangeEvent.fromJson(params) {
    //range = Range.fromJson(params['range'].asIntOr(-1));
    //rangeLength = params['rangeLength'].asIntOr(-1);
    text = params['text'];
    //stderr.write(text);
  }
}

class DidOpenTextDocumentParams {
  TextDocumentItem textDocument;
}

class TextDocumentItem {
  Uri uri;
  String languageId;
  int version;
  String text;

  TextDocumentItem.fromJson(params) {
    uri = params['uri'].asUri;
    languageId = params['languageId'].asString;
    version = params['version'].asInt;
    text = params['text'].asString;
  }
}

class TextEdit {
  Range range;
  String newText;
}

class Position {
  int line;
  int character;
  Position({this.line, this.character});

  Position.fromJson(params) {
    line = params['line'].asInt;
    character = params['character'].asInt;
  }

  Map toJson() => {'line': line, 'character': character};
}

class Range {
  Position start;
  Position end;
  Range({this.start, this.end});

  Range.fromJson(params) {
    start = Position.fromJson(params['start']);
    end = Position.fromJson(params['end']);
  }

  Map toJson() => {
        'start': start.toJson(),
        'end': end.toJson(),
      };
}
