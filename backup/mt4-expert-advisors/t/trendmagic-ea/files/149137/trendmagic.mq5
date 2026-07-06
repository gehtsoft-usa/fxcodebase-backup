// More information about this indicator can be found at:
// http://fxcodebase.com/ 

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
 
//--- indicator properties
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1 Blue,Red
#property indicator_width1 2
//--- input parameters
input int CCI_Period = 50;
input int ATR_Period = 5;
//--- arrays for indicator buffers
double Buffer[];
double Color[];
double CCI[];
double ATR[];
//--- variables to store handles of the indicators
int Hcci = INVALID_HANDLE;
int Hatr = INVALID_HANDLE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- prepare buffers
   SetIndexBuffer(0,Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Color,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,CCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ATR,INDICATOR_CALCULATIONS);
//--- initialize buffers
   ArrayInitialize(Buffer,0.0);
   ArrayInitialize(CCI,0.0);
   ArrayInitialize(ATR,0.0);
//--- indicator buffers mapping
   Hcci=iCCI(_Symbol,_Period,CCI_Period,PRICE_TYPICAL);
   Hatr=iATR(_Symbol,_Period,ATR_Period);
//---
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
//--- check number of bars, necessary for the calculation
   if(rates_total<CCI_Period || rates_total<ATR_Period) return(rates_total);
//--- check handles of the indicators
   if(Hcci==INVALID_HANDLE || Hcci==0)
     {
      Hcci=iCCI(_Symbol,_Period,CCI_Period,PRICE_TYPICAL);
      return(rates_total);
     }
   if(Hatr==INVALID_HANDLE || Hatr==0)
     {
      Hatr=iATR(_Symbol,_Period,ATR_Period);
      return(rates_total);
     }
//--- check number of calculated data
   int calculated1=BarsCalculated(Hcci);
   int calculated2=BarsCalculated(Hatr);
//--- synchronize data
   int to_copy=MathMin(calculated1,calculated2);
   if(to_copy<0)return(rates_total);
//--- copy data of the indicators
   if(CopyBuffer(Hcci,0,0,to_copy,CCI)<to_copy)return(rates_total);
   if(CopyBuffer(Hatr,0,0,to_copy,ATR)<to_copy)return(rates_total);
//--- set arrays as time series
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(Buffer,true);
   ArraySetAsSeries(Color,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
//--- calculate and write data to the indicator's buffer
   for(int i=rates_total-2; i>=0; i--)
     {
      if(CCI[i]>=0.0)
        {
         Buffer[i]=low[i]-ATR[i];
         if(Buffer[i]<Buffer[i+1])Buffer[i]=Buffer[i+1];
         Color[i]=0.0;
        }
      else if(CCI[i]<0.0)
        {
         Buffer[i]=high[i]+ATR[i];
         if(Buffer[i]>Buffer[i+1])Buffer[i]=Buffer[i+1];
         Color[i]=1.0;
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
