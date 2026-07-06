//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160217#p160217

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5

int InpDepth     = 6;     // Depth
int InpDeviation = 5;     // Deviation
int InpBackstep  = 3;     // Backstep

input bool pinbarOn    = true;  // Control if the candle is PinBar
input int  swingsBack  = 5;     // Swing Back to find liquidity
input bool showLines   = true;  // Show liquidity line

//---- indicator buffers
double zz_line[];
double swHigh[];
double swLow[];

double Buy[];
double Sell[];

//--- globals
int ExtLevel = 3; // recounting's depth of extremums

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(ChartID(), "line_");
}

int OnInit()
{
   if(InpBackstep >= InpDepth)
   {
      InpBackstep = InpDepth + 1;
   }

   SetIndexBuffer(0, zz_line, INDICATOR_DATA);
   SetIndexBuffer(1, swHigh, INDICATOR_DATA);
   SetIndexBuffer(2, swLow, INDICATOR_DATA);
   SetIndexBuffer(3, Buy, INDICATOR_DATA);
   SetIndexBuffer(4, Sell, INDICATOR_DATA);

   ArraySetAsSeries(zz_line, true);
   ArraySetAsSeries(swHigh, true);
   ArraySetAsSeries(swLow, true);
   ArraySetAsSeries(Buy, true);
   ArraySetAsSeries(Sell, true);

   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(3, PLOT_ARROW, 233);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, clrNavy);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(4, PLOT_ARROW, 234);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, clrCrimson);

   IndicatorSetString(INDICATOR_SHORTNAME, "Liquidity Sweep(" + IntegerToString(InpDepth) + "," + IntegerToString(InpDeviation) + "," + IntegerToString(InpBackstep) + ")");

   return(INIT_SUCCEEDED);
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
   if(rates_total < InpDepth || InpBackstep >= InpDepth) return(0);

   int i, limit, counterZ, whatlookfor = 0;
   int back, pos, lasthighpos = 0, lastlowpos = 0;
   double extremum;
   double curlow = 0.0, curhigh = 0.0, lasthigh = 0.0, lastlow = 0.0;

   if(prev_calculated == 0)
      limit = InitializeAll(rates_total);
   else
   {
      i = 0; counterZ = 0;
      while(counterZ < ExtLevel && i < MathMin(100, rates_total))
      {
         if(zz_line[i] != 0.0) counterZ++;
         i++;
      }
      if(counterZ == 0)
         limit = InitializeAll(rates_total);
      else
      {
         int k = i; // position got
         limit = i - 1;
         if(swLow[k] != 0.0)
         {
            curlow = swLow[k];
            whatlookfor = 1;
         }
         else if(swHigh[k] != 0.0)
         {
            curhigh = swHigh[k];
            whatlookfor = -1;
         }
         for(i = limit - 1; i >= 0; i--)
         {
            zz_line[i] = 0.0;
            swLow[i] = 0.0;
            swHigh[i] = 0.0;
            Buy[i] = EMPTY_VALUE;
            Sell[i] = EMPTY_VALUE;
         }
      }
   }

   for(i = limit; i >= 0; i--)
   {
      {
         int end_i = MathMin(rates_total - 1, i + InpDepth - 1);
         double min_val = getLow(i, low, rates_total);
         for(int k = i + 1; k <= end_i; k++)
         {
            double v = getLow(k, low, rates_total);
            if(v < min_val)
            {
               min_val = v;
            }
         }
         extremum = min_val;
         if(extremum == lastlow)
            extremum = 0.0;
         else
         {
            lastlow = extremum;
            if(getLow(i, low, rates_total) - extremum > InpDeviation * _Point)
               extremum = 0.0;
            else
            {
               for(back = 1; back <= InpBackstep; back++)
               {
                  pos = i + back;
                  if(pos >= rates_total) continue;
                  if(swLow[pos] != 0.0 && swLow[pos] > extremum) swLow[pos] = 0.0;
               }
            }
         }
         swLow[i] = (getLow(i, low, rates_total) == extremum) ? extremum : 0.0;
      }

      {
         int end_i2 = MathMin(rates_total - 1, i + InpDepth - 1);
         double max_val = getHigh(i, high, rates_total);
         for(int k2 = i + 1; k2 <= end_i2; k2++)
         {
            double v2 = getHigh(k2, high, rates_total);
            if(v2 > max_val)
            {
               max_val = v2;
            }
         }
         extremum = max_val;
         if(extremum == lasthigh)
            extremum = 0.0;
         else
         {
            lasthigh = extremum;
            if(extremum - getHigh(i, high, rates_total) > InpDeviation * _Point)
               extremum = 0.0;
            else
            {
               for(back = 1; back <= InpBackstep; back++)
               {
                  pos = i + back;
                  if(pos >= rates_total) continue;
                  if(swHigh[pos] != 0.0 && swHigh[pos] < extremum) swHigh[pos] = 0.0;
               }
            }
         }
         swHigh[i] = (getHigh(i, high, rates_total) == extremum) ? extremum : 0.0;
      }
   }

   // build zz_line, with signal inside
   if(whatlookfor == 0)
   {
      lastlow = 0.0;
      lasthigh = 0.0;
   }
   else
   {
      lastlow = curlow;
      lasthigh = curhigh;
   }
   for(i = limit; i >= 0; i--)
   {
      switch(whatlookfor)
      {
         case 0:  // find first peak or valley
            if(lastlow == 0.0 && lasthigh == 0.0)
            {
               if(swHigh[i] != 0.0)
               {
                  lasthigh = getHigh(i, high, rates_total);
                  lasthighpos = i;
                  whatlookfor = -1;
                  zz_line[i] = lasthigh;
               }
               else if(swLow[i] != 0.0)
               {
                  lastlow = getLow(i, low, rates_total);
                  lastlowpos = i;
                  whatlookfor = 1;
                  zz_line[i] = lastlow;
               }
            }
            break;
         case 1:  // find peak
            if(swLow[i] != 0.0 && swLow[i] < lastlow && swHigh[i] == 0.0)
            {
               zz_line[lastlowpos] = 0.0;
               lastlowpos = i;
               lastlow = swLow[i];
               zz_line[i] = lastlow;
            }
            else if(swHigh[i] != 0.0 && swLow[i] == 0.0)
            {
               lasthigh = swHigh[i];
               lasthighpos = i;
               zz_line[i] = lasthigh;
               whatlookfor = -1;
            }
            break;
         case -1:  // find valley
            if(swHigh[i] != 0.0 && swHigh[i] > lasthigh && swLow[i] == 0.0)
            {
               zz_line[lasthighpos] = 0.0;
               lasthighpos = i;
               lasthigh = swHigh[i];
               zz_line[i] = lasthigh;
            }
            else if(swLow[i] != 0.0 && swHigh[i] == 0.0)
            {
               lastlow = swLow[i];
               lastlowpos = i;
               zz_line[i] = lastlow;
               whatlookfor = 1;
            }
            break;
      }

      // detect signal here, only for i < 500
      if(i + 1 >= rates_total) continue; // cần i+1
      if(i >= 500) continue;

      int _back = swingsBack;
      // SELL: candle i+1 closes below a previous swHigh and the nearest zz is higher than the previous swHigh
      for(int n = 1; n < _back; n++)
      {
         int j = zzHighShift(i + 1, n, rates_total);
         if(j < 0 || j >= rates_total) continue;
         if(getClose(i + 1, close, rates_total) < swHigh[j] && getClose(i + 1, close, rates_total) < getOpen(i + 1, open, rates_total))
         {
            int u = zzHighShift(i + 1, 1, rates_total);
            if(u < 0 || u >= rates_total) continue;
            if(zz_line[u] > swHigh[j])
            {
               if(pinbarOn)
               {
                  if(isPinbar("dn", u, open, high, low, close, rates_total))
                  {
                     Sell[u] = getHigh(u, high, rates_total);
                     if(showLines) drawLineByShift(getHigh(j, high, rates_total), j, u, time, rates_total, clrCrimson);
                  }
               }
               else
               {
                  Sell[u] = getHigh(u, high, rates_total);
                  if(showLines) drawLineByShift(getHigh(j, high, rates_total), j, u, time, rates_total, clrCrimson);
               }
               break;
            }
         }
      }

      // BUY: candle i+1 closes above a previous swLow and the nearest zz is lower than the previous swLow
      for(int n = 1; n < _back; n++)
      {
         int j = zzLowShift(i + 1, n, rates_total);
         if(j < 0 || j >= rates_total) continue;
         if(getClose(i + 1, close, rates_total) > swLow[j] && getClose(i + 1, close, rates_total) > getOpen(i + 1, open, rates_total))
         {
            int u = zzLowShift(i + 1, 1, rates_total);
            if(u < 0 || u >= rates_total) continue;
            if(zz_line[u] < swLow[j])
            {
               if(pinbarOn)
               {
                  if(isPinbar("up", u, open, high, low, close, rates_total))
                  {
                     Buy[u] = getLow(u, low, rates_total);
                     if(showLines) drawLineByShift(getLow(j, low, rates_total), j, u, time, rates_total, clrNavy);
                  }
               }
               else
               {
                  Buy[u] = getLow(u, low, rates_total);
                  if(showLines) drawLineByShift(getLow(j, low, rates_total), j, u, time, rates_total, clrNavy);
               }
               break;
            }
         }
      }
   }

   ChartRedraw(ChartID());

   return(rates_total);
}

int InitializeAll(int total)
{
   ArrayInitialize(zz_line, 0.0);
   ArrayInitialize(swHigh, 0.0);
   ArrayInitialize(swLow, 0.0);
   ArrayInitialize(Buy, EMPTY_VALUE);
   ArrayInitialize(Sell, EMPTY_VALUE);
   return(total - InpDepth);
}

bool notEmpty(double value)
{
   return value != 0.0 && value != EMPTY_VALUE;
}

bool isPinbar(string side, int si, const double &open[], const double &high[], const double &low[], const double &close[], int total)
{
   int idx = total - 1 - si;
   double o = open[idx];
   double h = high[idx];
   double l = low[idx];
   double c = close[idx];

   double body = MathAbs(o - c);
   double candle = h - l;
   double upperWick = h - MathMax(o, c);
   double lowerWick = MathMin(o, c) - l;

   if(candle == 0) return false;

   double bodyToRange = body / candle;

   if(side == "up")
   {
      if(lowerWick >= body * 2 && bodyToRange < 0.3 && upperWick < lowerWick * 0.5) return true;
   }
   else if(side == "dn")
   {
      if(upperWick >= body * 2 && bodyToRange < 0.3 && lowerWick < upperWick * 0.5) return true;
   }
   return false;
}

int zzHighShift(int i, int find, int total)
{
   int j = i;
   int count = 0;
   int max_j = MathMin(total - 1, i + 200);
   while(count < find && j <= max_j)
   {
      if(notEmpty(zz_line[j]) && notEmpty(swHigh[j]))
         count++;
      j++;
   }
   return j - 1;
}

int zzLowShift(int i, int find, int total)
{
   int j = i;
   int count = 0;
   int max_j = MathMin(total - 1, i + 200);
   while(count < find && j <= max_j)
   {
      if(notEmpty(zz_line[j]) && notEmpty(swLow[j]))
         count++;
      j++;
   }
   return j - 1;
}

void drawLine(double price, datetime iniTime, datetime endTime, color clr)
{
   string name = StringFormat("line_%I64d_%I64d_%s", (long)iniTime, (long)endTime, DoubleToString(price, _Digits));
   if(ObjectFind(ChartID(), name) >= 0)
   {
      ObjectMove(ChartID(), name, 0, iniTime, price);
      ObjectMove(ChartID(), name, 1, endTime, price);
   }
   else
   {
      if(!ObjectCreate(ChartID(), name, OBJ_TREND, 0, iniTime, price, endTime, price))
         return;
   }
   ObjectSetInteger(ChartID(), name, OBJPROP_RAY, false);
   ObjectSetInteger(ChartID(), name, OBJPROP_COLOR, clr);
   ObjectSetInteger(ChartID(), name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(ChartID(), name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(ChartID(), name, OBJPROP_BACK, false);
   ObjectSetInteger(ChartID(), name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(ChartID(), name, OBJPROP_HIDDEN, false);
}

int seriesToRawIndex(int si, int total, const double &arr[])
{
   bool is_series = ArrayGetAsSeries(arr);
   int idx = is_series ? si : (total - 1 - si);
   if(idx < 0) idx = 0;
   if(idx >= total) idx = total - 1;
   return idx;
}

int seriesToRawIndexT(int si, int total, const datetime &arr[])
{
   bool is_series = ArrayGetAsSeries(arr);
   int idx = is_series ? si : (total - 1 - si);
   if(idx < 0) idx = 0;
   if(idx >= total) idx = total - 1;
   return idx;
}

double getOpen(int si, const double &open[], int total)
{
   int idx = seriesToRawIndex(si, total, open);
   return open[idx];
}

double getHigh(int si, const double &high[], int total)
{
   int idx = seriesToRawIndex(si, total, high);
   return high[idx];
}

double getLow(int si, const double &low[], int total)
{
   int idx = seriesToRawIndex(si, total, low);
   return low[idx];
}

double getClose(int si, const double &close[], int total)
{
   int idx = seriesToRawIndex(si, total, close);
   return close[idx];
}

datetime getTime(int si, const datetime &time[], int total)
{
   int idx = seriesToRawIndexT(si, total, time);
   return time[idx];
}

void drawLineByShift(double price, int iniSi, int endSi, const datetime &time[], int total, color clr)
{
   datetime t0 = getTime(iniSi, time, total);
   datetime t1 = getTime(endSi, time, total);
   if(t0 > t1)
   {
      datetime tmp = t0; t0 = t1; t1 = tmp;
   }
   drawLine(price, t0, t1, clr);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160217#p160217

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+