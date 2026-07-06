//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76345
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

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern color Bullish = MediumSeaGreen;
extern color Bearish = Orange;

extern int Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int OverBought=70;
extern int OverSold=30;

double RSI[];

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


int init()
  {
   IndicatorName = GenerateIndicatorName("RSI Divergence");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSI);
   SetLevelValue(1,OverSold);
   SetLevelValue(2,OverBought);
   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }
  
bool HasLineFromFirst(int First)
{
 int total=ObjectsTotal();
 string prefix=IndicatorObjPrefix + Time[First] + "_";
 for (int i=0;i<total;i++)
 {
  string name=ObjectName(i);
  if (StringLen(name)>=StringLen(prefix) && StringSubstr(name,0,StringLen(prefix))==prefix)
  {
   return(true);
  }
 }
 return(false);
}

void DrawLine(int First, int Second, bool BullFl)
{
 string ObjName=IndicatorObjPrefix + Time[First]+"_"+Time[Second];
 int WindowNumber;
 // nếu đã có line bắt đầu từ First (và không phải đúng cặp First-Second này) thì bỏ qua
 if (HasLineFromFirst(First) && ObjectFind(ObjName)==-1)
  return;
 if (ObjectFind(ObjName)==-1)
 {
  WindowNumber=WindowFind("RSI Divergence");
  if (WindowNumber!=-1)
  {
   ObjectCreate(ObjName, OBJ_TREND, WindowNumber, Time[First], RSI[First], Time[Second], RSI[Second]);
   ObjectSet(ObjName, OBJPROP_RAY, false);
   ObjectCreate(ObjName+"A", OBJ_ARROW, WindowNumber, Time[Second], RSI[Second]);
   if (BullFl)
   {
    ObjectSet(ObjName, OBJPROP_COLOR, Bullish);
    ObjectCreate(ObjName+"~", OBJ_TREND, 0, Time[First], Low[First], Time[Second], Low[Second]);
    ObjectSet(ObjName+"~", OBJPROP_COLOR, Bullish);
    ObjectCreate(ObjName+"~A", OBJ_ARROW, 0, Time[Second], Low[Second]);
    ObjectSet(ObjName+"~A", OBJPROP_COLOR, Bullish);
    ObjectSet(ObjName+"~A", OBJPROP_ARROWCODE, 241);
    ObjectSet(ObjName+"A", OBJPROP_COLOR, Bullish);
    ObjectSet(ObjName+"A", OBJPROP_ARROWCODE, 241);
   }
   else
   {
    ObjectSet(ObjName, OBJPROP_COLOR, Bearish);
    ObjectCreate(ObjName+"~", OBJ_TREND, 0, Time[First], High[First], Time[Second], High[Second]);
    ObjectSet(ObjName+"~", OBJPROP_COLOR, Bearish);
    ObjectCreate(ObjName+"~A", OBJ_ARROW, 0, Time[Second], High[Second]);
    ObjectSet(ObjName+"~A", OBJPROP_COLOR, Bearish);
    ObjectSet(ObjName+"~A", OBJPROP_ARROWCODE, 242);
    ObjectSet(ObjName+"A", OBJPROP_COLOR, Bearish);
    ObjectSet(ObjName+"A", OBJPROP_ARROWCODE, 242);
   } 
   ObjectSet(ObjName+"~", OBJPROP_RAY, false);
  } 
 }
} 
  
bool isTrough(int bar)
{
 int i;
 if (RSI[bar]<OverSold && RSI[bar]<RSI[bar+1] && RSI[bar]<RSI[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (RSI[i]>OverSold)
   {
    return (true);
   }
   else
   {
    if (RSI[bar]>RSI[i])
    {
     return (false);
    }
   }
  }
 }
} 

int prevTrough(int bar)
{
 int i;
 for (i=bar+5;i<=Bars;i++)
 {
  if (RSI[i]<=RSI[i+1] && RSI[i]<RSI[i+2] && RSI[i]<=RSI[i-1] && RSI[i]<RSI[i-2])
  {
   return (i);
  }
 }
 return (EMPTY_VALUE);
}

void processBullish(int bar)
{
 if (isTrough(bar))
 {
  int curr, prev;
  curr=bar;
  prev=prevTrough(bar);
  if (prev!=EMPTY_VALUE)
  {
   if (RSI[curr]>RSI[prev] && Low[curr]<Low[prev])
   {
    DrawLine(prev, curr, true);
   }
   else
   {
    if (RSI[curr]<RSI[prev] && Low[curr]>Low[prev])
    {
     DrawLine(prev, curr, true);
    }
   }
  }
 }
}  

bool isPeak(int bar)
{
 int i;
 if (RSI[bar]>OverBought && RSI[bar]>RSI[bar+1] && RSI[bar]>RSI[bar-1])
 {
  for (i=bar+1;i<=Bars;i++)
  {
   if (RSI[i]<OverBought)
   {
    return (true);
   }
   else
   {
    if (RSI[bar]<RSI[i])
    {
     return (false);
    }
   }
  }
 }
} 

int prevPeak(int bar)
{
 int i;
 for (i=bar+5;i<=Bars;i++)
 {
  if (RSI[i]>=RSI[i+1] && RSI[i]>RSI[i+2] && RSI[i]>=RSI[i-1] && RSI[i]>RSI[i-2])
  {
   return (i);
  }
 }
 return (EMPTY_VALUE);
}

void processBearish(int bar)
{
 if (isPeak(bar))
 {
  int curr, prev;
  curr=bar;
  prev=prevPeak(bar);
  if (prev!=EMPTY_VALUE)
  {
   if (RSI[curr]<RSI[prev] && High[curr]>High[prev])
   {
    DrawLine(prev, curr, false);
   }
   else
   {
    if (RSI[curr]>RSI[prev] && High[curr]<High[prev])
    {
     DrawLine(prev, curr, false);
    }
   }
  }
 }
}  

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  RSI[pos]=iRSI(NULL, 0, Length, Price, pos);
  processBullish(pos+2);
  processBearish(pos+2);
  pos--;
 }
 return(0);
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76345
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