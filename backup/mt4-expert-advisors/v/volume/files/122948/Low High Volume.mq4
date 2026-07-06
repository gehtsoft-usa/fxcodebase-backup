// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67181

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Blue
#property indicator_color3 Red 

extern int Length=10;

double Data[],Up[], Down[];

int init()
{
 IndicatorShortName("Low High Volume");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Data);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Up);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Down);

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
 int limit=Bars-3;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Data[pos]=Volume[pos];
  Up[pos]=EMPTY_VALUE;
  Down[pos]=EMPTY_VALUE; 
  
  if ( Volume[pos]>Volume[pos+1]
  && Volume[pos]>Volume[pos+2]
  )
  {
   Up[pos]=Volume[pos];
  }
   
  if ( Volume[pos]<Volume[pos+1]
  && Volume[pos]<Volume[pos+2]
  )
  {
   Down[pos]=Volume[pos];
  }
 
  
  pos--;
 } 
 return(0);
}

