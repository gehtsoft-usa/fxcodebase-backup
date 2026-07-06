// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=59132
// Id: 9742

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=3;

double Delta[], Average[];

int init()
{
     double temp = iCustom(NULL, 0, "Heiken Ashi", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Heiken Ashi' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Heikin-Ashi Delta");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Delta);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Average);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=12) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-12;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double HA_Open0, HA_Open1;
 pos=limit;
 while(pos>=0)
 {
  HA_Open0=iCustom(NULL, 0, "Heiken Ashi", 2, pos);
  HA_Open1=iCustom(NULL, 0, "Heiken Ashi", 2, pos+1);
  Delta[pos]=HA_Open0-HA_Open1;
  pos--;
 } 
 
 pos=MathMin(limit, Bars-Length-12);
 while(pos>=0)
 {
  Average[pos]=iMAOnArray(Delta, 0, Length, 0, MODE_SMA, pos);
  pos--;
 } 
 
 return(0);
}

