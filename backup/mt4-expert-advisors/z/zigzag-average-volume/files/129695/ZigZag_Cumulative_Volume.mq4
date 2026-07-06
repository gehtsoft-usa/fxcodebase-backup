// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67212

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict

#property indicator_chart_window
#property indicator_buffers 0

input int Depth = 12; // Depth
input int Deviation = 5; // Deviation
input int Backstep = 3; // Backstep
input int Period = 100; // Backstep
input int Length = 60;
input int bars_limit = 1000; // Bars limit
input color up_color = Green; // Up color
input color down_color = Red; // Down color
input color label_color = Gray; // Label color

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

int init()
{
   double temp = iCustom(NULL, 0, "ZigZag", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'ZigZag' indicator");
      return INIT_FAILED;
   }
   temp = iCustom(NULL, 0, "Cumulative_Volume v1.3", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Cumulative_Volume v1.3' indicator");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("ZigZag Volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

bool GetZZ(const int period, bool &isUp, double &vol, int &first, int &second)
{
   first = -1;
   double firstZZ = 0;

   int i = period;
   long volume = 0;
   while (i < Bars)
   {
      double zigzag = iCustom(_Symbol, _Period, "ZigZag", Depth, Deviation, Backstep, 0, i);
      double vol2 = iCustom(_Symbol, _Period, "Cumulative_Volume v1.3", Length, 0, i);
      if (vol2 != EMPTY_VALUE)
      {
         if (zigzag != 0.0)
         {
            if (first == -1)
            {
               firstZZ = zigzag;
               first = i;
            }
            else
            {
               second = i;
               isUp = firstZZ > zigzag;
               volume += vol2;
               vol = (double)volume;
               return true;
            }
         }
         if (first != -1)
         {
            volume += vol2;
         }
      }
	  
      ++i;
   }
   return false;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;
   int pos = MathMin(bars_limit, limit);
   while (pos >= 0)
   {
      bool isUp;
      double vol;
      int first;
      int second;
      if (GetZZ(pos, isUp, vol, first, second) )
      {
         ResetLastError();
         string id = IndicatorObjPrefix + TimeToString(Time[first]) + "idValue";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[second], !isUp ? High[second] : Low[second]))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               return 0;
            }
            ObjectSetString(0, id, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 10);
            ObjectSetInteger(0, id, OBJPROP_COLOR, label_color);
         }
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, isUp ? ANCHOR_UPPER : ANCHOR_LOWER);
         ObjectSetInteger(0, id, OBJPROP_TIME, Time[second]);
         ObjectSetDouble(0, id, OBJPROP_PRICE1, !isUp ? High[second] : Low[second]);
         ObjectSetString(0, id, OBJPROP_TEXT, IntegerToString(vol));

         ResetLastError();
         string trendId = IndicatorObjPrefix + TimeToString(Time[second]) + "trendidValue";
         if (ObjectFind(0, trendId) == -1)
         {
            if (!ObjectCreate(0, trendId, OBJ_TREND, 0, Time[first], isUp ? High[first] : Low[first], Time[second], !isUp ? High[second] : Low[second]))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               return 0;
            }
            ObjectSetInteger(0, trendId, OBJPROP_COLOR, isUp ? up_color : down_color);
            ObjectSetInteger(0, trendId, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, trendId, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, trendId, OBJPROP_RAY_RIGHT, false);
         }
         ObjectSetDouble(0, trendId, OBJPROP_PRICE1, isUp ? High[first] : Low[first]);
         ObjectSetDouble(0, trendId, OBJPROP_PRICE2, !isUp ? High[second] : Low[second]);
      }
      pos--;
   } 
   return 0;
}