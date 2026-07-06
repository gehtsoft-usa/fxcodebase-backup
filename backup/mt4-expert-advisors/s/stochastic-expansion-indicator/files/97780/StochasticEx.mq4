//+------------------------------------------------------------------+
//|                                                 StochasticEx.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int K_Length=13;
extern int Slowing=6;
extern int Noise_Filter=6;

double K[], Signal[];
double LowBuff[], HighBuff[];

int init()
{
 IndicatorShortName("Stochastic expansion indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,LowBuff);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,HighBuff);

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
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, K_Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, K_Length, pos)];
  
  LowBuff[pos]=Close[pos]-Min;
  HighBuff[pos]=Max-Close[pos];

  pos--;
 } 

 double Avg_Low, Avg_High;
 double KB1, KB2;
 pos=limit;
 while(pos>=0)
 {
  Avg_Low=iMAOnArray(LowBuff, 0, Slowing, 0, MODE_SMA, pos);
  Avg_High=iMAOnArray(HighBuff, 0, Slowing, 0, MODE_SMA, pos);
  
  if (Avg_High==0.)
  {
   KB1=0.;
  }
  else
  {
   KB1=Avg_Low/Avg_High;
  }
  
  if (Avg_Low==0.)
  {
   KB2=0.;
  }
  else
  {
   KB2=-Avg_High/Avg_Low;
  }
  
  K[pos]=KB1+KB2;
 
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(K, 0, Noise_Filter, 0, MODE_SMA, pos);

  pos--;
 }  
  
 return(0);
}

