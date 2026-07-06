// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70594

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
#property indicator_chart_window

input string obj_id = "Triangle"; // Objects id
input bool k1 = true; // Triangle
input bool k2 = false; // Expanding Triangle
input bool k5 = false; // Wedges
input bool k6 = false; // Down Wedges
input int x = 5 ; // Max. Base / Side Ratio
input int y = 5; // Max. Side / Side Ratio
input int frame = 50; // Frame Size
input int bars_limit = 100000; // Bars limit
input color top_color = Green; // Top color
input color bottom_color = Red; // Bottom color

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double upy[], downy[];

int init()
{
   IndicatorObjPrefix = obj_id;
   IndicatorShortName("Triangle With Trading");

   IndicatorBuffers(2);

   int id = 0;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, upy);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, downy);
   ++id;

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(upy, EMPTY_VALUE);
      ArrayInitialize(downy, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 5;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      upy[pos] = 0;
      downy[pos] = 0;
      double curr = high[pos + 2];
      if (curr >= high[pos + 4] && curr >= high[pos + 3] && curr >= high[pos + 1] && curr >= high[pos])
      {
         upy[pos + 2] = high[pos + 2];
      }
      curr = low[pos + 2];
      if (curr <= low[pos + 4] && curr <= low[pos + 3] && curr <= low[pos + 1] && curr <= low[pos])
      {
         downy[pos + 2] = low[pos + 2];
      }

      upy[pos + 1] = 0;
      downy[pos + 1] = 0;
      upy[pos] = 0;
      downy[pos] = 0;

      Draw(pos);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}

double Distance(double x1, double y1, double x2, double y2)
{
   return MathSqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}

void getline(double x1, double y1, double x2, double y2, double& a, double& b)
{
   a = ((y2 - y1) / (x2 - x1));
   b = (y1 - a * x1);
}

void intersect(double a1, double b1, double a2, double b2, double& __x, double& __y)
{
   if (a1 == a2)
   {
      return;
   }

   __x = (b2 - b1) / (a1 - a2);
   __y = a1 * __x + b1;
}

void drawline(double x1, double y1, double x2, double y2, double ix, double iy, color clr, bool isTop)
{
   double lx1, lx2, ly1, ly2;
   if (ix > x1)
   {
      lx1 = ix;
      ly1 = iy;
      lx2 = x2;
      ly2 = y2;
   }
   else if (ix <= x1 && ix >= x2)
   {
      lx1 = x1;
      ly1 = y1;
      lx2 = x2;
      ly2 = y2;
   }
   else
   {
      lx1 = x1;
      ly1 = y1;
      lx2 = ix;
      ly2 = iy;
   }

   if (lx1 >= Bars || lx2 < 0)
   {
      double a, b;
      getline(lx1, ly1, lx2, ly2, a, b);
      if (lx1 >= Bars)
         lx1 = Bars - 1;
      if (lx2 < 0)
         lx2 = 0;
      ly1 = a * lx1 + b;
      ly2 = a * lx2 + b;
   }

   datetime date1, date2;
   date1 = Time[(int)lx1];
   datetime candlesize = Time[0] - Time[1];
   if (lx2 < 0)
      date2 = Time[0] - (datetime)(candlesize * (lx2));
   else
      date2 = Time[(int)lx2];

   ResetLastError();
   string id = IndicatorObjPrefix + TimeToString(date1);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, date1, ly1, date2, ly2))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, ly1);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, ly2);
   ObjectSetInteger(0, id, OBJPROP_TIME1, date1);
   ObjectSetInteger(0, id, OBJPROP_TIME2, date2);
}

void Draw(int period)
{
   double hx1 = 0, hy1 = 0, hx2 = 0, hy2 = 0;
   double lx1 = 0, ly1 = 0, lx2 = 0, ly2 = 0;
   double f = 0;
   for (int i = 0; i < frame; ++i)
   {
      if (upy[period + i] != 0)
      {
         if (hy1 == 0)
         {
            hy1 = upy[period + i];
            hx1 = period + i;
            f = f + 1;
         }
         else if (hy2 == 0)
         {
            hy2 = upy[period + i];
            hx2 = period + i;
            f = f + 1;
         }
      }
      if (downy[period + i] != 0)
      {
         if (ly1 == 0)
         {
            ly1 = downy[period + i];
            lx1 = period + i;
            f = f + 1;
         }
         else if (ly2 == 0)
         {
            ly2 = downy[period + i];
            lx2 = period + i;
            f = f + 1;
         }
      }
      if (f == 4)
         break;
   }

   if (f == 4)
   {
      double ix, iy;
      double a1, b1, a2, b2;
      getline(hx2, hy2, hx1, hy1, a1, b1);
      getline(lx2, ly2, lx1, ly1, a2, b2);
      intersect(a1, b1, a2, b2, ix, iy);
      if (ix == 0)
         return;
      else
      {
         double ls = Distance(lx2, ly2, ix, iy);
         double bs = Distance(hx2, hy2, lx2, ly2);
         double hs = Distance(hx2, hy2, ix, iy);

         if (bs != 0 && (ls / bs > x || hs / bs > x))
            return;
         if (bs > ls || bs > hs)
            return;
         if ((hs != 0 && ls / hs > y) || (ls != 0 && hs / ls > y))
            return;
         if (ix > hx1 && ix > lx1 && iy <= hy1 && iy >= ly1 && !k1)
            return;
         if (ix < hx1 && ix < lx1 && iy <= hy1 && iy >= ly1 && !k2)
            return;
         if (iy > hy1 && iy > ly1 && ix > hx1 && ix > lx1 && !k5)
            return;
         if (iy < hy1 && iy < ly1 && ix > hx1 && ix > lx1 && !k6)
            return;
         if (iy < hy1 && iy < ly1 && ix < hx1 && ix < lx1)
            return;
         if (iy > hy1 && iy > ly1 && ix < hx1 && ix < lx1)
            return;

         drawline(hx2, hy2, hx1, hy1, ix, iy, top_color, true);
         drawline(lx2, ly2, lx1, ly1, ix, iy, bottom_color, false);
      }
   }
}