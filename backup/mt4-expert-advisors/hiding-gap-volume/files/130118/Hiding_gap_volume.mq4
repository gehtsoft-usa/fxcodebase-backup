// More information about this indicator can be found at:
//http://fxcodebase.com/code/posting.php?mode=post&f=38

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
#property indicator_buffers 0

input int periods = 10; // Periods for the highest volume
input color lines_color = Red; // Lines color

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
   IndicatorName = GenerateIndicatorName("Hiding gap volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int highestIndex = iHighest(_Symbol, _Period, MODE_VOLUME, periods, 0);
   ResetLastError();
   string id = IndicatorObjPrefix + "highestValue";
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_HLINE, 0, 0, High[highestIndex]))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, lines_color);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE, High[highestIndex]);
   id = IndicatorObjPrefix + "lowestValue";
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_HLINE, 0, 0, Low[highestIndex]))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return 0;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, lines_color);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE, Low[highestIndex]);
   
   return 0;
}
