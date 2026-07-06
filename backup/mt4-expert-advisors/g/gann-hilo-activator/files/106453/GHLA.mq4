// Id: 16112
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=63522

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

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;

double UP[], DN[];
double pdir[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,DN);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,pdir);

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
 double AvgHigh, AvgLow;
 int Switch;
 pos=limit;
 while(pos>=0)
 {
  AvgHigh=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_HIGH, pos);
  AvgLow=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_LOW, pos);
  
  Switch=0;
  
  if (Close[pos]>AvgHigh)
  {
   Switch=1;
  }
  else
  {
   if (Close[pos]<AvgLow)
   {
    Switch=-1;
   }
  }
  
  if (Switch!=0)
  {
   pdir[pos]=Switch;
  }
  else
  {
   pdir[pos]=pdir[pos+1];
  }
  
  if (pdir[pos]<0.)
  {
   UP[pos]=AvgHigh;
   DN[pos]=AvgHigh;
  }
  else
  {
   UP[pos]=AvgLow;
   DN[pos]=EMPTY_VALUE;
  }
  
  pos--;
 } 
 return(0);
}

