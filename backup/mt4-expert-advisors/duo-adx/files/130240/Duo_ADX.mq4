// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69231

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

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

input int period = 14; // Period
input int mm = 3; // MM

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

double mioadxn[], mioADXnonSmoothed[], mioTR[], plusdm[], mindm[], temp[];

int init()
{
   IndicatorName = GenerateIndicatorName("Duo ADX");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(6);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, mioadxn);
   SetIndexLabel(0, "ADX Normal");   

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, mioADXnonSmoothed);
   SetIndexLabel(1, "ADX Fast");

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, mioTR);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, plusdm);

   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, mindm);

   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, temp);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 2;
   for (int i = limit; i >= 0; i--)
   {
      double up = High[i] - High[i + 1];
      double dw = Low[i + 1] - Low[i];
      plusdm[i] = up > dw && up >= 0 ? up : 0;
      mindm[i] = dw > up && dw >= 0 ? dw : 0;
      mioTR[i] = MathMax(MathAbs(High[i] - Close[i + 1]), MathMax(MathAbs(Low[i] - Close[i + 1]), High[i] - Low[i]));
      if (i >= Bars - 2 - mm)
      {
         continue;
      }
      double mioATR = iMAOnArray(mioTR, 0, mm, 0, MODE_SMA, i);
      double dip = iMAOnArray(plusdm, 0, mm, 0, MODE_SMA, i) / mioATR;
      double dim = iMAOnArray(mindm, 0, mm, 0, MODE_SMA, i) / mioATR;
      temp[i] = MathAbs(dip - dim) / (dip + dim);
      mioADXnonSmoothed[i] = 100 * MathAbs(dip - dim) / (dip + dim);
      if (i >= Bars - 2 - mm * 2)
      {
         continue;
      }
      mioadxn[i] = iMAOnArray(temp, 0, mm, 0, MODE_SMA, i) * 100;
   }
   return 0;
}

