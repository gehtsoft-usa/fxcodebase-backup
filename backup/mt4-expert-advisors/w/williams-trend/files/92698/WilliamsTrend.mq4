//+------------------------------------------------------------------+
//|                                                WilliamsTrend.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Green


extern int ATR_Period=66;
extern double ATRMultiplication=2.236;
extern int MidPriceVar=10;
 


double Trail[];
double Lower[];
double Upper[];
int init()
  { 
     IndicatorBuffers(3);
   IndicatorShortName("WilliamsTrend");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Trail);
   SetIndexBuffer(1,Lower);
   SetIndexBuffer(2,Upper); 
   
   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
 { 
  double BarsToCount = 0;
   int bars_counted = IndicatorCounted();
   if(bars_counted < 0)
   {
      return(1);
   }
   else if(bars_counted > 0) 
   {
      bars_counted--;
   }
   int limit = Bars - bars_counted;
   if(BarsToCount>0 && limit>BarsToCount) 
   {
      limit = BarsToCount;
   }
    
	
	int i;
	
   for(i=limit; i>=0; i--)
   {
 
		  double atr=iATR(NULL,0,ATR_Period,i)*  ATRMultiplication;
		  double midPrice1 =  High[iHighest(NULL,0,MODE_HIGH,MidPriceVar,i)]; 
          double midPrice2 =  Low[iLowest(NULL,0,MODE_LOW,MidPriceVar,i)];
		  double midPrice= (midPrice1 + midPrice2)/2;

		 Lower[i]= midPrice + atr;
		 Upper[i]=  midPrice - atr;
		 
		 if(Close[i] > Trail[i+1] && Close[i+1] > Trail[i+1])
		{
		Trail[i] = MathMax(Trail[i+1], Upper[i]);
		}
 		else if(Close[i] < Trail[i+1]  && Close[i+1] < Trail[i+1])
		{
		Trail[i] =  MathMin(Trail[i+1], Lower[i]);
		}
		else if(Close[i] > Trail[i+1])
		{
		Trail[i] = Upper[i];
		}
		else
		{
		Trail[i] = Lower[i];
		}
				
	  
  } 
 
  //for( i=limit; i>=0; i--)
  // {
 
		
		
				
 //}				

 return(0);
}