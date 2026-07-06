//+------------------------------------------------------------------+
//|                                                          SSS.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 3
#property indicator_color1 LightSeaGreen
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int KPeriod=5;
extern int DSlowing=3;
extern int DPeriod=3;
extern int DSPeriod=3;

double Kbuff[];
double Dbuff[];
double DSbuff[];
double HighestBuffer[];
double LowestBuffer[];

int Kfirst, Dfirst, DSfirst;

int init()
  {
   string short_name;

   IndicatorBuffers(5);
   SetIndexBuffer(3, HighestBuffer);
   SetIndexBuffer(4, LowestBuffer);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, Kbuff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, Dbuff);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2, DSbuff);

   short_name="Sto("+KPeriod+","+DSlowing+","+DPeriod+","+DSPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);

   Kfirst=KPeriod+DSlowing;
   Dfirst=Kfirst+DPeriod;
   DSfirst=Kfirst+DSPeriod;
   SetIndexDrawBegin(0,Kfirst);
   SetIndexDrawBegin(1,Dfirst);
   SetIndexDrawBegin(2,DSfirst);

   return(0);
  }

int start()
  {
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double price;

   if(Bars<=MathMax(Dfirst, DSfirst)) return(0);

   if(counted_bars<1)
     {
      for(i=1;i<=Kfirst;i++) Kbuff[Bars-i]=0;
      for(i=1;i<=Dfirst;i++) Dbuff[Bars-i]=0;
      for(i=1;i<=DSfirst;i++) DSbuff[Bars-i]=0;
     }

   i=Bars-KPeriod;
   if(counted_bars>KPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
      double min=1000000;
      double max=-1000000;
      k=i+KPeriod-1;
      while(k>=i)
        {
         if(min>Low[k]) min=Low[k];
         if(max<High[k]) max=High[k];
         k--;
        }
      LowestBuffer[i]=min;
      HighestBuffer[i]=max;
      i--;
     }

   i=Bars-Kfirst;
   if(counted_bars>Kfirst) i=Bars-counted_bars-1;
   while(i>=0)
     {
      double sumlow=0.0;
      double sumhigh=0.0;
      for(k=(i+DSlowing-1);k>=i;k--)
        {
         sumlow+=Close[k]-LowestBuffer[k];
         sumhigh+=HighestBuffer[k]-LowestBuffer[k];
        }
      if(sumhigh==0.0) Kbuff[i]=100.0;
      else Kbuff[i]=sumlow/sumhigh*100;
      i--;
     }

   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;

   for(i=0; i<limit; i++)
   {
    Dbuff[i]=iMAOnArray(Kbuff,Bars,DPeriod,0,MODE_SMA,i);
   } 

   for(i=0; i<limit; i++)
   {
    DSbuff[i]=iMAOnArray(Dbuff,Bars,DSPeriod,0,MODE_SMA,i);
   } 
   return(0);
  }

