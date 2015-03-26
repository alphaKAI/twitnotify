mixin template Util(){
  string getJsonData(JSONValue parsedJson, string key){
    return parsedJson.object[key].to!string.replace(regex("\"", "g") ,"");
  }
}
