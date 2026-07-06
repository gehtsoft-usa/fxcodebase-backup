//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76170&p=159974#p159974

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
#property strict

input double Lot = 0.1;
input int Slippage = 3;
input int Magic = 12345;
input int StopLoss = 0;
input int TakeProfit = 0;
input int period = 18;
input int SIGNAL_BAR = 1;
input string IndicatorName = "Up_and_Down";
input string Comment = "Up_and_Down EA";

int lastSignal = 0;

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

int start()
{
   if (Bars < 100) return(0);
   double buffer0_now = iCustom(NULL,0,IndicatorName,period,true,1,1,Blue,Red,0,0);
   double buffer0_prev = iCustom(NULL,0,IndicatorName,period,true,1,1,Blue,Red,0,1);

   // Buy : buffer0_prev > 0, buffer0_now < 0
   if (buffer0_prev > 0 && buffer0_now < 0 && lastSignal != 1)
   {
      if (OrdersTotalByMagic(Magic,OP_BUY)==0 && OrdersTotalByMagic(Magic,OP_SELL)==0)
      {
         OrderSend(Symbol(),OP_BUY,Lot,Ask,Slippage,GetSL(OP_BUY),GetTP(OP_BUY),Comment,Magic,0,clrBlue);
         lastSignal = 1;
      }
   }
   // Sell : buffer0_prev < 0, buffer0_now > 0
   if (buffer0_prev < 0 && buffer0_now > 0 && lastSignal != -1)
   {
      if (OrdersTotalByMagic(Magic,OP_BUY)==0 && OrdersTotalByMagic(Magic,OP_SELL)==0)
      {
         OrderSend(Symbol(),OP_SELL,Lot,Bid,Slippage,GetSL(OP_SELL),GetTP(OP_SELL),Comment,Magic,0,clrRed);
         lastSignal = -1;
      }
   }
   // reset lastSignal if no new signal
   if (!( (buffer0_prev > 0 && buffer0_now < 0) || (buffer0_prev < 0 && buffer0_now > 0) ))
      lastSignal = 0;
   return(0);
}

// count orders by magic and type
int OrdersTotalByMagic(int magic, int type)
{
   int total = 0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()==magic && OrderType()==type)
            total++;
   }
   return total;
}

// get SL/TP
double GetSL(int type)
{
   if(StopLoss<=0) return(0);
   if(type==OP_BUY) return(Bid-StopLoss*Point);
   else return(Ask+StopLoss*Point);
}

double GetTP(int type)
{
   if(TakeProfit<=0) return(0);
   if(type==OP_BUY) return(Bid+TakeProfit*Point);
   else return(Ask-TakeProfit*Point);
}
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76170&p=159974#p159974

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
