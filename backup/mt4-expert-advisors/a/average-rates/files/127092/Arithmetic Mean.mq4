// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68601

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
#property strict

// Bar overlay template v.1.0.0

#property indicator_separate_window
#property indicator_buffers 1

input string Base = "USD"; // Base
input string Group_1 = "====="; // Group 1
input bool       On1 = true; // Use this pair
input string Select1 = "EURUSD"; // Pair
input bool Inverse1 = false; // Use inverse rate
input double Weight1 = 1; // Weight
input string Group_2 = "====="; // Group 2
input bool       On2 = true; // Use this pair
input string Select2 = "USDJPY"; // Pair
input bool Inverse2 = false; // Use inverse rate
input double Weight2 = 1; // Weight
input string Group_3 = "====="; // Group 3
input bool       On3 = true; // Use this pair
input string Select3 = "GBPUSD"; // Pair
input bool Inverse3 = false; // Use inverse rate
input double Weight3 = 1; // Weight
input string Group_4 = "====="; // Group 4
input bool       On4 = true; // Use this pair
input string Select4 = "USDCHF"; // Pair
input bool Inverse4 = false; // Use inverse rate
input double Weight4 = 1; // Weight
input string Group_5 = "====="; // Group 5
input bool       On5 = true; // Use this pair
input string Select5 = "AUDUSD"; // Pair
input bool Inverse5 = false; // Use inverse rate
input double Weight5 = 1; // Weight
input string Group_6 = "====="; // Group 6
input bool       On6 = true; // Use this pair
input string Select6 = "NZDUSD"; // Pair
input bool Inverse6 = false; // Use inverse rate
input double Weight6 = 1; // Weight
input string Group_7 = "====="; // Group 7
input bool       On7 = true; // Use this pair
input string Select7 = "USDCAD"; // Pair
input bool Inverse7 = false; // Use inverse rate
input double Weight7 = 1; // Weight

input color LineColor = Red; // Line color

double out[];

class Instrument
{
public:
   string Symbol;
   double Weight;
   bool Inverse;
   Instrument(string symbol, double weight, bool inverse)
   {
      Symbol = symbol;
      Weight = weight;
      Inverse = inverse;
   }
};

Instrument* items[];

int init()
{
   IndicatorShortName("Arithmetic Mean");
   IndicatorDigits(Digits);

   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, LineColor);
   SetIndexBuffer(0, out);
   SetIndexLabel(0, "Line");
   if (On1)
   {
      int size = ArraySize(items);
      ArrayResize(items, size + 1);
      int index = StringFind(Select1, Base);
      if (index == -1)
      {
         Print("Wrong instrument: " + Select1);
         return INIT_FAILED;
      }
      items[size] = new Instrument(Select1, index == 0 ? Weight1 : -Weight1, Inverse1);
   }
   if (On2)
   {
      int size = ArraySize(items);
      ArrayResize(items, size + 1);
      int index = StringFind(Select2, Base);
      if (index == -1)
      {
         Print("Wrong instrument: " + Select2);
         return INIT_FAILED;
      }
      items[size] = new Instrument(Select2, index == 0 ? Weight2 : -Weight2, Inverse2);
   }
   if (On3)
   {
      int size = ArraySize(items);
      ArrayResize(items, size + 1);
      int index = StringFind(Select3, Base);
      if (index == -1)
      {
         Print("Wrong instrument: " + Select3);
         return INIT_FAILED;
      }
      items[size] = new Instrument(Select3, index == 0 ? Weight3 : -Weight3, Inverse3);
   }
   if (On4)
   {
      int size = ArraySize(items);
      ArrayResize(items, size + 1);
      int index = StringFind(Select4, Base);
      if (index == -1)
      {
         Print("Wrong instrument: " + Select4);
         return INIT_FAILED;
      }
      items[size] = new Instrument(Select4, index == 0 ? Weight4 : -Weight4, Inverse4);
   }
   if (On5)
   {
      int size = ArraySize(items);
      ArrayResize(items, size + 1);
      int index = StringFind(Select5, Base);
      if (index == -1)
      {
         Print("Wrong instrument: " + Select5);
         return INIT_FAILED;
      }
      items[size] = new Instrument(Select5, index == 0 ? Weight5 : -Weight5, Inverse5);
   }
   if (On6)
   {
      int size = ArraySize(items);
      ArrayResize(items, size + 1);
      int index = StringFind(Select6, Base);
      if (index == -1)
      {
         Print("Wrong instrument: " + Select6);
         return INIT_FAILED;
      }
      items[size] = new Instrument(Select6, index == 0 ? Weight6 : -Weight6, Inverse6);
   }
   if (On7)
   {
      int size = ArraySize(items);
      ArrayResize(items, size + 1);
      int index = StringFind(Select7, Base);
      if (index == -1)
      {
         Print("Wrong instrument: " + Select7);
         return INIT_FAILED;
      }
      items[size] = new Instrument(Select7, index == 0 ? Weight7 : -Weight7, Inverse7);
   }
   
   return 0;
}

int deinit()
{
   for (int i = 0; i < ArraySize(items); ++i)
   {
      delete items[i];
   }
   ArrayResize(items, 0);
   return 0;
}

int start()
{
   if (Bars <= 3) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if (ExtCountedBars > 0) 
      limit = Bars - ExtCountedBars - 1;
   
   for (int pos = limit; pos >= 0; --pos)
   {
      double val = 0;
      int N = ArraySize(items);
      for (int i = 0; i < N; ++i)
      {
         Instrument* item = items[i];
         int index = iBarShift(item.Symbol, _Period, Time[pos]);
         if (index < 0)
            continue;
         double close = iClose(item.Symbol, _Period, index);
         if (item.Inverse)
            val += (1 / close) * item.Weight;
         else
            val += close * item.Weight;
      }
      out[pos] = val / N;
   }
   return 0;
}
