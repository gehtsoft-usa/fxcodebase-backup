//+------------------------------------------------------------------+
//|                                                         VPCI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Slow_Length=50;
extern int Fast_Length=10;

double VPCI[];
double Vol[], CV[];

int init()
{
 IndicatorShortName("Volume price confirmation indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VPCI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Vol);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,CV);

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
  Vol[pos]=Volume[pos];
  CV[pos]=Close[pos]*Volume[pos];

  pos--;
 } 
 
 double Volume_Slow, Volume_Fast, VWMA_Slow, VWMA_Fast, SMA_Slow, SMA_Fast;
 double VPC, VPR, VM;
 pos=limit;
 while(pos>=0)
 {
  Volume_Slow=iMAOnArray(Vol, 0, Slow_Length, 0, MODE_SMA, pos)*Slow_Length;
  Volume_Fast=iMAOnArray(Vol, 0, Fast_Length, 0, MODE_SMA, pos)*Fast_Length;
  if (Volume_Slow!=0.)
  {
   VWMA_Slow=iMAOnArray(CV, 0, Slow_Length, 0, MODE_SMA, pos)*Slow_Length/Volume_Slow;
  }
  else
  {
   VWMA_Slow=0.;
  } 
  if (Volume_Fast!=0.)
  {
   VWMA_Fast=iMAOnArray(CV, 0, Fast_Length, 0, MODE_SMA, pos)*Fast_Length/Volume_Fast;
  }
  else
  {
   VWMA_Fast=0.;
  } 
  SMA_Slow=iMA(NULL, 0, Slow_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  SMA_Fast=iMA(NULL, 0, Fast_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  
  VPC=VWMA_Slow-SMA_Slow;
  VPR=1.;
  if (SMA_Fast!=0.)
  {
   VPR=VWMA_Fast/SMA_Fast;
  }
  
  VM=1.;
  if (Volume_Slow!=0.)
  {
   VM=(Volume_Fast*Slow_Length)/(Volume_Slow*Fast_Length);
  }
  
  VPCI[pos]=VPC*VPR*VM/(Point*Point);

  pos--;
 }
   
 return(0);
}

