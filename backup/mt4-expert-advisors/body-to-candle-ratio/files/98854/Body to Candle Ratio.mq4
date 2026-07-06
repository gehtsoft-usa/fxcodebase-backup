//+------------------------------------------------------------------+
//|                                         Body to Candle Ratio.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|------------------------------------------------------------------|
//|                                     Paypal: http://goo.gl/cEP5h5 |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
extern int Length=14;

double Ratio[];
double Average[];

int init()
  {
   IndicatorShortName("Range ratio oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Ratio);   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Average);
   SetLevelValue(1, 0.3);
   SetLevelValue(2, 0.5);
   SetLevelValue(3, 0.7);
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
 int pos=limit;
 while(pos>=0)
 { 
   Ratio[pos]=(Close[pos]-Low[pos])/(High[pos]-Low[pos]);
 
  pos--;
 } 
 
 
 
  pos=limit;
 if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
 while(pos>=0)
  {
  Average[pos]=iMAOnArray( Ratio, 0, Length, 0, MODE_SMA, pos);
  
   pos--;
  }

 return(0);
}

