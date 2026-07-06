//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159876#p159876

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#include <Trade/Trade.mqh>
CTrade trade;

input double Lot=0.1;                // Lot size
input int Slippage=5;                // Slippage (points)
input int StopLoss=200;              // Stop Loss (pips)
input int TakeProfit=400;            // Take Profit (pips)
input string IndiName="Two_MA_Cross_Indicator";
input int MA_Period1=30;
input int MA_Period2=100;
input int Limit_Bars=800;
input string Comment="Two MA Cross EA";

int handle=-1;
double Up[],Dn[];

int OnInit()
  {
   handle=iCustom(_Symbol,_Period,IndiName,MA_Period1,MA_Period2,Limit_Bars);
   if(handle==INVALID_HANDLE) return INIT_FAILED;
   ArraySetAsSeries(Up,true); ArraySetAsSeries(Dn,true);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   if(handle!=INVALID_HANDLE) IndicatorRelease(handle);
  }

void OnTick()
  {
   if(!IsNewBar())
     {
      return ;
     }
   if(handle==INVALID_HANDLE) return;
   if(CopyBuffer(handle,2,0,3,Up)<=0) return;
   if(CopyBuffer(handle,3,0,3,Dn)<=0) return;
   
   // BUY
   if(Up[1]!=EMPTY_VALUE) 
   {
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double sl = (StopLoss>0) ? ask - StopLoss*_Point : 0;
      double tp = (TakeProfit>0) ? ask + TakeProfit*_Point : 0;
      trade.Buy(Lot,_Symbol,ask,sl,tp,Comment);
   }
   
   // SELL
   if(Dn[1]!=EMPTY_VALUE) 
   {
      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double sl = (StopLoss>0) ? bid + StopLoss*_Point : 0;
      double tp = (TakeProfit>0) ? bid - TakeProfit*_Point : 0;
      trade.Sell(Lot,_Symbol,bid,sl,tp,Comment);
   }
  }

bool IsNewBar(){
   static datetime previousTime = 0;
   datetime currentTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(previousTime != currentTime)
      {
      previousTime = currentTime;
      return true;
      }
   return false;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159876#p159876

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+