// More information about this indicator can be found at:
// http://fxcodebase.com/code/posting.php?mode=post&f=38

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
//#property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Yellow

enum Method
{
   Cumulative,
   Separated,
   Absolute
};

input Method method = Cumulative;

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

double prevAsk, prevBid;
double Up[], Down[], output[];

int init()
{
   IndicatorName = GenerateIndicatorName("Tick Volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);
   prevAsk = 0;
   prevBid = 0;

   int id = 0;
   if (method == Cumulative)
   {
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, Up);
      ++id;
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, Down);
      ++id;
      SetIndexStyle(id, DRAW_HISTOGRAM);
      SetIndexBuffer(id, output);
      SetIndexLabel(id, "Cumulative");
   }
   else if (method == Absolute)
   {
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, Up);
      ++id;
      SetIndexStyle(id, DRAW_NONE);
      SetIndexBuffer(id, Down);
      ++id;
      SetIndexStyle(id, DRAW_HISTOGRAM);
      SetIndexBuffer(id, output);
      SetIndexLabel(id, "Absolute");
   }
   else
   {
      SetIndexStyle(id, DRAW_LINE);
      SetIndexBuffer(id, Up);
      SetIndexLabel(id, "Up");
      ++id;
      SetIndexStyle(id, DRAW_LINE);
      SetIndexBuffer(id, Down);
      SetIndexLabel(id, "Down");
   }

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   double bid = MarketInfo(_Symbol, MODE_BID);
   double ask = MarketInfo(_Symbol, MODE_ASK);

   if (Up[0] == EMPTY_VALUE)
   {
      Up[0] = 0;
      Down[0] = 0;

      if (ask != prevAsk)
      {
         if (ask > prevAsk)
            Up[0] = Up[0] + 1;
         else
            Down[0] = Down[0] + 1;
            
         prevAsk = ask;
      }

      if (bid != prevBid)
      {
         if (bid > prevBid)
            Up[0] = Up[0] + 1;
         else
            Down[0] = Down[0] + 1;
         prevBid = bid;
      }
   }
   else
   {
      if (ask != prevAsk)
      {
         if (ask > prevAsk)
            Up[0] = Up[0] + 1;
         else
            Down[0] = Down[0] - 1;
            
         prevAsk = ask;
      }

      if (bid != prevBid)
      {
         if (bid > prevBid)
            Up[0] = Up[0] + 1;
         else
            Down[0] = Down[0] - 1;
         prevBid = bid;
      }
   }
   if (method == Cumulative)
   {
      output[0] = Up[0] + Down[0];
   }
   else if (method == Separated)
   {
      output[0] = Up[0] + MathAbs(Down[0]);
   }
   return 0;
}