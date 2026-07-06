//+------------------------------------------------------------------+
//|                                                       ST_Bar.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;
extern int Shift=20;
extern bool Use_Filter=true;

double UP[], DN[];
double Flag[], ST[];

datetime LastAlert;

int init()
{
 IndicatorShortName("SuperTrend");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexLabel(0,"Up");
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DN);
 SetIndexLabel(1,"Dn");
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Flag);
 SetIndexLabel(2,"Flag");
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,ST);
 SetIndexLabel(3,"ST");

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double CCI;
 pos=limit;
 while(pos>=0)
 {
   CCI=iCCI(NULL, 0, Length, PRICE_TYPICAL, pos);
   ST[pos]=ST[pos+1];
   Flag[pos]=Flag[pos+1];
   
   if (CCI>0. && Flag[pos]<=0.)
   {
    Flag[pos]=1.;
    ST[pos]=Low[pos]-Shift*Point;
   }
   
   if (CCI<0. && Flag[pos]>=0.)
   {
    Flag[pos]=-1.;
    ST[pos]=High[pos]+Shift*Point;
   }
   
   if (Flag[pos]>0. && Low[pos]-Shift*Point>UP[pos+1])
   {
    ST[pos]=Low[pos]-Shift*Point;
   }
   else
   {
    if (Flag[pos]<0. && High[pos]+Shift*Point<UP[pos+1])
    {
     ST[pos]=High[pos]+Shift*Point;
    }
   }
   
   if (Use_Filter)
   {
    if (Flag[pos]>0. && ST[pos]>ST[pos+1])
    {
     if (Close[pos]<Open[pos])
     {
      ST[pos]=ST[pos+1];
     }
     if (High[pos]<High[pos+1])
     {
      ST[pos]=ST[pos+1];
     }
    }
    if (Flag[pos]<0. && ST[pos]<ST[pos+1])
    {
     if (Close[pos]>Open[pos])
     {
      ST[pos]=ST[pos+1];
     }
     if (Low[pos]>Low[pos+1])
     {
      ST[pos]=ST[pos+1];
     }
    }
   }
   
   UP[pos]=0.;
   DN[pos]=0.;
   if (Close[pos]>ST[pos])
   {
    UP[pos]=1.;
   }
   else
   {
    DN[pos]=1.;
   }

  pos--;
 } 
 
   // Alerts
   // Up
   if (Flag[1]==-1 && Flag[0]==1 && UP[0]>0 && Time[0] > LastAlert){
      Alert(Symbol() + "," + TFToStr(Period()) + ": Super Trend: New Up Signal");
      LastAlert = TimeCurrent();
   }
   // Down
   if (Flag[1]==1 && Flag[0]==-1 && DN[0]>0 && Time[0] > LastAlert){
      Alert(Symbol() + "," + TFToStr(Period()) + ": Super Trend: New Down Signal");
      LastAlert = TimeCurrent();
   }
 
 return(0);
}

//+------------------------------------------------------------------+                                                                          //
string TFToStr(int tf)   {                                                                                                                      //
//+------------------------------------------------------------------+                                                                          //
  if (tf == 0)        tf = Period();                                                                                                            //
  if (tf >= 43200)    return("MN");                                                                                                             //
  if (tf >= 10080)    return("W1");                                                                                                             //
  if (tf >=  1440)    return("D1");                                                                                                             //
  if (tf >=   240)    return("H4");                                                                                                             //
  if (tf >=    60)    return("H1");                                                                                                             //
  if (tf >=    30)    return("M30");                                                                                                            //
  if (tf >=    15)    return("M15");                                                                                                            //
  if (tf >=     5)    return("M5");                                                                                                             //
  if (tf >=     1)    return("M1");                                                                                                             //
  return("");                                                                                                                                   //
}