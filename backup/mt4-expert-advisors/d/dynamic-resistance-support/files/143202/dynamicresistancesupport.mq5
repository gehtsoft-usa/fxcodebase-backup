// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71417

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property description "Dynamic Resistance Support"
//---
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_width1  1
#property indicator_width2  1
#property indicator_color1  clrRed
#property indicator_color2  clrGreen
#property indicator_label1  "Resistance"
#property indicator_label2  "Support"
//--- input parametrs
double ExtResistanceBuffer[];
double ExtSupportBuffer[];
input double InpAccurency=75.0;
input int InpBacklook=100;
//--- global variables
double accurency;
int backlook;
//---- indicator buffer
double avgCandleHeight;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input values
   if(InpAccurency>100.0)
     {
      printf("Incorrect value for input variable InpAccurency=%f to high, set to 100",InpAccurency);
      accurency=100.0;
     }
   else if(InpAccurency<10)
     {
      printf("Incorrect value for input variable InpAccurency=%f to low, set to 10",InpAccurency);
      accurency=10.0;
     }
   else
     {
      accurency=InpAccurency;
     }
   if(InpBacklook<5)
     {
      printf("Incorrect value for input variable InpBacklook=%f to low, set to 5",InpBacklook);
      backlook=5;
     }
   else
     {
      backlook=InpBacklook;
     }
//--- setup buffers
   PlotIndexSetInteger(0,PLOT_ARROW,158);
   PlotIndexSetInteger(1,PLOT_ARROW,158);
   SetIndexBuffer(0,ExtResistanceBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtSupportBuffer,INDICATOR_DATA);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int start=prev_calculated-1;
   if(start<1)
     {
      ExtResistanceBuffer[0]=EMPTY_VALUE;
      ExtSupportBuffer[0]=EMPTY_VALUE;
      start=1;
      avgCandleHeight=getAvgCandleHeight(rates_total,High,Low);
      printf("Calculated average candle hight for this time frame is %.4f",avgCandleHeight);
     }
   for(int i=start;i<rates_total;i++)
     {
      int matches=0;
      double matchSumUpper=0.0;
      double matchSumLower=0.0;
      double matchAvgUpper=0.0;
      double matchAvgLower=0.0;
      double iUpper=High[i]+avgCandleHeight;
      double iLower=Low[i]-avgCandleHeight;
      ExtResistanceBuffer[i]=ExtResistanceBuffer[i-1];
      ExtSupportBuffer[i]=ExtSupportBuffer[i-1];
      //--- skip candles which are abnormal high
      if(!isNormalCandle(High[i],Low[i]))
        {
         continue;
        }
      //--- look back for candles in the same range
      for(int k=i-1;k>=i-backlook && k>=0;k--)
        {
         if(High[k]<=iUpper && Low[k]>=iLower)
           {
            matches++;
            matchSumUpper+=High[k];
            matchSumLower+=Low[k];
           }
        }
      // --- set new resistance level
      if(matches/(double)backlook*100>=accurency)
        {
         matchAvgUpper=matchSumUpper/(double)matches;
         matchAvgLower=matchSumLower/(double)matches;
         if(matchAvgUpper>ExtResistanceBuffer[i] || matchAvgLower<ExtSupportBuffer[i])
           {
            ExtResistanceBuffer[i]=matchAvgUpper+avgCandleHeight;
            ExtSupportBuffer[i]=matchAvgLower-avgCandleHeight;
           }
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Calculate average candle height                                  |
//+------------------------------------------------------------------+
double getAvgCandleHeight(const int rates_total,const double &High[],const double &Low[])
  {
   double sum=0.0;
   for(int i=0;i<rates_total-1;i++)
     {
      sum+=High[i]-Low[i];
     }
   return sum/(rates_total-1);
  }
//+------------------------------------------------------------------+
//| Check for abnormal high candle                                   |
//+------------------------------------------------------------------+
bool isNormalCandle(const double high,const double low)
  {
   if(high-low>avgCandleHeight*2.0)
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
