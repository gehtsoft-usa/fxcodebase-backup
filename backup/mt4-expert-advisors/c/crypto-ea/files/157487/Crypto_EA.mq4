//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75409

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

extern bool   Exit               = true; // Enable Exit strategy
extern bool   USEMOVETOBREAKEVEN = true; // Enable "no loss"
extern double WHENTOMOVETOBE     = 10;   // When to move break even
extern double PIPSTOMOVESL       = 5;    // How much pips to move sl
extern double Lots               = 0.01; // Lots size
double  MaximumRisk        = 0;
double  DecreaseFactor     = 0;
extern double TrailingStop       = 40;   // TrailingStop
extern double Stop_Loss          = 200;  // Stop Loss
extern int    MagicNumber        = 1234; // MagicNumber
input double  Take_Profit        = 200;  // TakeProfit
extern int    FastMA             = 1;    // FastMA
extern int    SlowMA             = 5;    // SlowMA
extern double Mom_Sell           = 0.3;  // Momentum_Sell
extern double Mom_Buy            = 0.3;  // Momentum_Buy
extern int    FractalNum         = 10;   // Number Of High And Low
int           err;

int    total = 0;
double Lot, Dmax, Dmin, // Amount of lots in a selected order
    Lts,                // Amount of lots in an opened order
    Min_Lot,            // Minimal amount of lots
    Step,               // Step of lot size change
    Free,               // Current free margin
    One_Lot,            // Price of one lot
    Price,              // Price of a selected order,
    pips, MA_1, MA_2, MACD_SIGNAL;
int Type, freeze_level, Spread;
//--- price levels for orders and positions
double priceopen, stoploss, takeprofit;
//--- ticket of the current order
int orderticket;

double Linenow   = 0;
double Lineprev  = 0;
double Linenow1  = 0;
double Lineprev1 = 0;
//--------------------------------------------------------------- 3 --
int Period_MA_2, Period_MA_3,   // Calculation periods of MA for other timefr.
    Period_MA_02, Period_MA_03, // Calculation periods of supp. MAs
    K2, K3, T, L;
//---
//---
datetime dt   = 0;
datetime dt1  = 0;
datetime dt2  = 0;
datetime dt12 = 0;

int    First_Low_Candel = 0, Secund_Low_Candel = 3, First_High_Candel = 0, Secund_High_Candel = 3, FractalHCandel[], FractalLCandel[];
double FractalHigh[], FractalLow[], LineValLow = 0, LineValHigh = 0;
int    First_Low_Candel1 = 0, Secund_Low_Candel1 = 3, First_High_Candel1 = 0, Secund_High_Candel1 = 3, FractalHCandel1[], FractalLCandel1[];
double FractalHigh1[], FractalLow1[], LineValLow1 = 0, LineValHigh1 = 0;
//+---------------------------------------------------------------
//+------------------------------------------------------------------+
//| Expert initialization function |
//+------------------------------------------------------------------+
int OnInit()
{

    //--------------------------------------------------------------- 5 --
    switch (Period()) // Calculating coefficient for..
    {
    // .. different timeframes
    case 1:
        L = PERIOD_M5;
        T = PERIOD_M15;
        break; // Timeframe M1
    case 5:
        L = PERIOD_M1;
        T = PERIOD_M15;
        break; // Timeframe M5
    case 15:
        L = PERIOD_M5;
        T = PERIOD_M30;
        break; // Timeframe M15
    case 30:
        L = PERIOD_M15;
        T = PERIOD_H1;
        break; // Timeframe M30
    case 60:
        L = PERIOD_M30;
        T = PERIOD_H4;
        break; // Timeframe H1
    case 240:
        L = PERIOD_H1;
        T = PERIOD_D1;
        break; // Timeframe H4
    case 1440:
        L = PERIOD_H4;
        T = PERIOD_W1;
        break; // Timeframe D1
    case 10080:
        L = PERIOD_D1;
        T = PERIOD_MN1;
        break; // Timeframe W1
    case 43200:
        L = PERIOD_W1;
        T = PERIOD_D1;
        break; // Timeframe MN
    }

    double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
    if (ticksize == 0.00001 || ticksize == 0.001)
        pips = ticksize * 10;
    else
        pips = ticksize;
    return (INIT_SUCCEEDED);
    //--- distance from the activation price, within which it is not allowed to modify orders and positions
    freeze_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
    if (freeze_level != 0) {
        PrintFormat("SYMBOL_TRADE_FREEZE_LEVEL=%d: order or position modification is not allowed," + " if there are %d points to the activation price", freeze_level, freeze_level);
    }

    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { del(); }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void OnTick(void)
{
    drow();
    // Check for New Bar (Compatible with both MQL4 and MQL5)
    static datetime dtBarCurrent  = WRONG_VALUE;
    datetime        dtBarPrevious = dtBarCurrent;
    dtBarCurrent                  = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
    bool NewBarFlag               = (dtBarCurrent != dtBarPrevious);
    if (NewBarFlag) {
        if (Exit) {
            stop();
        }
        if (USEMOVETOBREAKEVEN) {
            MOVETOBREAKEVEN();
        }
        Trail1();
        int ticket = 0;
        // initial data checks
        // it is important to make sure that the expert works with a normal
        // chart and the user did not make any mistakes setting external
        // variables (Lots, StopLoss, TakeProfit,
        // TrailingStop) in our case, we check TakeProfit
        // on a chart of less than 100 bars
        //---
        if (Bars < 100) {
            Print("bars less than 100");
            return;
        }
        if (Take_Profit < 10) {
            Print("TakeProfit less than 10");
            return;
        }
        //--- to simplify the coding and speed up access data are put into internal variables
        HideTestIndicators(true);
        double MomLevel  = MathAbs(100 - iMomentum(NULL, 0, 14, PRICE_CLOSE, 1));
        double MomLevel1 = MathAbs(100 - iMomentum(NULL, 0, 14, PRICE_CLOSE, 2));
        double MomLevel2 = MathAbs(100 - iMomentum(NULL, 0, 14, PRICE_CLOSE, 3));
        //--------------------------------------------------------------------------------------------------
        double MA_1_t = iMA(NULL, 0, FastMA, 0, MODE_LWMA, PRICE_TYPICAL, 0); // МА_1
        double MA_2_t = iMA(NULL, 0, SlowMA, 0, MODE_LWMA, PRICE_TYPICAL, 0); // МА_2
        //-------------------------------------------------------------------------------------------------
        //+------------------------------------------------------------------+
        double MacdMAIN0   = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double MacdSIGNAL0 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
        double MacdMAIN1   = iMACD(NULL, T, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double MacdSIGNAL1 = iMACD(NULL, T, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
        double MacdMAIN2   = iMACD(NULL, L, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
        double MacdSIGNAL2 = iMACD(NULL, L, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
        //+------------------------------------------------------------------+
        HideTestIndicators(false);
        //--------------------------------------------------------------------------------------------------
        LineValHigh1 = NormalizeDouble(ObjectGetValueByShift("FractalHigh.", 1), Digits);
        LineValLow1  = NormalizeDouble(ObjectGetValueByShift("FractalLow.", 1), Digits);

        if (getOpenOrders() == 0) {
            //--- no opened orders identified
            if (AccountFreeMargin() < (1000 * Lots)) {
                Print("We have no money. Free Margin = ", AccountFreeMargin());
                return;
            }

            //--- check for long position (BUY) possibility
            //+------------------------------------------------------------------+
            //| BUY BUY BUY |
            //+------------------------------------------------------------------+
            if (find() == 1 && Close[1] < Ask)
                if ((MA_1_t > MA_2_t) && ((MacdMAIN2 > 0 && MacdMAIN2 > MacdSIGNAL2) || (MacdMAIN2 < 0 && MacdMAIN2 > MacdSIGNAL2)))
                    if (MomLevel < Mom_Buy || MomLevel1 < Mom_Buy || MomLevel2 < Mom_Buy) {
                        if (IsTesting() == true) {
                            if ((CheckVolumeValue(LotsOptimizedMxs(Lots))) == TRUE)
                                if ((CheckMoneyForTrade(Symbol(), LotsOptimizedMxs(Lots), OP_BUY)) == TRUE)
                                    if ((CheckStopLoss_Takeprofit(OP_BUY, NDTP(Bid - Stop_Loss * pips), NDTP(Bid + Take_Profit * pips))) == TRUE)
                                        ticket = OrderSend(Symbol(), OP_BUY, LotsOptimizedMxs(Lots), ND(Ask), 3, NDTP(Bid - Stop_Loss * pips), NDTP(Bid + Take_Profit * pips), "Long 1", MagicNumber, 0,
                                                           PaleGreen);
                            if (ticket > 0) {
                                if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) Print("BUY order opened : ", OrderOpenPrice());
                                Alert("we just got a buy signal on the ", _Period, "M", _Symbol);
                                SendNotification("we just got a buy signal on the1 " + (string)_Period + "M" + _Symbol);
                                SendMail("Order sent successfully", "we just got a buy signal on the1 " + (string)_Period + "M" + _Symbol);
                            } else
                                Print("Error opening BUY order : ", GetLastError());
                            return;
                        }
                        if (IsTesting() == false) // only in live trading we use the line
                        {
                            if (High[1] >= LineValLow1)
                                if ((CheckVolumeValue(LotsOptimizedMxs(Lots))) == TRUE)
                                    if ((CheckMoneyForTrade(Symbol(), LotsOptimizedMxs(Lots), OP_BUY)) == TRUE)
                                        if ((CheckStopLoss_Takeprofit(OP_BUY, NDTP(Bid - Stop_Loss * pips), NDTP(Bid + Take_Profit * pips))) == TRUE)
                                            ticket = OrderSend(Symbol(), OP_BUY, LotsOptimizedMxs(Lots), ND(Ask), 3, NDTP(Bid - Stop_Loss * pips), NDTP(Bid + Take_Profit * pips), "Long 1",
                                                               MagicNumber, 0, PaleGreen);
                            if (ticket > 0) {
                                if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) Print("BUY order opened : ", OrderOpenPrice());
                                Alert("we just got a buy signal on the ", _Period, "M", _Symbol);
                                SendNotification("we just got a buy signal on the1 " + (string)_Period + "M" + _Symbol);
                                SendMail("Order sent successfully", "we just got a buy signal on the1 " + (string)_Period + "M" + _Symbol);
                            } else
                                Print("Error opening BUY order : ", GetLastError());
                            return;
                        }
                    }
            //--- check for short position (SELL) possibility
            //+------------------------------------------------------------------+
            //| SELL SELL SELL |
            //+------------------------------------------------------------------+
            if (find() == 1 && Close[1] > Bid)
                if ((MA_1_t < MA_2_t) && ((MacdMAIN2 > 0 && MacdMAIN2 < MacdSIGNAL2) || (MacdMAIN2 < 0 && MacdMAIN2 < MacdSIGNAL2)))
                    if (MomLevel < Mom_Sell || MomLevel1 < Mom_Sell || MomLevel2 < Mom_Sell) {
                        if (IsTesting() == true) {
                            if ((CheckVolumeValue(LotsOptimizedMxs(Lots))) == TRUE)
                                if ((CheckMoneyForTrade(Symbol(), LotsOptimizedMxs(Lots), OP_SELL)) == TRUE)
                                    if ((CheckStopLoss_Takeprofit(OP_SELL, NDTP(Ask + Stop_Loss * pips), NDTP(Ask - Take_Profit * pips))) == TRUE)
                                        ticket = OrderSend(Symbol(), OP_SELL, LotsOptimizedMxs(Lots), ND(Bid), 3, NDTP(Ask + Stop_Loss * pips), NDTP(Ask - Take_Profit * pips), "Short 1", MagicNumber,
                                                           0, Red);
                            if (ticket > 0) {
                                if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) Print("SELL order opened : ", OrderOpenPrice());
                                Alert("we just got a sell signal on the ", _Period, "M", _Symbol);
                                SendMail("Order sent successfully", "we just got a sell signal on the " + (string)_Period + "M" + _Symbol);
                            } else
                                Print("Error opening SELL order : ", GetLastError());
                        }
                        if (IsTesting() == false) // only in live trading we use the line
                        {
                            if (High[1] >= LineValLow1)
                                if ((CheckVolumeValue(LotsOptimizedMxs(Lots))) == TRUE)
                                    if ((CheckMoneyForTrade(Symbol(), LotsOptimizedMxs(Lots), OP_SELL)) == TRUE)
                                        if ((CheckStopLoss_Takeprofit(OP_SELL, NDTP(Ask + Stop_Loss * pips), NDTP(Ask - Take_Profit * pips))) == TRUE)
                                            ticket = OrderSend(Symbol(), OP_SELL, LotsOptimizedMxs(Lots), ND(Bid), 3, NDTP(Ask + Stop_Loss * pips), NDTP(Ask - Take_Profit * pips), "Short 1",
                                                               MagicNumber, 0, Red);
                            if (ticket > 0) {
                                if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) Print("SELL order opened : ", OrderOpenPrice());
                                Alert("we just got a sell signal on the ", _Period, "M", _Symbol);
                                SendMail("Order sent successfully", "we just got a sell signal on the " + (string)_Period + "M" + _Symbol);
                            } else
                                Print("Error opening SELL order : ", GetLastError());
                        }
                        //--- exit from the "no opened orders" block
                        return;
                    }
        }
    }
}

//+------------------------------------------------------------------+
//| stop |
//+------------------------------------------------------------------+
//-----------------------------------------------------------------------------+
int stop()
{
    total = 0;
    HideTestIndicators(true);
    double MA_1_t = iMA(NULL, L, FastMA, 0, MODE_LWMA, PRICE_TYPICAL, 0); // МА_1
    double MA_2_t = iMA(NULL, L, SlowMA, 0, MODE_LWMA, PRICE_TYPICAL, 0); // МА_2
    //+------------------------------------------------------------------+
    double middleBB = iBands(Symbol(), 0, 20, 2, 0, 0, MODE_MAIN, 1);  // middle
    double lowerBB  = iBands(Symbol(), 0, 20, 2, 0, 0, MODE_LOWER, 1); // lower
    double upperBB  = iBands(Symbol(), 0, 20, 2, 0, 0, MODE_UPPER, 1); // upper
    //+------------------------------------------------------------------+
    double MacdMAIN    = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
    double MacdSIGNAL  = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
    double MacdMAIN0   = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
    double MacdSIGNAL0 = iMACD(NULL, 0, 12, 26, 9, PRICE_CLOSE, MODE_SIGNAL, 1);
    //+------------------------------------------------------------------+
    //+------------------------------------------------------------------+
    // DALYN GUPPY MMA
    //----------------------------------------------------------------------------
    double MA_3  = iMA(NULL, L, 3, 0, MODE_EMA, PRICE_TYPICAL, 0);  // МА_3 DALYN GUPPY MMA
    double MA_5  = iMA(NULL, L, 5, 0, MODE_EMA, PRICE_TYPICAL, 0);  // МА_5 DALYN GUPPY MMA
    double MA_8  = iMA(NULL, L, 8, 0, MODE_EMA, PRICE_TYPICAL, 0);  // МА_8 DALYN GUPPY MMA
    double MA_10 = iMA(NULL, L, 10, 0, MODE_EMA, PRICE_TYPICAL, 0); // МА_10 DALYN GUPPY MMA
    double MA_12 = iMA(NULL, L, 12, 0, MODE_EMA, PRICE_TYPICAL, 0); // МА_12 DALYN GUPPY MMA
    double MA_15 = iMA(NULL, L, 15, 0, MODE_EMA, PRICE_TYPICAL, 0); // МА_15 DALYN GUPPY MMA
    double MA_30 = iMA(NULL, L, 30, 0, MODE_EMA, PRICE_TYPICAL, 0); // МА_30 DALYN GUPPY MMA
    double MA_35 = iMA(NULL, L, 35, 0, MODE_EMA, PRICE_TYPICAL, 0); // МА_35 DALYN GUPPY MMA
    double MA_40 = iMA(NULL, L, 40, 0, MODE_EMA, PRICE_TYPICAL, 0); // МА_40 DALYN GUPPY MMA
    double MA_45 = iMA(NULL, L, 45, 0, MODE_EMA, PRICE_TYPICAL, 0); // МА_45 DALYN GUPPY MMA
    double MA_50 = iMA(NULL, L, 50, 0, MODE_EMA, PRICE_TYPICAL, 0); // МА_50 DALYN GUPPY MMA
    double MA_60 = iMA(NULL, L, 60, 0, MODE_EMA, PRICE_TYPICAL, 0); // МА_60 DALYN GUPPY MMA
    //-----------------------------------------------------------------------------------
    HideTestIndicators(false);
    for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
        if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
                if (OrderType() == OP_BUY) {
                    //--- should it be closed?
                    if (((MA_3 == MA_5 && MA_5 == MA_8 && MA_8 == MA_10 && MA_10 == MA_12 && MA_12 == MA_15) ||
                         (MA_30 == MA_35 && MA_35 == MA_40 && MA_40 == MA_45 && MA_45 == MA_50 && MA_50 == MA_60)) ||
                        (Close[1] <= lowerBB))
                        if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, Red)) Print("Did not close");
                    break;
                    Print(" CLOSE BY EXIT STRATEGY ");
                    //--- check for trailing stop
                } else // go to short position
                {
                    //--- should it be closed?
                    if (((MA_3 == MA_5 && MA_5 == MA_8 && MA_8 == MA_10 && MA_10 == MA_12 && MA_12 == MA_15) ||
                         (MA_30 == MA_35 && MA_35 == MA_40 && MA_40 == MA_45 && MA_45 == MA_50 && MA_50 == MA_60)) ||
                        (Close[1] <= lowerBB))
                        if (!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3, Red)) Print("Did not close");
                    break;
                    Print(" CLOSE BY EXIT STRATEGY ");
                    //--- check for trailing stop
                }
            }
        }
    }
    return (0);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Trailing stop loss |
//+------------------------------------------------------------------+
// --------------- ----------------------------------------------------------- ------------------------
void Trail1()
{
    total = OrdersTotal();
    //--- it is important to enter the market correctly, but it is more important to exit it correctly...
    for (int cnt = 0; cnt < total; cnt++) {
        if (!OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) continue;
        if (OrderType() <= OP_SELL &&  // check for opened position
            OrderSymbol() == Symbol()) // check for symbol
        {
            //--- long position is opened
            if (OrderType() == OP_BUY) {

                //--- check for trailing stop
                if (TrailingStop > 0) {
                    if (Bid - OrderOpenPrice() > pips * TrailingStop) {
                        if (OrderStopLoss() < Bid - pips * TrailingStop) {

                            RefreshRates();
                            stoploss         = Bid - (pips * TrailingStop);
                            takeprofit       = OrderTakeProfit();
                            double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD);
                            if (stoploss < StopLevel * pips) stoploss = StopLevel * pips;
                            string symbol = OrderSymbol();
                            double point  = SymbolInfoDouble(symbol, SYMBOL_POINT);
                            if (MathAbs(OrderStopLoss() - stoploss) > point)
                                if ((pips * TrailingStop) > (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * pips)

                                    //--- modify order and exit
                                    if (CheckStopLoss_Takeprofit(OP_BUY, stoploss, takeprofit))
                                        if (OrderModifyCheck(OrderTicket(), OrderOpenPrice(), stoploss, takeprofit))
                                            if (!OrderModify(OrderTicket(), OrderOpenPrice(), stoploss, takeprofit, 0, Green)) Print("OrderModify error ", GetLastError());
                            return;
                        }
                    }
                }
            } else // go to short position
            {
                //--- check for trailing stop
                if (TrailingStop > 0) {
                    if ((OrderOpenPrice() - Ask) > (pips * TrailingStop)) {
                        if ((OrderStopLoss() > (Ask + pips * TrailingStop)) || (OrderStopLoss() == 0)) {

                            RefreshRates();
                            stoploss         = Ask + (pips * TrailingStop);
                            takeprofit       = OrderTakeProfit();
                            double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD);
                            if (stoploss < StopLevel * pips) stoploss = StopLevel * pips;
                            if (takeprofit < StopLevel * pips) takeprofit = StopLevel * pips;
                            string symbol = OrderSymbol();
                            double point  = SymbolInfoDouble(symbol, SYMBOL_POINT);
                            if (MathAbs(OrderStopLoss() - stoploss) > point)
                                if ((pips * TrailingStop) > (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * pips)

                                    //--- modify order and exit
                                    if (CheckStopLoss_Takeprofit(OP_SELL, stoploss, takeprofit))
                                        if (OrderModifyCheck(OrderTicket(), OrderOpenPrice(), stoploss, takeprofit))
                                            if (!OrderModify(OrderTicket(), OrderOpenPrice(), stoploss, takeprofit, 0, Red)) Print("OrderModify error ", GetLastError());
                            return;
                        }
                    }
                }
            }
        }
    }
}
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
//| MOVE TO BREAK EVEN |
//+---------------------------------------------------------------------------+
void MOVETOBREAKEVEN()

{
    for (int b = OrdersTotal() - 1; b >= 0; b--) {
        if (OrderSelect(b, SELECT_BY_POS, MODE_TRADES))
            if (OrderMagicNumber() != MagicNumber) continue;
        if (OrderSymbol() == Symbol())
            if (OrderType() == OP_BUY)
                if (Bid - OrderOpenPrice() > WHENTOMOVETOBE * pips)
                    if (OrderOpenPrice() > OrderStopLoss())
                        if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + (PIPSTOMOVESL * pips), OrderTakeProfit(), 0, CLR_NONE)) Print("eror");
    }

    for (int s = OrdersTotal() - 1; s >= 0; s--) {
        if (OrderSelect(s, SELECT_BY_POS, MODE_TRADES))
            if (OrderMagicNumber() != MagicNumber) continue;
        if (OrderSymbol() == Symbol())
            if (OrderType() == OP_SELL)
                if (OrderOpenPrice() - Ask > WHENTOMOVETOBE * pips)
                    if (OrderOpenPrice() < OrderStopLoss())
                        if (!OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - (PIPSTOMOVESL * pips), OrderTakeProfit(), 0, CLR_NONE)) Print("eror");
    }
}
//--------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy |
//+------------------------------------------------------------------+
double LotsOptimized()
{
    double lot    = Lots;
    int    orders = OrdersHistoryTotal(); // history orders total
    int    losses = 0;                    // number of losses orders without a break
    //--- select lot size
    if (MaximumRisk > 0) {
        lot = NormalizeDouble(AccountFreeMargin() * MaximumRisk / 1000.0, 1);
    }
    //--- calcuulate number of losses orders without a break
    if (DecreaseFactor > 0) {
        for (int i = orders - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false) {
                Print("Error in history!");
                break;
            }
            if (OrderSymbol() != Symbol()) continue;
            //---
            if (OrderProfit() > 0) break;
            if (OrderProfit() < 0) losses++;
        }
        if (losses > 1) lot = NormalizeDouble(lot - lot * losses / DecreaseFactor, 1);
    }
    //--- minimal allowed volume for trade operations
    double minlot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
    if (lot < minlot) {
        lot = minlot;
        Print("Volume is less than the minimal allowed ,we use", minlot);
    }
    // lot=minlot;

    //--- maximal allowed volume of trade operations
    double maxlot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
    if (lot > maxlot) {
        lot = maxlot;
        Print("Volume is greater than the maximal allowed,we use", maxlot);
    }
    // lot=maxlot;

    //--- get minimal step of volume changing
    double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
    int    ratio       = (int)MathRound(lot / volume_step);
    if (MathAbs(ratio * volume_step - lot) > 0.0000001) {
        lot = ratio * volume_step;

        Print("Volume is not a multiple of the minimal step ,we use the closest correct volume ", ratio * volume_step);
    }
    return (lot);
}
//+------------------------------------------------------------------+
double NDTP(double val)
{
    RefreshRates();
    double SPREAD    = MarketInfo(Symbol(), MODE_SPREAD);
    double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
    if (val < StopLevel * pips + SPREAD * pips) val = StopLevel * pips + SPREAD * pips;
    return (NormalizeDouble(val, Digits));
    // return(val);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double ND(double val) { return (NormalizeDouble(val, Digits)); }
//+------------------------------------------------------------------+
//| Checking the new values of levels before order modification |
//+------------------------------------------------------------------+
bool OrderModifyCheck(int ticket, double price, double sl, double tp)
{
    //--- select order by ticket
    if (OrderSelect(ticket, SELECT_BY_TICKET)) {
        //--- point size and name of the symbol, for which a pending order was placed
        string symbol = OrderSymbol();
        double point  = SymbolInfoDouble(symbol, SYMBOL_POINT);
        //--- check if there are changes in the Open price
        bool PriceOpenChanged = true;
        int  type             = OrderType();
        if (!(type == OP_BUY || type == OP_SELL)) {
            PriceOpenChanged = (MathAbs(OrderOpenPrice() - price) > point);
        }
        //--- check if there are changes in the StopLoss level
        bool StopLossChanged = (MathAbs(OrderStopLoss() - sl) > point);
        //--- check if there are changes in the Takeprofit level
        bool TakeProfitChanged = (MathAbs(OrderTakeProfit() - tp) > point);
        //--- if there are any changes in levels
        if (PriceOpenChanged || StopLossChanged || TakeProfitChanged) return (true); // order can be modified
        //--- there are no changes in the Open, StopLoss and Takeprofit levels
        else
            //--- notify about the error
            PrintFormat("Order #%d already has levels of Open=%.5f SL=%.5f TP=%.5f", ticket, OrderOpenPrice(), OrderStopLoss(), OrderTakeProfit());
    }
    //--- came to the end, no changes for the order
    return (false); // no point in modifying
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool CheckStopLoss_Takeprofit(ENUM_ORDER_TYPE type, double SL, double TP)
{
    //--- get the SYMBOL_TRADE_STOPS_LEVEL level
    int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    if (stops_level != 0) {
        PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must" + " not be nearer than %d points from the closing price", stops_level, stops_level);
    }
    //---
    bool SL_check = false, TP_check = false;
    //--- check only two order types
    switch (type) {
    //--- Buy operation
    case ORDER_TYPE_BUY: {
        //--- check the StopLoss
        SL_check = (Bid - SL > stops_level * _Point);
        if (!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be less than %.5f" + " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)", EnumToString(type), SL, Bid - stops_level * _Point, Bid, stops_level);
        //--- check the TakeProfit
        TP_check = (TP - Bid > stops_level * _Point);
        if (!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f" + " (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)", EnumToString(type), TP, Bid + stops_level * _Point, Bid,
                        stops_level);
        //--- return the result of checking
        return (SL_check && TP_check);
    }
    //--- Sell operation
    case ORDER_TYPE_SELL: {
        //--- check the StopLoss
        SL_check = (SL - Ask > stops_level * _Point);
        if (!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f " + " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)", EnumToString(type), SL, Ask + stops_level * _Point, Ask,
                        stops_level);
        //--- check the TakeProfit
        TP_check = (Ask - TP > stops_level * _Point);
        if (!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f " + " (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)", EnumToString(type), TP, Ask - stops_level * _Point, Ask,
                        stops_level);
        //--- return the result of checking
        return (TP_check && SL_check);
    } break;
    }
    //--- a slightly different function is required for pending orders
    return false;
}
//+------------------------------------------------------------------+
////////////////////////////////////////////////////////////////////////////////////
int getOpenOrders()
{

    int Orders = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) {
            continue;
        }
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) {
            continue;
        }
        Orders++;
    }
    return (Orders);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy |
//+------------------------------------------------------------------+
double LotsOptimized1Mxs(double llots)
{
    double lots = llots;
    //--- minimal allowed volume for trade operations
    double minlot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
    if (lots < minlot) {
        lots = minlot;
    }
    //--- maximal allowed volume of trade operations
    double maxlot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
    if (lots > maxlot) {
        lots = maxlot;
    }
    //--- get minimal step of volume changing
    double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
    int    ratio       = (int)MathRound(lots / volume_step);
    if (MathAbs(ratio * volume_step - lots) > 0.0000001) {
        lots = ratio * volume_step;
    }
    if (((AccountStopoutMode() == 1) && (AccountFreeMarginCheck(Symbol(), OP_BUY, lots) > AccountStopoutLevel())) ||
        ((AccountStopoutMode() == 0) && ((AccountEquity() / (AccountEquity() - AccountFreeMarginCheck(Symbol(), OP_BUY, lots)) * 100) > AccountStopoutLevel())))
        return (lots);
    /* else Print("StopOut level Not enough money for ",OP_SELL," ",lot," ",Symbol());*/
    return (0);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy |
//+------------------------------------------------------------------+
double LotsOptimizedMxs(double llots)
{
    double lots = llots;
    //--- minimal allowed volume for trade operations
    double minlot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
    if (lots < minlot) {
        lots = minlot;
        Print("Volume is less than the minimal allowed ,we use", minlot);
    }
    //--- maximal allowed volume of trade operations
    double maxlot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
    if (lots > maxlot) {
        lots = maxlot;
        Print("Volume is greater than the maximal allowed,we use", maxlot);
    }
    //--- get minimal step of volume changing
    double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
    int    ratio       = (int)MathRound(lots / volume_step);
    if (MathAbs(ratio * volume_step - lots) > 0.0000001) {
        lots = ratio * volume_step;

        Print("Volume is not a multiple of the minimal step ,we use the closest correct volume ", ratio * volume_step);
    }

    return (lots);
}
//+------------------------------------------------------------------+
//| Check the correctness of the order volume |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume /*,string &description*/)
{
    double lot    = volume;
    int    orders = OrdersHistoryTotal(); // history orders total
    int    losses = 0;                    // number of losses orders without a break
    //--- select lot size
    //--- maximal allowed volume of trade operations
    double max_volume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
    if (lot > max_volume) Print("Volume is greater than the maximal allowed ,we use", max_volume);
    // return(false);

    //--- minimal allowed volume for trade operations
    double minlot = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
    if (lot < minlot) Print("Volume is less than the minimal allowed ,we use", minlot);
    // return(false);

    //--- get minimal step of volume changing
    double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
    int    ratio       = (int)MathRound(lot / volume_step);
    if (MathAbs(ratio * volume_step - lot) > 0.0000001) {
        Print("Volume is not a multiple of the minimal step ,we use, the closest correct volume is %.2f", volume_step, ratio * volume_step);
        // return(false);
    }
    // description="Correct volume value";
    return (true);
}
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots, int type)
{
    double free_margin = AccountFreeMarginCheck(symb, type, lots);
    //-- if there is not enough money
    // else if(free_margin<0)
    if ((((AccountStopoutMode() == 1) && (AccountFreeMarginCheck(symb, type, lots) < AccountStopoutLevel())) ||
         ((AccountStopoutMode() == 0) && ((AccountEquity() / (AccountEquity() - AccountFreeMarginCheck(Symbol(), OP_SELL, lots)) * 100) < AccountStopoutLevel())))) {
        Print("StopOut level Not enough money for ", OP_SELL, " ", lots, " ", Symbol());
        return (false);
    } else if (free_margin < 0) {
        string oper = (type == OP_BUY) ? "Buy" : "Sell";
        Print("Not enough money for ", oper, " ", lots, " ", symb, " Error code=", GetLastError());
        return (false);
    }
    //--- checking successful
    return (true);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Fractal High Low horizital line Show |
//+------------------------------------------------------------------+
int drow()
{

    datetime T2 = 0; // Second time coordinate
    double   t2 = 0;
    int      Error; // Error code
    //--------------------------------------------------------------- 3 --
    ArrayResize(FractalHigh, FractalNum, 1);
    ArrayResize(FractalLow, FractalNum, 1);
    ArrayResize(FractalHCandel, FractalNum, 1);
    ArrayResize(FractalLCandel, FractalNum, 1);
    double high = -1, low = -1;
    double data     = 0;
    int    lowcount = 0, highcount = 0;

    for (int i = 0; i < Bars; i++) {
        high = iFractals(NULL, 0, MODE_UPPER, i);
        if (high > 0) {
            FractalHigh[highcount]    = high;
            FractalHCandel[highcount] = i;
            highcount++;
        }
        high = -1;
        if (highcount == FractalNum) break;
    }

    for (int i = 0; i < Bars; i++) {
        low = iFractals(NULL, 0, MODE_LOWER, i);
        if (low > 0) {
            FractalLow[lowcount]     = low;
            FractalLCandel[lowcount] = i;
            lowcount++;
        }
        low = -1;
        if (lowcount == FractalNum) break;
    }
    for (int j = 0; j <= FractalNum - 1; j++) {
        if (ObjectFind(0, "FractalHigh") < 0) {
            ObjectDelete("FractalHigh." + IntegerToString(j));
            ObjectCreate(0, "FractalHigh." + IntegerToString(j), OBJ_HLINE, 0, 0, 0, 0, 0);   // Create ARROW
            ObjectSetInteger(0, "FractalHigh." + IntegerToString(j), OBJPROP_ARROWCODE, 238); // Set the arrow code
            ObjectSetInteger(0, "FractalHigh." + IntegerToString(j), OBJPROP_COLOR, clrNavy);
        }
        ObjectSetInteger(0, "FractalHigh." + IntegerToString(j), OBJPROP_TIME, Time[FractalHCandel[j]]);                         // Set time
        ObjectSetDouble(0, "FractalHigh." + IntegerToString(j), OBJPROP_PRICE, FractalHigh[j] + (10 + (Period() / 100)) * pips); // Set price
    }

    for (int j = 0; j <= FractalNum - 1; j++) {
        if (ObjectFind(0, "FractalLow") < 0) {
            ObjectDelete("FractalLow." + IntegerToString(j));
            ObjectCreate(0, "FractalLow." + IntegerToString(j), OBJ_HLINE, 0, 0, 0, 0, 0);   // Create ARROW
            ObjectSetInteger(0, "FractalLow." + IntegerToString(j), OBJPROP_ARROWCODE, 236); // Set the arrow code
            ObjectSetInteger(0, "FractalLow." + IntegerToString(j), OBJPROP_COLOR, clrOrangeRed);
        }
        ObjectSetInteger(0, "FractalLow." + IntegerToString(j), OBJPROP_TIME, Time[FractalLCandel[j]]);                        // Set time
        ObjectSetDouble(0, "FractalLow." + IntegerToString(j), OBJPROP_PRICE, FractalLow[j] - (10 + (Period() / 250)) * pips); // Set price
    }

    First_Low_Candel   = 0;
    Secund_Low_Candel  = 2;
    First_High_Candel  = 0;
    Secund_High_Candel = 2;

    Error = GetLastError(); // Getting an error code

    return (0);
}
//--------------------------------------------------------------- 7 --
//+------------------------------------------------------------------+
//| Fractal High Low horizital line Show |
//+------------------------------------------------------------------+
int find()
{
    datetime T2 = 0; // Second time coordinate
    double   t2 = 0;
    // int Error; // Error code
    //--------------------------------------------------------------- 3 --
    double high = -1, low = -1;
    double data     = 0;
    int    lowcount = 0, highcount = 0;

    for (int i = 0; i < Bars; i++) {
        high = iFractals(NULL, 0, MODE_UPPER, i);
        if (high > 0) {
            if (Ask == high /*&&High[1]<high*/) return (1);
        }
    }
    for (int i = 0; i < Bars; i++) {
        low = iFractals(NULL, 0, MODE_LOWER, i);
        if (low > 0) {
            if (Bid == low /*&&Low[1]>low*/) return (1);
        }
    }
    return (0);
}
//--------------------------------------------------------------- 7 --
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void del()
{
    static datetime dtBarCurrent  = WRONG_VALUE;
    datetime        dtBarPrevious = dtBarCurrent;
    dtBarCurrent                  = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
    bool NewBarFlag               = (dtBarCurrent != dtBarPrevious);
    if (NewBarFlag) {
        // Sleep(3000);
        int obj_total = ObjectsTotal();
        PrintFormat("Total %d objects", obj_total);
        for (int i = obj_total - 1; i >= 0; i--) {
            string name = ObjectName(i);
            PrintFormat("object %d: %s", i, name);
            ObjectDelete(name);
        }
    }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
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