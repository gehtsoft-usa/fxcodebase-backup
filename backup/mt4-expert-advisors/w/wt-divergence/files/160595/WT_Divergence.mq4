//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76313
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

//--- input parameters
input int WT_ChannelLength = 10;      // WaveTrend channel length
input int WT_Average      = 21;       // WaveTrend average length
input int PivotLeft       = 5;        // pivot detection left bars
input int PivotRight      = 5;        // pivot detection right bars
input int LookbackBars    = 200;      // how many bars to scan for pivots
input bool ShowRegular    = true;     // show regular divergences
input color BullArrowColor = Lime;
input color BearArrowColor = Red;

//--- indicator buffers
double WT_main[];

//--- alert inputs (sound + popup only)
input bool   AlertOn        = true;        // enable alerts
input string UpTrendSound   = "alert.wav";   // BUY sound file name
input string DnTrendSound   = "alert2.wav";  // SELL sound file name

//--- alert state
string   IndicatorName;
string   TF;
datetime warningtime;
datetime pausetime;
string   prevmess;

//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(1);
   SetIndexBuffer(0,WT_main);
   ArraySetAsSeries(WT_main,true);
   IndicatorName = WindowExpertName();
   TF = tf(Period());
   return(INIT_SUCCEEDED);
  }
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
   int start = prev_calculated;
   if(start==0) start=WT_ChannelLength+WT_Average;

   //--- prepare arrays
   static double ap[]; ArrayResize(ap,rates_total);
   ArraySetAsSeries(ap,true);
   for(int i=0;i<rates_total;i++) ap[i]=(high[i]+low[i]+close[i])/3.0;

   //--- ESA
   static double esa[]; ArrayResize(esa,rates_total); ArraySetAsSeries(esa,true);
   double alpha = 2.0/(WT_ChannelLength+1.0);
   esa[rates_total-1]=ap[rates_total-1];
   for(int i=rates_total-2;i>=0;i--)
      esa[i]=alpha*ap[i]+(1-alpha)*esa[i+1];

   //--- D
   static double d[]; ArrayResize(d,rates_total); ArraySetAsSeries(d,true);
   for(int i=0;i<rates_total;i++) d[i]=ap[i]-esa[i];

   //--- CI
   static double ci[]; ArrayResize(ci,rates_total); ArraySetAsSeries(ci,true);
   double alpha2=2.0/(WT_Average+1.0);
   ci[rates_total-1]=d[rates_total-1];
   for(int i=rates_total-2;i>=0;i--)
      ci[i]=alpha2*d[i]+(1-alpha2)*ci[i+1];

   for(int i=0;i<rates_total;i++) WT_main[i]=ci[i];

   if(rates_total<LookbackBars) return(rates_total);

   DetectDivergences(rates_total,time,high,low);

   return(rates_total);
  }
//+------------------------------------------------------------------+
void DetectDivergences(int rates_total,const datetime &time[],const double &high[],const double &low[])
  {
   // scan pivots
   for(int i=PivotRight;i<LookbackBars;i++)
     {
      int idx=i;
      if(IsHighPivot(idx,high) && ShowRegular)
        {
         int prev=FindPrevHigh(idx,high);
         if(prev!=-1)
           {
            if(high[idx]>high[prev] && WT_main[idx]<WT_main[prev])
              {
               DrawArrow("BearDiv"+IntegerToString(idx),time[idx],high[idx]+(Point*10),234,BearArrowColor);
               if(AlertOn && idx==PivotRight)
                 {
                  BoxAlert(true,": SELL Divergence @ "+DoubleToStr(high[idx],Digits));
                  WarningSound(true,1,3,DnTrendSound,time[idx]);
                 }
              }
           }
        }
      if(IsLowPivot(idx,low) && ShowRegular)
        {
         int prev=FindPrevLow(idx,low);
         if(prev!=-1)
           {
            if(low[idx]<low[prev] && WT_main[idx]>WT_main[prev])
              {
               DrawArrow("BullDiv"+IntegerToString(idx),time[idx],low[idx]-(Point*10),233,BullArrowColor);
               if(AlertOn && idx==PivotRight)
                 {
                  BoxAlert(true,": BUY Divergence @ "+DoubleToStr(low[idx],Digits));
                  WarningSound(true,1,3,UpTrendSound,time[idx]);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
bool IsHighPivot(int i,const double &high[])
  {
   for(int l=1;l<=PivotLeft;l++) if(high[i]<=high[i+l]) return(false);
   for(int r=1;r<=PivotRight;r++) if(high[i]<=high[i-r]) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
bool IsLowPivot(int i,const double &low[])
  {
   for(int l=1;l<=PivotLeft;l++) if(low[i]>=low[i+l]) return(false);
   for(int r=1;r<=PivotRight;r++) if(low[i]>=low[i-r]) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
int FindPrevHigh(int from,const double &high[])
  {
   for(int i=from+PivotRight;i<LookbackBars;i++) if(IsHighPivot(i,high)) return(i);
   return(-1);
  }
//+------------------------------------------------------------------+
int FindPrevLow(int from,const double &low[])
  {
   for(int i=from+PivotRight;i<LookbackBars;i++) if(IsLowPivot(i,low)) return(i);
   return(-1);
  }
//+------------------------------------------------------------------+
void DrawArrow(string name,datetime t,double price,int code,color col)
  {
   if(ObjectFind(0,name)>=0) return;
   ObjectCreate(0,name,OBJ_ARROW,0,t,price);
   ObjectSetInteger(0,name,OBJPROP_ARROWCODE,code);
   ObjectSetInteger(0,name,OBJPROP_COLOR,col);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,2);
  }
//+------------------------------------------------------------------+

bool Pause(int sec)
  {
   if(TimeCurrent() >= pausetime + sec) {pausetime = TimeCurrent(); return(true);}   
   return(false);
  }
//+------------------------------------------------------------------+
void WarningSound(bool cond,int num,int sec,string sound,datetime curtime)
  {
   static int i;
   if(cond)
     {
      if(curtime != warningtime) i = 0;
      if(i < num && Pause(sec)) { PlaySound(sound); warningtime = curtime; i++; }
     }
  }
//+------------------------------------------------------------------+
bool BoxAlert(bool cond,string text)
  {
   string mess = IndicatorName + "("+Symbol()+","+TF+")" + text;
   if (cond && mess != prevmess)
     {
      Alert(mess);
      prevmess = mess;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
string tf(int itimeframe)
  {
   switch(itimeframe)
     {
      case PERIOD_M1:   return("M1");
      case PERIOD_M5:   return("M5");
      case PERIOD_M15:  return("M15");
      case PERIOD_M30:  return("M30");
      case PERIOD_H1:   return("H1");
      case PERIOD_H4:   return("H4");
      case PERIOD_D1:   return("D1");
      case PERIOD_W1:   return("W1");
      case PERIOD_MN1:  return("MN1");
      default:
        {
         if(itimeframe <  PERIOD_H1 ) return("M"  + IntegerToString(itimeframe));
         if(itimeframe >= PERIOD_H1 ) return("H"  + IntegerToString(itimeframe/PERIOD_H1));
         if(itimeframe >= PERIOD_D1 ) return("D"  + IntegerToString(itimeframe/PERIOD_D1));
         if(itimeframe >= PERIOD_W1 ) return("W"  + IntegerToString(itimeframe/PERIOD_W1));
         if(itimeframe >= PERIOD_MN1) return("MN" + IntegerToString(itimeframe/PERIOD_MN1));
        }
     }
   return("N/A");
  }
//+------------------------------------------------------------------+
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76313
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
 