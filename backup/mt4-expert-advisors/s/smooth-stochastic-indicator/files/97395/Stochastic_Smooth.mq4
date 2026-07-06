//+------------------------------------------------------------------+
//|                                            Stochastic_Smooth.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=13;
extern int Slowing=8;
extern int Signal_Slowing=9;

double Stoch[], Signal[];
double K, K_S;

int init()
{
 IndicatorShortName("Smooth stochastic oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Stoch);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 
 SetLevelValue(0, 0.);
 SetLevelValue(1, 20.);
 SetLevelValue(2, 80.);
 SetLevelValue(3, 100.);
 
 K=2./(1.+Slowing);
 K_S=2./(1.+Signal_Slowing);

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
 double H, L;
 double St;
 pos=limit;
 while(pos>=0)
 {
  H=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  L=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  
  if (H!=L)
  {
   St=100.*(Close[pos]-L)/(H-L);
  }
  else
  {
   St=0.;
  }
  
  Stoch[pos]=K*(St-Stoch[pos+1])+Stoch[pos+1];
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  H=Stoch[ArrayMaximum(Stoch, Length, pos)];
  L=Stoch[ArrayMinimum(Stoch, Length, pos)];
  
  if (H!=L)
  {
   St=100.*(Stoch[pos]-L)/(H-L);
  }
  else
  {
   St=0.;
  }
  
  Signal[pos]=K_S*(St-Signal[pos+1])+Signal[pos+1];

  pos--;
 }
   
 return(0);
}

