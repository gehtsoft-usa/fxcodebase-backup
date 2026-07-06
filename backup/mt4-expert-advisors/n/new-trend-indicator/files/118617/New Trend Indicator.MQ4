// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65918

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
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Gray

#property indicator_width1 5
#property indicator_width2 5
#property indicator_width3 5
  
extern int ATR_Period=12; 
extern int MVA_Period=14;

  
double UP[], DN[],NE[];
 
 

int init()
{
 IndicatorShortName("New Trend Indicator");
 IndicatorDigits(Digits);
 
 IndicatorBuffers(3);
	
 
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DN);
  SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,NE);
  
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 
	
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;

 
 
   double MVA;
   double ATR;
   

   
 while(pos>=0)
 {
   
 
  
   
         MVA= iMA(NULL,0,MVA_Period ,0,MODE_SMA,PRICE_CLOSE,pos);
         ATR= iATR(NULL,0,ATR_Period,pos);
		 
		 
		   NE[pos]=1.;
 
			if (Close[pos] >  MVA + ATR  )
			{
			UP[pos]=1.;
			DN[pos]=0.;
			NE[pos]=0.;
			}
		    
			if (Close[pos] <  MVA - ATR  ) 
			{
			DN[pos]=1.;
			UP[pos]=0.;
			NE[pos]=0.;
		   }
   
  
  pos--;
 } 
 
 
 
 
 
 return(0);
}

