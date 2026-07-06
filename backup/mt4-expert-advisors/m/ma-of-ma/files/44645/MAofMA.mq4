//+------------------------------------------------------------------+
//|                                                 MAofMA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Green

extern int Price1=0;
extern int Period1=10;
extern int Mode1=0;


extern int Period2=10;
extern int Mode2=0;


double MAofMA[];
double Buff[];

int init()
  {
   IndicatorBuffers(2);
   IndicatorShortName("MAofMA");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MAofMA);
   
    SetIndexBuffer(1,Buff);
   
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
	
   for(int i=limit-Period1; i>=0; i--)
   {
 
		  Buff[i]= iMA (NULL,0,Period1,0,Mode1,Price1,i);
	  
  } 
  
   for(int j=limit-Period1-Period2; j>=0; j--)
   {
   MAofMA[j]= iMAOnArray(Buff,0,Period2,0,Mode2,j);
   }

 return(0);
}

