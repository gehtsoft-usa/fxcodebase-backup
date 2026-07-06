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
#property indicator_buffers 40

input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input int atr_period = 14; // ATR Period
input double atr_mult = 2.5; // ATR Multiplicator
input int lines_count = 20; // Number of lines
input color lines_color = Red; // Color

string IndicatorName;
string IndicatorObjPrefix;

class Streams
{
public:
   double up[], down[];
   int index;
};

Streams* streams[];

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
   IndicatorName = GenerateIndicatorName("ATR GRID MTF History");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   IndicatorBuffers(lines_count * 2);

   ArrayResize(streams, lines_count);

   for (int i = 0; i < lines_count; ++i)
   {
      Streams* stream = new Streams();
      SetIndexStyle(i * 2, DRAW_LINE, 0, 1, lines_color);
      SetIndexBuffer(i * 2, stream.up);
      SetIndexLabel(i * 2, "Up");

      SetIndexStyle(i * 2 + 1, DRAW_LINE, 0, 1, lines_color);
      SetIndexBuffer(i * 2 + 1, stream.down);
      SetIndexLabel(i * 2 + 1, "Down");
      stream.index = i;
      streams[i] = stream;
   }
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

   for (int i = 0; i < ArraySize(streams); ++i)
   {
      delete streams[i];
   }
   ArrayResize(streams, 0);
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
   for (int pos = limit; pos >= 0; --pos)
   {
      int index = iBarShift(_Symbol, tf, Time[pos]);
      if (index < 0)
         continue;

      double atr = iATR(Symbol(), tf, atr_period, index) * atr_mult;
      double price = iClose(Symbol(), tf, index);
      for (int i = 0; i < ArraySize(streams); ++i)
      {
         Streams* item = streams[i];
         item.up[pos] = price + atr * (item.index + 1);
         item.down[pos] = price - atr * (item.index + 1);
      }
   }
   
   return 0;
}

