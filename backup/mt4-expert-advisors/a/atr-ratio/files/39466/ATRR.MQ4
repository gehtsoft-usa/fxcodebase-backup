//+------------------------------------------------------------------+
//|                                                 ATRR.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green


extern int Period1=10;
extern int Period2=20;



double ATRR[];


int init()
  {
   IndicatorShortName("ATRR");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ATRR);
   
   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
 {
   int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
	 int limit=Bars;
	
   for(int i=limit; i>=0; i--)
   {
 
		  double One=iATR(NULL,0,Period1,i);
		  double Two=iATR(NULL,0,Period2,i);
		  if (Two!=0) ATRR[i]=(One/Two)*100;
		
	  
  } 
 

 return(0);
}

