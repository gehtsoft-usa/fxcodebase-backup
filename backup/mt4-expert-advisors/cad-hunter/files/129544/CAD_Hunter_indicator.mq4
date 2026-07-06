// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69084

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
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

input int period = 8; // Period
input int smooth = 13; // Smooth
input int minmaxperiod = 25; // Min/max period
input double uplevel = 90; // Up level
input double downlevel = 10; // Down level

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

double workSsm11[], workSsm12[], workSsm13[], workSsm14[], workSsm15[], workzdh[], workzdl[], aADX[], flu[], fld[];

int init()
{
   IndicatorName = GenerateIndicatorName("CAD-Hunter indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(10);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, aADX);
   SetIndexLabel(0, "ADX");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, flu);
   SetIndexLabel(1, "FLU");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, fld);
   SetIndexLabel(2, "FLD");

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, workSsm11);

   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, workSsm12);

   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, workSsm13);

   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, workSsm14);

   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, workSsm15);

   SetIndexStyle(8, DRAW_NONE);
   SetIndexBuffer(8, workzdh);

   SetIndexStyle(9, DRAW_NONE);
   SetIndexBuffer(9, workzdl);

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
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1 - period - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      double noise = 0;
      double vhf = 0;
      double mmax = Close[pos];
      double mmin = Close[pos];
      for (int k = 0; k < period; ++k)
      {
         noise += MathAbs(Close[pos + k] - Close[pos + k + 1]);
         mmax = MathMax(Close[pos + k], mmax);
         mmin = MathMin(Close[pos + k], mmin);
      }
      if (noise > 0)
         vhf = (mmax - mmin) / noise;
      
      double tperiod = period;
      double fzPeriod = minmaxperiod;
      if (vhf > 0)
      {
         tperiod = -MathLog(vhf) * period;
         fzPeriod = MathFloor(MathMax(-MathLog(vhf) * minmaxperiod, 3));
      }
      double alpha = 2.0 / (tperiod + 1.0);

      //ISSM settings
      double Pi = 3.14159265358979323846264338327950288;
      double a1 = MathExp(-1.414 * Pi / smooth);
      double b1 = 2.0 * a1 * MathCos(1.414 * Pi / smooth);
      double sc2 = b1;
      double sc3 = -a1 * a1;
      double sc1 = 1.0 - sc2 - sc3;
      //Exponential Smoothing and Innovation State Space Model (ISSM)
      if (workSsm11[pos + 2] != EMPTY_VALUE)
         workSsm11[pos] = sc1 * (High[pos] + High[pos + 1]) / 2.0 + sc2 * workSsm11[pos + 1] + sc3 * workSsm11[pos + 2];
      else
         workSsm11[pos] = High[pos];
      //Exponential Smoothing and Innovation State Space Model (ISSM)
      if (workSsm12[pos + 2] != EMPTY_VALUE)
         workSsm12[pos] = sc1 * (Low[pos] + Low[pos + 1]) / 2.0 + sc2 * workSsm12[pos + 1] + sc3 * workSsm12[pos + 2];
      else
         workSsm12[pos] = Low[pos];
      //Exponential Smoothing and Innovation State Space Model (ISSM)
      if (workSsm13[pos + 2] != EMPTY_VALUE)
         workSsm13[pos] = sc1 * (Close[pos + 1] + Close[pos + 2]) / 2.0 + sc2 * workSsm13[pos + 1] + sc3 * workSsm13[pos + 2];
      else
         workSsm13[pos] = Close[pos + 1];
      //Exponential Smoothing and Innovation State Space Model (ISSM)
      if (workSsm14[pos + 2] != EMPTY_VALUE)
         workSsm14[pos] = sc1 * (High[pos + 1] + High[pos + 2]) / 2.0 + sc2 * workSsm14[pos + 1] + sc3 * workSsm14[pos + 2];
      else
         workSsm14[pos] = High[pos + 1];
      //Exponential Smoothing and Innovation State Space Model (ISSM)
      if (workSsm15[pos + 2] != EMPTY_VALUE)
         workSsm15[pos] = sc1 * (Low[pos + 1] + Low[pos + 2]) / 2.0 + sc2 * workSsm15[pos + 1] + sc3 * workSsm15[pos + 2];
      else
         workSsm15[pos] = Low[pos + 1];

      double dh = MathMax(workSsm11[pos] - workSsm14[pos], 0);
      double dl = MathMax(workSsm15[pos] - workSsm12[pos], 0);
      if (dh == dl)
      {
         dh = 0;
         dl = 0;
      }
      else if (dh < dl)
         dh = 0;
      else if (dl < dh)
         dl = 0;

      double ttr = MathMax(workSsm11[pos], workSsm13[pos]) - MathMin(workSsm12[pos], workSsm13[pos]);
      double dhk = 0;
      double dlk = 0;

      if (ttr != 0)
      {
         dhk = 100.0 * dh / ttr;
         dlk = 100.0 * dl / ttr;
      }

      if (workzdh[pos + 1] != EMPTY_VALUE)
      {
         workzdh[pos] = workzdh[pos + 1] + alpha * (dhk - workzdh[pos + 1]);
         workzdl[pos] = workzdl[pos + 1] + alpha * (dlk - workzdl[pos + 1]);
      }
      else
      {
         workzdh[pos] = alpha * dhk;
         workzdl[pos] = alpha * dlk;
      }
      double dDI = workzdh[pos] - workzdl[pos];
      double div = MathAbs(workzdh[pos] + workzdl[pos]);
      double temp = 0;
      if (div != 0.0)
         temp = 100 * dDI / div;

      if (aADX[pos + 1] != EMPTY_VALUE)
         aADX[pos] = aADX[pos + 1] + alpha * (temp - aADX[pos + 1]);
      else
         aADX[pos] = alpha * temp;

      double maxi = GetHighestAdx(pos, MathMin(Bars - 1 - pos, fzPeriod));
      double mini = GetLowestAdx(pos, MathMin(Bars - 1 - pos, fzPeriod));
      double rrange = maxi - mini;
      flu[pos] = mini + uplevel * rrange / 100.0;
      fld[pos] = mini + downlevel * rrange / 100.0;
   }
   return 0;
}

double GetHighestAdx(int pos, int period)
{
   double val = aADX[pos];
   for (int i = pos + 1; i < pos + period; ++i)
   {
      if (val < aADX[i] && aADX[i] != EMPTY_VALUE)
         val = aADX[i];
   }
   return val;
}

double GetLowestAdx(int pos, int period)
{
   double val = aADX[pos];
   for (int i = pos + 1; i < pos + period; ++i)
   {
      if (val > aADX[i] && aADX[i] != EMPTY_VALUE)
         val = aADX[i];
   }
   return val;
}