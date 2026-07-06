//+------------------------------------------------------------------+
//|                              Guppy's Multiple Moving Average.mq4 |
//|                                 Copyright 2013, Gehtsoft USA LLC |
//|                                       http://www.fxcodebase.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com/"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Red
#property indicator_width1  2
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1

//--- input parameters
extern int       MAType=1;

extern int       Short1=3;
extern int       Short2=5;
extern int       Short3=8;
extern int       Short4=10;
extern int       Long1=30;
extern int       Long2=35;
extern int       Long3=45;
extern int       Long4=50;


double Level1[];
double Level2[];
double Level3[];
double Level4[];
double Level5[];
double Level6[];
double Level7[];
double Level8[];

int MAX=0;

int    MAMode;
string strMAType;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----


   IndicatorBuffers(8);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Level1);
   SetIndexDrawBegin(0,Short1);
   
    SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Level2);
   SetIndexDrawBegin(1,Short2);
   
    SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Level3);
   SetIndexDrawBegin(2,Short3);
   
    SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Level4);
   SetIndexDrawBegin(3,Short4);
   
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Level5);
   SetIndexDrawBegin(4,Long1);
   
    SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Level6);
   SetIndexDrawBegin(5,Long2);
   
    SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Level7);
   SetIndexDrawBegin(6,Long3);
   
    SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,Level8);
   SetIndexDrawBegin(7,Long4);
 
  MAX = MathMax( MAX,Short1);
  MAX = MathMax( MAX,Short2);
  MAX = MathMax( MAX,Short3);
  MAX = MathMax( MAX,Short4);
  MAX = MathMax( MAX,Long1);
  MAX = MathMax( MAX,Long2);
  MAX = MathMax( MAX,Long3);
  MAX = MathMax( MAX,Long4);
  


   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
	 int limit=Bars;
   
    if (limit<MAX) return(1);

for(int i=limit; i>=0; i--)
     {
      Level1[i]=iMA(NULL,0,Short1,0,MAType,0,i); 
      Level2[i]=iMA(NULL,0,Short2,0,MAType,0,i); 
      Level3[i]=iMA(NULL,0,Short3,0,MAType,0,i); 
      Level4[i]=iMA(NULL,0,Short4,0,MAType,0,i); 
      Level5[i]=iMA(NULL,0,Long1,0,MAType,0,i); 
      Level6[i]=iMA(NULL,0,Long2,0,MAType,0,i); 
      Level7[i]=iMA(NULL,0,Long3,0,MAType,0,i);  
      Level8[i]=iMA(NULL,0,Long4,0,MAType,0,i);
	}
	
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+