// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=68711

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int ADXcrossesPeriod = 14;
input bool act_on_close = true; // End of turn mode
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//----
double b4plusdi, b4minusdi, nowplusdi, nowminusdi;
int    nShift;   
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
    SetIndexStyle(0, DRAW_ARROW, 0, 1);
    SetIndexArrow(0, 233);
    SetIndexBuffer(0, ExtMapBuffer1);
//----
    SetIndexStyle(1, DRAW_ARROW, 0, 1);
    SetIndexArrow(1, 234);
    SetIndexBuffer(1, ExtMapBuffer2);
//---- name for DataWindow and indicator subwindow label
    IndicatorShortName("ADXcrosses(" + ADXcrossesPeriod + ")");
    SetIndexLabel(0, "ADXcrUp");
    SetIndexLabel(1, "ADXcrDn"); 
//----
    switch(Period())
      {
        case     1: nShift = 1;   break;    
        case     5: nShift = 3;   break; 
        case    15: nShift = 5;   break; 
        case    30: nShift = 10;  break; 
        case    60: nShift = 15;  break; 
        case   240: nShift = 20;  break; 
        case  1440: nShift = 80;  break; 
        case 10080: nShift = 100; break; 
        case 43200: nShift = 200; break;               
      }
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    int limit;
    int counted_bars = IndicatorCounted();
//---- check for possible errors
    if(counted_bars < 0) 
        return(-1);
//---- last counted bar will be recounted
    if(counted_bars > 0) 
        counted_bars--;
    limit = Bars - counted_bars;
//----
    for(int i = act_on_close ? 1 : 0; i < limit; i++)
      {
        b4plusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, i - 1);
        nowplusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, i);
        b4minusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, i - 1);
        nowminusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, i);  
        //----
        if(b4plusdi > b4minusdi && nowplusdi < nowminusdi)
            ExtMapBuffer1[i] = Low[i] - nShift*Point;
        //----
        if(b4plusdi < b4minusdi && nowplusdi > nowminusdi)
            ExtMapBuffer2[i] = High[i] + nShift*Point;
      }
//----
    return(0);
  }
//+------------------------------------------------------------------+

