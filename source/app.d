/*
  TwitNotify

  The Twitter Notification tool.
  Copyright (C) 2014 - 2015 alphaKAI http://alpha-kai-net.info

  The MIT License

  using : My Twitter API Wrapper Twitter4D(twitter4d.d)
    Twitter4D's Repository : https://github.com/alphaKAI/twitter4d
    Twitter4D's License    : The MIT License
*/
import twitter4d;
import std.net.curl,
       std.process,
       std.string,
       std.stdio,
       std.regex,
       std.file,
       std.conv,
       std.json;
import std.c.linux.linux;
import notify,
       util;

class TwitNotify{
  mixin Util;
  Twitter4D t4d;
  Notify    notify;

  this(){
    string jsonString = readSettingFile();
    auto parsed       = parseJSON(jsonString);
    
    t4d = new Twitter4D([
        "consumerKey"       : getJsonData(parsed, "consumerKey"),
        "consumerSecret"    : getJsonData(parsed, "consumerSecret"),
        "accessToken"       : getJsonData(parsed, "accessToken"),
        "accessTokenSecret" : getJsonData(parsed, "accessTokenSecret")]);
    notify = new Notify(t4d);
  }

  void startWatchingService(){
    bool firstTime = true;
    foreach(status; t4d.stream()){
      if(firstTime && status.to!string.match(regex(r"\{.*\}"))
          && status.to!string.match(regex(r"friends"))){
        firstTime = false;
      } else if(status.to!string.match(regex(r"\{.*\}"))){
        //writeln(parseJSON(status.to!string));
        notify.notify(parseJSON(status.to!string));
      }
    }
  }

  private{
      string readSettingFile(){
    string settingFilePath = "setting.json";
    if(!exists(settingFilePath))
      throw new Error("Please create file of setting.json and configure your consumer & access tokens");

    auto file = File(settingFilePath, "r");
    string buf;

    foreach(line; file.byLine)
      buf = buf ~ cast(string)line;      
      return buf;
    }
  }
}

void main(){
  TwitNotify tn = new TwitNotify();
  tn.startWatchingService();
}
