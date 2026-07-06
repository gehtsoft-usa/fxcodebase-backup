//+------------------------------------------------------------------+
//|                                                        SSSAR.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red

extern double Step=0.02;
extern double Max=0.2;

double Up[], Dn[];
double tradeHigh[], tradeLow[], position[], parOp[], af[];
double SAR[];

int init()
{
 IndicatorShortName("Single Stream SAR");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexBuffer(0,Up);
 SetIndexArrow(0,119);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexBuffer(1,Dn);
 SetIndexArrow(1,119);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,tradeHigh);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,tradeLow);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,position);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,parOp);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,af);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,SAR);

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
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   tradeHigh[pos]=High[pos+1];
   tradeLow[pos]=Low[pos+1];
   position[pos]=-1;
   parOp[pos]=High[pos+1];
   af[pos]=0;
  }
  else
  {
   parOp[pos]=parOp[pos+1];
   position[pos]=position[pos+1];
   tradeHigh[pos]=tradeHigh[pos+1];
   tradeLow[pos]=tradeLow[pos+1];
   af[pos]=af[pos+1];
  }
  if (High[pos]>tradeHigh[pos])
  {
   tradeHigh[pos]=High[pos];
  }
  if (Low[pos]<tradeLow[pos])
  {
   tradeLow[pos]=Low[pos];
  }
  
  if (position[pos]==1)
  {
   if (Low[pos]<parOp[pos])
   {
    position[pos]=-1;
    SAR[pos]=tradeHigh[pos];
    tradeHigh[pos]=High[pos];
    tradeLow[pos]=Low[pos];
    af[pos]=Step;
    parOp[pos]=SAR[pos]+af[pos]*(tradeLow[pos]-SAR[pos]);
    if (parOp[pos]<High[pos])
    {
     parOp[pos]=High[pos];
    }
    if (parOp[pos]<High[pos+1])
    {
     parOp[pos]=High[pos+1];
    }
   }
   else
   {
    SAR[pos]=parOp[pos];
    if (tradeHigh[pos]>tradeHigh[pos+1] && af[pos]<Max)
    {
     af[pos]=af[pos]+Step;
     if (af[pos]>Max)
     {
      af[pos]=Max;
     }
    }
    parOp[pos]=SAR[pos]+af[pos]*(tradeHigh[pos]-SAR[pos]);
    if (parOp[pos]>Low[pos])
    {
     parOp[pos]=Low[pos];
    }
    if (parOp[pos]>Low[pos+1])
    {
     parOp[pos]=Low[pos+1];
    }
   }
  }
  else
  {
   if (High[pos]>parOp[pos])
   {
    position[pos]=1;
    SAR[pos]=tradeLow[pos];
    tradeHigh[pos]=High[pos];
    tradeLow[pos]=Low[pos];
    af[pos]=Step;
    parOp[pos]=SAR[pos]+af[pos]*(tradeHigh[pos]-SAR[pos]);
    if (parOp[pos]>Low[pos])
    {
     parOp[pos]=Low[pos];
    }
    if (parOp[pos]>Low[pos+1])
    {
     parOp[pos]=Low[pos+1];
    }
   }
   else
   {
    SAR[pos]=parOp[pos];
    if (tradeLow[pos]<tradeLow[pos+1] && af[pos]<Max)
    {
     af[pos]=af[pos]+Step;
     if (af[pos]>Max)
     {
      af[pos]=Max;
     }
    }
    parOp[pos]=SAR[pos]+af[pos]*(tradeLow[pos]-SAR[pos]);
    if (parOp[pos]<High[pos])
    {
     parOp[pos]=High[pos];
    }
    if (parOp[pos]<High[pos+1])
    {
     parOp[pos]=High[pos+1];
    }
   }
  }
  
  if (position[pos]==1)
  {
   Up[pos]=SAR[pos];
   Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   Dn[pos]=SAR[pos];
   Up[pos]=EMPTY_VALUE;
  }
  
  pos--;
 } 
 return(0);
}

