// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69390

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

input int nFE = 8; // length for Fractal Energy calculation.
input int Glength = 13;
input int betaDev = 8;

#define Pi 3.14159265358979323846

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

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

double w, beta, alpha, Go[], Gh[], Gl[], Gc[], gamma[], L0[], L1[], L2[], L3[], RSI[];
int init()
{
   IndicatorName = GenerateIndicatorName("RSI Laguerre Auto-Adjusted with Fractal Energy");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   w = (2 * Pi / Glength);
   beta = (1 - MathCos(w)) / (MathPow(1.414, 2.0 / betaDev) - 1);
   alpha = (-beta + MathSqrt(beta * beta + 2 * beta));

   IndicatorBuffers(10);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, gamma);
   SetIndexLabel(0, "Gamma");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, RSI);
   SetIndexLabel(1, "RSI");

   int index = 2;
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, Go);
   SetIndexEmptyValue(index, 0);
   index++;
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, Gh);
   SetIndexEmptyValue(index, 0);
   index++;
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, Gl);
   SetIndexEmptyValue(index, 0);
   index++;
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, Gc);
   SetIndexEmptyValue(index, 0);
   index++;
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, L0);
   SetIndexEmptyValue(index, 0);
   index++;
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, L1);
   SetIndexEmptyValue(index, 0);
   index++;
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, L2);
   SetIndexEmptyValue(index, 0);
   index++;
   SetIndexStyle(index, DRAW_NONE);
   SetIndexBuffer(index, L3);
   SetIndexEmptyValue(index, 0);
   index++;

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
   int limit = MathMin(Bars - 1 - 0, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      double gc4 = 0;
      double gl4 = 0;
      double gh4 = 0;
      double go4 = 0;
      if (i < Bars - 1 - 4)
      {
         gc4 = Gc[i + 4];
         gh4 = Gh[i + 4];
         gl4 = Gl[i + 4];
         go4 = Go[i + 4];
      }
      double gc3 = 0;
      double gl3 = 0;
      double gh3 = 0;
      double go3 = 0;
      if (i < Bars - 1 - 3)
      {
         gc3 = Gc[i + 3];
         gh3 = Gh[i + 3];
         gl3 = Gl[i + 3];
         go3 = Go[i + 3];
      }
      double gc2 = 0;
      double gl2 = 0;
      double gh2 = 0;
      double go2 = 0;
      if (i < Bars - 1 - 2)
      {
         gc2 = Gc[i + 2];
         gh2 = Gh[i + 2];
         gl2 = Gl[i + 2];
         go2 = Go[i + 2];
      }
      double gc1 = 0;
      double gl1 = 0;
      double gh1 = 0;
      double go1 = 0;
      if (i < Bars - 1 - 1)
      {
         gc1 = Gc[i + 1];
         gh1 = Gh[i + 1];
         gl1 = Gl[i + 1];
         go1 = Go[i + 1];
      }
      Go[i] = MathPow(alpha, 4) * Open[i]  + 4 * (1 - alpha) * go1 - 6 * MathPow(1 - alpha, 2) * go2 + 4 * MathPow(1 - alpha, 3) * go3 - MathPow(1 - alpha, 4) * go4;
      Gh[i] = MathPow(alpha, 4) * High[i]  + 4 * (1 - alpha) * gh1 - 6 * MathPow(1 - alpha, 2) * gh2 + 4 * MathPow(1 - alpha, 3) * gh3 - MathPow(1 - alpha, 4) * gh4;
      Gl[i] = MathPow(alpha, 4) * Low[i]   + 4 * (1 - alpha) * gl1 - 6 * MathPow(1 - alpha, 2) * gl2 + 4 * MathPow(1 - alpha, 3) * gl3 - MathPow(1 - alpha, 4) * gl4;
      Gc[i] = MathPow(alpha, 4) * Close[i] + 4 * (1 - alpha) * gc1 - 6 * MathPow(1 - alpha, 2) * gc2 + 4 * MathPow(1 - alpha, 3) * gc3 - MathPow(1 - alpha, 4) * gc4;
      if (i >= Bars - 2)
      {
         continue;
      }
      double o = (Go[i] + Gc[i + 1]) / 2;
      double h = MathMax(Gh[i], Gc[i + 1]);
      double l = Gc[i + 1] == 0 ? Gl[i] : MathMin(Gl[i], Gc[i + 1]);
      double c = (o + h + l + Gc[i]) / 4;
      if (i >= Bars - 1 - nFE - 1)
      {
         continue;
      }

      double summ = 0;
      double hh = 0;
      double ll = 0;
      for (int ii = 0; ii < nFE; ++ii)
      {
         summ += MathMax(Gh[i + ii], Gc[i + ii + 1]) - MathMin(Gl[i + ii], Gc[i + ii + 1]);
         if (hh < Gh[i + ii])
         {
            hh = Gh[i + ii];
         }
         if (ll == 0 || ll > Gl[i + ii])
         {
            ll = Gl[i + ii];
         }
      }
      gamma[i] = 0;
      if (hh - ll != 0)
      {
         gamma[i] = MathLog(summ / (hh - ll)) / MathLog(nFE);
      }
      L0[i] = (1 - gamma[i]) * Gc[i] + gamma[i] * L0[i + 1];
      L1[i] = -gamma[i] * L0[i] + L0[i + 1] + gamma[i] * L1[i + 1];
      L2[i] = -gamma[i] * L1[i] + L1[i + 1] + gamma[i] * L2[i + 1];
      L3[i] = -gamma[i] * L2[i] + L2[i + 1] + gamma[i] * L3[i + 1];
      double CU1, CD1, CU2, CD2, CU, CD;
      if (L0[i] >= L1[i])
      {
         CU1 = L0[i] - L1[i];
         CD1 = 0;
      } 
      else 
      {
         CD1 = L1[i] - L0[i];
         CU1 = 0;
      }
      if (L1[i] >= L2[i])
      {
         CU2 = CU1 + L1[i] - L2[i];
         CD2 = CD1;
      } 
      else 
      {
         CD2 = CD1 + L2[i] - L1[i];
         CU2 = CU1;
      }
      if (L2[i] >= L3[i])
      {
         CU = CU2 + L2[i] - L3[i];
         CD = CD2;
      }
      else
      {
         CU = CU2;
         CD = CD2 + L3[i] - L2[i];
      }

      RSI[i] = CU + CD != 0 ? CU / (CU + CD) : 0;
   }
   return 0;
}