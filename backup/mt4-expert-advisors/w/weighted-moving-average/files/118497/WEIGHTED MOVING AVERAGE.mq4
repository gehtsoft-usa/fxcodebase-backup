// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65876

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
 
 
 enum Price_Types{ open=1, high=2, low=3, close=4};
 
input  Price_Types Price = close;
 
//---- indicator buffers
double WMA[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  IndicatorDigits(Digits);
  
   string short_name="WEIGHTED MOVING AVERAGE "; 
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=1; 
   IndicatorShortName( "("+ short_name+MA_Period+")");
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,WMA);
   SetIndexLabel(0,"WMA"); 
   

//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
 
   if (ExtCountedBars<0) return(-1);
 
   if (ExtCountedBars>0) ExtCountedBars--;
 
 
     int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   int i;
    
  for(i=limit; i>=0; i--)
  
  {
    Calculate(i);
  }
 
 
 
    return(0);
	
}	
 
//+------------------------------------------------------------------+

void Calculate(int Start)
  {
  
  int j; 
  double Sum=0;
  
   for(j=MA_Period; j>=0; j--)
  
  {
     if (Price== 1) Sum= Sum+Open[Start+j]*(MA_Period-j);
	 if (Price== 2) Sum= Sum+High[Start+j]*(MA_Period-j);
	 if (Price== 3) Sum= Sum+Low[Start+j]*(MA_Period-j);
     if (Price== 4) Sum= Sum+Close[Start+j]*(MA_Period-j);
  }
    
	 	WMA[Start]= Sum/ ( MA_Period * ( MA_Period + 1 ) / 2 );
	
  }
//+------------------------------------------------------------------+

