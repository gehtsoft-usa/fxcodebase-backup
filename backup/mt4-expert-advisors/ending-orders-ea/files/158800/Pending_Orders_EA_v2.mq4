//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75763

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
#include <stdlib.mqh>
#property strict
//---
input bool   DynamicLotSize    = true;  //Use Money Management
input double EquityPercent     = 2;     //Risk Percent
input double FixedLotSize      = 0.1;   //Fixed LotSize
input double StopLoss          = 100;   //StopLoss( in Point)
input double TakeProfit        = 300;   //TakeProfit( in  Point)
input double TrailingStop      = 50;    //TrailingStop(in Point)
input double PipsAway          = 50;    //points away from the current Bid & Ask
input double Slippage          = 30;    //Slippage
input double Magic             = 1111;  //Magic Number
input bool   UseLimitOrders    = false; //Use Limit Orders instead of Stop Orders
input bool   closeSecondOrder  = true;  //Close second order if first order is opened

double LotSize;
int ticket1;
int ticket2;
int t=0;

//---
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   //---Detect Open or Pending Orders
   int total=OrdersTotal();
   t=0;
   for(int i=total-1;i>=0;i--)
     {
      OrderSelect(i,SELECT_BY_POS);
      int type=OrderType();
      if(( OrderSymbol()==Symbol()) && (OrderMagicNumber()==Magic))
        {
         switch(type)
           {
            case OP_BUY       : t=1;
            case OP_SELL      : t=1;
            case OP_BUYLIMIT  : t=1;
            case OP_BUYSTOP   : t=1;
            case OP_SELLLIMIT : t=1;
            case OP_SELLSTOP  : t=1;
           }
        }
     }
   if(t<1)
     {   
  
      if(IsNewBar())
     {
      //Lot Size Calculation
      if(DynamicLotSize==true)
        {
         double RiskAmount= AccountEquity() *(EquityPercent/100);
         double TickValue = MarketInfo(Symbol(),MODE_TICKVALUE);
         if(Point==0.001 || Point==0.00001) TickValue*=10;
         double CalcLots=(RiskAmount/StopLoss)/TickValue;
         LotSize=CalcLots;
        }
      else LotSize=FixedLotSize;
      // Lot size verification
      if(LotSize<MarketInfo(Symbol(),MODE_MINLOT))
        {
         LotSize=MarketInfo(Symbol(),MODE_MINLOT);
        }
      else if(LotSize>MarketInfo(Symbol(),MODE_MAXLOT))
        {
         LotSize=MarketInfo(Symbol(),MODE_MAXLOT);
        }
      if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.1)
        {
         LotSize=NormalizeDouble(LotSize,1);
        }
      else LotSize=NormalizeDouble(LotSize,2);
      
      // Decide order type based on UseLimitOrders
      int buyOrderType = UseLimitOrders ? OP_BUYLIMIT : OP_BUYSTOP;
      int sellOrderType = UseLimitOrders ? OP_SELLLIMIT : OP_SELLSTOP;
      
      //Open two Pending Orders simultaneously
      // Stop Orders
      if(!UseLimitOrders)
      {
        double t1 = Ask + PipsAway * Point; //BuyStop Entry Point
        double t2 = Bid - PipsAway * Point; //SellStop Entry Point
        double sl1 = t1 - StopLoss * Point; //BuyStop Stoploss
        double sl2 = t2 + StopLoss * Point; //SellStop Stoploss
        double tp1 = t1 + TakeProfit * Point; //BuyStop TakeProfit
        double tp2 = t2 - TakeProfit * Point; //SellStop TakeProfit
  
        ticket1 = OrderSend( Symbol(),OP_BUYSTOP,LotSize,t1, Slippage,sl1,tp1,"ZAY",Magic,0,White);
        ticket2 = OrderSend( Symbol(),OP_SELLSTOP,LotSize,t2, Slippage, sl2,tp2,"ZAY",Magic,0,White);
      }
      
      // Limit Orders
      if(UseLimitOrders)
      {
        // buy limit
        double t1  = Ask - PipsAway * Point;   //BuyStop/BuyLimit Entry Point
        double sl1 = t1 - StopLoss * Point;   //BuyStop/BuyLimit Stoploss
        double tp1 = t1 + TakeProfit * Point; //BuyStop/BuyLimit TakeProfit
        
        // sell limit
        double t2  = Bid + PipsAway * Point;   //SellStop/SellLimit Entry Point
        double sl2 = t2 + StopLoss * Point;   //SellStop/SellLimit Stoploss
        double tp2 = t2 - TakeProfit * Point; //SellStop/SellLimit TakeProfit
  
        ticket1 = OrderSend(Symbol(), buyOrderType, LotSize, t1, Slippage, sl1, tp1, "ZAY", Magic, 0, White);
        ticket2 = OrderSend(Symbol(), sellOrderType, LotSize, t2, Slippage, sl2, tp2, "ZAY", Magic, 0, White);      
      }
     }
  }
     
   for(int j=0; j<OrdersTotal(); j++)
     {
      //---if opened order is "Buy", close another pending order "Sellstop" and use trailing stop for opened "Buy" order
      OrderSelect(ticket1,SELECT_BY_TICKET);
      if(OrderType()==OP_BUY)
        {
         // delete pending order
          if(closeSecondOrder)OrderDelete(ticket2);
        
        // use Trailling Stop
         if(Bid-OrderOpenPrice()>Point*TrailingStop)
           {
            if(OrderStopLoss()<Bid-Point*TrailingStop)
              {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
              }
           }
        }
      //---if opened order is "Sell", close another pending order "Buystop" and use trailing stop for opened "Sell" order
      OrderSelect(ticket2,SELECT_BY_TICKET);
      if(OrderType()==OP_SELL)
        {
         // delete pending order
         if(closeSecondOrder)OrderDelete(ticket1);
         
        // use Trailling Stop
         if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
           {
            if(OrderStopLoss()>(Ask+Point*TrailingStop))
              {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
              }
           }
        }
     }
   return(0);
  }


  bool IsNewBar()
  {
   static datetime lastTime=0;
   datetime curTime=iTime(Symbol(),0,0);
   if(curTime!=lastTime)
     {
      lastTime=curTime;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75763

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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