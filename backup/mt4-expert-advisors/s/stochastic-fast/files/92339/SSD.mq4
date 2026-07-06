//+------------------------------------------------------------------+
//|                                              Stochastic Slow.mq4 |
//|                                 Copyright 2013, Gehtsoft USA LLC |
//|                                       http://www.fxcodebase.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com/"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue
 
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1

//--- input parameters
 
extern double  Overbought=80;
extern double  Oversold=20;
extern int       K_Line_Period=5;
extern int       D_Line_Period=3;
extern int       D_Line_Slowing_Period=3;

double OB[];
double OS[]; 
double K[];
double D[];
double DS[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----


   IndicatorBuffers(5);

   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,D);
   
    SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,DS);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,OB);
   
    SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,OS);
   
   
     SetIndexStyle(4,DRAW_NONE);
      SetIndexBuffer(4,K);
  
   
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
   int bars_counted = IndicatorCounted();
   if(bars_counted < 0)
   {
      return(1);
   }
   
   int limit = Bars - bars_counted;
   
    
    
   double Maximum;
    double Minimum;
	double mins;
	double maxes;
for(int i=limit; i>=0; i--)
     {
	 
  
   Maximum =  High[iHighest(NULL,0,MODE_HIGH,K_Line_Period,i)]; 
   Minimum =  Low[iLowest(NULL,0,MODE_LOW,K_Line_Period,i)];
   
        mins = Close[i] - Minimum;
        maxes = Maximum  - Minimum;   
		
		if ( maxes  > 0 ) 
		{
		K[i] = (mins / maxes) * 100;
		}
        else
		{
            K[i] = 50;
		}	
		 
		 OB[i]=Overbought;
		 OS[i]=Oversold;
		
	}
	
	for( i=limit; i>=0; i--)
     {    
	       D[i]= iMAOnArray(K,0,D_Line_Period,0,0,i);
	     
	 }
	 for( i=limit; i>=0; i--)
     {  
	  DS[i]= iMAOnArray(D,0,D_Line_Slowing_Period,0,0,i);
	  }
	
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+