//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76327
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
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
//HEADER:END

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2

//---- plot Zigzag

#property indicator_label1 "Arrow Up"
#property  indicator_type1  DRAW_ARROW
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property  indicator_type2  DRAW_ARROW
#property indicator_color2 Crimson
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property  indicator_type3   DRAW_SECTION
#property indicator_color3  Red
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

// NOTE: Inputs
// ------------------------------------------------------------------
input string T0                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrDodgerBlue;               // Arrow Up Color:
input color  ArrowDnClr            = Crimson;                // Arrow Down Color:
input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers
double lineTop[];
double lineBottom[];
double ArrowUp[];
double ArrowDn[];


//--- input parameters
int      ExtDepth=17;
int      ExtDeviation=5;
int      ExtBackstep=3;
//--- indicator buffers
double         ZigzagBuffer[];      // main buffer
double         HighMapBuffer[];     // highs
double         LowMapBuffer[];      // lows
int            level=3;             // recounting depth
double         deviation;           // deviation in points
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
  PlotIndexSetInteger(0, PLOT_ARROW, 233);
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);

  SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
  PlotIndexSetInteger(1, PLOT_ARROW, 234);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);
   
   
    SetIndexBuffer(2,ZigzagBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,HighMapBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,LowMapBuffer,INDICATOR_CALCULATIONS);

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

   ArrayInitialize(ArrowUp, 0);
   ArrayInitialize(ArrowDn, 0);

   deviation=ExtDeviation*_Point;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(const double &array[],
             int depth,
             int startPos)
  {
   int index=startPos;
//--- start index validation
   if(startPos<0)
     {
      Print("Invalid parameter in the function iHighest, startPos =",startPos);
      return 0;
     }
   int size=ArraySize(array);
//--- depth correction if need
   if(startPos-depth<0) depth=startPos;
   double max=array[startPos];
//--- start searching
   for(int i=startPos;i>startPos-depth;i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//--- return index of the highest bar
   return(index);
  }
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(const double &array[],
            int depth,
            int startPos)
  {
   int index=startPos;
//--- start index validation
   if(startPos<0)
     {
      Print("Invalid parameter in the function iLowest, startPos =",startPos);
      return 0;
     }
   int size=ArraySize(array);
//--- depth correction if need
   if(startPos-depth<0) depth=startPos;
   double min=array[startPos];
//--- start searching
   for(int i=startPos;i>startPos-depth;i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//--- return index of the lowest bar
   return(index);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   int i=0;
   int limit=0,counterZ=0,whatlookfor=0;
   int shift=0,back=0,lasthighpos=0,lastlowpos=0;
   double val=0,res=0;
   double curlow=0,curhigh=0,lasthigh=0,lastlow=0;
//--- auxiliary enumeration
   enum looling_for
     {
      Pike=1,  // searching for next high
      Sill=-1  // searching for next low
     };
//--- initializing
   if(prev_calculated==0)
     {
      ArrayInitialize(ZigzagBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
      ArrayInitialize(ArrowUp,0.0);
      ArrayInitialize(ArrowDn,0.0);
     }
//--- 
   if(rates_total<100) return(0);
//--- set start position for calculations
   if(prev_calculated==0) limit=ExtDepth;

//--- ZigZag was already counted before
   if(prev_calculated>0)
     {
      i=rates_total-1;
      //--- searching third extremum from the last uncompleted bar
      while(counterZ<level && i>rates_total-100)
        {
         res=ZigzagBuffer[i];
         if(res!=0) counterZ++;
         i--;
        }
      i++;
      limit=i;

      //--- what type of exremum we are going to find
      if(LowMapBuffer[i]!=0)
        {
         curlow=LowMapBuffer[i];
         whatlookfor=Pike;
        }
      else
        {
         curhigh=HighMapBuffer[i];
         whatlookfor=Sill;
        }
      //--- chipping
      for(i=limit+1;i<rates_total && !IsStopped();i++)
        {
         ZigzagBuffer[i]=0.0;
         LowMapBuffer[i]=0.0;
         HighMapBuffer[i]=0.0;
         ArrowUp[i] = 0.0;
         ArrowDn[i] = 0.0;
        }
     }

//--- searching High and Low
   for(shift=limit;shift<rates_total && !IsStopped();shift++)
     {
      val=low[iLowest(low,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else
        {
         lastlow=val;
         if((low[shift]-val)>deviation) val=0.0;
         else
           {
            for(back=1;back<=ExtBackstep;back++)
              {
               res=LowMapBuffer[shift-back];
               if((res!=0) && (res>val)) LowMapBuffer[shift-back]=0.0;
              }
           }
        }
      if(low[shift]==val) LowMapBuffer[shift]=val; else LowMapBuffer[shift]=0.0;
      //--- high
      val=high[iHighest(high,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else
        {
         lasthigh=val;
         if((val-high[shift])>deviation) val=0.0;
         else
           {
            for(back=1;back<=ExtBackstep;back++)
              {
               res=HighMapBuffer[shift-back];
               if((res!=0) && (res<val)) HighMapBuffer[shift-back]=0.0;
              }
           }
        }
      if(high[shift]==val) HighMapBuffer[shift]=val; else HighMapBuffer[shift]=0.0;
     }

//--- last preparation
   if(whatlookfor==0)// uncertain quantity
     {
      lastlow=0;
      lasthigh=0;
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }

//--- final rejection
   for(shift=limit;shift<rates_total && !IsStopped();shift++)
     {
      res=0.0;
      switch(whatlookfor)
        {
         case 0: // search for peak or lawn
            if(lastlow==0 && lasthigh==0)
              {
               if(HighMapBuffer[shift]!=0)
                 {
                  lasthigh=high[shift];
                  lasthighpos=shift;
                  whatlookfor=Sill;
                  ZigzagBuffer[shift]=lasthigh;
                  res=1;
                 }
               if(LowMapBuffer[shift]!=0)
                 {
                  lastlow=low[shift];
                  lastlowpos=shift;
                  whatlookfor=Pike;
                  ZigzagBuffer[shift]=lastlow;
                  res=1;
                 }
              }
            break;
         case Pike: // search for peak
            if(LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<lastlow && HighMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lastlowpos]=0.0;
               lastlowpos=shift;
               lastlow=LowMapBuffer[shift];
               ZigzagBuffer[shift]=lastlow;
               res=1;
              }
            if(HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
              {
               lasthigh=HighMapBuffer[shift];
               lasthighpos=shift;
               ZigzagBuffer[shift]=lasthigh;
               whatlookfor=Sill;
               res=1;
              }
            break;
         case Sill: // search for lawn
            if(HighMapBuffer[shift]!=0.0 && HighMapBuffer[shift]>lasthigh && LowMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lasthighpos]=0.0;
               lasthighpos=shift;
               lasthigh=HighMapBuffer[shift];
               ZigzagBuffer[shift]=lasthigh;
              }
            if(LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
              {
               lastlow=LowMapBuffer[shift];
               lastlowpos=shift;
               ZigzagBuffer[shift]=lastlow;
               whatlookfor=Pike;
              }
            break;
         default: return(rates_total);
        }
     }

    
     for (int i = 0; i < rates_total; i++) {
        if (ZigzagBuffer[i] != 0.0 && HighMapBuffer[i] != 0.0) {
                ArrowDn[i] = high[i] + 50 * _Point;
            }            
        if (ZigzagBuffer[i] != 0.0 && LowMapBuffer[i] != 0.0) {
                ArrowUp[i] = low[i]- 50 * _Point;
            }
        }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+



void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

    text += " ";

    if (!notifications) return;
    if (desktop_notifications) Alert(text);
    if (push_notifications) SendNotification(text);
    if (email_notifications) SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch (lPeriod) {
    case PERIOD_M1:
        return ("M1");
    case PERIOD_M5:
        return ("M5");
    case PERIOD_M15:
        return ("M15");
    case PERIOD_M30:
        return ("M30");
    case PERIOD_H1:
        return ("H1");
    case PERIOD_H4:
        return ("H4");
    case PERIOD_D1:
        return ("D1");
    case PERIOD_W1:
        return ("W1");
    case PERIOD_MN1:
        return ("MN1");
    }
    return IntegerToString(lPeriod);
}

class CNewCandle
{
 private:
  int             _initialCandles;
  string          _symbol;
  ENUM_TIMEFRAMES _tf;

 public:
  CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
  CNewCandle()
  {
    // toma los valores del chart actual
    _initialCandles = iBars(Symbol(), Period());
    _symbol         = Symbol();
    _tf             = Period();
  }
  ~CNewCandle() { ; }

  bool IsNewCandle()
  {
    int _currentCandles = iBars(_symbol, _tf);
    if (_currentCandles > _initialCandles) {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();


//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76327
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
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
//FOOTER:END