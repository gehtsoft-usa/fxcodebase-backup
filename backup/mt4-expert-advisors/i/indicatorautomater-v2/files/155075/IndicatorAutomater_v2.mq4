//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74797

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

extern string IndicatorName = "MyCustomIndicator";
extern bool   UseStopLoss      = true;
extern int    StopLossPips     = 20;
extern int    Slippage         = 3;
extern double Lots             = 0.1;
extern double NetProfitToClose = 1.0; // Set this to the net profit at which you want to close the trade

extern int BuySignalBuffer  = 0;
extern int SellSignalBuffer = 1;

double   initialLots = Lots;
datetime lastOrderOpenTime;
int      magicNumber = 18123;

int    lastClosedOrderType = -1; // Initialize lastClosedOrderType to -1
bool   lastClosedOrderProfit;
double lastClosedOrderLoss = 0.0; // Declare lastClosedOrderLoss

double totalNetLoss  = 0.0;              // Declare totalNetLoss
double profitToClose = NetProfitToClose; // Declare profitToClose

int tickets[100];

int lastSignal = -1; // Declare lastSignal

int lastOrderType()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol()) {
            return OrderType();
        }
    }
    return -1;
}

void OnTick()
{
    double buySignal, sellSignal;
    int    ticket;

    // Get the buy and sell signals from the custom indicator
    buySignal  = iCustom(Symbol(), 0, IndicatorName, BuySignalBuffer, 1);
    sellSignal = iCustom(Symbol(), 0, IndicatorName, SellSignalBuffer, 1);

    // Check if a new signal is present and it's not the same as the last signal
    
// remember to chek the EMPTY_VALUE, because is represent with a value > 0

    // Also check if 10 seconds have passed since the last order was opened
    if ((buySignal > 0 && buySignal != EMPTY_VALUE && lastSignal != OP_BUY) ||
        (sellSignal > 0 && sellSignal != EMPTY_VALUE && lastSignal != OP_SELL)) {
        if (GetTickCount() - lastOrderOpenTime > 10000) {
            
            // If there are open orders, close them
            if (OrdersTotal() > 0) {
                for (int j = OrdersTotal() - 1; j >= 0; j--) {
                    if (OrderSelect(j, SELECT_BY_POS)) {
                        lastClosedOrderType   = OrderType();
                        lastClosedOrderProfit = OrderProfit() > 0;
                        bool closeResult1     = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage);
                        if (!closeResult1) {
                            Print("OrderClose failed with error #", GetLastError());
                            Sleep(5000);                                                                        // Wait for 5 seconds
                            closeResult1 = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage); // Retry closing the order
                            if (!closeResult1) {
                                Print("OrderClose failed again with error #", GetLastError());
                            }
                        }
                    }
                }
            }

            // If the last closed order was a loss, double the lot size
            if (!lastClosedOrderProfit) {
                Lots *= 1;
            } else {
                // Reset the lot size to initialLots
                Lots = initialLots;
            }

            // Set profitToClose to NetProfitToClose only
            profitToClose = NetProfitToClose;

            // Send a request to the server to open a new order based on the new signal

// remember to chek the EMPTY_VALUE, because is represent with a value > 0
            if (buySignal > 0 && buySignal != EMPTY_VALUE) {
                ticket     = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, "My EA", magicNumber, 0, Green);
                lastSignal = OP_BUY;
            } else if (sellSignal > 0 && sellSignal != EMPTY_VALUE) {
                ticket     = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, "My EA", magicNumber, 0, Red);
                lastSignal = OP_SELL;
            }

            // Check if the order was successfully opened
            if (ticket < 0) {
                Print("OrderSend failed with error #", GetLastError());
            } else {
                // Record the time the order was opened
                lastOrderOpenTime = GetTickCount();
            }
        }
    }

    // Check if the current order's profit has reached the desired threshold
    if (OrderSelect(0, SELECT_BY_POS)) {
        // Close at NetProfitToClose
        if (OrderProfit() >= profitToClose) {
            lastClosedOrderType   = OrderType();
            lastClosedOrderProfit = OrderProfit() > 0;
            bool closeResult2     = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage);
            if (!closeResult2) {
                Print("OrderClose failed with error #", GetLastError());
                Sleep(5000);                                                                        // Wait for 5 seconds
                closeResult2 = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage); // Retry closing the order
                if (!closeResult2) {
                    Print("OrderClose failed again with error #", GetLastError());
                }
            }
            if (closeResult2) {
                // If the last closed order was profitable, reset the lot size to initialLots
                if (lastClosedOrderProfit) {
                    Lots = initialLots;
                }

// this part generate a loop to open continually
                // Open a new order of the same type
                // if (lastClosedOrderType == OP_BUY) {
                //     ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, "My EA", magicNumber, 0, Green);
                // } else if (lastClosedOrderType == OP_SELL) {
                //     ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, "My EA", magicNumber, 0, Red);
                // }
// --

                if (ticket < 0) {
                    Print("OrderSend failed with error #", GetLastError());
                } else {
                    lastOrderOpenTime = GetTickCount();
                }
            }
        }
    }

    // Reset the last signal when all orders are closed
    if (OrdersTotal() == 0) {
        lastSignal = -1;
    }
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 