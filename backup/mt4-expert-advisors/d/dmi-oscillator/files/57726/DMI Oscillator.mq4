//+------------------------------------------------------------------+
//|                                               DMI Oscillator.mq4 |
//|                                 Copyright 2013, Gehtsoft USA LLC |
//|                                       http://www.fxcodebase.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com/"
#property indicator_buffers 1
#property indicator_separate_window
#property indicator_color1 Red
//--- input parameters
extern int       DMI_Period=14;
extern int       Price_Method=0;
double DMIO[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

 IndicatorShortName("DMIO");
  IndicatorDigits(Digits);  
   IndicatorBuffers(1);
   
   
    SetIndexBuffer(0,DMIO);
   SetIndexStyle(0,DRAW_LINE); 
  
  
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    ObjectsDeleteAll();
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
	 
   int    limit=Bars;
   
   
//----
 if (limit<DMI_Period) return(0);	
 
 int i;
 double DIP;
 double DIM;
 
          for( i=limit-DMI_Period+1; i>=0; i--)
		   {
		    DIP = iADX(NULL,0,DMI_Period,Price_Method,1,i);
			DIM = iADX(NULL,0,DMI_Period,Price_Method,2,i);
			
		   DMIO[i]=DIP-DIM;
		   }
  
   return(0);
  }
//+------------------------------------------------------------------+