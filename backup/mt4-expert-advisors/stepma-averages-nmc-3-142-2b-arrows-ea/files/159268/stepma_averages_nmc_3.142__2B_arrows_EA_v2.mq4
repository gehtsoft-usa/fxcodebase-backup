//Available @   https://fxcodebase.com/code/viewtopic.php?f=38&t=75865

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
   #property strict
 //------------------------------------------------------------------
   enum enPModes
   {
      pr_hl,      // High/low
      pr_lh,      // Low/high
      pr_co,      // Close/open
      pr_oc,      // Open/close
      pr_hahl,    // Heiken ashi high/low
      pr_halh,    // Heiken ashi low/high
      pr_haco,    // Heiken ashi close/open
      pr_haoc     // Heiken ashi open/close
   };

   enum enPrices
   {
      pr_close,      // Close
      pr_open,       // Open
      pr_high,       // High
      pr_low,        // Low
      pr_median,     // Median
      pr_typical,    // Typical
      pr_weighted,   // Weighted
      pr_average,    // Average (high+low+open+close)/4
      pr_medianb,    // Average median body (open+close)/2
      pr_tbiased,    // Trend biased price
      pr_tbiased2,   // Trend biased (extreme) price
      pr_haclose,    // Heiken ashi close
      pr_haopen ,    // Heiken ashi open
      pr_hahigh,     // Heiken ashi high
      pr_halow,      // Heiken ashi low
      pr_hamedian,   // Heiken ashi median
      pr_hatypical,  // Heiken ashi typical
      pr_haweighted, // Heiken ashi weighted
      pr_haaverage,  // Heiken ashi average
      pr_hamedianb,  // Heiken ashi median body
      pr_hatbiased,  // Heiken ashi trend biased price
      pr_hatbiased2  // Heiken ashi trend biased (extreme) price
   };
   
    enum enMaTypes
{
   ma_sma,     // simple moving average - SMA
   ma_ema,     // exponential moving average - EMA
   ma_dsema,   // double smoothed exponential moving average - DSEMA
   ma_dema,    // double exponential moving average - DEMA
   ma_tema,    // tripple exponential moving average - TEMA
   ma_smma,    // smoothed moving average - SMMA
   ma_lwma,    // linear weighted moving average - LWMA
   ma_pwma,    // parabolic weighted moving average - PWMA
   ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // volume weighted moving average - VWMA
   ma_hull,    // Hull moving average
   ma_tma,     // triangular moving average
   ma_sine,    // sine weighted moving average
   ma_linr,    // linear regression value
   ma_ie2,     // IE/2
   ma_nlma,    // non lag moving average
   ma_zlma,    // zero lag moving average
   ma_lead,    // leader exponential moving average
   ma_ssm,     // super smoother
   ma_smoo     // smoother
};


   extern bool   OpenOpposite= true;   // Open opposite Positions
   extern int    MagicNumber = 333;  // Magic number to use for the EA
   extern bool   EcnBroker   = false;   // Is your broker ECN/STP type of broker?
   extern double LotSize     = 0.1;     // Lot size to use for trading
   extern int    Slippage    = 3;       // Slipage to use when opening new orders
   extern double StopLoss    = 100;     // Initial stop loss (in pips)
   extern double TakeProfit  = 100;     // Initial take profit (in pips)

   extern string dummy1      = "";      // .
   extern string dummy2      = "";      // Settings for indicators
   extern int    BarToUse    = 1;       // Bar to test (0, for still opened, 1 for first closed, and so on)
   
   extern enMaTypes        MaType              = ma_tema;
   extern bool             PriceFirstList      = true;        // First or second price list (below)
   extern enPModes         MaPriceFirstList    = pr_hl;
   extern enPrices         MaPriceSecondList   = pr_close;
   extern int              MaLength            = 10;          // MA Length
   extern double           Sensitivity         = 5.0;         // Sensivity Factor
   extern double           StepSize            = 2.0;         // Constant Step Size
   extern enPrices         StepMaPrice         = pr_close;
   extern bool             ATRScaling          = false;
  
   // iCustom(NULL,0,"StepMA averages nmc 3.142 + arrows",MaType,PriceFirstList,MaPriceSecondList,MaLength,Sensitivity,StepMaPrice,ATRScaling, 5,BarToUse);

   extern string dummy3      = "";      // . 
   extern string dummy4      = "";      // General settings
   extern bool   DisplayInfo = true;    // Dislay info

   bool dummyResult;
   int  ticket; 
   
 //---------------------------- Time Control
 
   input uint UseHourTrade = true;
   input uint StartHour    =  0; // Start hour
   input uint StartMinute  =  0; // Start minute
   input uint StartSecond  =  0; // Start second
   input uint EndHour      = 24; // Ending hour
   input uint EndMinute    =  0; // Ending minute
   input uint EndSecond    =  0; // Ending second

 //------------------------------------------------------------------
 //
 //------------------------------------------------------------------
 //
 //
 //
 //
 //

   int init()   { return(0); }
   int deinit() { return(0); }

 //------------------------------------------------------------------
 //
 //------------------------------------------------------------------
 //
 //
 //
 //
 //

   #define _doNothing 0
   #define _doBuy     1
   #define _doSell    2
   int start()
 {
   int doWhat = _doNothing;
      double stepma_trend_current  = iCustom(NULL,0,"StepMA averages nmc 3.142 + arrows",MaType,PriceFirstList,MaPriceFirstList,MaPriceSecondList,MaLength,Sensitivity,StepSize,StepMaPrice,ATRScaling,5,BarToUse);
      double stepma_trend_previous = iCustom(NULL,0,"StepMA averages nmc 3.142 + arrows",MaType,PriceFirstList,MaPriceFirstList,MaPriceSecondList,MaLength,Sensitivity,StepSize,StepMaPrice,ATRScaling,5,BarToUse+1);
   
      if (stepma_trend_current!=stepma_trend_previous)
      if (stepma_trend_current==1)
               doWhat = _doBuy;
         else  doWhat = _doSell;
           if (doWhat==_doNothing && !DisplayInfo) return(0);
         
   //
   //
   //
   //
   //
   
    double currentProfit = 0;
   int openedBuys  = 0;
int openedSells = 0;
for(int i = OrdersTotal()-1; i >= 0; i--)
{
   if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
   if(OrderSymbol()      != Symbol())    continue;
   if(OrderMagicNumber() != MagicNumber) continue;

   if(DisplayInfo)
      currentProfit += OrderProfit() + OrderCommission() + OrderSwap();

   RefreshRates();
   ResetLastError();

    if(OrderType() == OP_BUY)
   {
      if(OpenOpposite && doWhat == _doSell)
      {
          dummyResult = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, CLR_NONE);
         checkLastError();
      }
      else
      {
          openedBuys++;
      }
   }
    else if(OrderType() == OP_SELL)
   {
      if(OpenOpposite && doWhat == _doBuy)
      {
          dummyResult = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, CLR_NONE);
         checkLastError();
      }
      else
      {
          openedSells++;
      }
   }
}

   
   
         if (DisplayInfo)
      {
       string strTicket = openedBuys+openedSells<1 ? "" : "\nOrder ticket: "+IntegerToString(ticket);
       Comment("Current profit : "+DoubleToStr(currentProfit,2)+" "+AccountCurrency()+"\nMagicNumber,333"+strTicket+ "\nServer time: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
      }
   if (doWhat==_doNothing) return(0);

   //
   //
   //
   //
   //

   if (!checkTimeLimits(StartHour,StartMinute,StartSecond,EndHour,EndMinute,EndSecond,TimeCurrent()))  return(0);
   
   //
   //
   //
   //
   //
   
   ResetLastError();
   if (doWhat==_doBuy && openedBuys==0)
      {
         RefreshRates();
         double stopLossBuy   = 0; if (StopLoss>0)   stopLossBuy   = Ask-StopLoss*Point*MathPow(10,Digits%2);
         double takeProfitBuy = 0; if (TakeProfit>0) takeProfitBuy = Ask+TakeProfit*Point*MathPow(10,Digits%2);
         if (EcnBroker)
         {
              ticket = OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,0,0,"",MagicNumber,0,CLR_NONE);
         if (ticket>-1)
         dummyResult = OrderModify(ticket,OrderOpenPrice(),stopLossBuy,takeProfitBuy,0,CLR_NONE);
         }
         else ticket = OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,stopLossBuy,takeProfitBuy,"",MagicNumber,0,CLR_NONE);
         checkLastError();
         }
         if (doWhat==_doSell && openedSells==0)
         {
         RefreshRates();
         double stopLossSell   = 0; if (StopLoss>0)   stopLossSell   = Bid+StopLoss*Point*MathPow(10,Digits%2);
         double takeProfitSell = 0; if (TakeProfit>0) takeProfitSell = Bid-TakeProfit*Point*MathPow(10,Digits%2);
         if (EcnBroker)
         {
             ticket = OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,0,0,"",MagicNumber,0,CLR_NONE);
         if (ticket>-1)
        dummyResult = OrderModify(ticket,OrderOpenPrice(),stopLossSell,takeProfitSell,0,CLR_NONE);
         }
        else ticket = OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,stopLossSell,takeProfitSell,"",MagicNumber,0,CLR_NONE);
         checkLastError();
      }
   return(0);
 }


   #include <stderror.mqh>
   #include <stdlib.mqh>
   void checkLastError()
 {
   int lastError = GetLastError();
   if (lastError>1)
         { Print("Error: "+ErrorDescription(lastError));
         Comment("Error: "+ErrorDescription(lastError)); }
 } 
  
 //------------------ Time Control
 
   bool checkTimeLimits(uint startHour, uint endHour, datetime timeToCheck) { return(checkTimeLimits(startHour,0,0,endHour,0,0,timeToCheck)); }
   bool checkTimeLimits(uint startHour, uint startMinute, uint endHour, uint endMinute, datetime timeToCheck) { return(checkTimeLimits(startHour,startMinute,0,endHour,endMinute,0,timeToCheck)); }
   bool checkTimeLimits(uint startHour, uint startMinute, uint startSecond, uint endHour, uint endMinute, uint endSecond, datetime timeToCheck)
 {
   bool answer = false;
   MqlDateTime tempTime; TimeToStruct(timeToCheck,tempTime);
      datetime startTime,endTime,checkTime;
               startTime = _ctMinMax(startHour,0,24)    *3600+_ctMinMax(startMinute,0,60) *60+_ctMinMax(startSecond,0,60);
               endTime   = _ctMinMax(endHour,0,24)      *3600+_ctMinMax(endMinute,0,60)   *60+_ctMinMax(endSecond,0,60);
               checkTime = _ctMinMax(tempTime.hour,0,24)*3600+_ctMinMax(tempTime.min,0,60)*60+_ctMinMax(tempTime.sec,0,60);
              
   if (startTime>endTime)
          answer = (checkTime>=startTime || checkTime<=endTime);
   else   answer = (checkTime>=startTime && checkTime<=endTime);
   return(answer);
 }
   uint _ctMinMax(uint value, uint min, uint max) { return((uint)MathMax(MathMin(value,max),min)); }
   
//------------------------------------------------------  
//Available @   https://fxcodebase.com/code/viewtopic.php?f=38&t=75865

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 