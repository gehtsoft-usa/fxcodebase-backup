/── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=153956#p153956
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

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
 

#property indicator_chart_window
#property indicator_buffers  3
#property indicator_color1   Green
#property indicator_color2   Red
#property indicator_width1   3
#property indicator_width2   3
#property strict

extern int    avgPeriod   = 30; // Average period
extern double sensitivity = 3;  // Sensitivity
extern bool alerts = false; //Enable Alerts
extern bool emails = false; //Enable Email Notification
extern bool push   = false; //Enable Push Notification

double upBuffer[],dnBuffer[],signalBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,upBuffer); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,dnBuffer); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,signalBuffer); SetIndexStyle(2,DRAW_NONE); SetIndexLabel(2,"2. Signal (1=Long; 0=Short)"); SetIndexEmptyValue(2,0.0);
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason) { return; }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime &btime[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
  {
   int counted_bars=prev_calculated;
   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=MathMin(rates_total-counted_bars,rates_total-1);

   for(int i=(limit-1); i>=0 && !_StopFlag; i--)
     {
      upBuffer[(i+1)] = EMPTY_VALUE;
      dnBuffer[(i+1)] = EMPTY_VALUE;

      double trend=iPrecisionTrend(high,low,close,avgPeriod,sensitivity,(i+1),rates_total);
      double ptrend=iPrecisionTrend(high,low,close,avgPeriod,sensitivity,i,rates_total);

      if(trend ==  1) { upBuffer[(i+1)] = High[(i+1)]; dnBuffer[(i+1)] = Low[(i+1)]; }
      if(trend == -1) { dnBuffer[(i+1)] = High[(i+1)]; upBuffer[(i+1)] = Low[(i+1)]; }
      if(trend>ptrend)
        {
         signalBuffer[i]=-1;
         if(alerts && i==1)Alert("SELL SIGNAL ON "+Symbol());
         if(emails && i==1)SendMail("SELL SIGNAL ON "+Symbol(),"Signal Sent From Simpler Trend Indicator");
         if(push  &&  i==1)SendNotification("Simpler Trend: SELL SIGNAL ON "+Symbol());
        }
      if(trend<ptrend)
        {
         signalBuffer[i]=1;
         if(alerts && i==1)Alert("BUY SIGNAL ON "+Symbol());
         if(emails && i==1)SendMail("BUY SIGNAL ON "+Symbol(),"Signal Sent From Simpler Trend Indicator");
         if(push  &&  i==1)SendNotification("Simpler Trend: BUY SIGNAL ON "+Symbol());
           }else{
         signalBuffer[i]=trend;
        }

     }
   return(rates_total);
  }

#define _ptInstances     1
#define _ptInstancesSize 7
double  _ptWork[][_ptInstances*_ptInstancesSize];
#define __range 0
#define __trend 1
#define __avgr  2
#define __avgd  3
#define __avgu  4
#define __minc  5
#define __maxc  6
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iPrecisionTrend(const double &_high[],const double &_low[],const double &_close[],int _period,double _sensitivity,int i,int bars,int instanceNo=0)
  {
   if(ArrayRange(_ptWork,0)!=bars) ArrayResize(_ptWork,bars); instanceNo*=_ptInstancesSize; int r=bars-i-1;

   _ptWork[r][instanceNo+__range] = _high[i]-_low[i];
   _ptWork[r][instanceNo+__avgr]  = _ptWork[r][instanceNo+__range];
   int k=1; for(; k<_period && (r-k)>=0; k++) _ptWork[r][instanceNo+__avgr]+=_ptWork[r-k][instanceNo+__range];
   _ptWork[r][instanceNo+__avgr] /= k;
   _ptWork[r][instanceNo+__avgr] *= _sensitivity;


   if(i==(bars-1))
     {
      _ptWork[r][instanceNo+__trend]= 0;
      _ptWork[r][instanceNo+__avgd] = _close[i]-_ptWork[r][instanceNo+__avgr];
      _ptWork[r][instanceNo+__avgu] = _close[i]+_ptWork[r][instanceNo+__avgr];
      _ptWork[r][instanceNo+__minc] = _close[i];
      _ptWork[r][instanceNo+__maxc] = _close[i];
     }
   else
     {
      _ptWork[r][instanceNo+__trend] = _ptWork[r-1][instanceNo+__trend];
      _ptWork[r][instanceNo+__avgd]  = _ptWork[r-1][instanceNo+__avgd];
      _ptWork[r][instanceNo+__avgu]  = _ptWork[r-1][instanceNo+__avgu];
      _ptWork[r][instanceNo+__minc]  = _ptWork[r-1][instanceNo+__minc];
      _ptWork[r][instanceNo+__maxc]  = _ptWork[r-1][instanceNo+__maxc];


      switch((int)_ptWork[r-1][instanceNo+__trend])
        {
         case 0 :
            if(_close[i]>_ptWork[r-1][instanceNo+__avgu])
              {
               _ptWork[r][instanceNo+__minc]  = _close[i];
               _ptWork[r][instanceNo+__avgd]  = _close[i]-_ptWork[r][instanceNo+__avgr];
               _ptWork[r][instanceNo+__trend] =  1;
              }
            if(_close[i]<_ptWork[r-1][instanceNo+__avgd])
              {
               _ptWork[r][instanceNo+__maxc]  = _close[i];
               _ptWork[r][instanceNo+__avgu]  = _close[i]+_ptWork[r][instanceNo+__avgr];
               _ptWork[r][instanceNo+__trend] = -1;
              }
            break;
         case 1 :
            _ptWork[r][instanceNo+__avgd]=_ptWork[r-1][instanceNo+__minc]-_ptWork[r][instanceNo+__avgr];
            if(_close[i]>_ptWork[r-1][instanceNo+__minc]) _ptWork[r][instanceNo+__minc]=_close[i];
            if(_close[i]<_ptWork[r-1][instanceNo+__avgd])
              {
               _ptWork[r][instanceNo+__maxc] = _close[i];
               _ptWork[r][instanceNo+__avgu] = _close[i]+_ptWork[r][instanceNo+__avgr];
               _ptWork[r][instanceNo+__trend]= -1;
              }
            break;
         case -1 :
            _ptWork[r][instanceNo+__avgu]=_ptWork[r-1][instanceNo+__maxc]+_ptWork[r][instanceNo+__avgr];
            if(_close[i]<_ptWork[r-1][instanceNo+__maxc]) _ptWork[r][instanceNo+__maxc]=_close[i];
            if(_close[i]>_ptWork[r-1][instanceNo+__avgu])
              {
               _ptWork[r][instanceNo+__minc]  = _close[i];
               _ptWork[r][instanceNo+__avgd]  = _close[i]-_ptWork[r][instanceNo+__avgr];
               _ptWork[r][instanceNo+__trend] = 1;
              }
        }
     }
   return(_ptWork[r][instanceNo+__trend]);
  }
//+------------------------------------------------------------------+
/── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=153956#p153956
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
