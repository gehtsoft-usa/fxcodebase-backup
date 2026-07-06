//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern string Method_Str="Method: 0 - Pips, 1 - Percentage";
extern int Method=0; // 0 - Pips, 1 - Percentage
extern int Length=20;
extern double Pip_Offset=50;
extern double Percentage=1;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int MA_MODE=1;     


//MODE_SMA 0 Simple averaging
//MODE_EMA 1 Exponential averaging
//MODE_SMMA 2 Smoothed averaging
//MODE_LWMA 3 Linear-weighted averaging
					   
double TL[], BL[], CL[];

int init()
{
 IndicatorShortName("EMA Offset Bands");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TL);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,BL);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,CL);

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
 double MA;
 double Offset;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, MA_MODE, Price, pos);
  CL[pos]=MA;
  
  if (Method==1)
  {
   Offset=Percentage*CL[pos]/100.;
  }
  else
  {
   Offset=Pip_Offset*Point;
  }
  
  TL[pos]=MA+Offset;
  BL[pos]=MA-Offset;

  pos--;
 } 
 return(0);
}

