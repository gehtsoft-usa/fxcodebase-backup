// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=64634

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

#property description "Color RSI OB/OS Levels"

#property indicator_buffers 3
#property indicator_chart_window
#property indicator_width2 2
#property indicator_color2 clrLime
#property indicator_width3 2
#property indicator_color3 clrRed

extern int RSI_Period     = 14;
extern int RSI_OverBought = 70;
extern int RSI_OverSold   = 30;

double RSI[];
double RSI_Up_Arrow[];
double RSI_Dn_Arrow[];

int init()
{
   IndicatorShortName("Color RSI");
   
   color BGColor = BackgroundColor();
   
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,RSI);
   SetIndexLabel(0,"RSI");
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,RSI_Up_Arrow);
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,RSI_Dn_Arrow);
   
   return(0);
}

int start()
{
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars - counted_bars - 2;
   int rsi_color = 0;
   for(i=limit; i>=0; i--)
   {
      RSI[i] = iRSI(NULL,0,RSI_Period,PRICE_CLOSE,i);
      
      if (RSI[i] > RSI_OverBought)
      {
         if (RSI[i+1] < RSI_OverBought)
         {
            RSI_Up_Arrow[i] = High[i];
         }
      }
      
      if (RSI[i] < RSI_OverSold)
      {
         if (RSI[i+1] > RSI_OverSold)
         {
            RSI_Dn_Arrow[i] = Low[i];
         }
      }
   }
   
//----
   return(0);
}

color BackgroundColor()
{
   long bgcolor=clrNONE;
   ResetLastError();
   if(!ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,bgcolor))
   {
      Print(__FUNCTION__+", Error_Code = ",GetLastError());
   }
   return((color)bgcolor);
}