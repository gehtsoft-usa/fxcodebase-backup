// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68811

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
//#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 LightBlue
#property indicator_color3 Pink
#property indicator_color4 Red

input int mva_period = 7; // SMA period
input double sf = 1; // Scaling factor
input double asf = 90; // Scaling factor %avg
input int loopback_period = 100; // Loopback periods
input int max_peaks = 3; // Max peaks
input int min_peaks = 3; // Min peaks
input bool manual_max_ob = false; // Manual Max.OB
input double max_ob_val = 0; // Max.OB Value
input bool manual_avg_ob = false; // Manual %Avg.OB
input double avg_ob_val = 0; // %Avg.OB Value
input bool manual_avg_os = false; // Manual %Avg.OS
input double avg_os_val = 0; // %Avg.OS Value
input bool manual_max_os = false; // Manual Max.OS
input double max_os_val = 0; // Max.OS Value

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

double max_ob[], max_os[], avg_ob[], avg_os[], ddpo[];

int init()
{
   IndicatorName = GenerateIndicatorName("DDPO OBOS Price Projection Band");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(5);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, max_ob);
   SetIndexLabel(0, "Max.OB");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, avg_ob);
   SetIndexLabel(1, "%Avg.OB");
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, avg_os);
   SetIndexLabel(2, "%Avg.OS");
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, max_os);
   SetIndexLabel(3, "Max.OS");
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, ddpo);
   
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
   for (int pos = limit; pos >= 0; --pos)
   {
      double maValue = iMA(_Symbol, _Period, mva_period, 0, MODE_SMA, PRICE_CLOSE, pos);
      ddpo[pos] = sf * (Close[pos] - maValue);
      if (Bars < pos + loopback_period + 1)
         continue;
      double ob = 0;
      double os = 0;
      double levels[];
      for (int i = 0; i < loopback_period; ++i)
      {
         if (ob == 0 || ob < ddpo[pos + i])
            ob = ddpo[pos + i];
         if (os == 0 || os > ddpo[pos + i])
            os = ddpo[pos + i];
         if (i != 0 && IsRising(ddpo, pos + i) == IsFalling(ddpo, pos + i - 1))
         {
            int size = ArraySize(levels);
            ArrayResize(levels, size + 1);
            levels[size] = ddpo[pos + i];
            if (pos == 2)
            Print(ddpo[pos + i]);
         }
      }
      ArraySort(levels);

      int size = ArraySize(levels);
      double summ = 0;
      for (int i = 0; i < MathMin(size, min_peaks); ++i)
      {
         summ += levels[size - i - 1];
      }
      double mva2 = iMA(_Symbol, _Period, mva_period - 1, 0, MODE_SMA, PRICE_CLOSE, pos);
      if (!manual_avg_ob)
         avg_ob[pos] = (asf / sf) * (summ / min_peaks) / 100 * (mva_period / (mva_period - 1)) + mva2;
      else
         avg_ob[pos] = (asf / sf) * avg_ob_val / 100 * (mva_period / (mva_period - 1)) + mva2;
      if (!manual_max_ob)
         max_ob[pos] = (levels[size - 1] / sf) * (mva_period / (mva_period - 1)) + mva2;
      else
         max_ob[pos] = (max_ob_val / sf) * (mva_period / (mva_period - 1)) + mva2;
      summ = 0;
      for (int i = 0; i < MathMin(size, max_peaks); ++i)
      {
         summ += levels[i];
      }
      if (!manual_avg_os)
         avg_os[pos] = (asf / sf) * (summ / max_peaks) / 100 * (mva_period / (mva_period - 1)) + mva2;
      else
         avg_os[pos] = (asf / sf) * avg_os_val / 100 * (mva_period / (mva_period - 1)) + mva2;
      if (!manual_max_os)
         max_os[pos] = (levels[0] / sf) * (mva_period / (mva_period - 1)) + mva2;
      else
         max_os[pos] = (max_os_val / sf) * (mva_period / (mva_period - 1)) + mva2;
   }

   return 0;
}

bool IsRising(double &stream[], int period)
{
   return stream[period] > stream[period + 1];
}

bool IsFalling(double &stream[], int period)
{
   return stream[period] < stream[period + 1];
}

