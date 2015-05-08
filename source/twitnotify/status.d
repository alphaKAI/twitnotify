module twitnotify.status;
import std.regex,
       std.json,
       std.conv;
import twitnotify.util;

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

      if("source" in json.object)
        foreach(key; source.keys)
          source[key] = key in json.object["source"].object ? json.object["source"].object[key].str : "null";
      if("target" in json.object)
        foreach(key; target.keys)
          target[key] = key in json.object["target"].object ? json.object["target"].object[key].str : "null";
      if("target_object" in json.object)
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

