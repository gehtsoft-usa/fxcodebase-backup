//+------------------------------------------------------------------+
//|                                            Range Contraction.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC "
#property link      " http://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

extern double Threshold=50;
//--- plot Threshold
#property indicator_label1  "Threshold"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Range
#property indicator_label2  "Range"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrChartreuse
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         ThresholdBuffer[];
double         RangeBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ThresholdBuffer);
   SetIndexBuffer(1,RangeBuffer);
   
//---
   return(INIT_SUCCEEDED);
  }
  
  int start()
{


 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  ThresholdBuffer[pos]=Threshold;
  RangeBuffer[pos]= (High[pos]-Low[pos])/ ((High[pos+1]-Low[pos+1])/100); 
   
  pos--;
 }

 return (0);
} 