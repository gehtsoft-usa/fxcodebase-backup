// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=59355

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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
//#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=8;


#property indicator_level1 0
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT

double LWTI[];
double Raw[];

int init()
{
 IndicatorShortName("Larry Large Trade Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,LWTI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Raw);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Raw[pos]=Close[pos]-Close[pos+Length-1];
  pos--;
 } 
 
 double MA, ATR;
 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(Raw, 0, Length, 0, MODE_SMA, pos);
  ATR=iATR(NULL, 0, Length, pos);
  if (ATR!=0)
  {
   LWTI[pos]=50*MA/ATR+50;
  }
  else
  {
   LWTI[pos]=0;
  }
  pos--;
 }  
 return(0);
}

