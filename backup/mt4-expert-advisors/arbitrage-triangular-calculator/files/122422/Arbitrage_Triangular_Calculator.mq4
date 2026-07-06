// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67025

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
#property version   "1.0"
#property strict

extern string symbol1 = "USDJPY"; // Symbol #1
extern string symbol2 = "EURJPY"; // Symbol #2
extern string symbol3 = "EURUSD"; // Symbol #3

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green
#property indicator_label1 "SS"

double SS[];

string IndicatorName;
string IndicatorObjPrefix;
struct Desc
{
   string Symbol;
   double Weight;
};
Desc symbols[];

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

void split(string in, string &out1, string &out2)
{
   out1 = StringSubstr(in, 0, 3);
   out2 = StringSubstr(in, 3, 3);
}

int init()
{
   IndicatorName = GenerateIndicatorName("Arbitrage triangular calculator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, SS);
   ArrayResize(symbols, ArraySize(symbols) + 1);
   symbols[ArraySize(symbols) - 1].Symbol = symbol1;
   symbols[ArraySize(symbols) - 1].Weight = 1;
   ArrayResize(symbols, ArraySize(symbols) + 1);
   symbols[ArraySize(symbols) - 1].Symbol = symbol2;
   symbols[ArraySize(symbols) - 1].Weight = 0.0;
   string C1, C2, C1_, C2_;
   split(symbol1, C1, C2);
   split(symbol2, C1_, C2_);
   if (C1 == C1_ && C2 != C2_)
   {
      symbols[ArraySize(symbols) - 1].Weight = -1;
      C1 = C2_;
   }
   else if (C1 == C2_ && C2 != C1_)
   {
      symbols[ArraySize(symbols) - 1].Weight = 1;
      C1 = C1_;
   }
   else if (C2 == C1_ && C1 != C2_)
   {
      symbols[ArraySize(symbols) - 1].Weight = 1;
      C2 = C2_;
   }
   else if (C2 == C2_ && C1 != C1_)
   {
      symbols[ArraySize(symbols) - 1].Weight = -1;
      C2 = C1_;
   }
   if (symbols[ArraySize(symbols) - 1].Weight == 0)
   {
      Print("Pairs do not a triangle");
      return INIT_FAILED;
   }
   ArrayResize(symbols, ArraySize(symbols) + 1);
   symbols[ArraySize(symbols) - 1].Symbol = symbol3;
   symbols[ArraySize(symbols) - 1].Weight = 0.0;
   
   split(symbol3, C1_, C2_);
   if (C1 == C1_ && C2 == C2_)
      symbols[ArraySize(symbols) - 1].Weight = -1;
   else if (C1 == C2_ && C2 == C1_)
      symbols[ArraySize(symbols) - 1].Weight = 1;

   if (symbols[ArraySize(symbols) - 1].Weight == 0)
   {
      Print("Pairs do not a triangle");
      return INIT_FAILED;
   }
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 1;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int period = limit;
   while (period >= 1)
   {
      datetime lastdate = Time[period];
      double x = 1;
      for (int i = 0; i < 3; ++i)
      {
         x *= MathPow(iClose(symbols[i].Symbol, _Period, period), symbols[i].Weight);
      }
      SS[period] = x;
      period--;
   } 
   SS[0] = SS[1];
   return(0);
}
