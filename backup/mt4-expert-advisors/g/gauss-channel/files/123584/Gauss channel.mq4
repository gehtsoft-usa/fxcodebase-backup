// Id: 23774

// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67306

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
#property version   "1.1"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_color4 Blue
#property indicator_color5 Lime
#property indicator_label1 "Top"
#property indicator_label2 "DevTop"
#property indicator_label3 "Central"
#property indicator_label4 "DevBottom"
#property indicator_label5 "Bottom"

extern int p = 125; // Period
extern int m = 2; // m
extern int i = 0; // i
extern double kstd = 2; // kstd

double Top[], DevTop[], Central[], DevBottom[], Bottom[];

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

class AI
{
public:
   double data[];
   AI(const int n)
   {
      ArrayResize(data, n);
   }
};

int nn;
class ArraysBuffer
{
public:
   double sx[];
   double b[];
   double x[];
   AI *ai[];

   ArraysBuffer(const int n)
   {
      ArrayResize(sx, n * 2 - 1);      
      ArrayResize(b, n);
      ArrayResize(ai, n);
      ArrayResize(x, n);
      ArrayResize(ai, n);
      for (int ii = 0; ii < n; ++ii)
      {
         ai[ii] = new AI(n);
      }
      
      sx[0] = p + 1;
      for (int mi = 1; mi <= nn * 2 - 2; mi++)
      {
         double sum = 0;
         for (int ii = 0; ii <= p; ++ii)
         {
            sum += MathPow(i + ii, mi);
         }
         sx[mi] = sum;
      }
   }
   ~ArraysBuffer()
   {
      int n = ArraySize(ai);
      for (int ii = 0; ii < n; ++ii)
      {
         delete ai[ii];
      }
   }

};
ArraysBuffer *arrays;

int init()
{
   IndicatorName = GenerateIndicatorName("Gauss channel");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexBuffer(0, Top);
   SetIndexStyle(1, DRAW_LINE, 0, 2);
   SetIndexBuffer(1, DevTop);
   SetIndexStyle(2, DRAW_LINE, 0, 2);
   SetIndexBuffer(2, Central);
   SetIndexStyle(3, DRAW_LINE, 0, 2);
   SetIndexBuffer(3, DevBottom);
   SetIndexStyle(4, DRAW_LINE, 0, 2);
   SetIndexBuffer(4, Bottom);
   nn = m + 1;
   arrays = new ArraysBuffer(nn);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

void CalcSyx(const int pos)
{
   for (int mi = 1; mi <= nn; mi++)
   {
      double sum = 0.00000;
      for (int ii = 0; ii <= p; ii++)
      {
         if (mi == 1)
            sum += Close[i + ii];
         else
            sum += Close[i + ii] * MathPow(i + ii, (mi - 1));
      }
      arrays.b[mi - 1] = sum;
   }
}

int FindLL(const int kk)
{
   int ll = 0;
   double mm = 0;
   for (int ii = kk; ii <= nn; ++ii)
   {
      if (MathAbs(arrays.ai[ii - 1].data[kk - 1]) > mm)
      {
         mm = MathAbs(arrays.ai[ii - 1].data[kk - 1]);
         ll = ii;
      }
   }
   return ll;
}

void CalcMatrix(const int pos)
{
   for (int jj = 1; jj <= nn; jj++)
   {
      for (int ii = 1; ii <= nn; ii++)
      {
         int kk = ii + jj - 1;
         arrays.ai[ii - 1].data[jj - 1] = arrays.sx[kk - 1];
      }
   }
}

void Calc(const int pos)
{
   CalcMatrix(pos);
   CalcSyx(pos);
   //===============Gauss===================
   for (int kk = 1; kk <= (nn - 1); ++kk)
   {
      int ll = FindLL(kk);
      if (ll == 0)
         return;

      if (ll != kk)
      {
         for (int jj = 1; jj <= nn; ++jj)
         {
            double tt = arrays.ai[kk - 1].data[jj - 1];
            arrays.ai[kk - 1].data[jj - 1] = arrays.ai[ll - 1].data[jj - 1];
            arrays.ai[ll - 1].data[jj - 1] = tt;
         }
         double tt = arrays.b[kk - 1];
         arrays.b[kk - 1] = arrays.b[ll - 1];
         arrays.b[ll - 1] = tt;
      }

      for (int ii = kk + 1; ii <= nn; ++ii)
      {
         double qq = arrays.ai[ii - 1].data[kk - 1] / arrays.ai[kk - 1].data[kk - 1];
         for (int jj = 1; jj <= nn; ++jj)
         {
            if (jj == kk)
               arrays.ai[ii - 1].data[jj - 1] = 0;
            else
               arrays.ai[ii - 1].data[jj - 1] = arrays.ai[ii - 1].data[jj - 1] - qq * arrays.ai[kk - 1].data[jj - 1];
         }
         arrays.b[ii - 1] = arrays.b[ii - 1] - qq * arrays.b[kk - 1];
      }
   }

   arrays.x[nn - 1] = arrays.b[nn - 1] / arrays.ai[nn - 1].data[nn - 1];

   for (int ii = nn - 1; ii >= 1; ii--)
   {
      double tt = 0;
      for (int jj = 1; jj <= nn - ii; jj++)
      {
         tt += arrays.ai[ii - 1].data[ii + jj - 1] * arrays.x[ii + jj - 1];
         arrays.x[ii - 1] = (1 / arrays.ai[ii - 1].data[ii - 1]) * (arrays.b[ii - 1] - tt);
      }
   }

   //===========================================================================================================================

   for (int n = i; n <= (i + p); n++)
   {
      double sum = 0;
      for (int kk = 1; kk <= m; kk++)
         sum += arrays.x[kk] * MathPow(n, kk);

      Central[pos + n] = arrays.x[0] + sum;
   }
   //-----------------------------------Std-----------------------------------------------------------------------------------
   double sq = 0.0;
   for (int n = i; n <= i + p; n++)
      sq += MathPow((Close[pos + n] - Central[pos + n]), 2);
   
   sq = MathSqrt(sq / (p + 1)) * kstd;
   double std = iStdDev(NULL, 0, p, MODE_SMA, 0, PRICE_CLOSE, pos);
   for (int n = i; n <= p; n++)
   {
      Top[pos + n] = Central[pos + n] + sq;
      Bottom[pos + n] = Central[pos + n] - sq;
      DevTop[pos + n] = Central[pos + n] + std;
      DevBottom[pos + n] = Central[pos + n] - std;
   }
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 1 - i - p - 1;
   if(ExtCountedBars > 1) 
      limit = MathMin(Bars - ExtCountedBars - 1 - i - p - 1, limit);
   int pos = limit;
   while (pos >= 0)
   {
      Central[pos + i + p + 1] = EMPTY_VALUE;
      Top[pos + i + p + 1] = EMPTY_VALUE;
      Bottom[pos + i + p + 1] = EMPTY_VALUE;
      DevTop[pos + i + p + 1] = EMPTY_VALUE;
      DevBottom[pos + i + p + 1] = EMPTY_VALUE;
      Calc(pos);
      pos--;
   } 
   return(0);
}
