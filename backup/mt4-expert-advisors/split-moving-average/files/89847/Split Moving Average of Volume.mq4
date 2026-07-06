//+------------------------------------------------------------------+
//|                                         Split Moving Average.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red



extern int Length=14;
extern int MA_Method=0;
 
 
double BufferUp[];
double BufferDown[];

double Up[];
double Down[];
 
int init()
  {
   IndicatorBuffers(4);
   IndicatorShortName("SplitMovingAverage");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Up);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Down);
   
   SetIndexBuffer(2,BufferUp);
    SetIndexStyle(2,DRAW_NONE);
	SetIndexBuffer(3,BufferDown);
    SetIndexStyle(3,DRAW_NONE);
 
	
	  if(! (MA_Method >= 0 && MA_Method <= 3  )  ) 
   {
   Alert("Permitted MA Modes are between 0 and 3");

   return(-1);
   }
   
   
  
   
   return(0);
  }



int start()
 {
 
 
  int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
	 int limit=Bars;
 
  int i;
   for( i=limit -1; i>=0; i--)
   {
      
	     BufferDown[i]=0;
		 BufferUp[i]=0;
	  
		if  (Close[i]>Close[i+1])
        {
		BufferUp[i]= Volume[i];
		 
		}	
        else
        {
		BufferDown[i]= Volume[i];		
	 
			 
		}		
	  
  } 
  
  for( i=limit-Length-1; i>=0; i--)
   {
 
	Up[i]=iMAOnArray(BufferUp,0,Length,0,MA_Method,i);
	Down[i]=iMAOnArray(BufferDown,0,Length,0,MA_Method,i);
 
  } 
  
 

 return(0);
}

