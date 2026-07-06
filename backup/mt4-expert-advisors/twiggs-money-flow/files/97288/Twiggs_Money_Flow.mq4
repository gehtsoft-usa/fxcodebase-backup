//+------------------------------------------------------------------+
//|                                            Twiggs_Money_Flow.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Yellow

extern int Length=21;

double TMF[];
double ADV[], Vol[], WMA_ADV[], WMA_V[];
double k;

int init()
{
 IndicatorShortName("Twiggs Money Flow");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TMF);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,ADV);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Vol);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,WMA_ADV);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,WMA_V);
 
 k=1./Length;

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
 double TRH, TRL, TR;
 pos=limit;
 while(pos>=0)
 {
  TRH=MathMax(High[pos], Close[pos+1]);
  TRL=MathMin(Low[pos], Close[pos+1]);
  TR=TRH-TRL;
  if (TR!=0.)
  {
   ADV[pos]=Volume[pos]*(2.*Close[pos]-TRL-TRH)/TR;
  }
  Vol[pos]=Volume[pos];

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   WMA_ADV[pos]=iMAOnArray(ADV, 0, Length, 0, MODE_SMA, pos);
   WMA_V[pos]=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
  }
  else
  {
   WMA_ADV[pos]=(ADV[pos]-WMA_ADV[pos+1])*k+WMA_ADV[pos+1];
   WMA_V[pos]=(Vol[pos]-WMA_V[pos+1])*k+WMA_V[pos+1];
  }
  
  if (WMA_V[pos]==0.)
  {
   TMF[pos]=0.;
  }
  else
  {
   TMF[pos]=WMA_ADV[pos]/(WMA_V[pos]*Point);
  }
  
  pos--;
 }
   
 return(0);
}

