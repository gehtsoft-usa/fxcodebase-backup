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
#property version "1.0"


#property indicator_buffers 3
#property indicator_separate_window
#property indicator_color1 clrRed
#property indicator_color2 clrGreen
#property indicator_color3 clrBlue
//--- input parameters
extern int       FastPeriod=12;
extern int       SlowPeriod=26;
extern int       SignalPeriod=9;
double fastAMA[];
double slowAMA[];
double signalAMA[];


double HISTOGRAM[];
double MACD[];
double SIGNAL[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

 IndicatorShortName("AhrensMovingAverage");
  IndicatorDigits(Digits);  
   IndicatorBuffers(5);
   
   
   SetIndexBuffer(0,MACD);
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexBuffer(1,SIGNAL);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2,HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
	
   SetIndexBuffer(3,slowAMA);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(4,fastAMA);
   SetIndexStyle(4,DRAW_NONE);	
  
  
  
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
 if (limit<FastPeriod) return(0);	
 if (limit<SlowPeriod) return(0);	
 
 int i;
 double MedianPrice;
 double MedianMA1;
 double MedianMA2; 
 double MedianMA3;
 
          for( i=limit; i>=0; i--)
		   {
		   
		    MedianPrice = (High[i] + Low[i]) / 2;
			
			MedianMA1=(fastAMA[i+1]+fastAMA[i+FastPeriod])/2; 			
			fastAMA[i]=  fastAMA[i+1]+((MedianPrice-MedianMA1)/FastPeriod);
			
			MedianMA2=(slowAMA[i+1]+slowAMA[i+SlowPeriod])/2; 			
			slowAMA[i]=  slowAMA[i+1]+((MedianPrice-MedianMA2)/SlowPeriod);
			
			MACD[i]= fastAMA[i]-slowAMA[i];
		    
		   }
		   
		   limit=Bars;
		   
		   
          for( i=limit; i>=0; i--)
		   {		   
		   MedianMA3=(SIGNAL[i+1]+SIGNAL[i+SignalPeriod])/2; 		
		   SIGNAL[i]=  SIGNAL[i+1]+((MACD[i]-MedianMA3)/SignalPeriod);
		   HISTOGRAM[i]= MACD[i]-SIGNAL[i];		   
		   }
  
   return(0);
  }
//+------------------------------------------------------------------+