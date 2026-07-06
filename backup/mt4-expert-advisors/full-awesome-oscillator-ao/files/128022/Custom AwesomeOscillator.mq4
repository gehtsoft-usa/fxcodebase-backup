// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=60391


//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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


#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property description ""

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 DarkGreen
#property indicator_color4 Red
#property indicator_color5 Maroon


extern int Fast_Length=5;
extern int Slow_Length=34;
extern int Method=0;     // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
                         
extern int Price=4;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  


double AO[], AO_UU[], AO_UD[], AO_DU[], AO_DD[];

int init()
{
 IndicatorShortName("Awesome oscillator");
 IndicatorDigits(Digits);
 
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,AO);
 
 
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,AO_UU);
 
  SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,AO_UD);
 
 
  SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,AO_DU);
 
 
  SetIndexStyle(4,DRAW_HISTOGRAM);
 SetIndexBuffer(4,AO_DD);
 

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
 double Fast_MA, Slow_MA;
 pos=limit;
 while(pos>=0)
 {
  Fast_MA=iMA(NULL, 0, Fast_Length, 0, Method, Price, pos);
  Slow_MA=iMA(NULL, 0, Slow_Length, 0, Method, Price, pos);
  AO[pos]=Fast_MA-Slow_MA;
  
    AO_UU[pos]=EMPTY_VALUE;
	AO_UD[pos]=EMPTY_VALUE;
	AO_DU[pos]=EMPTY_VALUE;
	AO_DD[pos]=EMPTY_VALUE;
	
  if (AO[pos]>0 )
  {
  
		   if (AO[pos]>AO[pos+1] )
		  {
			AO_UU[pos]=AO[pos];
		  }
		  else
		  {
		     AO_UD[pos]=AO[pos];
		  }
    
  }
  else
  {
  
          if (AO[pos]>AO[pos+1] )
		  {
			AO_DU[pos]=AO[pos];
		  }
		  else
		  {
           AO_DD[pos]=AO[pos]; 
		  }
 
  }
  
  
  pos--;
 } 
 return(0);
}


