// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68473

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

input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input int atr_period = 14; // ATR Period
input double atr_mult = 2.5; // ATR Multiplicator
input int lines_count = 20; // Number of lines
input color lines_color = Red; // Color

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
   IndicatorName = GenerateIndicatorName("ATR GRID MTF");
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

void DrawLine(string id, double price)
{
   ObjectDelete(id);
   ObjectCreate(id, OBJ_HLINE, 0, Time[0], price);
   ObjectSet(id, OBJPROP_COLOR, lines_color);
}

int start()
{
   double atr = iATR(Symbol(), tf, atr_period, 0) * atr_mult;
   double price = Close[0];
   DrawLine(IndicatorObjPrefix + "_Main", price);
   for (int i = 1; i <= lines_count; ++i)
   {
      string index = IntegerToString(i);
      DrawLine(IndicatorObjPrefix + "_Up_" + index, price + atr * i);
      DrawLine(IndicatorObjPrefix + "_Down_" + index, price - atr * i);
   }
   return 0;
}

