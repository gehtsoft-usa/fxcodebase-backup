// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66300

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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Green

extern ENUM_TIMEFRAMES TF = PERIOD_D1; // Bar Size to display High/Low
input double channel_width = 10; // Channel width, pips

double vwap[], wp[], up[], dn[];

int init()
{
   IndicatorShortName("Any Time Frame VWAP");
   IndicatorDigits(Digits);
   IndicatorBuffers(4);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, vwap);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, up);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, dn);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, wp);

   return 0;
}

int deinit()
{
   return 0;
}

double Calculate(const datetime from, const int to)
{
   double wp_summ = 0;
   double volume_summ = 0;
   int i = to;
   while (i < Bars && Time[i] >= from)
   {
      wp_summ += wp[i];
      volume_summ += (double)Volume[i];
      i++;
   }
   return volume_summ == 0 ? 0 : wp_summ / volume_summ;
}

int start()
{
   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;

   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   int pos = limit;
   while (pos >= 0)
   {
      wp[pos] = Volume[pos] * (High[pos] + Low[pos] + Close[pos]) / 3;
      
      int index = iBarShift(_Symbol, TF, Time[pos]);
      vwap[pos] = Calculate(iTime(_Symbol, TF, index), pos);
      up[pos] = vwap[pos] + channel_width * pipSize;
      dn[pos] = vwap[pos] - channel_width * pipSize;
      
      pos--;
   }
   return(0);
}
