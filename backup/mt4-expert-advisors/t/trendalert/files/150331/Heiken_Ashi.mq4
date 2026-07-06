//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73577

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 White
#property indicator_color3 Red
#property indicator_color4 White
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3

//---
input color ExtColor1 = Red;    // Shadow of bear candlestick
input color ExtColor2 = White;  // Shadow of bull candlestick
input color ExtColor3 = Red;    // Bear candlestick body
input color ExtColor4 = White;  // Bull candlestick body
//--- buffers
double ExtLowHighBuffer[];
double ExtHighLowBuffer[];
double ExtOpenBuffer[];
double ExtCloseBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
void OnInit(void)
  {
   IndicatorShortName("Heiken Ashi");
   IndicatorDigits(Digits);
//--- indicator lines
   SetIndexStyle(0,DRAW_HISTOGRAM,0,1,ExtColor1);
   SetIndexBuffer(0,ExtLowHighBuffer);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,1,ExtColor2);
   SetIndexBuffer(1,ExtHighLowBuffer);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,3,ExtColor3);
   SetIndexBuffer(2,ExtOpenBuffer);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,3,ExtColor4);
   SetIndexBuffer(3,ExtCloseBuffer);
//---
   SetIndexLabel(0,"Low/High");
   SetIndexLabel(1,"High/Low");
   SetIndexLabel(2,"Open");
   SetIndexLabel(3,"Close");
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtLowHighBuffer);
   SetIndexBuffer(1,ExtHighLowBuffer);
   SetIndexBuffer(2,ExtOpenBuffer);
   SetIndexBuffer(3,ExtCloseBuffer);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Heiken Ashi                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int    i,pos;
   double haOpen,haHigh,haLow,haClose;
//---
   if(rates_total<=10)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtLowHighBuffer,false);
   ArraySetAsSeries(ExtHighLowBuffer,false);
   ArraySetAsSeries(ExtOpenBuffer,false);
   ArraySetAsSeries(ExtCloseBuffer,false);
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//--- preliminary calculation
   if(prev_calculated>1)
      pos=prev_calculated-1;
   else
     {
      //--- set first candle
      if(open[0]<close[0])
        {
         ExtLowHighBuffer[0]=low[0];
         ExtHighLowBuffer[0]=high[0];
        }
      else
        {
         ExtLowHighBuffer[0]=high[0];
         ExtHighLowBuffer[0]=low[0];
        }
      ExtOpenBuffer[0]=open[0];
      ExtCloseBuffer[0]=close[0];
      //---
      pos=1;
     }
//--- main loop of calculations
   for(i=pos; i<rates_total; i++)
     {
      haOpen=(ExtOpenBuffer[i-1]+ExtCloseBuffer[i-1])/2;
      haClose=(open[i]+high[i]+low[i]+close[i])/4;
      haHigh=MathMax(high[i],MathMax(haOpen,haClose));
      haLow=MathMin(low[i],MathMin(haOpen,haClose));
      if(haOpen<haClose)
        {
         ExtLowHighBuffer[i]=haLow;
         ExtHighLowBuffer[i]=haHigh;
        }
      else
        {
         ExtLowHighBuffer[i]=haHigh;
         ExtHighLowBuffer[i]=haLow;
        }
      ExtOpenBuffer[i]=haOpen;
      ExtCloseBuffer[i]=haClose;
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+
