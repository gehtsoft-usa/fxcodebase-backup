//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73576

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
#property strict
//---
enum ltype { RiskMM,
             Fixed_lot };
sinput string            EA_1           = "============ EA options ============";             //============ EA settings ============
input bool               manual_mode    = true;                                               // Manual mode
input ltype              Typem          = Fixed_lot;                                          // Risk management Mode
input double             vol            = 0.02;                                               // Start lot / start percent
input double             x_lotadd       = 0.01;                                               // Add lot
int                      magic          = 888;                                                // Magic number
input bool               one_trade_per  = false;                                              // One trade per acc by magic
input int                sl             = 4000;                                               // Stop Loss (points)
input int                tp             = 4000;                                               // Take Profit (points)
input int                bars_average   = 24;                                                 // X bars before (minimum average distance)
input ENUM_TIMEFRAMES    bars_tf        = PERIOD_H1;                                          // X bars before TF

input int BuyStopDistance = 1000; // Buy Stop Distance:
input int BuyLimitDistance = 1000; // Buy limit Distance:
input int SellStopDistance = 1000; // Sell Stop Distance:
input int SellLimitDistance = 1000; // Sell limit Distance:
input bool deletePendingsWhenCloseAll = true; // Delete Pendings When Close All:

sinput string            EA_2           = "============ Trailing ============";               //============ Trailing ============
input int                trail_start    = 20;                                                 // Trail start (0 - not use trail)
extern int               trail_step     = 200;                                                // Trail step
input string             EA_3           = "============ Close part from grid  ============";  //============ Close part from grid  ============
input int                when_start     = 0;                                                  // Start close part when we have X orders (0 - not use)
input int                ammount_orders = 2;                                                  // Ammount of orders for close
input int                minimum_summ   = 10;                                                 // Minimum sum for close
input string             EA_4           = "============ MACD SETTINGS  ============";         //============ MACD SETTINGS  ============
input int                Fema           = 30;                                                 // Fast EMA Period Long Term
input int                Sema           = 60;                                                 // Slow EMA Period Long Term
input int                signalMA       = 30;                                                 // Signal EMA Period Long Term
input ENUM_APPLIED_PRICE macd_price     = PRICE_CLOSE;                                        // EMA price Long Term
input int                Femas          = 12;                                                 // Fast EMA Period Short term
input int                Semas          = 26;                                                 // Slow EMA Period Short term
input int                signalMAs      = 5;                                                  // Signal EMA Period Short term
input ENUM_APPLIED_PRICE macd_prices    = PRICE_CLOSE;                                        // EMA price Short term
input string             EA_5           = "============ MA SETTINGS  ============";           //============ MA SETTINGS  ============
input int                ma_period      = 60;                                                 // Period MA
input int                ma_shift       = 0;                                                  // Shift MA
input ENUM_MA_METHOD     ma_method      = MODE_SMA;                                           // Method MA
input ENUM_APPLIED_PRICE applied_price  = PRICE_CLOSE;                                        // Applied price MA
int                      bars_before    = 10;                                                 // Bars before for slope//---
input string             EA_6           = "============ Trade time  ============";            //============ Trade time  ============
input int                hb             = 0;                                                  // Hour start
int                      mb             = 0;                                                  // Minute start
input int                he             = 23;                                                 // Hour End
int                      me             = 59;                                                 // Minute End
//---
//---
int      dos, buy_m, sell_m;
datetime tim;
double   down_price_buy;
double   up_price_sell;
string   GL_NAME, GL_NAME_LOT;
int      tt;
double   dd;
//+-------------------------------------------------------------------+
//|MA                                                                 |
//+-------------------------------------------------------------------+
int ma()
{
    bool slope_down = true;
    bool slope_up   = true;
    for (int i = 1; i < bars_before + 1; i++)
    {
        double ma  = iMA(Symbol(), PERIOD_CURRENT, ma_period, ma_shift, ma_method, applied_price, i);
        double map = iMA(Symbol(), PERIOD_CURRENT, ma_period, ma_shift, ma_method, applied_price, i + 1);
        if (ma > map) slope_down = false;
        if (ma < map) slope_up = false;
    }

    if (slope_down) return 1;
    if (slope_up) return 0;
    return -1;
}
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
// NOTE: Oninit
int OnInit()
{
    //---
    GL_NAME     = Symbol() + IntegerToString(magic) + "Tax" + IntegerToString(IsTesting());
    GL_NAME_LOT = Symbol() + IntegerToString(magic) + "LOTsax" + IntegerToString(IsTesting());
    dos         = 2;
    if (MarketInfo(Symbol(), MODE_MINLOT) == 0.1) dos = 1;
    if (MarketInfo(Symbol(), MODE_MINLOT) == 1) dos = 0;
    creat_data("0", 20, 30, " ");
    creat_data("1", 20, 50, " ");
    creat_data("2", 20, 70, " ");
    creat_data("3", 20, 90, " ");
    creat_data("4", 20, 110, " ");
    creat_data("5", 20, 130, " ");
    if (sl == 0 || tp == 0)
        Alert("SL or TP can not be 0! Just increase to 5000 if you do not want to use SL or TP");

    // if (sl > 50000 || tp > 50000)
    // {
    //     Alert("SL or TP can not be so high!");
    //     return -1;
    // }
    dd = 0;

    if (manual_mode)
    {
        //---
        ObjectCreate(0, "Buttonxb", OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, "Buttonxb", OBJPROP_XDISTANCE, 90);
        ObjectSetInteger(0, "Buttonxb", OBJPROP_YDISTANCE, 155);
        ObjectSetInteger(0, "Buttonxb", OBJPROP_XSIZE, 80);
        ObjectSetInteger(0, "Buttonxb", OBJPROP_YSIZE, 20);
        ObjectSetInteger(0, "Buttonxb", OBJPROP_CORNER, 1);
        ObjectSetString(0, "Buttonxb", OBJPROP_TEXT, "Open buy");
        ObjectSetInteger(0, "Buttonxb", OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, "Buttonxb", OBJPROP_BGCOLOR, clrTeal);
        ObjectSetInteger(0, "Buttonxb", OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, "Buttonxb", OBJPROP_STATE, false);
        ObjectSetInteger(0, "Buttonxb", OBJPROP_FONTSIZE, 9);

        //---
        ObjectCreate(0, "Buttons", OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, "Buttons", OBJPROP_XDISTANCE, 180);
        ObjectSetInteger(0, "Buttons", OBJPROP_YDISTANCE, 155);
        ObjectSetInteger(0, "Buttons", OBJPROP_XSIZE, 80);
        ObjectSetInteger(0, "Buttons", OBJPROP_YSIZE, 20);
        ObjectSetInteger(0, "Buttons", OBJPROP_CORNER, 1);
        ObjectSetString(0, "Buttons", OBJPROP_TEXT, "Open sell");
        ObjectSetInteger(0, "Buttons", OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, "Buttons", OBJPROP_BGCOLOR, clrMaroon);
        ObjectSetInteger(0, "Buttons", OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, "Buttons", OBJPROP_STATE, false);
        ObjectSetInteger(0, "Buttons", OBJPROP_FONTSIZE, 9);

        ObjectCreate(0, "Button_close_all", OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, "Button_close_all", OBJPROP_XDISTANCE, 90);
        ObjectSetInteger(0, "Button_close_all", OBJPROP_YDISTANCE, 185);
        ObjectSetInteger(0, "Button_close_all", OBJPROP_XSIZE, 80);
        ObjectSetInteger(0, "Button_close_all", OBJPROP_YSIZE, 20);
        ObjectSetInteger(0, "Button_close_all", OBJPROP_CORNER, 1);
        ObjectSetString(0, "Button_close_all", OBJPROP_TEXT, "Close all");
        ObjectSetInteger(0, "Button_close_all", OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, "Button_close_all", OBJPROP_BGCOLOR, clrBlack);
        ObjectSetInteger(0, "Button_close_all", OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, "Button_close_all", OBJPROP_STATE, false);
        ObjectSetInteger(0, "Button_close_all", OBJPROP_FONTSIZE, 9);

        //---
        ObjectCreate(0, "Button_close_pair", OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_XDISTANCE, 180);
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_YDISTANCE, 185);
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_XSIZE, 80);
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_YSIZE, 20);
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_CORNER, 1);
        ObjectSetString(0, "Button_close_pair", OBJPROP_TEXT, "Close this");
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_BGCOLOR, clrBlack);
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_STATE, false);
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_FONTSIZE, 9);

				//--- 
				ObjectCreate(0, "ButtonBuyStop", OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_XDISTANCE, 90);
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_YDISTANCE, 215);
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_XSIZE, 80);
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_YSIZE, 20);
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_CORNER, 1);
        ObjectSetString(0, "ButtonBuyStop", OBJPROP_TEXT, "Buy Stop");
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_BGCOLOR, clrTeal);
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_STATE, false);
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_FONTSIZE, 9);

				ObjectCreate(0, "ButtonSellStop", OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_XDISTANCE, 180);
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_YDISTANCE, 215);
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_XSIZE, 80);
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_YSIZE, 20);
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_CORNER, 1);
        ObjectSetString(0, "ButtonSellStop", OBJPROP_TEXT, "Sell Stop");
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_BGCOLOR, clrMaroon);
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_STATE, false);
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_FONTSIZE, 9);
				
				ObjectCreate(0, "ButtonBuyLimit", OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_XDISTANCE, 90);
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_YDISTANCE, 245);
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_XSIZE, 80);
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_YSIZE, 20);
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_CORNER, 1);
        ObjectSetString(0, "ButtonBuyLimit", OBJPROP_TEXT, "Buy Limit");
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_BGCOLOR, clrTeal);
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_STATE, false);
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_FONTSIZE, 9);

				ObjectCreate(0, "ButtonSellLimit", OBJ_BUTTON, 0, 0, 0);
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_XDISTANCE, 180);
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_YDISTANCE, 245);
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_XSIZE, 80);
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_YSIZE, 20);
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_CORNER, 1);
        ObjectSetString(0, "ButtonSellLimit", OBJPROP_TEXT, "Sell Limit");
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_BGCOLOR, clrMaroon);
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_STATE, false);
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_FONTSIZE, 9);
    }

    for (int i = 0; i < 100; i++)
    {
        if (EventSetMillisecondTimer(500)) break;
        Sleep(500);
    }
    OnTick();

    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //---
    ObjectDelete("datf_0");
    ObjectDelete("datf_1");
    ObjectDelete("datf_5");
    ObjectDelete("datf_2");
    ObjectDelete("datf_3");
    ObjectDelete("datf_4");
    Print("MAX DD ", dd);
    ObjectDelete(0, "Buttonxb");
    ObjectDelete(0, "Button_close_all");
    ObjectDelete(0, "Buttons");
    ObjectDelete(0, "Button_close_pair");
    ObjectDelete(0, "ButtonBuyStop");
    ObjectDelete(0, "ButtonSellStop");
    ObjectDelete(0, "ButtonBuyLimit");
    ObjectDelete(0, "ButtonSellLimit");
    EventKillTimer();
}
//+-------------------------------------------------------------------+
//| pofit                                                             |
//+-------------------------------------------------------------------+
double pofit()
{
    double profit = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            {
                profit += OrderProfit() + OrderSwap() + OrderCommission();
            }
        }
    }
    return (profit);
}
//+-------------------------------------------------------------------+
//|data indi                                                          |
//+-------------------------------------------------------------------+
int macd_trend()
{
    double macd_main = iMACD(NULL, PERIOD_CURRENT, Fema, Sema, signalMA, macd_price, MODE_MAIN, 1);
    if (macd_main > 0) return 0;
    if (macd_main < 0) return 1;
    return -1;
}
//+-------------------------------------------------------------------+
//|data indi                                                          |
//+-------------------------------------------------------------------+
int macd_signal()
{
    double macd_main_1 = iMACD(NULL, PERIOD_CURRENT, Femas, Semas, signalMAs, macd_prices, MODE_MAIN, 1);
    double macd_main_2 = iMACD(NULL, PERIOD_CURRENT, Femas, Semas, signalMAs, macd_prices, MODE_MAIN, 2);
    double macd_main_3 = iMACD(NULL, PERIOD_CURRENT, Femas, Semas, signalMAs, macd_prices, MODE_MAIN, 3);
    double macd_main_4 = iMACD(NULL, PERIOD_CURRENT, Femas, Semas, signalMAs, macd_prices, MODE_MAIN, 4);
    double macd_main_5 = iMACD(NULL, PERIOD_CURRENT, Femas, Semas, signalMAs, macd_prices, MODE_MAIN, 5);

    if (macd_main_1 > 0 && macd_main_2 > 0 && macd_main_3 > 0 && macd_main_4 > 0 && macd_main_5 <= 0) return 0;
    if (macd_main_1 < 0 && macd_main_2 < 0 && macd_main_3 < 0 && macd_main_4 < 0 && macd_main_5 >= 0) return 0;
    return -1;
}

// NOTE: OnTimer
void OnTimer()
{
    //---
    if (ObjectGet("Buttonxb", OBJPROP_STATE) == 1)
    {
        double lots = NormalizeDouble(vol, dos);
        if (Typem != Fixed_lot) lots = NormalizeDouble(vol / 100000 * AccountEquity(), dos);
        GlobalVariableSet(GL_NAME_LOT, lots);

        open_buy(lots);
        Print("Manualy buy");
        ObjectSetInteger(0, "Buttonxb", OBJPROP_STATE, false);
    }
    //---
    if (ObjectGet("Buttons", OBJPROP_STATE) == 1)
    {
        double lots = NormalizeDouble(vol, dos);
        if (Typem != Fixed_lot) lots = NormalizeDouble(vol / 100000 * AccountEquity(), dos);
        GlobalVariableSet(GL_NAME_LOT, lots);

        open_sell(lots);
        Print("Manualy sell");
        ObjectSetInteger(0, "Buttons", OBJPROP_STATE, false);
    }

		// NOTE: New Buttons Actions
	 	// ------------------------------------------------------------------
	 if (ObjectGet("ButtonBuyStop", OBJPROP_STATE) == 1)
	 {
				double lots = NormalizeDouble(vol, dos);
        if (Typem != Fixed_lot) lots = NormalizeDouble(vol / 100000 * AccountEquity(), dos);
        GlobalVariableSet(GL_NAME_LOT, lots);

        open_buy_stop(lots);

        Print("Manualy Buy Stop");
        ObjectSetInteger(0, "ButtonBuyStop", OBJPROP_STATE, false);
	 }
	 if (ObjectGet("ButtonSellStop", OBJPROP_STATE) == 1)
	 {
				double lots = NormalizeDouble(vol, dos);
        if (Typem != Fixed_lot) lots = NormalizeDouble(vol / 100000 * AccountEquity(), dos);
        GlobalVariableSet(GL_NAME_LOT, lots);
        
				open_sell_stop(lots);

        Print("Manualy Sell Stop");
        ObjectSetInteger(0, "ButtonSellStop", OBJPROP_STATE, false);
	 }
	 
	 if (ObjectGet("ButtonBuyLimit", OBJPROP_STATE) == 1)
	 {
				double lots = NormalizeDouble(vol, dos);
        if (Typem != Fixed_lot) lots = NormalizeDouble(vol / 100000 * AccountEquity(), dos);
        GlobalVariableSet(GL_NAME_LOT, lots);

        open_buy_limit(lots);

        Print("Manualy Buy Limit");
        ObjectSetInteger(0, "ButtonBuyLimit", OBJPROP_STATE, false);
	 }
	 if (ObjectGet("ButtonSellLimit", OBJPROP_STATE) == 1)
	 {
				double lots = NormalizeDouble(vol, dos);
        if (Typem != Fixed_lot) lots = NormalizeDouble(vol / 100000 * AccountEquity(), dos);
        GlobalVariableSet(GL_NAME_LOT, lots);

        open_sell_limit(lots);

        Print("Manualy Sell Limit");
        ObjectSetInteger(0, "ButtonSellLimit", OBJPROP_STATE, false);
	 }
	 
	 
	 
	 
	 // ------------------------------------------------------------------



    //---
    if (ObjectGet("Button_close_pair", OBJPROP_STATE) == 1)
    {
        close_all(true);
        Print("Close this pair");
        ObjectSetInteger(0, "Button_close_pair", OBJPROP_STATE, false);
    }

    if (ObjectGet("Button_close_all", OBJPROP_STATE) == 1)
    {
        close_all(false);
        Print("Close all ");
        ObjectSetInteger(0, "Button_close_all", OBJPROP_STATE, false);
    }
}
//+------------------------------------------------------------------+
//|        Close order                                               |
//+------------------------------------------------------------------+
void close_all(bool this_)
{
    int ORDT = OrdersTotal();
    if (ORDT == 0) return;
    for (int i = ORDT - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (!this_ || OrderSymbol() == Symbol())
            {
                if (MarketInfo(OrderSymbol(), MODE_BID) == 0)
                {
                    RefreshRates();
                    Sleep(2000);
                    close_all(this_);
                }
                if (OrderType() == 0) bool cls = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 100);
                if (OrderType() == 1) bool cls = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 100);
                
								if(deletePendingsWhenCloseAll){
									if (OrderType() == 2 || OrderType() == 3 || OrderType() == 4 || OrderType() == 5) 
									bool cls = OrderDelete(OrderTicket(), clrNONE);
								}
            }
        }
    }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if (IsTesting()) OnTimer();
    if (IsConnected() != true)
    {
        ObjectSetText("datf_0", "Terminal not connected!", 10, "Verdana", clrRed);
        return;
    }
    if (IsTradeAllowed() != true)
    {
        ObjectSetText("datf_0", "Expert trade not allowed (check mt4 settings)!", 10, "Verdana", clrRed);
        return;
    }
    if (IsExpertEnabled() == false && IsTesting() == false)
    {
        ObjectSetText("datf_0", "Expert trade not enabled! (check mt4 settings)", 10, "Verdana", clrRed);
        return;
    }
    if (IsTradeContextBusy())
    {
        ObjectSetText("datf_0", "Trade Context is Busy!", 10, "Verdana", clrRed);
        return;
    }
    if (tim > TimeCurrent())
    {
        ObjectSetText("datf_0", "Waiting 15 seconds. CHECK LOGS!", 10, "Verdana", clrRed);
        return;
    }
    ObjectSetText("datf_0", "Working...", 10, "Verdana", clrChartreuse);
    //---
    count();

    if (buy_m == 0 && sell_m == 0 && order_allow_open() == 0)
    {
        if (time_ch())
        {
            if (one_trade_per && count_magic() > 0)
            {
                ObjectSetText("datf_1", "OPENED ON ", 10, "Verdana", clrGold);
                ObjectSetText("datf_2", "     OTHER", 10, "Verdana", clrGold);
                ObjectSetText("datf_3", "             PAIR", 10, "Verdana", clrGold);
                return;
            }

            double lots = NormalizeDouble(vol, dos);
            if (Typem != Fixed_lot) lots = NormalizeDouble(vol / 100000 * AccountEquity(), dos);
            GlobalVariableSet(GL_NAME_LOT, lots);
            if (!manual_mode)
            {
                int MA_SLOPE = ma();
                if (MA_SLOPE == 0) ObjectSetText("datf_1", "MA for BUY only", 10, "Verdana", clrChartreuse);
                if (MA_SLOPE == 1) ObjectSetText("datf_1", "MA for SELL only", 10, "Verdana", clrRed);
                if (MA_SLOPE == -1) ObjectSetText("datf_1", "MA - no slope", 10, "Verdana", clrGold);
                //---
                int MACD_TREND = macd_trend();
                if (MACD_TREND == 0) ObjectSetText("datf_2", "MACD trend for BUY ", 10, "Verdana", clrChartreuse);
                if (MACD_TREND == 1) ObjectSetText("datf_2", "MACD trend for SELL ", 10, "Verdana", clrRed);
                if (MACD_TREND == -1) ObjectSetText("datf_2", "MACD trend - no trend", 10, "Verdana", clrGold);
                ObjectSetText("datf_3", "Waiting MACD signal", 10, "Verdana", clrGold);
                if (MA_SLOPE == 0 && MACD_TREND == 0 && macd_signal() == 0)
                {
                    SendNotification("BUY opened by signal " + Symbol());
                    open_buy(lots);
                }
                if (MA_SLOPE == 1 && MACD_TREND == 1 && macd_signal() == 1)
                {
                    SendNotification("SELL opened by signal " + Symbol());
                    open_sell(lots);
                }
            } else
            {
                ObjectSetText("datf_3", " ", 10, "Verdana", clrBlack);
                ObjectSetText("datf_1", "MANUAL MODE", 10, "Verdana", clrBlack);
                ObjectSetText("datf_2", " ", 10, "Verdana", clrBlack);
            }

            GlobalVariableSet(GL_NAME, TimeCurrent() + 15 * 60);  // next check
            GlobalVariableSet(GL_NAME + "TF", 15);

        } else
        {
            ObjectSetText("datf_1", "NOT", 10, "Verdana", clrGold);
            ObjectSetText("datf_2", "     TRADE", 10, "Verdana", clrGold);
            ObjectSetText("datf_3", "             TIME", 10, "Verdana", clrGold);
        }
    } else
        ObjectSetText("datf_3", "Equity: " + DoubleToString(AccountEquity(), 1) + " " + AccountCurrency(), 10, "Verdana", clrChartreuse);

    double cur_p = pofit();
    if (dd > cur_p) dd = cur_p;

    ObjectSetText("datf_4", "Max DD: " + DoubleToString(dd, 1) + " " + AccountCurrency(), 10, "Verdana", clrChartreuse);
    ObjectSetText("datf_5", "Profit current: " + DoubleToString(cur_p, 1) + " " + AccountCurrency(), 10, "Verdana", cur_p >= 0 ? clrChartreuse : clrRed);

    if (buy_m + sell_m > 0)
    {
        double TIME_WHE_NEED = GlobalVariableGet(GL_NAME);
        if (TIME_WHE_NEED <= TimeCurrent())
        {
            double all_dist = 0;
            double HIG      = iHigh(Symbol(), bars_tf, bars_average);
            for (int i = 1; i < bars_average + 1; i++)
            {
                HIG          = iHigh(Symbol(), bars_tf, i);
                double LOW   = iLow(Symbol(), bars_tf, i);
                double dists = (HIG - LOW) / Point;
                all_dist += dists;
            }
            all_dist = all_dist / bars_average;
            if (HIG == 0)
            {
                ObjectSetText("datf_2", "(!) Need history (!)", 10, "Verdana", clrChartreuse);
                ObjectSetText("datf_1", "(!) ----------- (!)", 10, "Verdana", clrChartreuse);
                ObjectSetText("datf_0", "(!) ----------- (!)", 10, "Verdana", clrChartreuse);
                Print("Need history.......................");
                return;
            }

            ObjectSetText("datf_2", "Average dist. need: " + DoubleToString(all_dist, 0), 10, "Verdana", clrChartreuse);

            // check for put new order
            // SELL DIRECTION----------------------------------------------------------
            if (buy_m > 0)
            {
                // ObjectSetText("datf_3","Current dist.: "+DoubleToString(down_price_buy-all_dist*Point(),0),10,"Verdana",clrChartreuse);
                double which_tf = GlobalVariableGet(GL_NAME + "TF");
                if (down_price_buy - all_dist * Point() >= Ask)
                {
                    open_buy(LOT_X());
                    write_next_time(which_tf);
                } else
                {
                    GlobalVariableSet(GL_NAME, TimeCurrent() + which_tf * 60);  // next check
                    GlobalVariableSet(GL_NAME + "TF", which_tf);
                    Print("DISTANCE TO LITTEL, will check again at: " + TimeToString(TimeCurrent() + (int)which_tf * 60));
                    ObjectSetText("datf_1", "Next check time: " + TimeToString(TimeCurrent() + (int)which_tf * 60, TIME_MINUTES), 10, "Verdana", clrChartreuse);
                }
            }

            // SELL DIRECTION----------------------------------------------------------
            if (sell_m > 0)
            {
                // ObjectSetText("datf_3","Current dist.: "+DoubleToString(up_price_sell+all_dist*Point(),0),10,"Verdana",clrChartreuse);
                double which_tf = GlobalVariableGet(GL_NAME + "TF");
                if (up_price_sell + all_dist * Point() <= Bid)
                {
                    open_sell(LOT_X());
                    write_next_time(which_tf);
                } else
                {
                    GlobalVariableSet(GL_NAME, TimeCurrent() + which_tf * 60);  // next check
                    GlobalVariableSet(GL_NAME + "TF", which_tf);
                    Print("DISTANCE TO LITTEL, will check again at: " + TimeToString(TimeCurrent() + (int)which_tf * 60));
                    ObjectSetText("datf_1", "Next check time: " + TimeToString(TimeCurrent() + (int)which_tf * 60, TIME_MINUTES), 10, "Verdana", clrChartreuse);
                }
            }
        }
    }
    //---
    if (trail_start > 0)
        trailing_function();

    if (buy_m + sell_m >= when_start && when_start > 0)
    {
        // need firsts
        int part_from_end   = (int)(ammount_orders / 2);
        int part_from_start = (int)(ammount_orders / 2);
        if (((ammount_orders) % 2) != 0) part_from_end = part_from_end + 1;

        if (profit_from_start(part_from_start) + profit_from_end(part_from_end) >= minimum_summ)
        {
            close_from_start(part_from_start);
            close_from_end(part_from_end);

            Print("-----------");
            sl_all_s(100);
            sl_all_b(100);
        }
    }

    //---
}
//+-------------------------------------------------------------------+
//|Function return flag - allowed time trade or not for first session |
//+-------------------------------------------------------------------+
bool time_ch()
{
    datetime time_our = TimeCurrent();
    datetime db, de;
    int      hc;
    db = StrToTime(TimeToStr(time_our, TIME_DATE) + " " + string(hb) + ":" + string(mb));
    de = StrToTime(TimeToStr(time_our, TIME_DATE) + " " + string(he) + ":" + string(me));
    hc = TimeHour(time_our);
    if (db >= de)
    {
        if (hc >= he)
            de += 24 * 60 * 60;
        else
            db -= 24 * 60 * 60;
    }
    if (time_our >= db && time_our <= de)
        return (True);
    else
        return (False);
}
//+------------------------------------------------------------------+
//|        Close order                                               |
//+------------------------------------------------------------------+
void close_from_end(int ammount)
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            {
                if (ammount <= 0) break;
                bool cls = OrderClose(OrderTicket(), OrderLots(), OrderType() == 0 ? Bid : Ask, 100);
                Print("CLOSED BY PART CLOSE FUNCTION (e)");
                ammount--;
            }
        }
    }
}
//+------------------------------------------------------------------+
//|        Close order                                               |
//+------------------------------------------------------------------+
void close_from_start(int ammount)
{
    int cnt = OrdersTotal();
    for (int i = 0; i < cnt; i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            {
                if (ammount <= 0) break;
                bool cls = OrderClose(OrderTicket(), OrderLots(), OrderType() == 0 ? Bid : Ask, 100);
                Print("CLOSED BY PART CLOSE FUNCTION (s)");
                i--;
                ammount--;
            }
        }
    }
}
//+-------------------------------------------------------------------+
//|GeneralProfitAllOrders                                             |
//+-------------------------------------------------------------------+
double profit_from_end(int X)
{
    int    I   = 0;
    double pro = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            {
                if (I >= X) break;
                pro += OrderProfit() + OrderSwap() + OrderCommission();
                I++;
            }
        }
    }
    return (pro);
}
//+-------------------------------------------------------------------+
//|GeneralProfitAllOrders                                             |
//+-------------------------------------------------------------------+
double profit_from_start(int X)
{
    int    I   = 0;
    double pro = 0;
    int    cnt = OrdersTotal();
    for (int i = 0; i < cnt; i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            {
                if (I >= X) break;
                pro += OrderProfit() + OrderSwap() + OrderCommission();
                I++;
            }
        }
    }
    return (pro);
}
//+------------------------------------------------------------------+
//| SET NEW CHECKING                                                 |
//+------------------------------------------------------------------+
void write_next_time(double which_tf)
{
    if (which_tf == 15)
    {
        datetime current_t = iTime(Symbol(), PERIOD_M30, 0) + PeriodSeconds(PERIOD_M30);
        GlobalVariableSet(GL_NAME, current_t);  // next check
        GlobalVariableSet(GL_NAME + "TF", 30);
        Print("Will check again at: " + TimeToString(current_t));
        ObjectSetText("datf_1", "Next check time: " + TimeToString(current_t, TIME_MINUTES), 10, "Verdana", clrBlack);
    }

    if (which_tf == 30)
    {
        datetime current_t = iTime(Symbol(), PERIOD_H1, 0) + PeriodSeconds(PERIOD_H1);
        GlobalVariableSet(GL_NAME, current_t);  // next check
        GlobalVariableSet(GL_NAME + "TF", 60);
        Print("Will check again at: " + TimeToString(current_t));
        ObjectSetText("datf_1", "Next check time: " + TimeToString(current_t, TIME_MINUTES), 10, "Verdana", clrBlack);
    }

    if (which_tf == 60)
    {
        datetime current_t = iTime(Symbol(), PERIOD_H4, 0) + PeriodSeconds(PERIOD_H4);
        GlobalVariableSet(GL_NAME, current_t);  // next check
        GlobalVariableSet(GL_NAME + "TF", 240);
        Print("Will check again at: " + TimeToString(current_t));
        ObjectSetText("datf_1", "Next check time: " + TimeToString(current_t, TIME_MINUTES), 10, "Verdana", clrBlack);
    }

    if (which_tf == 240)
    {
        datetime current_t = iTime(Symbol(), PERIOD_H4, 0) + PeriodSeconds(PERIOD_H4);
        GlobalVariableSet(GL_NAME, current_t);  // next check
        GlobalVariableSet(GL_NAME + "TF", 240);
        Print("Will check again at: " + TimeToString(current_t));
        ObjectSetText("datf_1", "Next check time: " + TimeToString(current_t, TIME_MINUTES), 10, "Verdana", clrBlack);
    }
}
//+------------------------------------------------------------------+
//| Found                                                            |
//+------------------------------------------------------------------+
int order_allow_open()
{
    int tot    = 0;
    int market = 0;
    for (int POS = OrdersTotal() - 1; POS >= 0; POS--)
    {
        if (!OrderSelect(POS, SELECT_BY_POS, MODE_TRADES)) continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
        {
            if (OrderOpenTime() >= iTime(Symbol(), PERIOD_H1, 0))
                tot++;
            else
                break;
        }
    }
    market = tot;
    if (tot == 0)
    {
        //---
        tot = 0;
        for (int POS = OrdersHistoryTotal() - 1; POS >= 0; POS--)
        {
            if (!OrderSelect(POS, SELECT_BY_POS, MODE_HISTORY)) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            {
                if (OrderOpenTime() >= iTime(Symbol(), PERIOD_H1, 0))
                    tot++;
                else
                    break;
            }
        }
    }
    return tot;
}
//+------------------------------------------------------------------+
//| Kolpos_count                                                     |
//+------------------------------------------------------------------+
void count()
{
    buy_m          = 0;
    sell_m         = 0;
    down_price_buy = 9999;
    up_price_sell  = 0;
    for (int POS = 0; POS < OrdersTotal(); POS++)
    {
        if (!OrderSelect(POS, SELECT_BY_POS, MODE_TRADES)) continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
        {
            int    type     = OrderType();
            double op_price = OrderOpenPrice();
            //---
            if (type == 0)
            {
                buy_m++;
                if (op_price < down_price_buy)
                    down_price_buy = op_price;
            }
            //---
            if (type == 1)
            {
                sell_m++;
                if (op_price > up_price_sell)
                    up_price_sell = op_price;
            }
        }
    }
}
//+------------------------------------------------------------------+
//| Kolpos_count                                                     |
//+------------------------------------------------------------------+
int count_magic()
{
    int cc = 0;

    for (int POS = 0; POS < OrdersTotal(); POS++)
    {
        if (!OrderSelect(POS, SELECT_BY_POS, MODE_TRADES)) continue;
        if (OrderMagicNumber() == magic)
        {
            cc++;
        }
    }
    return cc;
}
//+------------------------------------------------------------------+
//| Create data                                                      |
//+------------------------------------------------------------------+
void creat_data(string nameas, int x, int y, string tex)
{
    string nam = "datf_" + nameas;
    ObjectCreate(nam, OBJ_LABEL, 0, 0, 0);
    ObjectSetText(nam, tex, 12, "Verdana", clrBlack);
    ObjectSet(nam, OBJPROP_CORNER, 1);
    ObjectSet(nam, OBJPROP_XDISTANCE, x);
    ObjectSet(nam, OBJPROP_YDISTANCE, y);
    ObjectSet(nam, OBJPROP_SELECTABLE, false);
    ObjectSet(nam, OBJPROP_HIDDEN, true);
}
//+-------------------------------------------------------------------+
//|OPEN SELL                                                          |
//+-------------------------------------------------------------------+



// NOTE: sell function
void open_sell(double LOT)
{
    double lots = NormalizeDouble(LOT, dos);
    int    tk   = 0;
    if (AccountFreeMarginCheck(Symbol(), OP_SELL, lots) <= 0)
    {
        Alert("Not enjoy money for open order with size: " + DoubleToString(lots, 2) + " !");
        tim = TimeCurrent() + 15;
        return;
    }
    if (CheckVolumeValue(lots) == false)
    {
        tim = Time[0];
        return;
    }
    RefreshRates();
    tk = OrderSend(Symbol(), OP_SELL, lots, Bid, 100, 0, 0, "", magic, 0, clrBlack);
    if (tk == -1)
    {
        Alert("Order SELL not open! Error: " + IntegerToString(GetLastError()) + " pair: " + Symbol());
        tim = TimeCurrent() + 15;
        Sleep(1000);
        open_sell(LOT);
    } else
    {
        sl_all_s(100);
    }
}

void open_sell_stop(double LOT)
{
    double lots = NormalizeDouble(LOT, dos);
    int    tk   = 0;
    if (AccountFreeMarginCheck(Symbol(), OP_SELL, lots) <= 0)
    {
        Alert("Not enjoy money for open order with size: " + DoubleToString(lots, 2) + " !");
        tim = TimeCurrent() + 15;
        return;
    }
    if (CheckVolumeValue(lots) == false)
    {
        tim = Time[0];
        return;
    }
    RefreshRates();
    
		double price = Bid - (SellStopDistance * _Point);

    tk = OrderSend(Symbol(), OP_SELLSTOP, lots, price, 100, 0, 0, "", magic, 0, clrBlack);
    if (tk == -1)
    {
        Alert("Order SELL Stop not open! Error: " + IntegerToString(GetLastError()) + " pair: " + Symbol());
        tim = TimeCurrent() + 15;
        Sleep(1000);
        open_sell_stop(LOT);
    } else
    {
        sl_all_s(100);
    }
}

void open_sell_limit(double LOT)
{
    double lots = NormalizeDouble(LOT, dos);
    int    tk   = 0;
    if (AccountFreeMarginCheck(Symbol(), OP_SELL, lots) <= 0)
    {
        Alert("Not enjoy money for open order with size: " + DoubleToString(lots, 2) + " !");
        tim = TimeCurrent() + 15;
        return;
    }
    if (CheckVolumeValue(lots) == false)
    {
        tim = Time[0];
        return;
    }
    RefreshRates();
    
		double price = Bid + (SellLimitDistance * _Point);

    tk = OrderSend(Symbol(), OP_SELLLIMIT, lots, price, 100, 0, 0, "", magic, 0, clrBlack);
    if (tk == -1)
    {
        Alert("Order SELL Limit not open! Error: " + IntegerToString(GetLastError()) + " pair: " + Symbol());
        tim = TimeCurrent() + 15;
        Sleep(1000);
        open_sell_limit(LOT);
    } else
    {
        sl_all_s(100);
    }
}

//+-------------------------------------------------------------------+
//|Open BUY                                                           |
//+-------------------------------------------------------------------+
void open_buy(double LOT)
{
    int    tk   = 0;
    double lots = NormalizeDouble(LOT, dos);
    if (AccountFreeMarginCheck(Symbol(), OP_BUY, lots) <= 0)
    {
        Alert("Not enjoy money for open order with size: " + DoubleToString(lots, 2) + " !");
        tim = TimeCurrent() + 15;
        return;
    }
    if (CheckVolumeValue(lots) == false)
    {
        tim = Time[0];
        return;
    }
    RefreshRates();
    tk = OrderSend(Symbol(), OP_BUY, lots, Ask, 100, 0, 0, "", magic, 0, clrGreen);
    if (tk == -1)
    {
        Alert("Order BUY not open! Error: " + IntegerToString(GetLastError()) + " pair: " + Symbol());
        tim = TimeCurrent() + 15;
        Sleep(1000);
        open_buy(LOT);
    } else
    {
        sl_all_b(100);
    }
}
void open_buy_stop(double LOT)
{
    double lots = NormalizeDouble(LOT, dos);
    int    tk   = 0;
    if (AccountFreeMarginCheck(Symbol(), OP_BUY, lots) <= 0)
    {
        Alert("Not enjoy money for open order with size: " + DoubleToString(lots, 2) + " !");
        tim = TimeCurrent() + 15;
        return;
    }
    if (CheckVolumeValue(lots) == false)
    {
        tim = Time[0];
        return;
    }
    RefreshRates();
    
		double price = Ask + (BuyStopDistance * _Point);

    tk = OrderSend(Symbol(), OP_BUYSTOP, lots, price, 100, 0, 0, "", magic, 0, clrBlack);
    if (tk == -1)
    {
        Alert("Order Buy Stop not open! Error: " + IntegerToString(GetLastError()) + " pair: " + Symbol());
        tim = TimeCurrent() + 15;
        Sleep(1000);
        open_buy_stop(LOT);
    } else
    {
        sl_all_s(100);
    }
}

void open_buy_limit(double LOT)
{
    double lots = NormalizeDouble(LOT, dos);
    int    tk   = 0;
    if (AccountFreeMarginCheck(Symbol(), OP_BUY, lots) <= 0)
    {
        Alert("Not enjoy money for open order with size: " + DoubleToString(lots, 2) + " !");
        tim = TimeCurrent() + 15;
        return;
    }
    if (CheckVolumeValue(lots) == false)
    {
        tim = Time[0];
        return;
    }
    RefreshRates();
    
		double price = Ask - (BuyLimitDistance * _Point);

    tk = OrderSend(Symbol(), OP_BUYLIMIT, lots, price, 100, 0, 0, "", magic, 0, clrBlack);
    if (tk == -1)
    {
        Alert("Order BUY Limit not open! Error: " + IntegerToString(GetLastError()) + " pair: " + Symbol());
        tim = TimeCurrent() + 15;
        Sleep(1000);
        open_buy_limit(LOT);
    } else
    {
        sl_all_s(100);
    }
}

//+------------------------------------------------------------------+
//|  Check lot funtcion                                              |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume)
{
    double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
    int    ratio       = (int)MathRound(volume / volume_step);
    if (MathAbs(ratio * volume_step - volume) > 0.0000001)
    {
        Print("Wrong lot");
        return (false);
    }
    return (true);
}
//+-------------------------------------------------------------------+
//|sl_all                                                             |
//+-------------------------------------------------------------------+
void sl_all_b(int cc)
{
    double aver1 = AVE_BUY();
    if (aver1 != 0)
    {
        double tp1  = 0;
        double sl1  = 0;
        int    tak  = (tp * 10 / 100 * cc) / 10;
        int    tak2 = sl;
        //---
        tp1 = NormalizeDouble(aver1 + tak * Point, Digits);
        sl1 = NormalizeDouble(aver1 - tak2 * Point, Digits);
        for (int trade = OrdersTotal() - 1; trade >= 0; trade--)
        {
            if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == magic && OrderType() == OP_BUY && OrderSymbol() == Symbol())
            {
                for (int i = 0; i < 3; i++)
                {
                    RefreshRates();
                    if (OrderStopLoss() != sl1 || OrderTakeProfit() != tp1)
                    {
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), sl1, tp1, 0, Violet)) break;
                    }
                }
            }
        }
    }
}
//+-------------------------------------------------------------------+
//|sl_all                                                             |
//+-------------------------------------------------------------------+
void sl_all_s(int cc)
{
    double aver1 = AVE_SELL();
    if (aver1 != 0)
    {
        double tp1  = 0;
        double sl1  = 0;
        double tak  = (tp * 10 / 100 * cc) / 10;
        double tak2 = sl;
        tp1         = NormalizeDouble(aver1 - tak * Point, Digits());
        sl1         = NormalizeDouble(aver1 + tak2 * Point, Digits());
        double hh   = aver1 - tak * Point;
        for (int trade = OrdersTotal() - 1; trade >= 0; trade--)
        {
            if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == magic && OrderType() == 1 && OrderSymbol() == Symbol())
            {
                for (int i = 0; i < 3; i++)
                {
                    if (OrderStopLoss() != sl1 || OrderTakeProfit() != tp1)
                    {
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), sl1, tp1, 0, Violet)) break;
                    }
                }
            }
        }
    }
}
//+-------------------------------------------------------------------+
//|all tp                                                             |
//+-------------------------------------------------------------------+
double AVE_SELL()
{
    double lots1 = 0, sum = 0;
    RefreshRates();
    for (int trade = OrdersTotal() - 1; trade >= 0; trade--)
    {
        if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
        {
            if (OrderType() == OP_SELL)
            {
                lots1 += OrderLots();
                sum += OrderLots() * OrderOpenPrice();
            }
        }
    }
    if (lots1 == 0) return (0);
    return (sum / lots1);
}
//+-------------------------------------------------------------------+
//|all tp                                                             |
//+-------------------------------------------------------------------+
double AVE_BUY()
{
    double lots1 = 0, sum = 0;
    RefreshRates();
    for (int trade = OrdersTotal() - 1; trade >= 0; trade--)
    {
        if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES) && OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
        {
            lots1 += OrderLots();
            sum += OrderLots() * OrderOpenPrice();
        }
    }
    if (lots1 == 0) return (0);
    return (sum / lots1);
}
//+------------------------------------------------------------------+
//| lot return                                                       |
//+------------------------------------------------------------------+
double LOT_X()
{
    int tot = 0;
    for (int POS = OrdersTotal() - 1; POS >= 0; POS--)
    {
        if (!OrderSelect(POS, SELECT_BY_POS, MODE_TRADES)) continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
        {
            return NormalizeDouble(OrderLots() + x_lotadd, dos);
        }
    }
    return 0;
}
//+---------------------------------------------------------------------+
//|          Tral                                                       |
//+---------------------------------------------------------------------+
void trailing_function()
{
    ResetLastError();
    double stop = MarketInfo(Symbol(), MODE_STOPLEVEL);
    if (trail_step < stop)
    {
        Alert("Trail step less then minimal broker stop level, set as minimal allowed +1 point: ", stop + 1);
        trail_step = (int)stop + 1;
    }
    double zero_sell = NormalizeDouble(AVE_SELL(), Digits());
    double zero_buy  = NormalizeDouble(AVE_BUY(), Digits());
    //---
    int cnt = OrdersTotal();
    for (int i = 0; i < cnt; i++)
    {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            continue;
        else if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
        {
            if (OrderType() == OP_BUY && Bid - (trail_start + stop) * Point > zero_buy)
            {
                double new_sl = NormalizeDouble(Bid - trail_step * Point, Digits());
                if (new_sl > zero_buy || OrderStopLoss() == 0)
                {
                    if (OrderStopLoss() < new_sl - 0 * Point || OrderStopLoss() == 0)
                    {
                        if (Bid - stop * Point > new_sl)
                        {
                            bool check = OrderModify(OrderTicket(), OrderOpenPrice(), new_sl, OrderTakeProfit(), 0, CLR_NONE);
                            if (!check)
                                Print("Trail error: ", GetLastError());
                        }
                    }
                }
            }
            if (OrderType() == OP_SELL && Ask + trail_start * Point < zero_sell)
            {
                double new_sl_sell = NormalizeDouble(Ask + trail_step * Point, Digits());
                if (new_sl_sell < zero_sell || OrderStopLoss() == 0)
                {
                    if (OrderStopLoss() > new_sl_sell + 0 * Point || OrderStopLoss() == 0)
                    {
                        if (Ask + stop * Point < new_sl_sell)
                        {
                            bool check = OrderModify(OrderTicket(), OrderOpenPrice(), new_sl_sell, OrderTakeProfit(), 0, CLR_NONE);
                            if (!check)
                                Print("Trail error: ", GetLastError());
                        }
                    }
                }
            }
        }
    }
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