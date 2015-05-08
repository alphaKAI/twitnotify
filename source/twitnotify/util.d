module twitnotify.util;

mixin template Util(){
  string getJsonData(JSONValue parsedJson, string key){
    return parsedJson.object[key].to!string.replace(regex("\"", "g") ,"");
  }

  string readFile(string filePath){
    import std.stdio;
    auto file = File(filePath, "r");
    string buf;

    foreach(line; file.byLine)
      buf = buf ~ cast(string)line;      
    return buf;
  }
}
