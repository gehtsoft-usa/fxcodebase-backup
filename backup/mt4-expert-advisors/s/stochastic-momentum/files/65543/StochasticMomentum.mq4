//+------------------------------------------------------------------+
//|                                           StochasticMomentum.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int StochasticPeriod=13;
extern int SignalPeriod=3;
extern int SignalMethod=0;
extern bool Smooth = true;
extern int FirstPeriod=10;
extern int FirstMethod=0;
extern int SecondPeriod=20;
extern int SecondMethod=0;



double STOCHASTIC[];
double SIGNAL[];
double Raw[];
double FIRST[];
double SECOND[];
int init()
  {
  
   IndicatorBuffers(5); 
   IndicatorShortName("STOCHASTIC");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,STOCHASTIC);
   
   IndicatorShortName("SIGNAL");
   IndicatorDigits(Digits);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,SIGNAL);
   
   SetIndexBuffer(2,Raw);
   SetIndexStyle(2,DRAW_NONE); 
   
   SetIndexBuffer(3,FIRST);
   SetIndexStyle(3,DRAW_NONE);
   
   SetIndexBuffer(4,SECOND);
   SetIndexStyle(4,DRAW_NONE);
   
   
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
    
	int i;
   for( i=limit-StochasticPeriod; i>=0; i--)
   {
  
  
   double max = High[iHighest(NULL,0,MODE_HIGH,StochasticPeriod,i)];
   double min = Low[iLowest(NULL,0,MODE_LOW,StochasticPeriod,i)];
   Raw[i]= Close[i] - 0.5* (min + max);
	  
  } 
  
  if (Smooth)  
  {
  
          for( i=limit-StochasticPeriod-FirstMethod; i>=0; i--)
		  {
		  FIRST[i]=iMAOnArray(Raw,0,FirstPeriod,0,FirstMethod,i);		   		  
		  }
		  
		  for( i=limit-StochasticPeriod-FirstPeriod-SecondPeriod; i>=0; i--)
		  {
		  SECOND[i]=iMAOnArray(FIRST,0,SecondPeriod,0,SecondMethod,i);		 
		  STOCHASTIC[i]=SECOND[i];
		  }
  
  }
  else
  {
		   for( i=limit-StochasticPeriod; i>=0; i--)
		   {
		  STOCHASTIC[i]=Raw[i];	
		  }
  }
  
  
       for( i=limit-StochasticPeriod-FirstPeriod-SecondPeriod-SignalPeriod; i>=0; i--)
		  {
		  SIGNAL[i]= iMAOnArray(STOCHASTIC,0,SignalPeriod,0,SignalMethod,i);		   
		  }
 

 return(0);
}

