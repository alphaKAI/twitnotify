import std.process,
       std.stdio,
       std.file;

void main(){
  writeln("TwitNotify Build Script");
  writeln("Copyright (C) 2014 - 2015 alphaKAI http://alpha-kai-net.info");
  writeln("The MIT License");

  if(!exists("setting.json")){
    writeln("[PROCESS] => Create File \'setting.json\'");
    auto f = File("setting.json", "w");
    string fileLines[] = [
      "{",
        "  \"consumerKey\"       : \"Your Consumer Key\",",
        "  \"consumerSecret\"    : \"Your Consumer Secret\",",
        "  \"accessToken\"       : \"Your Access Token\",",
        "  \"accessTokenSecret\" : \"Your Access Token Secret\"",
      "}"];
    
    foreach(line; fileLines)
      f.writeln(line);

    writeln("Please configure your consumer & access tokens");
  }
  
  if(!exists("icons")){
    writeln("[PROCESS] => Make Directory \'icons\'");
    mkdir("icons");
  }

  writeln("[PROCESS] complete");
  writeln("Please type command:");
  writeln("  $ dub");
}
