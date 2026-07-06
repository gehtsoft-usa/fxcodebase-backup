//Available @  https://fxcodebase.com/code/viewtopic.php?f=27&p=144984#p144984

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
#property indicator_chart_window
#property indicator_buffers 0

string lineObjectName = "Breakeven";
double lastBreakevenPrice = 0;
int lastOrdersTotal = 0;
datetime lastSwapCheck = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   CalculateAndDisplayBreakeven();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, lineObjectName);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   CalculateAndDisplayBreakeven();
   return(rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateAndDisplayBreakeven()
  {
   double totalLots = 0;
   double weightedBreakeven = 0;
   double totalCosts = 0;
   double totalBuyLots = 0;
   double totalSellLots = 0;
   double breakeven = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            double orderLots = OrderLots();
            double orderOpenPrice = OrderOpenPrice();
            double orderSwap = OrderSwap();
            double orderCommission = OrderCommission();
            double pointValue = MarketInfo(Symbol(), MODE_POINT);
            double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
            double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
            double spreadInPoints = MarketInfo(Symbol(), MODE_SPREAD);
            double spreadCost = spreadInPoints * pointValue * orderLots * (tickValue / tickSize);
            double positionCosts = MathAbs(orderCommission) + MathAbs(orderSwap) + spreadCost;
            if(OrderType() == OP_BUY)
              {
               totalBuyLots += orderLots;
               double buyBreakeven = orderOpenPrice + (positionCosts / (orderLots * tickValue)) * tickSize;
               weightedBreakeven += buyBreakeven * orderLots;
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  totalSellLots += orderLots;
                  double sellBreakeven = orderOpenPrice - (positionCosts / (orderLots * tickValue)) * tickSize;
                  weightedBreakeven += sellBreakeven * orderLots;
                 }
            totalLots += orderLots;
            totalCosts += positionCosts;
           }
        }
     }
   if(totalLots > 0)
     {
      breakeven = weightedBreakeven / totalLots;
      lastBreakevenPrice = breakeven;
      if(ObjectFind(0, lineObjectName) < 0)
        {
         ObjectCreate(0, lineObjectName, OBJ_HLINE, 0, 0, breakeven);
         ObjectSetInteger(0, lineObjectName, OBJPROP_COLOR, clrYellow);
         ObjectSetInteger(0, lineObjectName, OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, lineObjectName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetString(0, lineObjectName, OBJPROP_TOOLTIP, "Average Breakeven Point");
        }
      else
        {
         ObjectSetDouble(0, lineObjectName, OBJPROP_PRICE, breakeven);
        }
     }
   else
     {
      ObjectDelete(0, lineObjectName);
      lastBreakevenPrice = 0;
     }
   ChartRedraw();
   Comment("Breakeven point recalculated: ", breakeven, " (Total costs: ", totalCosts, ") Total positions: ", totalLots, " Buy: ", totalBuyLots, " Sell: ", totalSellLots, " Time: ", TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES), " Order Count: ", OrdersTotal());
  }

//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=27&p=144984#p144984

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
