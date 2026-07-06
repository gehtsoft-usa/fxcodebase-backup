//+------------------------------------------------------------------+
//|                                                          CRF.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

double RF[], RF_Dn[], RF_N[];

int init()
{
 IndicatorShortName("Cumulative Rotation Factor");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,RF);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,RF_Dn);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,RF_N);

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
   RF[pos]=0.;
  }
  else
  {
  RF[pos]=RF[pos+1];
  
  if (High[pos]>High[pos+1])
  {
   RF[pos]=RF[pos]+1.;
  }
  else
  {
   if (High[pos]<High[pos+1])
   {
    RF[pos]=RF[pos]-1.;
   }
  }
  
  if (Low[pos]>Low[pos+1])
  {
   RF[pos]=RF[pos]+1.;
  }
  else
  {
   if (Low[pos]<Low[pos+1])
   {
    RF[pos]=RF[pos]-1.;
   }
  }
  
  RF_Dn[pos]=0.;
  RF_N[pos]=0.;
  
  if (RF[pos]<RF[pos+1])
  {
   RF_Dn[pos]=RF[pos];
  }
  else
  {
   if (RF[pos]==RF[pos+1])
   {
    RF_N[pos]=RF[pos];
   }
  }
  }

  pos--;
 
 }
 return(0);
}

