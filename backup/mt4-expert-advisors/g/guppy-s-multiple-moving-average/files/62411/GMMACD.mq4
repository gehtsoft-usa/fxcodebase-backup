//+------------------------------------------------------------------+
//|       Guppy's Multiple Moving Average Convergence/Divergence.mq4 |
//|                                 Copyright 2013, Gehtsoft USA LLC |
//|                                       http://www.fxcodebase.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue 
#property indicator_width1  2
 

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


double Level[];


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


   IndicatorBuffers(1);
   
  
  MAX = MathMax( MAX,Short1);
  MAX = MathMax( MAX,Short2);
  MAX = MathMax( MAX,Short3);
  MAX = MathMax( MAX,Short4);
  MAX = MathMax( MAX,Long1);
  MAX = MathMax( MAX,Long2);
  MAX = MathMax( MAX,Long3);
  MAX = MathMax( MAX,Long4);
  
  
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Level);
   SetIndexDrawBegin(0,MAX);
  


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
      double S1=iMA(NULL,0,Short1,0,MAType,0,i); 
      double S2=iMA(NULL,0,Short2,0,MAType,0,i); 
      double S3=iMA(NULL,0,Short3,0,MAType,0,i); 
      double S4=iMA(NULL,0,Short4,0,MAType,0,i); 
      double F1=iMA(NULL,0,Long1,0,MAType,0,i); 
      double F2=iMA(NULL,0,Long2,0,MAType,0,i); 
      double F3=iMA(NULL,0,Long3,0,MAType,0,i);  
      double F4=iMA(NULL,0,Long4,0,MAType,0,i);
	  
	  double f=F1+F2+F3+F4;
	  double s=S1+S2+S3+S4;
	  
	 if (s!=0) Level[i]= (f - s) / s * 100;
	}
	
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+