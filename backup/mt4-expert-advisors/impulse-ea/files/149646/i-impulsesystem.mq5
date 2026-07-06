//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73383

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
 
#property description "The Indicator is based on Elder's Impulse system"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  Lime,Red,Gray
#property indicator_width1  1
#property indicator_label1  "Open;High;Low;Close"

double OBuffer[];
double HBuffer[];
double LBuffer[];
double CBuffer[];
double OsMaBuffer[];
double EMABuffer[];
double ColorBuffer[];
//--- handles
int    hOsMaBuffer;
int    hEMABuffer;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(ChartGetInteger(0,CHART_MODE)!=CHART_CANDLES)
     {
      Print("It's better to set candstick mode on the chart.");
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,OBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,CBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,ColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,OsMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,EMABuffer,INDICATOR_CALCULATIONS);
//--- set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,27);
//--- set indicator shortname   
   IndicatorSetString(INDICATOR_SHORTNAME,"i-ImpulseSystem");
//--- don't show indicator data in DataWindow
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//--- get handles
   hOsMaBuffer=iOsMA(Symbol(),PERIOD_CURRENT,12,26,9,PRICE_CLOSE);
   hEMABuffer=iMA(Symbol(),PERIOD_CURRENT,13,0,MODE_EMA,PRICE_CLOSE);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   int i;
   if(rates_total<27)
     {
      Print("Not enough history for indicator i-ImpulseSystem!");
      return(0);
     }
   int calculated=BarsCalculated(hOsMaBuffer);
   if(calculated<rates_total)
     {
      Print("Not all data of hOsMaBuffer is calculated (",calculated,"bars ). Error ",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(hEMABuffer);
   if(calculated<rates_total)
     {
      Print("Not all data of hEMABuffer is calculated (",calculated,"bars ). Error ",GetLastError());
      return(0);
     }
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   if(CopyBuffer(hOsMaBuffer,0,0,to_copy,OsMaBuffer)<=0)
     {
      Print("Getting iOsma is failed! Error ",GetLastError());
      return(0);
     }
   if(CopyBuffer(hEMABuffer,0,0,to_copy,EMABuffer)<=0)
     {
      Print("Getting iMa is failed! Error ",GetLastError());
      return(0);
     }
   int start;
   if(prev_calculated==0) start=1;
   else start=prev_calculated-1;

   for(i=start;i<rates_total;i++)
     {
      OBuffer[i]=open[i];
      HBuffer[i]=high[i];
      LBuffer[i]=low[i];
      CBuffer[i]=close[i];
      //--- green zone
      if(OsMaBuffer[i]>OsMaBuffer[i-1] && EMABuffer[i]>EMABuffer[i-1])
        {
         ColorBuffer[i]=0.0;
        }
      else if(OsMaBuffer[i]<OsMaBuffer[i-1] && EMABuffer[i]<EMABuffer[i-1])
        {
         ColorBuffer[i]=1.0;
        }
      else
        {
         ColorBuffer[i]=2.0;
        }
     }
//--- return value of prev_calculated for next call
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
