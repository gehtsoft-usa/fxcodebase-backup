// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67352

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

#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Yellow

extern ENUM_TIMEFRAMES TF = PERIOD_M1; // Timeframe
extern int BandsPeriod = 20; // Bands period
extern int BandsShift = 0; // Bands shift
extern double BandsDeviations = 2.0; // Bands deviations

double Up[], Center[], Down[];

int init()
{
   IndicatorShortName("LTF BB");
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Up);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Center);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Down);
   return 0;
}

int deinit()
{
   return 0;
}

int start()
{
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int pos = Bars - 2;
   if (ExtCountedBars > 2) 
      pos = Bars - ExtCountedBars - 1;
   while (pos >= 0)
   {
      int period = iBarShift(NULL, TF, Time[pos], true);
      Up[pos] = iBands(NULL, TF, BandsPeriod, BandsDeviations, BandsShift, PRICE_CLOSE, MODE_UPPER, period);
      Down[pos] = iBands(NULL, TF, BandsPeriod, BandsDeviations, BandsShift, PRICE_CLOSE, MODE_LOWER, period);
      Center[pos] = iBands(NULL, TF, BandsPeriod, BandsDeviations, BandsShift, PRICE_CLOSE, MODE_MAIN, period);
      pos--;
   } 
   return(0);
}

