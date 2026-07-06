// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73219

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
#property link "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

//---- input parameters
input int Depth = 16;
input ENUM_APPLIED_PRICE appprice = PRICE_TYPICAL; // Aplied Price:
//---- buffers
double TrixBuf[];
double T1Buf[];
double T2Buf[];
double T3Buf[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(4);
//---- additional buffers
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, TrixBuf);
   SetIndexBuffer(1, T1Buf);
   SetIndexBuffer(2, T2Buf);
   SetIndexBuffer(3, T3Buf);
   //---- name for DataWindow and indicator subwindow label
   string short_name = "Trix(" + Depth + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int i;
//----
   if(Bars <= Depth + 10) 
       return(0);
//---- last counted bar will be recounted
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars;
   if(counted_bars > 0) 
       limit++;
//-- The Trix Calc
   for(i = limit; i >= 0; i--)
       T1Buf[i] = iMA(NULL, 0, Depth, 0, MODE_EMA, appprice, i);
//----
   for(i = limit; i >= 0; i--)
       T2Buf[i] = iMAOnArray(T1Buf, 0, Depth, 0, MODE_EMA, i);
//----
   for(i = limit; i >= 0; i--)
       T3Buf[i] = iMAOnArray(T2Buf, 0, Depth, 0, MODE_EMA, i);
//----
   for(i = limit; i >= 0; i--)
     {
       if(T3Buf[i+1] != 0) 
           TrixBuf[i] = ((T3Buf[i] - T3Buf[i+1]) / T3Buf[i+1])*100;       
     }  
   return(0);
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

