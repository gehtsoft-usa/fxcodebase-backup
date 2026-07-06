// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68400

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

input ENUM_TIMEFRAMES BTF = PERIOD_D1;
input int DOJI = 10; // Max. Doji Body Lengt
input color UP_Color = Green; // Color for UP
input color DOWN_Color = Red; // Color for DOWN
input color DOJI_Color = Gray; // Color for Doji

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

double pipSize;

int init()
{
   IndicatorName = GenerateIndicatorName("Bigger TF Candle");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS); 
   double mult = digits == 3 || digits == 5 ? 10 : 1;
   pipSize = point * mult;
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      int index = iBarShift(_Symbol, BTF, Time[pos]);
      if (index >= 0)
      {
         datetime time = iTime(_Symbol, BTF, index);
         string timeStr = TimeToString(time);
         string bodyId = IndicatorObjPrefix + timeStr + "body";
         double open = iOpen(_Symbol, BTF, index);
         double high = iHigh(_Symbol, BTF, index);
         double low = iLow(_Symbol, BTF, index);
         double close = iClose(_Symbol, BTF, index);
         bool isDoji = (MathAbs(open - close) / pipSize) < DOJI;
         color clr = isDoji ? DOJI_Color : (open > close ? DOWN_Color : UP_Color);
         ObjectCreate(0, bodyId, OBJ_RECTANGLE, 0, time, open);
         ObjectSet(bodyId, OBJPROP_TIME2, Time[pos]);
         ObjectSet(bodyId, OBJPROP_PRICE2, close);
         ObjectSetInteger(0, bodyId, OBJPROP_COLOR, clr);

         string highId = IndicatorObjPrefix + timeStr + "high";
         datetime center = (time + Time[pos]) / 2;
         ObjectCreate(highId, OBJ_TREND, 0, center, MathMax(open, close), center, high);
         ObjectSet(highId, OBJPROP_COLOR, clr);
         ObjectSet(highId, OBJPROP_WIDTH, 5);
         ObjectSet(highId, OBJPROP_RAY, false);
         ObjectSet(highId, OBJPROP_TIME1, center);
         ObjectSet(highId, OBJPROP_PRICE1, MathMax(open, close));
         ObjectSet(highId, OBJPROP_TIME2, center);
         ObjectSet(highId, OBJPROP_PRICE2, high);

         string lowId = IndicatorObjPrefix + timeStr + "low";
         ObjectCreate(lowId, OBJ_TREND, 0, center, MathMin(open, close), center, low);
         ObjectSet(lowId, OBJPROP_COLOR, clr);
         ObjectSet(lowId, OBJPROP_WIDTH, 5);
         ObjectSet(lowId, OBJPROP_RAY, false);
         ObjectSet(lowId, OBJPROP_TIME1, center);
         ObjectSet(lowId, OBJPROP_PRICE1, MathMin(open, close));
         ObjectSet(lowId, OBJPROP_TIME2, center);
         ObjectSet(lowId, OBJPROP_PRICE2, high);
      }

      pos--;
   } 
   return 0;
}
