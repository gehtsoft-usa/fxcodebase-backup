//+------------------------------------------------------------------+
//|                                          AhrensMovingAverage.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_buffers 1
#property indicator_chart_window
#property indicator_color1 Red
//--- input parameters
extern int       Period=5;
double AMA[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

 IndicatorShortName("AhrensMovingAverage");
  IndicatorDigits(Digits);  
   IndicatorBuffers(1);
   
   
    SetIndexBuffer(0,AMA);
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
 if (limit<Period) return(0);	
 
 int i;
 double MedianPrice;
 double MedianMA;
        
          for( i=limit; i>=0; i--)
		   {
		   
		    MedianPrice = (High[i] + Low[i]) / 2;
			MedianMA=(AMA[i+1]+AMA[i+Period])/2; 
			
			AMA[i]=  AMA[i+1]+((MedianPrice-MedianMA)/Period);
			 
		    
		   }
  
   return(0);
  }
//+------------------------------------------------------------------+