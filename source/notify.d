import twitter4d;
import std.algorithm,
       std.datetime,
       std.net.curl,
       std.process,
       std.string,
       std.stdio,
       std.regex,
       std.array,
       std.file,
       std.json,
       std.conv;
import util;

class Status{
  mixin Util;
  string kind;//event or status
  string text,
         in_reply_to_status_id,
         profile_image_url_https;
  string event;
  bool _protected;
  string[string] user;
  string[string] target_object;
  string[string] source;
  string[string] target;

  this(JSONValue json){
    user = ["name"        : "",
            "screen_name" : "",
            "id_str"      : ""];
    source = user.dup;
    target = user.dup;
    target_object = user.dup;
    target_object["text"] = "";

    if("event" in json.object){
      kind  = "event";
      event  = getJsonData(json, "event");

      foreach(key; source.keys)
        source[key] = key in json.object["source"].object ? json.object["source"].object[key].str : "null";
      foreach(key; target.keys)
        target[key] = key in json.object["target"].object ? json.object["target"].object[key].str : "null";
      foreach(key; target_object.keys)
        target_object[key] = key in json.object["target_object"].object ? json.object["target_object"].object[key].str : "null";
      profile_image_url_https = getJsonData(json.object["source"], "profile_image_url_https").replace(regex(r"\\", "g"), "");
    } else if("text" in json.object){
      kind = "status";
      foreach(key; user.keys)
        user[key] = key in json.object["user"].object ? json.object["user"].object[key].str : "null";
      in_reply_to_status_id = getJsonData(json, "id_str");
      text                  = json.object["text"].str;
      _protected            = getJsonData(json.object["user"], "protected").to!bool;
      profile_image_url_https = getJsonData(json.object["user"], "profile_image_url_https").replace(regex(r"\\", "g"), "");
    }
  }

  bool isReply(string botID){
    return text.match(regex(r"^@" ~ botID)).empty ? false: true;
  }
}

class NotifyItem{
  mixin Util;

  bool notifyFlag;
  string[string] item;
  private{
    string defaultTime = "1500";  
    string userName;
    string iconBasePath;
  }

  this(Status status, string _userName){
    iconBasePath = getcwd() ~ "/icons";
    userName     = _userName;

    if("event" == status.kind)
      processEvent(status);
    else if("status" == status.kind)
      processTweet(status);
  }

  private{
    void processTweet(Status status){
      string textData = status.text;
      if(match(textData, regex(r"@" ~ userName))){
        string name       = status.user["name"];
        string screenName = status.user["screen_name"];

        if(match(textData, regex(r"^RT @" ~ userName))){
          item["event"]   = "retweet";
          item["icon"]    = status.profile_image_url_https;
          item["urgency"] = "normal";
          item["wait"]    = defaultTime;
          item["title"]   = name ~ "(@" ~ screenName ~ ") retweet your tweet!";
          item["body"]    = status.text.replace(regex(r"^ RT @" ~ screenName ~ r": \s"), "");
        } else {
          item["event"]   = "reply";
          item["icon"]    = status.profile_image_url_https;
          item["urgency"] = "critical";
          item["wait"]    = defaultTime;
          item["title"]   = "Reply From " ~ name ~ "(@" ~ screenName ~ ")";
          item["body"]    = textData;
        }
        notifyFlag = true;
      }
    }

    void processEvent(Status status){
      string eventName     = status.event;
      string name          = status.source["name"];
      string screenName    = status.source["screen_name"];

      switch(eventName){
        case "favorite":
          if(screenName == userName)
            goto default;
          item["event"]   = eventName;
          item["icon"]    = getIconPath(status);
          item["urgency"] = "normal";
          item["wait"]    = defaultTime;
          item["title"]   = name ~ "(@" ~ screenName ~ ") favorite your tweet!";
          item["body"]    = status.target_object["text"];
          notifyFlag = true;
          break;
        case "unfavorite":
          if(screenName == userName)
            goto default;
          item["event"]   = eventName;
          item["icon"]    = getIconPath(status);
          item["urgency"] = "critical";
          item["wait"]    = defaultTime;
          item["title"]   = name ~ "(@" ~ screenName ~ ") unfavorite your tweet";
          item["body"]    = status.target_object["text"];
          notifyFlag = true;
          break;
        case "follow":
          if(screenName == userName)
            goto default;
          item["event"]   = eventName;
          item["icon"]    = getIconPath(status);
          item["urgency"] = "normal";
          item["wait"]    = defaultTime;
          item["title"]   = "<span size=\"10500\">" ~ name ~ "(@" ~ screenName ~ ") follow you!" ~ "</span>";
          item["body"]    = "";
          notifyFlag = true;
          break;
        default: break;
      }
    }

    string getIconPath(Status status){
      string iconUrl = status.profile_image_url_https;
      string iconPath;
      string screenName;

      if(status.kind == "event")
        screenName = status.source["screen_name"];
      else
        screenName = status.user["screen_name"];

      if(saveIconImage(iconUrl, screenName))
        iconPath = iconBasePath ~ "/" ~ screenName ~ ".jpeg";
      else
        iconPath = "NULL";

      return iconPath;
    }

    bool saveIconImage(string iconUrl, string screenName){
      string iconPath = iconBasePath ~ "/" ~ screenName ~ ".jpeg";
      
      if(!exists(iconPath))
        download(iconUrl, iconPath);

      return true;
    }
  }
}

class Notify{
  mixin Util;
  private{
    Twitter4D t4d;
    string userName;
  }

  this(Twitter4D twitter4dInstance){
    t4d = twitter4dInstance;
    userName = getJsonData(parseJSON(t4d.request("GET", "account/verify_credentials.json", ["" : ""])), "screen_name");
  }

  void notify(JSONValue parsed){
    Status thisStatus = new Status(parsed);
    NotifyItem item   = new NotifyItem(thisStatus, userName);
    if(item.notifyFlag)
      execNotification(item);
  }

  private{
    void execNotification(NotifyItem nItem){
      writeln("[EVENT] => ", nItem.item["event"]);
      string notifyCommandString;
      version(OSX){
        notifyCommandString = "terminal-notifier ";

        if(nItem.item["icon"] != "NULL")
          notifyCommandString ~= "-appIcon " ~ nItem.item["icon"] ~ " ";
        notifyCommandString ~= "-title "   ~ "\'" ~ nItem.item["title"] ~ "\' ";
        notifyCommandString ~= "-message " ~ "\'" ~ nItem.item["body"]  ~ "\'";
      }
      version(linux){
        notifyCommandString = "notify-send ";

        if(nItem.item["icon"] != "NULL")
          notifyCommandString ~= "-i " ~ nItem.item["icon"] ~ " ";
        notifyCommandString ~= "-u " ~ nItem.item["urgency"] ~ " ";
        notifyCommandString ~= "-t " ~ nItem.item["wait"]    ~ " ";
        notifyCommandString ~= "\'"  ~ nItem.item["title"]   ~ "\'" ~ " ";
        notifyCommandString ~= "\'"  ~ nItem.item["body"]    ~ "\'";
      }
      system(notifyCommandString);
    }
  }
}

