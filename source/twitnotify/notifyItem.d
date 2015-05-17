module twitnotify.notifyItem;
import std.net.curl,
       std.regex,
       std.json,
       std.conv,
       std.file;
import twitnotify.status,
       twitnotify.util;

class NotifyItem{
  mixin Util;

  bool notifyFlag;
  string[string] item;
  private{
    string defaultTime = "1500";  
    string userName;
    string iconBasePath;
    immutable twitterURL = "https://twitter.com/";
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
          item["url"]     = twitterURL ~  screenName ~ "/status/" ~ status.id_str;
        } else {
          item["event"]   = "reply";
          item["icon"]    = status.profile_image_url_https;
          item["urgency"] = "critical";
          item["wait"]    = defaultTime;
          item["title"]   = "Reply From " ~ name ~ "(@" ~ screenName ~ ")";
          item["body"]    = textData;
          item["url"]     = twitterURL ~ screenName ~ "/status/" ~ status.id_str;
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
          item["url"]     = twitterURL ~ screenName ~ "/status/" ~ status.id_str;
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
          item["url"]     = twitterURL ~ screenName ~ "/status/" ~ status.id_str;
          notifyFlag = true;
          break;
        case "follow":
          if(screenName == userName)
            goto default;
          item["event"]   = eventName;
          item["icon"]    = getIconPath(status);
          item["urgency"] = "normal";
          item["wait"]    = defaultTime;
          item["title"]   = name ~ "(@" ~ screenName ~ ") follow you!";
          item["body"]    = "New follower!";
          item["url"]     = twitterURL ~ screenName;
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
