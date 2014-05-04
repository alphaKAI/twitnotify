/*
  TwitNotify

  The Twitter Notification tool.
  Copyright (C) 2014 alphaKAI http://alpha-kai-net.info

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

class TwitNotify{
  Twitter4D t4d;
  string iconBasePath;
  string userName;

  this(){
    string jsonString = readSettingFile();
    auto parsed       = parseJSON(jsonString);
    iconBasePath      = getcwd() ~ "/icons";
    
    t4d = new Twitter4D([
        "consumerKey"       : getJsonData(parsed, "consumerKey"),
        "consumerSecret"    : getJsonData(parsed, "consumerSecret"),
        "accessToken"       : getJsonData(parsed, "accessToken"),
        "accessTokenSecret" : getJsonData(parsed, "accessTokenSecret")]);

    userName = getJsonData(parseJSON(t4d.request("GET", "account/verify_credentials.json", ["" : ""])), "screen_name");
  }

  void startWatchingService(){
    foreach(line; t4d.stream()){
      if(match(line.to!string, regex(r"\{.*\}"))){
       auto parsed = parseJSON(line.to!string);
        if("event" in parsed.object)
          execNotification(parseEvent(parsed));
        if("text" in parsed.object){//For retweet notify
          //超やっつけの絵文字対策()
          //If target tweet include pictograph, this program skip such tweet to avoid crash.
          if(match(line.to!string, regex(r"ud")))
            continue;

          string textData = getJsonData(parsed, "text");
          if(match(textData, regex(r"@" ~ userName))){//For Reply
            JSONValue userJson     = parsed.object["user"];
            string name            = getJsonData(userJson, "name");
            string screenName      = getJsonData(userJson, "screen_name");
            string[string] message;

            if(match(textData, regex(r"^RT @" ~ userName))){
              message["event"]   = "retweet";
              message["icon"]    = getIconPath(userJson);
              message["urgency"] = "normal";
              message["title"]   = name ~ "(@" ~ screenName ~ ") retweet your tweet!";
              message["body"]    = getJsonData(parsed, "text").replace(regex(r"^ RT @" ~ screenName ~ r": \s"), "");
            } else {
              message["event"]   = "reply";
              message["icon"]    = getIconPath(userJson);
              message["urgency"] = "critical";
              message["title"]   = "Reply From " ~ name ~ "(@" ~ screenName ~ ")";
              message["body"]    = textData;
            }

            execNotification(message);
          }
        }
      }
    }
  }

  private{
    string readSettingFile(){
      if(!exists("setting.json"))
        throw new Error("Please create file of setting.json and configure your consumer & access tokens");
      auto file = File("setting.json", "r");
      string buf;
      foreach(line; file.byLine){
        buf = buf ~ cast(string)line;
      }
      return buf;
    }

    string getJsonData(JSONValue parsedJson, string key){
      return parsedJson.object[key].to!string.replace(regex("\"", "g") ,"");
    }

    string[string] parseEvent(JSONValue parsedJson){
      string eventName       = getJsonData(parsedJson, "event");
      JSONValue targetJson   = parsedJson.object["target"];
      JSONValue sourceJson   = parsedJson.object["source"];
      string name            = getJsonData(sourceJson, "name");
      string screenName      = getJsonData(sourceJson, "screen_name");
      string[string] message = ["" : ""];

      switch(eventName){      
        case "favorite":
          if(screenName == userName)
            goto default;
          message["event"]   = eventName;
          message["icon"]    = getIconPath(sourceJson);
          message["urgency"] = "normal";
          message["title"]   = name ~ "(@" ~ screenName ~ ") favorite your tweet!";
          message["body"]    = getJsonData(parsedJson.object["target_object"], "text");
          break;
        case "unfavorite":
         if(screenName == userName)
            goto default;
          message["event"]   = eventName;
          message["icon"]    = getIconPath(sourceJson);
          message["urgency"] = "critical";
          message["title"]   = name ~ "(@" ~ screenName ~ ") unfavorite your tweet";
          message["body"]    = getJsonData(parsedJson.object["target_object"], "text");
          break;
        case "follow":
         if(screenName == userName)
            goto default;
          message["event"]   = eventName;
          message["icon"]    = getIconPath(sourceJson);
          message["urgency"] = "normal";
          message["title"]   = "<span size=\"10500\">" ~ name ~ "(@" ~ screenName ~ ") follow you!" ~ "</span>";
          message["body"]    = "";
          break;
        default:
          break;
      }

      return message;
    }

    string getIconPath(JSONValue sourceJson){
      string iconUrl       = getJsonData(sourceJson, "profile_image_url_https").replace(regex(r"\\", "g"), "");
      string screenName    = getJsonData(sourceJson, "screen_name");
      string iconPath;

      if(saveIconImage(iconUrl, screenName))
        iconPath = iconBasePath ~ "/" ~ screenName ~ ".jpeg";
      else
        iconPath = "NULL";
        
      return iconPath;
    }


    bool saveIconImage(string iconUrl, string screenName){
      string iconPath = iconBasePath ~ "/" ~ screenName ~ ".jpeg";
      writeln(iconUrl);
      download(iconUrl, iconPath);
      if(!exists(iconPath))
        return false;
      return true;
    }

    void execNotification(string[string] sendMessage){
      if(sendMessage == ["" : ""])
        return;
      writeln("[EVENT] => ", sendMessage["event"]);
      string notifyCommandString = "notify-send ";
      if(sendMessage["icon"] != "NULL")
        notifyCommandString ~= "-i " ~ sendMessage["icon"] ~ " ";
      
      notifyCommandString ~= "-u " ~ sendMessage["urgency"] ~ " ";
      notifyCommandString ~= "\'" ~ sendMessage["title"] ~ "\'" ~ " ";
      notifyCommandString ~= "\'" ~ sendMessage["body"] ~ "\'";
      
      system(notifyCommandString);
    }
  }
}

void main(){
  TwitNotify tn = new TwitNotify();
  tn.startWatchingService();
}
