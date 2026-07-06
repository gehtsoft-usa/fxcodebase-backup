// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65881

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int MA_Period=14;
 
 
 
//---- indicator buffers
double VWAP[];
double Raw_Median[];
double Raw_Volume[];

//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
   IndicatorBuffers(3);
   IndicatorDigits(Digits);   
   if(MA_Period<2) MA_Period=1; 
   IndicatorShortName( "VWAP1");
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,VWAP);
   SetIndexLabel(0,"VWAP"); 
   
 
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,Raw_Median);  

 
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,Raw_Volume);     

//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1; 
   int i,j;
   

   
   for(i=limit; i>=0; i--)
  
  {
  
    Raw_Median[i]=((High[i]+Low[i])/2)*Volume[i];
	Raw_Volume[i]= Volume[i];
    
  }

   
  double total_sum=0;
  double volume_sum=0;
   
  for(i=limit; i>=0; i--)
  
  {
   
   
	
	       volume_sum= iMAOnArray(Raw_Volume,0,MA_Period,0,MODE_SMA,i)*MA_Period;
	       total_sum = iMAOnArray(Raw_Median,0,MA_Period,0,MODE_SMA,i)*MA_Period;
	 
	   if (volume_sum!= 0 )
	   {
	   VWAP[i]= total_sum/volume_sum;
	   }
  }
 
 
 
    return(0);
	
}	

