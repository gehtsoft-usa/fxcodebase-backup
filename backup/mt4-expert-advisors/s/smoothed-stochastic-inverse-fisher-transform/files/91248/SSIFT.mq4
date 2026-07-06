//+------------------------------------------------------------------+
//|                                                        SSIFT.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Green

extern int Length=30;
extern int Slowing=5;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double IFT[], RBW[];
double Rainbow[], Stoch[], Pr[];

int init()
{
 IndicatorShortName("Smoothed Stochastic Inverse Fisher Transform");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,IFT);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,RBW);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Rainbow);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Stoch);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Pr);

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
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Rainbow[pos]=(20*Pr[pos]+75*Pr[pos+1]+180*Pr[pos+2]+336*Pr[pos+3]+463*Pr[pos+4]+462*Pr[pos+5]+330*Pr[pos+6]+165*Pr[pos+7]+55*Pr[pos+8]+11*Pr[pos+9]+Pr[pos+10])/2098;
  pos--;
 }  

 double Min, Max; 
 pos=limit;
 while(pos>=0)
 {
  Min=Rainbow[ArrayMinimum(Rainbow, Length, pos)];
  Max=Rainbow[ArrayMaximum(Rainbow, Length, pos)];
  Stoch[pos]=100*(Rainbow[pos]-Min)/(Max-Min);
  pos--;
 }  
 
 double x;
 pos=limit;
 while(pos>=0)
 {
  RBW[pos]=iMAOnArray(Stoch, 0, Slowing, 0, MODE_SMA, pos);
  x=(RBW[pos]-50)/5;
  IFT[pos]=((MathExp(x)-1)/(MathExp(x)+1)+1)*50;
  pos--;
 }
   
 return(0);
}

