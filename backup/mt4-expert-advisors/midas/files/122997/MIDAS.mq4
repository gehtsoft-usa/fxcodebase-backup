// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&p=123008

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
#property version   "1.1"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_label1 "VWAP"
#property indicator_color2 Red
#property indicator_label2 "VWAP Shift"

// params
extern int shift = 20; // Shift
extern int bars_limit = 1000; // Bars limit
extern ENUM_TIMEFRAMES BTF = PERIOD_CURRENT; // Bigget timeframe

double CumVol[], CumPVol[], VWAPOut[], VWAPShift[];

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
   IndicatorBuffers(4);

   IndicatorName = GenerateIndicatorName("MIDAS");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, VWAPOut);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, VWAPShift);
   SetIndexBuffer(2, CumVol);
   SetIndexBuffer(3, CumPVol);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

double CumVol_J = -1;
double CumPVol_J = -1;

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = MathMin(bars_limit, Bars - 1);
   if(ExtCountedBars > 1) 
      limit = MathMin(bars_limit, Bars - ExtCountedBars - 1);
   int pos = limit;
   while (pos >= 0)
   {
      if (BTF == PERIOD_CURRENT)
      {
         double median = (High[pos] + Low[pos]) / 2.0;
         if (pos == limit)
         {
            CumVol[pos] = (double)Volume[pos];
            CumPVol[pos] = (double)Volume[pos] * median;
            CumPVol_J = CumPVol[pos];
            CumVol_J = CumVol[pos];
            VWAPOut[pos] = median;
            VWAPShift[pos] = VWAPOut[pos] + VWAPOut[pos] * shift / 10000;
         }
         else
         {
            CumVol[pos] = CumVol[pos + 1] + Volume[pos];
            CumPVol[pos] = CumPVol[pos + 1] + Volume[pos] * median;
            VWAPOut[pos] = (CumPVol[pos] - CumPVol_J) / (CumVol[pos] - CumVol_J);
            VWAPShift[pos] = VWAPOut[pos] + VWAPOut[pos] * shift / 10000;
         }
      }
      else
      {
         int index = iBarShift(_Symbol, BTF, Time[pos]);
         if (index >= 0)
         {
            VWAPOut[pos] = iCustom(_Symbol, BTF, "MIDAS", shift, bars_limit, 0, index);
            VWAPShift[pos] = iCustom(_Symbol, BTF, "MIDAS", shift, bars_limit, 1, index);
         }
      }
      pos--;
   } 
   return 0;
}

