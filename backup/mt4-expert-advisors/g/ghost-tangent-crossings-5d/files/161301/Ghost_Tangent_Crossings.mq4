// -- Project -------------------------------------------------------------------------------
/*
Name:        Ghost_Tangent_Crossings
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161191#p161191
License:     GNU
*/

// -- Author --------------------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations -------------------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -----------------------------------------------------------------------------
/*
(c) 2025 Gehtsoft USA LLC - https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/

#property copyright "Copyright (c) 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   0
#define PREFIX  "GTC_"
#define DEG2RAD 0.017453292519943295
enum PivotStyle
  {
   PIVOT_WICK = 0,
   PIVOT_BODY = 1
  };
enum EquipointStyle
  {
   EQUIP_DIRECTIONAL = 0,
   EQUIP_HORIZONTAL  = 1,
   EQUIP_NONE        = 2
  };
input PivotStyle      InpPivotStyle      = PIVOT_WICK;          // Pivot Style (Wick/Body)
input int             InpPivotForward    = 25;                  // Pivot Lookforward (>=1)
input bool            InpShowElliptical  = true;                // Show Elliptical Zig-Zag
input bool            InpShowGhosts      = true;                // Show Ghost Elliptical Zig-Zag
input bool            InpShowBreak       = true;                // Show Break
input int             InpMaxZig          = 10;                  // Max Zig-Zags
input EquipointStyle  InpEquipStyle      = EQUIP_DIRECTIONAL;   // Equipoint Style
input bool            InpExtendLines     = false;               // Extend Lines
input color           InpUpColor         = C'27,207,102';       // Up Color
input color           InpDownColor       = C'238,45,45';        // Down Color
input color           InpGhostUpColor    = C'80,200,150';       // Ghost Up Color (approx. transparent)
input color           InpGhostDownColor  = C'200,90,90';        // Ghost Down Color (approx. transparent)
input color           InpTextColor       = C'238,238,238';      // Text Color
input int             InpArrowOffsetPts  = 20;                  // Arrow offset in Points
input int             InpMaxBarsBack     = 1000;                // Max bars back
double                DummyBuffer[];
struct PivotState
  {
   double            current;
   int               current_idx;
   double            previous;
   int               previous_idx;
  };
struct ChartPoint
  {
   int               index;
   double            price;
  };
string                g_zigNames[];
string                g_zigPointNames[];
string                g_equipNames[];
string                g_breakArrowNames[];
string                g_ghostZigNames[];
string                g_ghostPointNames[];
string                g_ghostEquipNames[];
int                   g_objectCounter = 0;

int    ChronoToShift(const int total, const int pindex);

int    CurrentPeriodSeconds();

datetime IndexToTime(const int index, const int total, const datetime &chrono[]);

string NextName(const string tag);

void   PushName(string &arr[], const string name);

void   RemoveFirst(string &arr[]);

void   ClearNames(string &arr[]);

void   ClearByPrefix(const string prefix);

void   ResetObjectState();

void   DumpGhost();

void   AddPoint(ChartPoint &pts[], int &count, const int idx, const double price);

int    GenerateEllipse(const int start_x, const int end_x, const double start_y, const double end_y, ChartPoint &pts[]);

void   EllipseSlope(const int start_x, const int end_x, const double start_y, const double end_y, const ChartPoint &pts[], const int count, ChartPoint &tangent, double &slope);

bool   CheckBreak(const int tangentIdx, const double tangentPrice, const int forwardLength, const double slope, const bool polarityUp, const int currentIndex, const double &openSrc[], const double &closeSrc[], const int totalBars, double &foundPrice, int &foundIndex, double &linePrice);

bool   PivotHigh(const double &source[], const int total, const int pindex, const int back, const int forward, double &price, int &pivotIndex);

bool   PivotLow(const double &source[], const int total, const int pindex, const int back, const int forward, double &price, int &pivotIndex);

void   CreatePolyline(const string name, const ChartPoint &pts[], const int count, const color clr, const int width, const datetime &chrono[], const int totalBars);

void   CreatePointCircle(const string name, const int index, const double price, const color clr, const datetime &chrono[], const int totalBars);

void   CreateEquipLine(const string name, const int x1, const double y1, const int x2, const double y2, const bool rayRight, const color clr, const datetime &chrono[], const int totalBars, const bool dashed);

void   CreateBreakObjects(const string baseName, const int index, const double price, const bool polarityUp, const color bgColor, const datetime &chrono[], const int totalBars);

void   GenerateZigZag(const int start_x, const int end_x, const double start_y, const double end_y, const bool polarityUp, const bool ghost, const datetime &chrono[], const double &highSrc[], const double &lowSrc[], const double &hiWick[], const double &loWick[], const double &openSrc[], const double &closeSrc[], const int totalBars, const int currentIndex);

double MaxInArray(const double &arr[], const int count, int &idx);

double MinInArray(const double &arr[], const int count, int &idx);

int OnInit()
  {

   IndicatorShortName("Ghost Tangent Crossings [ChartPrime]");

   IndicatorDigits(_Digits);

   SetIndexStyle(0, DRAW_NONE);

   SetIndexBuffer(0, DummyBuffer);

   ArraySetAsSeries(DummyBuffer, true);

   ClearByPrefix(PREFIX);

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

   ClearByPrefix(PREFIX);
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
   int forward = MathMax(InpPivotForward, 1);

   ClearByPrefix(PREFIX);

   ResetObjectState();

   ArrayResize(DummyBuffer, rates_total);

   for(int i = prev_calculated; i < rates_total; i++)
      DummyBuffer[i] = EMPTY_VALUE;

   if(rates_total < (forward + 2))

      return(rates_total);
   int totalBars = MathMin(rates_total, InpMaxBarsBack);
   datetime chronoTime[];
   double   hiChron[];
   double   loChron[];
   double   openChron[];
   double   closeChron[];
   double   highSource[];
   double   lowSource[];

   ArrayResize(chronoTime, totalBars);

   ArrayResize(hiChron, totalBars);

   ArrayResize(loChron, totalBars);

   ArrayResize(openChron, totalBars);

   ArrayResize(closeChron, totalBars);

   ArrayResize(highSource, totalBars);

   ArrayResize(lowSource, totalBars);

   for(int p = 0; p < totalBars; p++)
     {
      int shift = totalBars - 1 - p;
      chronoTime[p]  = time[shift];
      hiChron[p]     = high[shift];
      loChron[p]     = low[shift];
      openChron[p]   = open[shift];
      closeChron[p]  = close[shift];

      if(InpPivotStyle == PIVOT_WICK)
        {
         highSource[p] = hiChron[p];
         lowSource[p]  = loChron[p];
        }
      else
        {
         highSource[p] = MathMax(openChron[p], closeChron[p]);
         lowSource[p]  = MathMin(openChron[p], closeChron[p]);
        }
     }
   PivotState ph;
   PivotState pl;
   ph.current = EMPTY_VALUE;
   ph.previous = EMPTY_VALUE;
   ph.current_idx = -1;
   ph.previous_idx = -1;
   pl = ph;
   int ph_back = forward;
   int pl_back = forward;
   int last_up_start = -1;
   int last_up_end   = -1;
   int last_down_start = -1;
   int last_down_end   = -1;
   double last_high = EMPTY_VALUE;
   double last_low  = EMPTY_VALUE;
   int polarityState = -1;
   int barsSincePH = -1;
   int barsSincePL = -1;

   for(int p = 0; p < totalBars; p++)
     {
      double phPrice = 0.0, plPrice = 0.0;
      int phIdx = -1, plIdx = -1;
      bool new_ph = PivotHigh(highSource, totalBars, p, ph_back, forward, phPrice, phIdx);
      bool new_pl = PivotLow(lowSource, totalBars, p, pl_back, forward, plPrice, plIdx);

      if(new_ph)
        {
         ph.previous     = ph.current;
         ph.previous_idx = ph.current_idx;
         ph.current      = phPrice;
         ph.current_idx  = phIdx;
         barsSincePH     = 0;

         if(polarityState == 1)
           {
            last_high = ph.current;
            last_up_end = ph.current_idx;
           }
        }
      else

         if(barsSincePH >= 0)
            barsSincePH++;

      if(new_pl)
        {
         pl.previous     = pl.current;
         pl.previous_idx = pl.current_idx;
         pl.current      = plPrice;
         pl.current_idx  = plIdx;
         barsSincePL     = 0;

         if(polarityState == 0)
           {
            last_low = pl.current;
            last_down_end = pl.current_idx;
           }
        }
      else

         if(barsSincePL >= 0)
            barsSincePL++;
      bool polarity_up   = (ph.current_idx >= 0 && pl.current_idx >= 0 && ph.current_idx > pl.current_idx);
      bool polarity_down = (ph.current_idx >= 0 && pl.current_idx >= 0 && ph.current_idx < pl.current_idx);
      bool up_wait   = (polarityState != 1);
      bool down_wait = (polarityState == 1);
      bool isConfirmed = (p < totalBars - 1);

      if(new_ph && polarity_up && (last_up_start < pl.current_idx || last_up_start < 0) && up_wait && isConfirmed)
        {

         DumpGhost();
         bool connect = (last_down_end >= 0 ? pl.current_idx == last_down_end : true);
         int start_x = connect ? pl.current_idx : last_down_end;
         int end_x   = ph.current_idx;
         double start_y = ph.current;
         double end_y   = connect ? pl.current : last_low;
         last_up_start = start_x;
         last_up_end   = end_x;
         last_high     = start_y;

         if(last_low == EMPTY_VALUE)
            last_low = end_y;
         polarityState = 1;

         GenerateZigZag(start_x, end_x, start_y, end_y, true, false, chronoTime, highSource, lowSource, hiChron, loChron, openChron, closeChron, totalBars, p);
        }

      if(new_pl && polarity_down && (last_down_start < ph.current_idx || last_down_start < 0) && down_wait && isConfirmed)
        {

         DumpGhost();
         bool connect = (last_up_end >= 0 ? ph.current_idx == last_up_end : true);
         int start_x = connect ? ph.current_idx : last_up_end;
         int end_x   = pl.current_idx;
         double start_y = pl.current;
         double end_y   = connect ? ph.current : last_high;
         last_down_start = start_x;
         last_down_end   = end_x;
         last_low        = start_y;

         if(last_high == EMPTY_VALUE)
            last_high = end_y;
         polarityState   = 0;

         GenerateZigZag(start_x, end_x, start_y, end_y, false, false, chronoTime, highSource, lowSource, hiChron, loChron, openChron, closeChron, totalBars, p);
        }
      bool ghost_up_connect = (last_down_end >= 0 ? pl.current_idx == last_down_end : true);
      int ghost_up_start_x = ghost_up_connect ? pl.current_idx : last_down_end;
      int ghost_up_range = (ghost_up_start_x >= 0 ? p - ghost_up_start_x : -1);
      double ghost_up_start_y = EMPTY_VALUE;
      int ghost_up_since = 0;

      if(ghost_up_range >= 0 && barsSincePL >= 0 && ghost_up_start_x >= 0)
        {
         int limit = ghost_up_range - barsSincePL;

         if(limit > p)
            limit = p;
         double ghostMax[];
         int gCount = 0;

         for(int i = 0; i <= limit; i++)
           {
            int idx = p - i;

            if(idx < 0)
               break;

            ArrayResize(ghostMax, gCount + 1);
            ghostMax[gCount] = highSource[idx];
            gCount++;
           }

         if(gCount > 0)
           {
            ghost_up_start_y = MaxInArray(ghostMax, gCount, ghost_up_since);
           }
        }
      double ghost_up_end_y = ghost_up_connect ? pl.current : last_low;

      if(ghost_up_end_y == EMPTY_VALUE)
         ghost_up_end_y = pl.current;
      int ghost_up_end_x = p - ghost_up_since;

      if(up_wait && !new_ph && InpShowGhosts && ghost_up_start_x >= 0 && ghost_up_end_y != EMPTY_VALUE && ghost_up_start_y != EMPTY_VALUE)
        {

         DumpGhost();

         GenerateZigZag(ghost_up_start_x, ghost_up_end_x, ghost_up_start_y, ghost_up_end_y, true, true, chronoTime, highSource, lowSource, hiChron, loChron, openChron, closeChron, totalBars, p);
        }
      bool ghost_down_connect = (last_up_end >= 0 ? ph.current_idx == last_up_end : true);
      int ghost_down_start_x = ghost_down_connect ? ph.current_idx : last_up_end;
      int ghost_down_range = (ghost_down_start_x >= 0 ? p - ghost_down_start_x : -1);
      double ghost_down_start_y = EMPTY_VALUE;
      int ghost_down_since = 0;

      if(ghost_down_range >= 0 && barsSincePH >= 0 && ghost_down_start_x >= 0)
        {
         int limit = ghost_down_range - barsSincePH;

         if(limit > p)
            limit = p;
         double ghostMin[];
         int gCount = 0;

         for(int i = 0; i <= limit; i++)
           {
            int idx = p - i;

            if(idx < 0)
               break;

            ArrayResize(ghostMin, gCount + 1);
            ghostMin[gCount] = lowSource[idx];
            gCount++;
           }

         if(gCount > 0)
           {
            ghost_down_start_y = MinInArray(ghostMin, gCount, ghost_down_since);
           }
        }
      double ghost_down_end_y = ghost_down_connect ? ph.current : last_high;

      if(ghost_down_end_y == EMPTY_VALUE)
         ghost_down_end_y = ph.current;
      int ghost_down_end_x = p - ghost_down_since;

      if(down_wait && !new_pl && InpShowGhosts && ghost_down_start_x >= 0 && ghost_down_end_y != EMPTY_VALUE && ghost_down_start_y != EMPTY_VALUE)
        {

         DumpGhost();

         GenerateZigZag(ghost_down_start_x, ghost_down_end_x, ghost_down_start_y, ghost_down_end_y, false, true, chronoTime, highSource, lowSource, hiChron, loChron, openChron, closeChron, totalBars, p);
        }

      while(ArraySize(g_zigNames) > InpMaxZig && InpMaxZig >= 0)
        {

         RemoveFirst(g_zigNames);

         RemoveFirst(g_zigPointNames);
        }

      while(ArraySize(g_equipNames) > InpMaxZig && InpMaxZig >= 0)

         RemoveFirst(g_equipNames);

      while(ArraySize(g_breakArrowNames) > InpMaxZig && InpMaxZig >= 0)
        {

         RemoveFirst(g_breakArrowNames);
        }
      int ph_back_new = ph_back;
      int pl_back_new = pl_back;
      double basePh = (last_down_end >= 0 ? (p - last_down_end - pl_back + 1) : 5);
      ph_back_new = (int)MathMin(MathMax(basePh, 0), 500);
      double basePl = (last_up_end >= 0 ? (p - last_up_end - ph_back_new + 1) : 5);
      pl_back_new = (int)MathMin(MathMax(basePl, 0), 500);
      ph_back = ph_back_new;
      pl_back = pl_back_new;
     }

   return(rates_total);
  }

int ChronoToShift(const int total, const int pindex)
  {

   return(total - 1 - pindex);
  }

int CurrentPeriodSeconds()
  {
   int tf = Period();

   if(tf == PERIOD_W1)

      return(604800);

   if(tf == PERIOD_MN1)

      return(2592000);
   int sec = tf * 60;

   if(sec <= 0)
      sec = 60;

   return(sec);
  }

datetime IndexToTime(const int index, const int total, const datetime &chrono[])
  {
   int periodSec = CurrentPeriodSeconds();

   if(index < 0)

      return(chrono[0] - (datetime)(-index) * periodSec);

   if(index >= total)

      return(chrono[total - 1] + (datetime)(index - (total - 1)) * periodSec);

   return(chrono[index]);
  }

string NextName(const string tag)
  {
   g_objectCounter++;

   return(PREFIX + tag + "_" + IntegerToString(g_objectCounter));
  }

void PushName(string &arr[], const string name)
  {
   int sz = ArraySize(arr);

   ArrayResize(arr, sz + 1);
   arr[sz] = name;
  }

void RemoveFirst(string &arr[])
  {
   int sz = ArraySize(arr);

   if(sz <= 0)
      return;
   string base = arr[0];

   if(base != "")
     {

      ObjectDelete(0, base);
      string pref = base + "_";
      int total = ObjectsTotal(0, 0, -1);

      for(int i = total - 1; i >= 0; i--)
        {
         string name = ObjectName(0, i);

         if(StringFind(name, pref) == 0)

            ObjectDelete(0, name);
        }
     }

   for(int i = 1; i < sz; i++)
      arr[i - 1] = arr[i];

   ArrayResize(arr, sz - 1);
  }

void ClearNames(string &arr[])
  {
   int sz = ArraySize(arr);

   for(int i = 0; i < sz; i++)
     {
      string base = arr[i];

      if(base != "")
        {

         ObjectDelete(0, base);
         string pref = base + "_";
         int total = ObjectsTotal(0, 0, -1);

         for(int j = total - 1; j >= 0; j--)
           {
            string name = ObjectName(0, j);

            if(StringFind(name, pref) == 0)

               ObjectDelete(0, name);
           }
        }
     }

   ArrayResize(arr, 0);
  }

void ClearByPrefix(const string prefix)
  {
   int total = ObjectsTotal(0, 0, -1);

   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i);

      if(StringFind(name, prefix) == 0)

         ObjectDelete(0, name);
     }
  }

void ResetObjectState()
  {
   g_objectCounter = 0;

   ClearNames(g_zigNames);

   ClearNames(g_zigPointNames);

   ClearNames(g_equipNames);

   ClearNames(g_breakArrowNames);

   ClearNames(g_ghostZigNames);

   ClearNames(g_ghostPointNames);

   ClearNames(g_ghostEquipNames);
  }

void DumpGhost()
  {

   ClearNames(g_ghostZigNames);

   ClearNames(g_ghostPointNames);

   ClearNames(g_ghostEquipNames);
  }

void AddPoint(ChartPoint &pts[], int &count, const int idx, const double price)
  {

   ArrayResize(pts, count + 1);
   pts[count].index = idx;
   pts[count].price = price;
   count++;
  }

int GenerateEllipse(const int start_x, const int end_x, const double start_y, const double end_y, ChartPoint &pts[])
  {

   ArrayResize(pts, 0);
   int count = 0;
   double a = (double)(end_x - start_x);
   double b = end_y - start_y;

   if(a > 1.0)
     {
      int x = 0;
      bool hasX = false;

      for(int deg = 0; deg <= 90; deg++)
        {
         int newX = (int)(a * MathCos(DEG2RAD * deg));
         double y = b * MathSin(DEG2RAD * deg);

         if(!hasX || x != newX)
           {
            int px = (hasX ? x : newX);

            AddPoint(pts, count, start_x + px, start_y + y);
           }
         x = newX;
         hasX = true;
        }

      AddPoint(pts, count, start_x, end_y);
     }
   else
     {

      AddPoint(pts, count, end_x, start_y);

      AddPoint(pts, count, start_x, end_y);
     }

   return(count);
  }

void EllipseSlope(const int start_x, const int end_x, const double start_y, const double end_y, const ChartPoint &pts[], const int count, ChartPoint &tangent, double &slope)
  {

   if(count > 2)
     {
      int dyCount = count - 1;
      double dy[];

      ArrayResize(dy, dyCount);

      for(int i = 0; i < dyCount; i++)
         dy[i] = MathAbs(pts[i + 1].price - pts[i].price);
      double bestCenter = DBL_MAX;
      int midIndex = 1;

      for(int i = 1; i < dyCount; i++)
        {
         double left = 0.0, right = 0.0;

         for(int l = 0; l <= i; l++)
            left += dy[l];

         for(int r = i - 1; r < dyCount; r++)
            right += dy[r];
         double center = MathAbs(left - right);

         if(center < bestCenter)
           {
            bestCenter = center;
            midIndex = i;
           }
        }
      tangent = pts[midIndex];
      double a = (double)(end_x - start_x);
      double b = end_y - start_y;
      double x = (double)(tangent.index - start_x);
      double y = tangent.price - start_y;

      if(a != 0.0 && y != 0.0)
         slope = -((b * b) * x) / ((a * a) * y);
      else
         slope = 0.0;
     }
   else
     {
      tangent = pts[0];
      slope = -(pts[count - 1].price - pts[0].price);
     }
  }

bool CheckBreak(const int tangentIdx, const double tangentPrice, const int forwardLength, const double slope, const bool polarityUp, const int currentIndex, const double &openSrc[], const double &closeSrc[], const int totalBars, double &foundPrice, int &foundIndex, double &linePrice)
  {
   foundPrice = EMPTY_VALUE;
   foundIndex = -1;
   linePrice  = EMPTY_VALUE;

   for(int i = forwardLength; ; i++)
     {
      int idx = tangentIdx + i;

      if(idx > currentIndex)
         break;

      if(idx < 0 || idx >= totalBars)
         break;
      double checkPrice = tangentPrice + slope * i;

      if(polarityUp)
        {
         double closeNow = closeSrc[idx];
         double openNow  = openSrc[idx];
         double prevClose = (idx - 1 >= 0 ? closeSrc[idx - 1] : openNow);

         if(closeNow < checkPrice && (openNow >= checkPrice || prevClose >= checkPrice))
           {
            foundPrice = closeNow;
            foundIndex = idx;
            linePrice  = checkPrice;

            return(true);
           }
        }
      else
        {
         double closeNow = closeSrc[idx];
         double openNow  = openSrc[idx];
         double prevClose = (idx - 1 >= 0 ? closeSrc[idx - 1] : openNow);

         if(closeNow > checkPrice && (openNow <= checkPrice || prevClose <= checkPrice))
           {
            foundPrice = closeNow;
            foundIndex = idx;
            linePrice  = checkPrice;

            return(true);
           }
        }
     }

   return(false);
  }

bool PivotHigh(const double &source[], const int total, const int pindex, const int back, const int forward, double &price, int &pivotIndex)
  {

   if(pindex < back + forward)

      return(false);
   int center = pindex - forward;

   if(center < 0)

      return(false);
   double candidate = source[center];
   double maxVal = candidate;

   for(int i = 1; i <= back; i++)
     {
      int idx = center - i;

      if(idx < 0)

         return(false);

      if(source[idx] > maxVal)
         maxVal = source[idx];
     }

   for(int i = 1; i <= forward; i++)
     {
      int idx = center + i;

      if(idx >= total)
         break;

      if(source[idx] > maxVal)
         maxVal = source[idx];
     }

   if(candidate >= maxVal - 1e-10)
     {
      price = candidate;
      pivotIndex = center;

      return(true);
     }

   return(false);
  }

bool PivotLow(const double &source[], const int total, const int pindex, const int back, const int forward, double &price, int &pivotIndex)
  {

   if(pindex < back + forward)

      return(false);
   int center = pindex - forward;

   if(center < 0)

      return(false);
   double candidate = source[center];
   double minVal = candidate;

   for(int i = 1; i <= back; i++)
     {
      int idx = center - i;

      if(idx < 0)

         return(false);

      if(source[idx] < minVal)
         minVal = source[idx];
     }

   for(int i = 1; i <= forward; i++)
     {
      int idx = center + i;

      if(idx >= total)
         break;

      if(source[idx] < minVal)
         minVal = source[idx];
     }

   if(candidate <= minVal + 1e-10)
     {
      price = candidate;
      pivotIndex = center;

      return(true);
     }

   return(false);
  }

void CreatePolyline(const string name, const ChartPoint &pts[], const int count, const color clr, const int width, const datetime &chrono[], const int totalBars)
  {

   if(count < 2)
      return;

   for(int i = 1; i < count; i++)
     {
      string seg = name + "_" + IntegerToString(i);
      datetime t1 = IndexToTime(pts[i - 1].index, totalBars, chrono);
      datetime t2 = IndexToTime(pts[i].index, totalBars, chrono);

      ObjectCreate(0, seg, OBJ_TREND, 0, t1, pts[i - 1].price, t2, pts[i].price);

      ObjectSetInteger(0, seg, OBJPROP_COLOR, clr);

      ObjectSetInteger(0, seg, OBJPROP_STYLE, STYLE_SOLID);

      ObjectSetInteger(0, seg, OBJPROP_WIDTH, width);

      ObjectSetInteger(0, seg, OBJPROP_RAY, false);

      ObjectSetInteger(0, seg, OBJPROP_BACK, false);

      ObjectSetInteger(0, seg, OBJPROP_SELECTABLE, false);
     }
  }

void CreatePointCircle(const string name, const int index, const double price, const color clr, const datetime &chrono[], const int totalBars)
  {
   datetime t = IndexToTime(index, totalBars, chrono);

   ObjectCreate(0, name, OBJ_ARROW, 0, t, price);

   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 159);

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);

   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);

   ObjectSetInteger(0, name, OBJPROP_BACK, false);

   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

void CreateEquipLine(const string name, const int x1, const double y1, const int x2, const double y2, const bool rayRight, const color clr, const datetime &chrono[], const int totalBars, const bool dashed)
  {
   datetime t1 = IndexToTime(x1, totalBars, chrono);
   datetime t2 = IndexToTime(x2, totalBars, chrono);

   ObjectCreate(0, name, OBJ_TREND, 0, t1, y1, t2, y2);

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);

   ObjectSetInteger(0, name, OBJPROP_STYLE, dashed ? STYLE_DASH : STYLE_SOLID);

   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);

   ObjectSetInteger(0, name, OBJPROP_RAY, rayRight);

   ObjectSetInteger(0, name, OBJPROP_BACK, false);

   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

void CreateBreakObjects(const string baseName, const int index, const double price, const bool polarityUp, const color bgColor, const datetime &chrono[], const int totalBars)
  {
   int arrowCode = polarityUp ? 234 : 233;
   double arrowPrice = price;
   string arrowName = baseName + "_A";
   datetime t = IndexToTime(index, totalBars, chrono);

   ObjectCreate(0, arrowName, OBJ_ARROW, 0, t, arrowPrice);

   ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, arrowCode);

   ObjectSetInteger(0, arrowName, OBJPROP_COLOR, bgColor);

   ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);

   ObjectSetInteger(0, arrowName, OBJPROP_BACK, false);

   ObjectSetInteger(0, arrowName, OBJPROP_SELECTABLE, false);

   PushName(g_breakArrowNames, arrowName);
  }

double MaxInArray(const double &arr[], const int count, int &idx)
  {
   idx = 0;
   double maxVal = arr[0];

   for(int i = 1; i < count; i++)
     {

      if(arr[i] > maxVal)
        {
         maxVal = arr[i];
         idx = i;
        }
     }

   return(maxVal);
  }

double MinInArray(const double &arr[], const int count, int &idx)
  {
   idx = 0;
   double minVal = arr[0];

   for(int i = 1; i < count; i++)
     {

      if(arr[i] < minVal)
        {
         minVal = arr[i];
         idx = i;
        }
     }

   return(minVal);
  }
void GenerateZigZag(const int start_x,
                    const int end_x,
                    const double start_y,
                    const double end_y,
                    const bool polarityUp,
                    const bool ghost,
                    const datetime &chrono[],
                    const double &highSrc[],
                    const double &lowSrc[],
                    const double &hiWick[],
                    const double &loWick[],
                    const double &openSrc[],
                    const double &closeSrc[],
                    const int totalBars,
                    const int currentIndex)
  {

   if(end_x <= start_x)
      return;
   color upClr = ghost ? InpGhostUpColor : InpUpColor;
   color downClr = ghost ? InpGhostDownColor : InpDownColor;
   color bullishColor = polarityUp ? upClr : downClr;
   ChartPoint ellipsePts[];
   int ellipseCount = GenerateEllipse(start_x, end_x, start_y, end_y, ellipsePts);

   if(ellipseCount < 2)
      return;
   ChartPoint tangent;
   double slope = 0.0;

   EllipseSlope(start_x, end_x, start_y, end_y, ellipsePts, ellipseCount, tangent, slope);
   int length = end_x - start_x;
   int backLength = tangent.index - start_x;
   int forwardLength = length - backLength;

   if(forwardLength < 0)
      forwardLength = 0;

   if(InpShowElliptical)
     {
      string pointName = NextName("ZP");

      CreatePointCircle(pointName, ellipsePts[ellipseCount - 1].index, ellipsePts[ellipseCount - 1].price, bullishColor, chrono, totalBars);

      if(ghost)

         PushName(g_ghostPointNames, pointName);
      else

         PushName(g_zigPointNames, pointName);
      string lineName = NextName("ZL");

      CreatePolyline(lineName, ellipsePts, ellipseCount, bullishColor, 2, chrono, totalBars);

      if(ghost)

         PushName(g_ghostZigNames, lineName);
      else

         PushName(g_zigNames, lineName);
     }

   if(InpEquipStyle != EQUIP_NONE)
     {
      string equipName = NextName("EQ");

      if(InpEquipStyle == EQUIP_DIRECTIONAL)
        {

         if(InpExtendLines)
           {
            int span = MathMax(totalBars, 200);
            int leftIndex = MathMax(0, tangent.index - span);
            int rightIndex = tangent.index + span;
            double leftPrice = tangent.price - slope * (tangent.index - leftIndex);
            double rightPrice = tangent.price + slope * (rightIndex - tangent.index);

            CreateEquipLine(equipName, leftIndex, leftPrice, rightIndex, rightPrice, false, bullishColor, chrono, totalBars, true);
           }
         else
           {
            int leftIndex = MathMax(0, tangent.index - backLength);
            int rightIndex = tangent.index + backLength;
            double leftPrice = tangent.price - slope * (tangent.index - leftIndex);
            double rightPrice = tangent.price + slope * (rightIndex - tangent.index);

            CreateEquipLine(equipName, leftIndex, leftPrice, rightIndex, rightPrice, false, bullishColor, chrono, totalBars, true);
           }
        }
      else

         if(InpEquipStyle == EQUIP_HORIZONTAL)
           {

            if(InpExtendLines)
              {
               int rightIndex = tangent.index + length + 2;

               CreateEquipLine(equipName, tangent.index, tangent.price, rightIndex, tangent.price, true, bullishColor, chrono, totalBars, true);
              }
            else
              {
               int rightIndex = tangent.index + length * 2;

               CreateEquipLine(equipName, tangent.index, tangent.price, rightIndex, tangent.price, false, bullishColor, chrono, totalBars, true);
              }
           }

      if(ghost)

         PushName(g_ghostEquipNames, equipName);
      else

         PushName(g_equipNames, equipName);
     }

   if(InpShowBreak && !ghost)
     {
      double foundPrice = 0.0;
      int foundIndex = -1;
      double linePrice = 0.0;

      if(CheckBreak(tangent.index, tangent.price, forwardLength, slope, polarityUp, currentIndex, openSrc, closeSrc, totalBars, foundPrice, foundIndex, linePrice))
        {
         string baseName = NextName("BR");
         color bg = polarityUp ? InpDownColor : InpUpColor;
         double arrowAt = linePrice;

         if(linePrice == EMPTY_VALUE)
            arrowAt = foundPrice;

         if(polarityUp)
            arrowAt = hiWick[foundIndex] + InpArrowOffsetPts * _Point;
         else
            arrowAt = loWick[foundIndex] - InpArrowOffsetPts * _Point;

         CreateBreakObjects(baseName, foundIndex, arrowAt, polarityUp, bg, chrono, totalBars);
        }
      else
        {

         PushName(g_breakArrowNames, "");
        }
     }
  }


// -- Project -------------------------------------------------------------------------------
/*
Name:        Ghost_Tangent_Crossings
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=161191#p161191
License:     GNU
*/

// -- Author --------------------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations -------------------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -----------------------------------------------------------------------------
/*
(c) 2025 Gehtsoft USA LLC - https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/