//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window

input color   BidColor  = Red; // Bid color
input color   AskColor  = Green; // Ask color
input int     LineStyle  = 0;
input int     LineLength = 5;
input bool    ShowAsk    = false;
input bool    ShowBid    = true;
input int     TextSize   = 2;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

//+------------------------------------------------------------------+
int init()  {
//+------------------------------------------------------------------+
   IndicatorName = GenerateIndicatorName("Bid Ask Line");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   del_obj();
   return(0);
}

//+------------------------------------------------------------------+
int deinit()  {
//+------------------------------------------------------------------+
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   del_obj();
   return(0);
}

//+------------------------------------------------------------------+
int start()  {
//+------------------------------------------------------------------+
   double bidp = Bid;
   double askp = Ask;
   del_obj();
   ObjectCreate(IndicatorObjPrefix+"-Ask",OBJ_TREND,0,Time[0],askp,Time[0]+LineLength*60*Period(),askp);
   ObjectSet(IndicatorObjPrefix+"-Ask",OBJPROP_COLOR,AskColor);
   ObjectSet(IndicatorObjPrefix+"-Ask",OBJPROP_STYLE,LineStyle);
   ObjectSet(IndicatorObjPrefix+"-Ask",OBJPROP_RAY,0);
   ObjectCreate(IndicatorObjPrefix+"-Bid",OBJ_TREND,0,Time[0],bidp,Time[0]+LineLength*60*Period(),bidp);
   ObjectSet(IndicatorObjPrefix+"-Bid",OBJPROP_COLOR,BidColor);
   ObjectSet(IndicatorObjPrefix+"-Bid",OBJPROP_STYLE,LineStyle);
   ObjectSet(IndicatorObjPrefix+"-Bid",OBJPROP_RAY,0);
   if (ShowAsk)
   {
      ObjectCreate(IndicatorObjPrefix+"-AskL",OBJ_ARROW,0,Time[0]+(LineLength+1)*60*Period(),askp);
      ObjectSet(IndicatorObjPrefix+"-AskL",OBJPROP_COLOR,AskColor);
      ObjectSet(IndicatorObjPrefix+"-AskL",OBJPROP_WIDTH,TextSize);
      ObjectSet(IndicatorObjPrefix+"-AskL",OBJPROP_ARROWCODE,6);
   }  
   if (ShowBid)
   {
      ObjectCreate(IndicatorObjPrefix+"-BidL",OBJ_ARROW,0,Time[0]+(LineLength+1)*60*Period(),bidp);
      ObjectSet(IndicatorObjPrefix+"-BidL",OBJPROP_COLOR,BidColor);
      ObjectSet(IndicatorObjPrefix+"-BidL",OBJPROP_WIDTH,TextSize);
      ObjectSet(IndicatorObjPrefix+"-BidL",OBJPROP_ARROWCODE,6);
   }  
   return(0);
}

//+------------------------------------------------------------------+
int del_obj()  {
//+------------------------------------------------------------------+
  ObjectDelete(IndicatorObjPrefix+"-Ask");
  ObjectDelete(IndicatorObjPrefix+"-Bid");
  if (ShowAsk)   ObjectDelete(IndicatorObjPrefix+"-AskL");
  if (ShowBid)   ObjectDelete(IndicatorObjPrefix+"-BidL");
  return(0);
}


