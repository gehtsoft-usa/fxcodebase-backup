
//+------------------------------------------------------------------+
//|                                               Smoothed RSI.mq4   |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|------------------------------------------------------------------|
//|                                     Paypal: http://goo.gl/cEP5h5 |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern int Price=0;
extern int PricePeriod=10;
extern int PriceMode=0;


extern int RSIPeriod=10;
extern int RSIMode=0;

#property indicator_level1     30.0
#property indicator_level2     70.0

double RSI[];
double Source[];
double Positive[];
double Negative[];

int init()
  {
   IndicatorBuffers(4);
   IndicatorShortName("Smoothed RSI");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSI);
   
    SetIndexBuffer(1,Source);
	SetIndexBuffer(2,Positive);
	SetIndexBuffer(3,Negative);
	
	   if(! (Price >= 0 && Price <= 6  )  ) 
   {
   Alert("Permitted Price are between 0 and 6");

   return(-1);
   }
   
      if(! (PriceMode >= 0 && PriceMode <= 3  )  ) 
   {
   Alert("Permitted Price Mode are between 0 and 3");

   return(-1);
   }
   
      if(! (RSIMode >= 0 && RSIMode <= 3  )  ) 
   {
   Alert("Permitted RSI Mode are between 0 and 3");

   return(-1);
   }
   
    
   
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
    
	
   for(int i=limit-PricePeriod; i>=0; i--)
   {
 
		  Source[i]= iMA (NULL,0,PricePeriod,0,PriceMode,Price,i);
		  
		double diff = Source[i] - Close[i] ;
		if (diff > 0)
		{
		Positive[i]=diff;
		Negative[i]=0;
		}
		else
		{
		Positive[i]=0;
		Negative[i]=-diff;
		}
     } 
	    
				   for(int j=limit; j>=0; j--)
		       {
		   		double MAofPositive= iMAOnArray(Positive,0,RSIPeriod,0,RSIMode,j);
				double MAofNegative= iMAOnArray(Negative,0,RSIPeriod,0,RSIMode,j);
				
				 if (MAofNegative == 0)  
				 {
				  RSI[j] = 0;
				 } 
				  else
				  {
						RSI[j] = 100 - (100 / (1 + MAofPositive / MAofNegative));
				   }
		   }
return(0);

}
