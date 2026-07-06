// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73554

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

#property indicator_chart_window
#property indicator_buffers 2

input int BBPeriod = 20;
input int BBDeviations = 2;
input int BBShift = 0;
input bool UseRsi = true;
input int RsiPeriod = 13;
input int RsiUpperLevel = 60;
input int RsiLowerLevel = 40;
input bool UseStochastic = true;
input int StochMainKPeriod = 5;
input int StochMainDPeriod = 3;
input int StochMainSlowing = 3;
input int StochSignalKPeriod = 5;
input int StochSignalDPeriod = 3;
input int StochSignalSlowing = 3;
input int StochUpperLevel = 80;
input int StochLowerLevel = 20;   

int inpBarsToCalculate = 3000;
double RSI; //RSI
double BBUP;//Upper Bands
double BBLOW;//Lowe Bands

double buffer1[];
double buffer2[];

double STOCHMAIN, STOCHSIGNAL;//Stoch
//+------------------------------------------------------------------+
//| Custom indicator initialization function      -----+
int OnInit()
//+-------------------------------------------------------------
{
//--- indicator buffers mapping
   SetIndexBuffer (0,buffer1);
   SetIndexStyle (0,DRAW_ARROW,EMPTY,3,clrBlue);
   SetIndexArrow (0,233);
           
   SetIndexBuffer (1,buffer2);
   SetIndexStyle (1,DRAW_ARROW,EMPTY,3,clrRed);
   SetIndexArrow (1,234);
   return(INIT_SUCCEEDED);
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

   int _limit = (prev_calculated>0) ? rates_total-prev_calculated : rates_total-1;
   int _barsToCaclulate = MathMin(inpBarsToCalculate,rates_total);

   for(int i=1; i<inpBarsToCalculate; i++)
   {
      arrow(i);
 
      if( Open[i]>BBUP && Low[i]<BBUP  && Close[i] < BBUP)
      if(!UseRsi || RSI>RsiUpperLevel)
      if(!UseStochastic || (STOCHMAIN > StochUpperLevel && STOCHSIGNAL > StochUpperLevel))
      {
         buffer2[i]= High[i]+20*_Point; //red down arrow (sell entry)
      }
     
      if( Open[i]<BBLOW && High[i]>BBLOW && Close[i] > BBLOW)
      if(!UseRsi || RSI<RsiLowerLevel)
      if(!UseStochastic || (STOCHMAIN < StochLowerLevel && STOCHSIGNAL < StochLowerLevel))
      {
         buffer1[i]= Low[i]-20*_Point; //blue up arrow (buy entry)
      }
   }
   
   return(rates_total);
}
//+------------------------------------------------------------------+\
void arrow( int i )
{   

    RSI = iRSI(NULL,0,RsiPeriod,PRICE_CLOSE,i);

    BBUP = iBands(NULL,0,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_UPPER,i);       
    BBLOW= iBands(NULL,0,BBPeriod,BBDeviations,BBShift,PRICE_CLOSE,MODE_LOWER,i);
             
    STOCHMAIN = iStochastic(NULL,0,StochMainKPeriod,StochMainDPeriod,StochMainSlowing,MODE_SMA,0,MODE_MAIN,i);   
    STOCHSIGNAL = iStochastic(NULL,0,StochSignalKPeriod,StochSignalDPeriod,StochSignalSlowing,MODE_SMA,0,MODE_SIGNAL,i); 
}

// ------------------------------------------------------------------

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