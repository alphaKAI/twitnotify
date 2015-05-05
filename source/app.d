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
import core.sys.posix.pwd;
import core.sys.posix.unistd;
import core.thread;
import twitnotify.notify,
       twitnotify.util;

class TNUser{
  string         name;
  string[string] authKeys;
  Twitter4D      t4d;
  Notify         notify;

  this(string _name, string[string] argHash){
    name = _name;
    this(argHash);
  }

  this(string[string] argHash){
    authKeys = argHash;
    t4d = new Twitter4D(authKeys);
    notify = new Notify(t4d);
  }
}

class TwitNotify{
  mixin Util;
  Twitter4D t4d;
  TNUser[string] tnUsers;
  bool multiAccount;

  this(){
    string jsonString = readSettingFile();
    auto parsed       = parseJSON(jsonString);
    
    if("accounts" in parsed.object){
      multiAccount = true;
      foreach(key; parsed.object["accounts"].object.keys)
        tnUsers[key] = new TNUser(key, buildAuthHash(parsed.object["accounts"].object[key]));
    }

    if(multiAccount){
      writeln("Boot as multiUser Mode");
      writeln("accounts");
      foreach(user; tnUsers)
        writeln(" - ", user.name);
    } else{
      writeln("Boot as singleUser Mode");
      tnUsers["single"] = new TNUser(buildAuthHash(parsed));
    }
  }

  void startWatchingService(){
    foreach(user; tnUsers){
      new Thread((){
        bool firstTime = true;
        foreach(status; user.t4d.stream())
          if(firstTime && status.to!string.match(regex(r"\{.*\}"))
              && status.to!string.match(regex(r"friends")))
            firstTime = false;
         else if(status.to!string.match(regex(r"\{.*\}")))
            user.notify.notify(parseJSON(status.to!string));
      }).start;
    }
  }

  private{
    string[string] buildAuthHash(JSONValue parsed){
        return ["consumerKey"       : getJsonData(parsed, "consumerKey"),
                "consumerSecret"    : getJsonData(parsed, "consumerSecret"),
                "accessToken"       : getJsonData(parsed, "accessToken"),
                "accessTokenSecret" : getJsonData(parsed, "accessTokenSecret")];
    }

    string readSettingFile(){
      string settingFilePath = "setting.json";
      if(!exists(settingFilePath)){
        string userName = getpwuid(geteuid).pw_name.to!string;
        bool errorFlag;
        
        version(OSX){
          if(exists("/Users/" ~ userName ~ "/.myscripts/twitterConf/" ~ settingFilePath))
            settingFilePath = "/Users/" ~ userName ~ "/.myscripts/twitterConf/" ~ settingFilePath;
          else
            errorFlag = true;
        }
        
        version(linux){
          if(exists("/home/" ~ userName ~ "/.myscripts/twitterConf/" ~ settingFilePath))
            settingFilePath = "/home/" ~ userName ~ "/.myscripts/twitterConf/" ~ settingFilePath;
          else
            errorFlag = true;
        }
        
        if(errorFlag)
          throw new Error("Please create file of setting.json and configure your consumer & access tokens");
      }

      return readFile(settingFilePath);
    }
  }
}

void main(){
  TwitNotify tn = new TwitNotify();
  tn.startWatchingService();
}
