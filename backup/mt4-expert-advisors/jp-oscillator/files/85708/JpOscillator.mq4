//+------------------------------------------------------------------+
//|                                                 JpOscillator.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//|                                            mario.jemic@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

 
extern int Period1=5;
extern int Mode1=0;
extern bool Smoothing = true;


double MAofMA[];
double Buff[];
double Up[];
double Down[];

int init()
  {
   IndicatorBuffers(4);
   IndicatorShortName("JpOscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MAofMA);
   
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Up);
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Down);
   
    SetIndexBuffer(3,Buff);
   
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
	
   for(int i=limit-4; i>=0; i--)
   {
 
		  Buff[i]= (Close[i] -  (Close[i+1]/2 + Close[i+2]/2)) - ( 0 - (Close[i] - Close[i+4]));
	  
  } 
  
  
  int j;
  
  if(Smoothing) 
  {
	  for( j=limit-Period1-4; j>=0; j--)
	   {
	   MAofMA[j]= iMAOnArray(Buff,0,Period1,0,Mode1,j);
	   
	         if (MAofMA[j]>MAofMA[j+1]) 
			   {
			   Up[j]= MAofMA[j];
			   Down[j]=  EMPTY_VALUE;
			   }
			   else
			   {
			   Down[j]= MAofMA[j];
			   Up[j]=  EMPTY_VALUE;
			   }
	   }

  }
  else
   {
   
   for( j=limit-4; j>=0; j--)
	   {
			MAofMA[j]= Buff[j];
			   if (MAofMA[j]>MAofMA[j+1]) 
			   {
			   Up[j]= MAofMA[j];
			   Down[j]=  EMPTY_VALUE;
			   }
			   else
			   {
			   Down[j]= MAofMA[j];
			   Up[j]=  EMPTY_VALUE;
			   }
			   
	   
	   }
   }
  
  
  
   
 return(0);
}

