//+------------------------------------------------------------------+
//|                                                          TAT.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red


extern int MACD_Fast_Period=12;
extern int MACD_Slow_Period=26;
extern int MACD_Signal_Period=9;
extern double SAR_Step=0.02;
extern double SAR_Max=0.2;
extern double TAT_MACD_Mult=66.67;
extern double TAT_SAR_Mult=6.67;
extern int TAT_Signal_Period=12;
extern double Overbought_Level=10;
extern double Oversold_Level=-10;

double TAT[], Signal[], IsLong[], af[], extreme[], sar[];


int init()
  {
   IndicatorShortName("TAT oscillator");
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,TAT);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Signal);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,IsLong);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,af);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,extreme);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,sar);
   SetLevelValue(1,Overbought_Level);
   SetLevelValue(2,Oversold_Level);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   IsLong[pos]=1;
   af[pos]=SAR_Step;
   extreme[pos]=High[pos];
   sar[pos]=Low[pos];
  }
  else
  {
   IsLong[pos]=IsLong[pos+1];
   af[pos]=af[pos+1];
   extreme[pos]=extreme[pos+1];
   sar[pos]=sar[pos+1]+af[pos+1]*(extreme[pos+1]-sar[pos+1]);
   if (IsLong[pos+1]==1)
   {
    if (Low[pos]<sar[pos])
    {
     IsLong[pos]=0;
     af[pos]=SAR_Step;
     sar[pos]=extreme[pos+1];
     extreme[pos]=Low[pos];
    }
    else
    {
     if (extreme[pos+1]<High[pos])
     {
      extreme[pos]=High[pos];
      af[pos]=af[pos+1]+SAR_Step;
      if (af[pos]>SAR_Max) af[pos]=SAR_Max;
     }
    }
   }
   else
   {
    if (High[pos]>sar[pos])
    {
     IsLong[pos]=1;
     af[pos]=SAR_Step;
     sar[pos]=extreme[pos+1];
     extreme[pos]=High[pos];
    }
    else
    {
     if (extreme[pos+1]>Low[pos])
     {
      extreme[pos]=Low[pos];
      af[pos]=af[pos+1]+SAR_Step;
      if (af[pos]>SAR_Max) af[pos]=SAR_Max;
     }
    }
   }
  } 
  pos--;
 } 
 
 double TAT_SAR=0;
 double TAT_MACD=0;
 pos=limit;
 while(pos>=0)
 {
  if (sar[pos]!=0) TAT_SAR=(Close[pos]-sar[pos])/sar[pos];
  TAT_MACD=(iMACD(NULL, 0, MACD_Fast_Period, MACD_Slow_Period, MACD_Signal_Period, PRICE_CLOSE, MODE_MAIN, pos)-iMACD(NULL, 0, MACD_Fast_Period, MACD_Slow_Period, MACD_Signal_Period, PRICE_CLOSE, MODE_SIGNAL, pos))/Close[pos];
  TAT[pos]=50*(TAT_SAR*TAT_SAR_Mult+TAT_MACD*TAT_MACD_Mult);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(TAT, 0, TAT_Signal_Period, 0, MODE_EMA, pos);
  pos--;
 }  
 

 return(0);
}

