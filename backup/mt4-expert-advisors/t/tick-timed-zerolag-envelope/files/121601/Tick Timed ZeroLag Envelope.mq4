// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66829

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

string IndicatorName = "Timed ZeroLag Envelope";

enum BandWidthUnitsType
{
   BandWidthUnitsPr, // %
   BandWidthUnitsPips // Pips
};

extern int Duration = 60; // MA Duration in seconds
extern double BandWidth = 25; // Band Width
extern BandWidthUnitsType BandWidthUnits = BandWidthUnitsPr; // Band Width Units

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_label1 "Bottom"
#property indicator_label2 "Top"
#property indicator_label3 "ZeroLag"

double top[], bottom[], ZeroLag[], ema[];

int init()
{
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, top);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, bottom);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, ZeroLag);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, ema);

   return 0;
}

int deinit()
{
   return 0;
}

int start()
{
   if (Bars <= 1)
      return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return(-1);
   int limit = Bars - 1;
   if(ExtCountedBars > 1)
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   int mult = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2 == 1 ? 10 : 1;
   double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * mult;
   while (pos >= 0)
   {
      int P1 = iBarShift(_Symbol, _Period, Time[pos] - Duration);
      ema[pos] = calculateEMA(P1, pos);
      ZeroLag[pos] = calculateZeroLag(P1, pos);
         
      if (BandWidthUnits == BandWidthUnitsPr)
      {
         double Delta =  ZeroLag[pos] * BandWidth / 10000;
         top[pos] =  ZeroLag[pos] + Delta;
         bottom[pos] =  ZeroLag[pos] - Delta;
      }
      else
      {
         top[pos] =  ZeroLag[pos] + BandWidth * pipSize;
         bottom[pos] =  ZeroLag[pos] - BandWidth * pipSize;
      }
      pos--;
   } 
   return 0;
}

double calculateZeroLag(int p, int period)
{
	int n = period + p;
	if (n >= Bars)
      return Close[period];
   else
   {
      double k = 2.0 / (period + 1);
      double x = (period - 1) / 2;
      return k * (2 * Close[period] - Close[(int)(period + x)]) + (1 - k) * ema[period + 1];       
   }
}

double calculateEMA(int p, int period)
{
	int n = period + p;
	if (n >= Bars)
      return Close[period];
   else
   {
		double k = 2.0 / (n + 1.0);
      return (1 - k) * ema[period + 1] + k * Close[period];
   }
}