module twitnotify.notify;
import twitter4d;
import std.algorithm,
       std.process,
       std.stdio,
       std.regex,
       std.json,
       std.conv;
import twitnotify.notifyItem,
       twitnotify.status,
       twitnotify.util;

class Notify{
  mixin Util;
  private{
    Twitter4D t4d;
    string userName;
  }

  this(Twitter4D twitter4dInstance){
    t4d = twitter4dInstance;
    userName = getJsonData(parseJSON(t4d.request("GET", "account/verify_credentials.json")), "screen_name");
  }

  void notify(JSONValue parsed){
    Status thisStatus = new Status(parsed);
    NotifyItem item   = new NotifyItem(thisStatus, userName);
    if(item.notifyFlag)
      execNotification(item);
  }

  private{
    void setParameter(ref string baseString, string key, string child){
      baseString ~= "-" ~ key ~ " " ~ child ~ " ";
    }

    void execNotification(NotifyItem nItem){
      writeln("\r[EVENT] => ", nItem.item["event"]);
      string notifyCommandString;
      version(OSX){
        notifyCommandString = "terminal-notifier ";

        if(nItem.item["icon"] != "NULL")
          setParameter(notifyCommandString, "appIcon", nItem.item["icon"]);
        setParameter(notifyCommandString, "title", "\'" ~ nItem.item["title"] ~ "\'");
        setParameter(notifyCommandString, "message",  "\'" ~ nItem.item["body"]  ~ "\'");
        setParameter(notifyCommandString, "open", nItem.item["url"]);
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

      executeShell(notifyCommandString);
    }
  }
}

