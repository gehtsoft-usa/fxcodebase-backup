// More information about this indicator can be found at:
//http://fxcodebase.com/code/posting.php?mode=post&f=38

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

input int periods = 10; // Periods for the highest volume
input color lines_color = Red; // Lines color
input color last_lines_color = Green; // Last level lines color

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

void OnInit()
{
   IndicatorName = GenerateIndicatorName("Hiding gap volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

double last_high, last_low;
datetime last_highLow;

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int highestIndex = iHighest(_Symbol, _Period, MODE_VOLUME, periods, 0);
   double hh = iHigh(_Symbol, _Period, highestIndex);
   double ll = iLow(_Symbol, _Period, highestIndex);
   if (last_highLow != iTime(_Symbol, _Period, highestIndex))
   {
      if (last_highLow != 0)
      {
         ResetLastError();
         string id = IndicatorObjPrefix + "PrevHighestValue";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_HLINE, 0, 0, last_high))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               return 0;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, last_lines_color);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
         }
         ObjectSetDouble(0, id, OBJPROP_PRICE, last_high);
         id = IndicatorObjPrefix + "PrevLowestValue";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_HLINE, 0, 0, last_low))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               return 0;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, last_lines_color);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
         }
         ObjectSetDouble(0, id, OBJPROP_PRICE, last_low);

         ResetLastError();
         id = IndicatorObjPrefix + "prevVLineValue";
         if (ObjectFind(0, id) == -1)
         {
            if (!ObjectCreate(0, id, OBJ_VLINE, 0, last_highLow, 0))
            {
               Print(__FUNCTION__, ". Error: ", GetLastError());
               return 0;
            }
            ObjectSetInteger(0, id, OBJPROP_COLOR, Red);
            ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
         }
         ObjectSetInteger(0, id, OBJPROP_TIME, last_highLow);
      }
      last_highLow = iTime(_Symbol, _Period, highestIndex);
      last_high = hh;
      last_low = ll;
   }
   ResetLastError();
   string id = IndicatorObjPrefix + "highestValue";
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_HLINE, 0, 0, hh))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, lines_color);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE, hh);
   id = IndicatorObjPrefix + "lowestValue";
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_HLINE, 0, 0, ll))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, lines_color);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE, ll);

   ResetLastError();
   id = IndicatorObjPrefix + "vLineValue";
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_VLINE, 0, iTime(_Symbol, _Period, highestIndex), 0))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, Green);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
   }
   ObjectSetInteger(0, id, OBJPROP_TIME, iTime(_Symbol, _Period, highestIndex));
   return rates_total;
}
