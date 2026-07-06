//+------------------------------------------------------------------+
//|                                                          TII.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=30;
extern int MA_Length=60;
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern double Overbought_Level=80;
extern double Oversold_Level=20;                        
extern int LevelWidth=1;
extern color LevelColor=Gray;                        

double TII[];
double Up[], Down[];

int init()
{
 IndicatorShortName("Trend Intensity Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TII);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Up);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Down);

 SetLevelValue(0, 50);
 SetLevelValue(1, Overbought_Level);
 SetLevelValue(2, Oversold_Level);
 SetLevelStyle(EMPTY, LevelWidth, LevelColor);

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
 double MA, Pr;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  MA=iMA(NULL, 0, MA_Length, 0, MA_Method, Price, pos);
  if (Pr>MA)
  {
   Up[pos]=Pr-MA;
   Down[pos]=0.;
  }
  else
  {
   if (Pr<MA)
   {
    Up[pos]=0.;
    Down[pos]=MA-Pr;
   }
   else
   {
    Up[pos]=0.;
    Down[pos]=0.;
   }
  }

  pos--;
 } 
 
 double Pos, Neg;
 pos=limit;
 while(pos>=0)
 {
  Pos=iMAOnArray(Up, 0, Length, 0, MODE_SMA, pos);
  Neg=iMAOnArray(Down, 0, Length, 0, MODE_SMA, pos);
  
  if (Pos+Neg!=0.)
  {
   TII[pos]=100.*Pos/(Pos+Neg);
  }
  else
  {
   TII[pos]=EMPTY_VALUE;
  } 

  pos--;
 }
   
 return(0);
}

