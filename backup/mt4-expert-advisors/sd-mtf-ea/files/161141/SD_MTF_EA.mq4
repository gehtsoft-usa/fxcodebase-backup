//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76430
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

#property description "Expert Advisor"
#property strict

//====================================================================================================================================================//
enum MO { Order_By_Order_All_Symbols,
          Same_Type_Of_Chart_Symbol_As_One };

enum ModeToOpen { byLive,
                  byCandleClose };
//====================================================================================================================================================//

input double lots          = 0.1;

input string EA_Comment = "// Settings";

input double  threshold = 0.5;                                      // Close by X Euro
extern string str       = "   -  =  shved_supply_and_demand =  -";  // set
extern int    BackLimit = 1000;

extern string     SetManageOrders  = "||=============== Manage Orders ===============||";
extern MO         ManageOrders     = Order_By_Order_All_Symbols;
extern ModeToOpen OpenMode         = byLive;
extern string     AddSLTP          = "||=============== Add SL/TP ===============||";
extern bool       PutTakeProfit    = true;
extern double     TakeProfitPips   = 20.0;
extern bool       PutStopLoss      = true;
extern double     StopLossPips     = 20.0;
extern string     TrailingSL       = "||=============== Trailing SL ===============||";
extern bool       UseTrailingStop  = true;
extern double     PutStopLossAfter = 0.0;
extern double     TrailingStop     = 5.0;
extern double     TrailingStep     = 1.0;
extern bool       UseBreakEven     = false;
extern double     BreakEvenAfter   = 10.0;
extern double     BreakEvenPips    = 5.0;
extern string     DeleteSLTP       = "||=============== Delete SL/TP ===============||";
extern bool       DeleteTakeProfit = false;
extern bool       DeleteStopLoss   = false;
extern string     AdvancedSets     = "||=============== Advanced Sets ===============||";
extern string     MagicNumberInfo1 = ">0 = modify identifier orders";
extern string     MagicNumberInfo2 = "0 = modify all orders";
extern string     MagicNumberInfo3 = "-1 = modify only manual orders";
extern string     MagicNumberInfo4 = "-2 = modify only chart symbol orders";
extern int        MagicNumber      = -2;
extern bool       SoundAlert       = true;
//====================================================================================================================================================//

string SoundModify = "tick.wav";
string BackgroundName;
double StopLevel;
double AveragePriceBuy  = 0;
double AveragePriceSell = 0;
int    SumOrders        = 0;
int    BuyOrders        = 0;
int    SellOrders       = 0;
int    MultiplierPoint;
int    DigitsPrices;
bool   MarketClosedCom;
bool   CallMain = false;
long   ChartColor;
string TP;
string SL;
string TSL;
string MN;
string SA;
string BE;
string ManageMode1 = "";
string ManageMode2 = "";

extern string pus1               = "/////////////////////////////////////////////////";
extern bool   zone_show_weak     = true;
extern bool   zone_show_untested = true;
extern bool   zone_show_turncoat = false;
extern double zone_fuzzfactor    = 0.75;

extern string pus2                = "/////////////////////////////////////////////////";
extern bool   fractals_show       = false;
extern double fractal_fast_factor = 3.0;
extern double fractal_slow_factor = 6.0;
extern bool   SetGlobals          = true;

extern string pus3 = "/////////////////////////////////////////////////";
double        StopLoss;
double        _point = 1;
double        last_sup, last_res;

// versuch Zeit Management Datetime siehe Void on Tick

datetime LastActiontime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // neuer TSL INT ON IT ANFANG

    //---------------------------------------------------------------------
    // Set timer
    EventSetMillisecondTimer(10);
    //---------------------------------------------------------------------
    // Set background
    // ChartColor     = ChartGetInteger(0, CHART_COLOR_BACKGROUND, 0);
    // BackgroundName = "Background-" + WindowExpertName();
    // if (ObjectFind(BackgroundName) == -1) ChartBackground(, (color)ChartColor, 0, 15, 135, 179);
    //------------------------------------------------------
    // Broker 4 or 5 digits
    MultiplierPoint = 1;
    if ((MarketInfo(Symbol(), MODE_DIGITS) == 3) || (MarketInfo(Symbol(), MODE_DIGITS) == 5)) MultiplierPoint = 10;
    //(MarketInfo(OrderSymbol(),MODE_POINT)*MultiplierPoint)
    //------------------------------------------------------
    // Minimum trailing, take profit, stop loss, break even
    StopLevel = MathMax(MarketInfo(Symbol(), MODE_FREEZELEVEL) / MultiplierPoint, MarketInfo(Symbol(), MODE_STOPLEVEL) / MultiplierPoint);
    if ((TrailingStop > 0) && (TrailingStop < StopLevel)) TrailingStop = StopLevel;
    if (TrailingStep > TrailingStop) TrailingStep = TrailingStop;
    if ((TakeProfitPips > 0) && (TakeProfitPips < StopLevel)) TakeProfitPips = StopLevel;
    if ((StopLossPips > 0) && (StopLossPips < StopLevel)) StopLossPips = StopLevel;
    if (BreakEvenAfter < BreakEvenPips) BreakEvenAfter = BreakEvenPips;
    if (BreakEvenAfter - BreakEvenPips < StopLevel) BreakEvenAfter = BreakEvenPips + StopLevel;
    if ((PutStopLossAfter > 0) && (PutStopLossAfter < TrailingStop)) PutStopLossAfter = TrailingStop;
    if (MagicNumber < -2) MagicNumber = -2;
    //------------------------------------------------------
    // External comment
    if (PutTakeProfit == true)
        TP = DoubleToStr(TakeProfitPips, 2);
    else
        TP = "FALSE";
    if (PutStopLoss == true)
        SL = DoubleToStr(StopLossPips, 2);
    else
        SL = "FALSE";
    if (UseTrailingStop == true)
        TSL = DoubleToStr(TrailingStop, 2) + "  (" + DoubleToStr(PutStopLossAfter, 2) + ")";
    else
        TSL = "FALSE";
    if (UseBreakEven == true)
        BE = DoubleToStr(BreakEvenPips, 2) + "  (" + DoubleToStr(BreakEvenAfter, 2) + ")";
    else
        BE = "FALSE";
    if (MagicNumber > 0) MN = DoubleToStr(MagicNumber, 0);
    if (MagicNumber == 0) MN = "All Orders";
    if (MagicNumber == -1) MN = "Manual Orders";
    if (MagicNumber == -2) MN = "Symbol Orders";
    if (SoundAlert == true)
        SA = "TRUE";
    else
        SA = "FALSE";
    //----------------------------------
    // Set manage mode
    if (ManageOrders == 0) ManageMode1 = "Order By Order";
    if (ManageOrders == 1) ManageMode1 = "Same Type As One";
    if ((ManageOrders == 0) && (MagicNumber != -2)) ManageMode2 = " All Symbols";
    if ((ManageOrders == 0) && (MagicNumber == -2)) ManageMode2 = " Chart Symbols";
    if (ManageOrders == 1) ManageMode2 = " " + Symbol() + " Symbol";
    //------------------------------------------------------
    if (!IsTesting()) MainFunction();  // For show comment if market is closed
    //------------------------------------------------------

    // neuer TSL INT ON IT ENDE

    // Get Symbol digit
    string _sym    = Symbol();
    double _digits = MarketInfo(_sym, MODE_DIGITS);
    if (_digits == 5 || _digits == 3) _point = 1 / MathPow(10, (_digits - 1));
    if (_digits == 4 || _digits == 2) _point = 1 / MathPow(10, (_digits));
    if (_digits == 1) _point = 0.1;
    last_sup = -1;
    last_res = -1;
    //
    //---
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
double Hi_p1, Hi_p2, Lo_p1, Lo_p2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
    // ANFANG TSL VOID ON TICK

    {
        //---------------------------------------------------------------------
        // Reset values
        CallMain = true;
        //---------------------------------------------------------------------
        // For testing
        if ((IsTesting()) || (IsOptimization()) || (IsVisualMode()))
        {
            CallMain = false;
            MainFunction();
        }
        //---------------------------------------------------------------------
    }

    
    get_indi();
		if (OpenMode == byLive)
    {
        double current_res = get_res();
        if (OrdersTotalT(OP_SELL) == 0 && Ask < current_res && current_res != 0 && current_res != last_res && iHigh(NULL, 0, 1) > current_res)
        {
            double _sl = MathAbs(current_res - get_res_sl()) / _point;
            SendOrder(OP_SELL, _sl);
            last_res = current_res;
        }
        double _sup = get_sup();
        if (OrdersTotalT(OP_BUY) == 0 && Bid > _sup && _sup != 0 && last_sup != _sup && iLow(NULL, 0, 1) < _sup)
        {
            double _sl = MathAbs(_sup - get_sup_sl()) / _point;  //
            SendOrder(OP_BUY, _sl);
            last_sup = _sup;
        }
    } 
		
		// ENDE TSL VOID ON TICK

    // Zeit Managment

    //+------------------------------------------------------------------+
    {
        // —
        // Comparing LastActionTime with the current starting time for the candle
        if (LastActiontime != Time[0] && 1)
        {
            // Code to execute once in the bar
            Print("This code is executed only once in the bar started", Time[0]);

            LastActiontime = Time[0];
        }
    }

    //---

    //  double current_res=get_res();
    //  if(OrdersTotalT(OP_SELL)==0 && Ask>current_res && current_res!=0 && current_res!=last_res)
    //  {
    // double _sl=MathAbs(current_res -get_res_sl())/_point;
    // SendOrder(OP_SELL,_sl);
    // last_res=current_res;
    //  }
    //  double _sup=get_sup();
    //  if(OrdersTotalT(OP_BUY)==0 && Bid<_sup && _sup!=0 && last_sup!=_sup)
    //  {
    // double _sl=MathAbs(_sup -get_sup_sl())/_point;//
    // SendOrder(OP_BUY,_sl);
    // last_sup=_sup;
    //  }

    // NOTE: Logic to Open Trades

    
		
		if (OpenMode == byCandleClose)
    {
        double current_res = get_res();
        if (OrdersTotalT(OP_SELL) == 0 && iClose(NULL,0,1) < current_res && current_res != 0 && current_res != last_res && iHigh(NULL, 0, 1) > current_res)
        {
            double _sl = MathAbs(current_res - get_res_sl()) / _point;
            SendOrder(OP_SELL, _sl);
            last_res = current_res;
        }
        double _sup = get_sup();
        if (OrdersTotalT(OP_BUY) == 0 && iClose(NULL,0,1) > _sup && _sup != 0 && last_sup != _sup && iLow(NULL, 0, 1) < _sup)
        {
            double _sl = MathAbs(_sup - get_sup_sl()) / _point;  //
            SendOrder(OP_BUY, _sl);
            last_sup = _sup;
        }
    }
}

//+----------------------------------Q--------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    //-------------Anfang TSL On Timer--------------------------------------------------------
    // Call main function
    if (CallMain == true) MainFunction();
    //--------------Ende TSL On Timer-------------------------------------------------------
}

// main function         ANFANG TSL MAIN FUNKTION
void MainFunction()
{
    MarketClosedCom         = false;
    double LocalTakeProfit  = 0;
    double LocalStopLoss    = 0;
    bool   WasOrderModified = false;
    double PriceBuyAsk      = 0;
    double PriceBuyBid      = 0;
    double PriceSellAsk     = 0;
    double PriceSellBid     = 0;
    double Spread           = 0;
    //----------------------------------
    // expert not enabled
    if ((!IsExpertEnabled()) && (!IsTesting()))
    {
        // Comment("==================",
        //         "\n\n    ", WindowExpertName(),
        //         "\n\n==================",
        //         "\n\n    Expert Not Enabled ! ! !",
        //         "\n\n    Please Turn On Expert",
        //         "\n\n\n\n==================");
        return;
    }
    
    //------------------------------------------------------
    // Comment in screen
    // Comment("==================",
    //         "\n  ", WindowExpertName(),
    //         "\n  Ready To Modify Orders",
    //         "\n==================",
    //         "\n  Manage: ", ManageMode1,
    //         "\n  Symbol: ", ManageMode2,
    //         "\n==================",
    //         "\n  Take Profit  : ", TP,
    //         "\n  Stop Loss    : ", SL,
    //         "\n  Trailing SL   : ", TSL,
    //         "\n  Break Even : ", BE,
    //         "\n==================",
    //         "\n  Orders ID   : ", MN,
    //         "\n  Sound Alert : ", SA,
    //         "\n==================");

    
    //------------------------------------------------------    
    // Reset switchs
    if (DeleteTakeProfit == true) PutTakeProfit = false;
    if (DeleteStopLoss == true)
    {
        PutStopLoss     = false;
        UseTrailingStop = false;
        UseBreakEven    = false;
    }
    //------------------------------------------------------
    // Count orders
    if (ManageOrders == 1)  // basket
    {
        CountOrders();
        Spread = (Ask - Bid) / (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint);
        if (AveragePriceBuy != 0)
        {
            PriceBuyAsk = AveragePriceBuy;
            PriceBuyBid = AveragePriceBuy - Spread;
        } else
        {
            PriceBuyAsk = Ask;
            PriceBuyBid = Bid;
        }
        //---
        if (AveragePriceSell != 0)
        {
            PriceSellAsk = AveragePriceSell + Spread;
            PriceSellBid = AveragePriceSell;
        } else
        {
            PriceSellAsk = Ask;
            PriceSellBid = Bid;
        }
    }
    //------------------------------------------------------
    // Select order
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
        {
            if ((((OrderMagicNumber() == MagicNumber) || (MagicNumber == 0)) || ((OrderMagicNumber() == 0) && (MagicNumber == -1)) || ((OrderSymbol() == Symbol()) && (MagicNumber == -2))) && ((OrderSymbol() == Symbol()) || (ManageOrders == 0)))
            {
                DigitsPrices = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
                //------------------------------------------------------
                // Set prices
                if (ManageOrders == 0)
                {
                    PriceBuyAsk  = MarketInfo(OrderSymbol(), MODE_ASK);
                    PriceBuyBid  = MarketInfo(OrderSymbol(), MODE_BID);
                    PriceSellAsk = MarketInfo(OrderSymbol(), MODE_ASK);
                    PriceSellBid = MarketInfo(OrderSymbol(), MODE_BID);
                }
                //------------------------------------------------------
                // Delete stoploss and/or take profit
                if ((DeleteTakeProfit == true) || (DeleteStopLoss == true))
                {
                    LocalStopLoss   = 0;
                    LocalTakeProfit = 0;
                    if (DeleteStopLoss == true) LocalStopLoss = -1;
                    if (DeleteTakeProfit == true) LocalTakeProfit = -1;
                    if ((DeleteStopLoss == true) && (OrderStopLoss() != 0)) LocalStopLoss = 0;
                    if ((DeleteStopLoss == false) && (OrderStopLoss() != 0)) LocalStopLoss = OrderStopLoss();
                    if ((DeleteTakeProfit == true) && (OrderTakeProfit() != 0)) LocalTakeProfit = 0;
                    if ((DeleteTakeProfit == false) && (OrderTakeProfit() != 0)) LocalTakeProfit = OrderTakeProfit();
                    //---
                    if ((LocalStopLoss == 0) || (LocalTakeProfit == 0)) WasOrderModified = OrderModify(OrderTicket(), OrderOpenPrice(), LocalStopLoss, LocalTakeProfit, 0, clrNONE);
                    if (WasOrderModified > 0)
                    {
                        Print("Modify ticket: " + DoubleToStr(OrderTicket(), 0));
                        if (SoundAlert == true) PlaySound(SoundModify);
                        continue;
                    }
                }
                //------------------------------------------------------
                // Check stop loss and take profit
                if ((UseBreakEven == false) && (UseTrailingStop == false))
                {
                    if ((PutStopLoss == true) && (OrderStopLoss() != 0) && (PutTakeProfit == true) && (OrderTakeProfit() != 0)) continue;
                    if ((PutStopLoss == true) && (OrderStopLoss() != 0) && (PutTakeProfit == false)) continue;
                    if ((PutStopLoss == false) && (PutTakeProfit == true) && (OrderTakeProfit() != 0)) continue;
                }
                //------------------------------------------------------
                // Modify buy
                if (OrderType() == OP_BUY)
                {
                    LocalStopLoss    = 0;
                    LocalTakeProfit  = 0;
                    WasOrderModified = false;
                    //------------------------------------------------------
                    // Put stoploss and/or take profit
                    if (ManageOrders == 0)
                    {
                        if ((PutStopLoss == true) && (OrderStopLoss() == 0))
                            LocalStopLoss = NormalizeDouble(PriceBuyBid - StopLossPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                        if ((PutTakeProfit == true) && (OrderTakeProfit() == 0))
                            LocalTakeProfit = NormalizeDouble(PriceBuyAsk + TakeProfitPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                        else
                            LocalTakeProfit = OrderTakeProfit();
                    }
                    //---
                    if (ManageOrders == 1)
                    {
                        if ((PutStopLoss == true) && ((OrderStopLoss() == 0) || (OrderStopLoss() != NormalizeDouble(PriceBuyBid - StopLossPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices))))
                            LocalStopLoss = NormalizeDouble(PriceBuyBid - StopLossPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                        if ((PutTakeProfit == true) && ((OrderTakeProfit() == 0) || (OrderTakeProfit() != NormalizeDouble(PriceBuyAsk + TakeProfitPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices))))
                            LocalTakeProfit = NormalizeDouble(PriceBuyAsk + TakeProfitPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                        else
                            LocalTakeProfit = OrderTakeProfit();
                    }
                    //------------------------------------------------------
                    // Trailing stop
                    if (((UseTrailingStop == true) && (LocalStopLoss == 0) && (TrailingStop > 0)) &&
                        ((PutStopLossAfter == 0) || (NormalizeDouble(PriceBuyBid - PutStopLossAfter * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices) >= OrderOpenPrice())) &&
                        (NormalizeDouble(PriceBuyBid - ((TrailingStop + TrailingStep) * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint)), DigitsPrices) > OrderStopLoss()))
                        LocalStopLoss = NormalizeDouble(PriceBuyBid - TrailingStop * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                    //------------------------------------------------------
                    // Break even
                    if ((UseBreakEven == true) && (LocalStopLoss == 0) && (BreakEvenPips > 0) &&
                        (NormalizeDouble(PriceBuyBid - BreakEvenAfter * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices) >= OrderOpenPrice()) &&
                        ((NormalizeDouble(OrderOpenPrice() + BreakEvenPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices) > OrderStopLoss()) || (OrderStopLoss() == 0)))
                        LocalStopLoss = NormalizeDouble(OrderOpenPrice() + BreakEvenPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                    //-----------------------
                    // Modify
                    if (((LocalStopLoss > 0) && (LocalStopLoss != NormalizeDouble(OrderStopLoss(), DigitsPrices)) && (OrderStopLoss() != 0)) || (((LocalStopLoss > 0) && (OrderStopLoss() == 0)) || ((LocalTakeProfit > 0) && (OrderTakeProfit() == 0))))
                        WasOrderModified = OrderModify(OrderTicket(), OrderOpenPrice(), LocalStopLoss, LocalTakeProfit, 0, clrBlue);
                    if (WasOrderModified > 0)
                    {
                        Print("Modify buy ticket: " + DoubleToStr(OrderTicket(), 0));
                        if (SoundAlert == true) PlaySound(SoundModify);
                    }
                }  // End if(OrderType()
                //------------------------------------------------------
                // Modify sell
                if (OrderType() == OP_SELL)
                {
                    LocalStopLoss    = 0;
                    LocalTakeProfit  = 0;
                    WasOrderModified = false;
                    //------------------------------------------------------
                    // Put stoploss and/or take profit
                    if (ManageOrders == 0)
                    {
                        if ((PutStopLoss == true) && (OrderStopLoss() == 0))
                            LocalStopLoss = NormalizeDouble(PriceSellAsk + StopLossPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                        if ((PutTakeProfit == true) && (OrderTakeProfit() == 0))
                            LocalTakeProfit = NormalizeDouble(PriceSellBid - TakeProfitPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                        else
                            LocalTakeProfit = OrderTakeProfit();
                    }
                    //---
                    if (ManageOrders == 1)
                    {
                        if ((PutStopLoss == true) && ((OrderStopLoss() == 0) || (OrderStopLoss() != NormalizeDouble(PriceSellAsk + StopLossPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices))))
                            LocalStopLoss = NormalizeDouble(PriceSellAsk + StopLossPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                        if ((PutTakeProfit == true) && ((OrderTakeProfit() == 0) || (OrderTakeProfit() != NormalizeDouble(PriceSellBid - TakeProfitPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices))))
                            LocalTakeProfit = NormalizeDouble(PriceSellBid - TakeProfitPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                        else
                            LocalTakeProfit = OrderTakeProfit();
                    }
                    //------------------------------------------------------
                    // Trailing stop
                    if (((UseTrailingStop == true) && (LocalStopLoss == 0) && (TrailingStop > 0)) &&
                        ((PutStopLossAfter == 0) || (NormalizeDouble(PriceSellAsk + PutStopLossAfter * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices) <= OrderOpenPrice())) &&
                        (NormalizeDouble(PriceSellAsk + ((TrailingStop + TrailingStep) * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint)), DigitsPrices) < OrderStopLoss()))
                        LocalStopLoss = NormalizeDouble(PriceSellAsk + TrailingStop * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                    //------------------------------------------------------
                    // Break even
                    if ((UseBreakEven == true) && (LocalStopLoss == 0) && (BreakEvenPips > 0) &&
                        (NormalizeDouble(PriceSellAsk + BreakEvenAfter * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices) <= OrderOpenPrice()) &&
                        ((NormalizeDouble(OrderOpenPrice() - BreakEvenPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices) < OrderStopLoss()) || (OrderStopLoss() == 0)))
                        LocalStopLoss = NormalizeDouble(OrderOpenPrice() - BreakEvenPips * (MarketInfo(OrderSymbol(), MODE_POINT) * MultiplierPoint), DigitsPrices);
                    //-----------------------
                    // Modify
                    if (((LocalStopLoss > 0) && (LocalStopLoss != NormalizeDouble(OrderStopLoss(), DigitsPrices)) && (OrderStopLoss() != 0)) || (((LocalStopLoss > 0) && (OrderStopLoss() == 0)) || ((LocalTakeProfit > 0) && (OrderTakeProfit() == 0))))
                        WasOrderModified = OrderModify(OrderTicket(), OrderOpenPrice(), LocalStopLoss, LocalTakeProfit, 0, clrRed);
                    if (WasOrderModified > 0)
                    {
                        Print("Modify sell ticket: " + DoubleToStr(OrderTicket(), 0));
                        if (SoundAlert == true) PlaySound(SoundModify);
                    }
                }  // End if(OrderType()
                //------------------------------------------------------
                // Closed Market
                if (GetLastError() == 132)
                {
                    MarketClosedCom = true;
                    break;
                }
                //------------------------------------------------------
            }  // End if((OrderMagicNumber()...
        }      // End OrderSelect(...
    }          // End for(...
    //------------------------------------------------------
    // Closed market
    if (MarketClosedCom == true)
    {
        MarketClosedCom = true;
        Print(WindowExpertName() + ": Could not run, market is closed!!!");
        // Comment("==================",
        //         "\n   ", WindowExpertName(),
        //         "\n==================",
        //         "\n\n\n      Market is closed!!! ",
        //         "\n\n      Not modify orders. ",
        //         "\n\n\n\n\n==================");
        Sleep(60000);
    }
    //------------------------------------------------------
}
//======================Ende  TSL MAIN FUNKTION==============================================================================================================================//
//========================TSL Anfang============================================================================================================================//
void CountOrders()
{
    SumOrders        = 0;
    BuyOrders        = 0;
    SellOrders       = 0;
    AveragePriceBuy  = 0;
    AveragePriceSell = 0;
    //---
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (((OrderMagicNumber() == MagicNumber) || (MagicNumber == 0)) || ((OrderMagicNumber() == 0) && (MagicNumber == -1)))
            {
                if (OrderSymbol() == Symbol())
                {
                    //---Count buy
                    if (OrderType() == OP_BUY)
                    {
                        BuyOrders++;
                        AveragePriceBuy += OrderOpenPrice();
                    }
                    //---Count sell
                    if (OrderType() == OP_SELL)
                    {
                        SellOrders++;
                        AveragePriceSell += OrderOpenPrice();
                    }
                    //---Count all
                    SumOrders++;
                }
            }
        }
    }
    //---Set average prices
    if (BuyOrders > 0) AveragePriceBuy /= BuyOrders;
    if (SellOrders > 0) AveragePriceSell /= SellOrders;
    //---
}
//===========================TSL ENDE=========================================================================================================================//

//===========================TSL Anfang=========================================================================================================================//

void ChartBackground(string StringName, color ImageColor, int Xposition, int Yposition, int Xsize, int Ysize)
{
    if (ObjectFind(0, StringName) == -1)
    {
        ObjectCreate(0, StringName, OBJ_RECTANGLE_LABEL, 0, 0, 0, 0, 0);
        ObjectSetInteger(0, StringName, OBJPROP_XDISTANCE, Xposition);
        ObjectSetInteger(0, StringName, OBJPROP_YDISTANCE, Yposition);
        ObjectSetInteger(0, StringName, OBJPROP_XSIZE, Xsize);
        ObjectSetInteger(0, StringName, OBJPROP_YSIZE, Ysize);
        ObjectSetInteger(0, StringName, OBJPROP_BGCOLOR, ImageColor);
        ObjectSetInteger(0, StringName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, StringName, OBJPROP_BORDER_COLOR, clrBlack);
        ObjectSetInteger(0, StringName, OBJPROP_BACK, false);
        ObjectSetInteger(0, StringName, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, StringName, OBJPROP_SELECTED, false);
        ObjectSetInteger(0, StringName, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, StringName, OBJPROP_ZORDER, 0);
    }
}
//=============================TSL ENDE=======================================================================================================================//

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int     id,
                  const long&   lparam,
                  const double& dparam,
                  const string& sparam)
{
    //---
}
//+------------------------------------------------------------------+
// function to send order
bool SendOrder(int type, double _sl)
{
    while (IsTradeContextBusy())
        ;
    int    ticket = -1;
    double SL, TP;
    if (type == OP_BUY)
    {
        if (_sl == 0)
        {
            SL = 0;
        } else
        {
            SL = Ask - 1.2 * _sl * _point;
        }
        if (_sl == 0)
        {
            TP = 0;
        } else
        {
            TP = Ask + 3 * _sl * _point;
        }
        ticket = OrderSend(Symbol(), OP_BUY, NormalizeLots(lots, Symbol()), Ask, 3, SL, TP, EA_Comment, MagicNumber, 0);
    }
    if (type == OP_SELL)
    {
        if (_sl == 0)
        {
            SL = 0;
        } else
        {
            SL = Bid + 1.2 * _sl * _point;
        }
        if (_sl == 0)
        {
            TP = 0;
        } else
        {
            TP = Bid - 3 * _sl * _point;
        }
        ticket = OrderSend(Symbol(), OP_SELL, NormalizeLots(lots, Symbol()), Bid, 3, SL, TP, EA_Comment, MagicNumber, 0);
    }
    if (ticket < 0)
    {
        Print("OrderSend  failed with error #", GetLastError());
        return (false);
    }
    return (true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// make lots to right format
double NormalizeLots(double _lots, string pair = "")
{
    if (pair == "") pair = Symbol();
    double lotStep = MarketInfo(pair, MODE_LOTSTEP),
           minLot  = MarketInfo(pair, MODE_MINLOT);
    _lots          = MathRound(_lots / lotStep) * lotStep;
    if (_lots < MarketInfo(pair, MODE_MINLOT)) _lots = MarketInfo(pair, MODE_MINLOT);
    if (_lots > MarketInfo(pair, MODE_MAXLOT)) _lots = MarketInfo(pair, MODE_MAXLOT);
    return (_lots);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// get res level from the chart
double get_res()
{
    double _res   = 999999999999;
    double _tmp   = 0;
    long   _chart = ChartID();
    // for(int i=0;i<ObjectsTotal(_chart);i++)
    //   {
    //    string _name=ObjectName(_chart,i);
    //    if(StringFind(_name,"R#R",0)>0 && StringFind(_name,"Untested",0)>0) _tmp=ObjectGetDouble(_chart,_name,OBJPROP_PRICE2);
    //    if(_res>_tmp && _tmp!=0) _res=_tmp;
    //   }
    _res = Hi_p2;
    return (_res);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_res_sl()
{
    double _res   = 999999999999;
    double _tmp   = 0;
    long   _chart = ChartID();
    // for(int i=0;i<ObjectsTotal(_chart);i++)
    //   {
    //    string _name=ObjectName(_chart,i);
    //    if(StringFind(_name,"R#R",0)>0 && StringFind(_name,"Untested",0)>0) _tmp=ObjectGetDouble(_chart,_name,OBJPROP_PRICE1);
    //    if(_res>_tmp && _tmp!=0) _res=_tmp;
    //   }
    _res = Hi_p1;
    return (_res);
}
//+------------------------------------------------------------------+                                Hier Kommentar wieder löschen

int OrdersTotalT(int _type)
{
    int _total = 0;
    for (int cnt = OrdersTotal() - 3; cnt >= 0; cnt--)
    {
        bool select = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderType() == _type)
        {
            _total++;
        }
    }
    return (_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double get_sup()
{
    double _res   = 0;
    double _tmp   = 0;
    long   _chart = ChartID();
    // for(int i=0;i<ObjectsTotal(_chart);i++)
    //   {
    //    string _name=ObjectName(_chart,i);
    //    if(StringFind(_name,"R#S",0)>0 && StringFind(_name,"Untested",0)>0){ _tmp=ObjectGetDouble(_chart,_name,OBJPROP_PRICE1);}
    //    if(_res<_tmp && _tmp!=0) _res=_tmp;
    //   }
    _res = Lo_p1;
    return (_res);  // return lower untested support
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_sup_sl()
{
    double _res   = 0;
    double _tmp   = 0;
    long   _chart = ChartID();
    //   for(int i=0;i<ObjectsTotal(_chart);i++)
    //     {
    //      string _name=ObjectName(_chart,i);
    //      if(StringFind(_name,"R#S",0)>0 && StringFind(_name,"Untested",0)>0) _tmp=ObjectGetDouble(_chart,_name,OBJPROP_PRICE2);
    //
    //      if(_res<_tmp && _tmp!=0) _res=_tmp;
    //     }
    _res = Lo_p2;
    return (_res);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double indi(int tip, int pos = 0)
{
    return (iCustom(NULL, 0, "shved_supply_and_demand-GOLD", BackLimit, pus1, zone_show_weak, zone_show_untested, zone_show_turncoat, zone_fuzzfactor, pus2, fractals_show, fractal_fast_factor, fractal_slow_factor, SetGlobals, pus3, tip, pos));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_indi()
{
    Hi_p1 = indi(4);
    Hi_p2 = indi(5);
    Lo_p1 = indi(6);
    Lo_p2 = indi(7);
    if ((Hi_p1 == Lo_p1) || (Hi_p2 == Lo_p2))
    {
        Hi_p1 = 0;
        Lo_p1 = 0;
        Hi_p2 = 0;
        Lo_p2 = 0;
    }
    // string txt="Get indi:"+
    //            "\nHi_p1 = "+DoubleToStr(Hi_p1,Digits)+
    //            "\nHi_p2 = "+DoubleToStr(Hi_p2,Digits)+
    //            "\nLo_p1 = "+DoubleToStr(Lo_p1,Digits)+
    //            "\nLo_p2 = "+DoubleToStr(Lo_p2,Digits);
    // Comment(txt);
}


//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76430
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/