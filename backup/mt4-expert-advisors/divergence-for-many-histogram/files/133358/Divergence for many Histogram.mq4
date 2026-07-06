// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69766

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

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

input int lb = 5; // Left Bars
input int rb = 5; // Right Bars
input bool shownum = true; // Show Divergence Number
input bool showindis = false; // Show Indicator Names
input bool showpivot = false; // Show Pivot Points
input bool calcmacd = true; // MACD
input bool calcmacda = true; // MACD Histogram
input bool calcrsi = true; // RSI
input bool calcstoc = true; // Stochastic
input bool calccci = true; // CCI
input bool calcmom = true; // Momentum
input bool calcobv = true; // OBV
input bool calccmf = true; // Chaikin Money Flow

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

double closeChange[], volume[], Cmfm[], lastHigh[], obv[], lastLow[], Cmfv[], negative[], positive[];

int init()
{
   IndicatorName = GenerateIndicatorName("Divergence for many indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(9);
   int id = 0;
   SetIndexStyle(id, DRAW_HISTOGRAM);
   SetIndexBuffer(id, negative);
   SetIndexLabel(id, "Negative Divergence");
   ++id;

   SetIndexStyle(id, DRAW_HISTOGRAM);
   SetIndexBuffer(id, positive);
   SetIndexLabel(id, "Positive Divergence");
   ++id;
   
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, closeChange);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, Cmfm);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, volume);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, lastHigh);
   SetIndexEmptyValue(id, 0);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, lastLow);
   SetIndexEmptyValue(id, 0);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, obv);
   SetIndexEmptyValue(id, 0);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, Cmfv);
   SetIndexEmptyValue(id, 0);
   ++id;

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

bool Isemptyh(int i)
{
   int newtopIndex = iHighest(_Symbol, _Period, MODE_HIGH, lb, i);
   double newtop = iHigh(_Symbol, _Period, newtopIndex);
   int lastHighI = (int)lastHigh[i] + i;
   if (newtop > High[lastHighI])
   {
      double diff = (newtop - High[lastHighI]) / lastHigh[i];
      double hline = newtop - diff;
      for (int x = 1; x < lastHigh[i] - 1; ++x)
      {
         if (Close[i + x] > hline)
         {
            return false;
         }
         hline = hline - diff;
      }
      return true;
   }
   return false;
}

bool Isemptyl(int i)
{
   int newtopIndex = iLowest(_Symbol, _Period, MODE_LOW, lb, i);
   double newtop = iLow(_Symbol, _Period, newtopIndex);
   int lastLowI = (int)lastLow[i] + i;
   if (newtop < Low[lastLowI])
   {
      double diff = (newtop - Low[lastLowI]) / lastLow[i];
      double hline = newtop - diff;
      for (int x = 1; x < lastLow[i] - 1; ++x)
      {
         if (Close[i + x] < hline)
         {
            return false;
         }
         hline = hline - diff;
      }
      return true;
   }
   return false;
}

void ProcessUp(int i)
{
   int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, lb + rb, i - rb);
   if (highestIndex == i)
   {
      //plotshape(top && showpivot, text="[PH]",  style=shape.labeldown, color=color.white, textcolor=color.black, location=location.abovebar, transp=0, offset = -rb)
      lastHigh[i] = lb;
   }
   else
   {
      lastHigh[i] = lastHigh[i + 1] + 1;
   }
   int lastHighI = (int)lastHigh[i] + i;
   int negdivergence = 0;
   if (Isemptyh(i))
   {
      if (calcrsi && rsi(lastHighI) > rsi(i))
      {
         negdivergence = negdivergence + 1;
      }
      if (calcmacd && macdMacd(lastHighI) > macdMacd(i))
      {
         negdivergence = negdivergence + 1;
      }
      if (calcmacda && deltamacd(lastHighI) > deltamacd(i))
      {
         negdivergence = negdivergence + 1;
      }
      if (calcmom && moment(lastHighI) > moment(i))
      {
         negdivergence = negdivergence + 1;
      }
      if (calccci && cci(lastHighI) > cci(i))
      {
         negdivergence = negdivergence + 1;
      }
      if (calcobv && obv[lastHighI] > obv[i])
      {
         negdivergence = negdivergence + 1;
      }
      if (calcstoc && stk(lastHighI) > stk(i))
      {
         negdivergence = negdivergence + 1;
      }
      if (calccmf && cmf(lastHighI) > cmf(i))
      {
         negdivergence = negdivergence + 1;
      }
   }
   negative[i] = -negdivergence;
}

void ProcessDown(int i)
{
   int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, lb + rb, i - rb);
   if (lowestIndex == i)
   {
      lastLow[i] = lb;
   }
   else
   {
      lastLow[i] = lastLow[i + 1] + 1;
   }
   int posdivergence = 0;
   int lastLowI = (int)lastLow[i] + i;
   if (Isemptyl(i))
   {
      if (calcrsi && rsi(lastLowI) < rsi(i))
      {
         posdivergence = 1;
      }
      if (calcmacd && macdMacd(lastLowI) < macdMacd(i))
      {
         posdivergence = posdivergence + 1;
      }
      if (calcmacda && deltamacd(lastLowI) < deltamacd(i))
      {
         posdivergence = posdivergence + 1;
      }
      if (calcmom && moment(lastLowI) < moment(i))
      {
         posdivergence = posdivergence + 1;
      }
      if (calccci && cci(lastLowI) < cci(i))
      {
         posdivergence = posdivergence + 1;
      }
      if (calcobv && obv[lastLowI] < obv[i])
      {
         posdivergence = posdivergence + 1;
      }
      if (calcstoc && stk(lastLowI) < stk(i))
      {
         posdivergence = posdivergence + 1;
      }
      if (calccmf && cmf(lastLowI) < cmf(i))
      {
         posdivergence = posdivergence + 1;
      }
   }
   positive[i] = posdivergence;
}

double rsi(int i)
{
   return iRSI(_Symbol, _Period, 14, PRICE_CLOSE, i);
}

double macdMacd(int i)
{
   return iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, i);
}

double macdSignal(int i)
{
   return iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, i);
}

double deltamacd(int i)
{
   return macdMacd(i) + macdSignal(i);
}

double moment(int i)
{
   return iMomentum(_Symbol, _Period, 10, PRICE_CLOSE, i);
}

double cci(int i)
{
   return iCCI(_Symbol, _Period, 10, PRICE_CLOSE, i);
}

double stk(int i)
{
   return iStochastic(_Symbol, _Period, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
}

double DI(int i)
{
   return (High[i] - High[i + 1]) - (Low[i + 1] - Low[i]);
}

double cmf(int i)
{
   Cmfv[i] = Cmfm[i] * Volume[i];
   double volumeMA = iMAOnArray(volume, 0, 21, 0, MODE_SMA, i);
   if (volumeMA == 0)
   {
      return 0;
   }
   return iMAOnArray(Cmfv, 0, 21, 0, MODE_SMA, i) / volumeMA;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int minBars = lb + rb + 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      double obvValue = 0;
      if ((Close[i] - Close[i + 1]) > 0)
      {
         obvValue = Volume[i];
      }
      else if ((Close[i] - Close[i + 1]) > 0)
      {
         obvValue = -Volume[i];
      }
      obv[i] = i == Bars - 1 - minBars ? obvValue : obv[i + 1] + obvValue;
      Cmfm[i] = (High[i] - Low[i]) == 0 ? 0 : ((Close[i] - Low[i]) - (High[i] - Close[i])) / (High[i] - Low[i]);
      ProcessUp(i);
      ProcessDown(i);
   }
   return 0;
}
