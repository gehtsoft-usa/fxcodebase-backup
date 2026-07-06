// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69581

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 10
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_color4 Yellow
#property indicator_color5 Pink
#property indicator_color6 Lime
#property indicator_color7 Purple
#property indicator_color8 Brown
#property indicator_color9 LightBlue
#property indicator_color10 White

input int period = 14; // Period
input string Pair1 = "EURUSD"; // Pair 1
input string Pair2 = "USDJPY"; // Pair 2
input string Pair3 = "GBPUSD"; // Pair 3
input string Pair4 = "EURJPY"; // Pair 4
input string Pair5 = ""; // Pair 5
input string Pair6 = ""; // Pair 6
input string Pair7 = ""; // Pair 7
input string Pair8 = ""; // Pair 8
input string Pair9 = ""; // Pair 9
input string Pair10 = ""; // Pair 10

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

class Stream
{
   string _symbol;
public:
   double out[];
   Stream(string symbol)
   {
      _symbol = symbol;
   }

   void Update(int pos)
   {
      out[pos] = iADX(_symbol, _Period, period, PRICE_CLOSE, MODE_MAIN, pos);
   }

   int Register(int id)
   {
      SetIndexStyle(id, DRAW_LINE);
      SetIndexBuffer(id, out);
      SetIndexLabel(id, _symbol);
      return id + 1;
   }
};

Stream* streams[];

int init()
{
   IndicatorName = GenerateIndicatorName("ADX Strength Meter Oscillator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(10);

   int id = 0;
   if (Pair1 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair1);
      id = streams[size].Register(id);
   }
   if (Pair2 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair2);
      id = streams[size].Register(id);
   }
   if (Pair3 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair3);
      id = streams[size].Register(id);
   }
   if (Pair4 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair4);
      id = streams[size].Register(id);
   }
   if (Pair5 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair5);
      id = streams[size].Register(id);
   }
   if (Pair6 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair6);
      id = streams[size].Register(id);
   }
   if (Pair7 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair7);
      id = streams[size].Register(id);
   }
   if (Pair8 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair8);
      id = streams[size].Register(id);
   }
   if (Pair9 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair9);
      id = streams[size].Register(id);
   }
   if (Pair10 != "")
   {
      int size = ArraySize(streams);
      ArrayResize(streams, size + 1);
      streams[size] = new Stream(Pair10);
      id = streams[size].Register(id);
   }

   return 0;
}

int deinit()
{
   for (int i = 0; i < ArraySize(streams); ++i)
   {
      delete streams[i];
   }
   ArrayResize(streams, 0);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      for (int ii = 0; ii < ArraySize(streams); ++ii)
      {
         streams[ii].Update(i);
      }
   }
   return 0;
}
