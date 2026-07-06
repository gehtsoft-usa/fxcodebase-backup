//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74877

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

#include <stdlib.mqh>
#include <stderror.mqh> 

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx LUKE_PERRETT_ea.mq4 xxx//

/*xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx specification xxx//
   UNIVERSAL EA

   This EA is to be based on buying /selling via buffers.
   This is based on the calling of a custom signal indicator.
   Here are the INPUTS below and I will give a description of how each INPUT works. Please see below.
   Source code needs to be provided on completion of project.

   EA INPUTS

   Variable                Value

   TP Mode                 Basket/Individual
   Lot Size                0.01
   TP (IN $)               100
   SL (IN $)               100
   Trail TP (IN $)         250
   Trail Step (IN $)       50
   Break Even (IN $)       100
   Custom Indicator Name   X
   Buy Buffer NO           0
   Sell Buffer NO          1
   Use Break Even          True/False
   Use Trailing Stop       True/False
   Use Close Out           True/false
   Close Out Trades Level  200
   Close Out Style         Break Even/Profit
   Magic Number            777


   TP Mode.
   BASKET means for ALL trades to close out based on the TP/SL- OR Trail SL OR Break Even...
   Basically its basket and everything closes based on the INPUTS. These figures are based on $, not pips

   INDIVIDUAL means that ALL trades are closed out based on Individual circumstances of TP/SL/ Trail/ Breakeven etc etc.
   These figures are based on $, not pips

   LOT Size.
   This is standard and needs for no explanation.

   TP (IN $)
   This means that all trades either in basket or individual will close out based on this $ amount. Simple

   SL (IN $)
   This means that all trades either in basket or individual will close out based on this $ amount. Simple

   Trail TP (IN $)
   This means that at this point of $ then the Trail of price will commence and will only be closed out be the Trail Step.
   This is for basket or Individual.

   Trail Step (IN $)
   This means that when price in the Trail TP is reached. As price goes up or down, the Trail Step will close out trades based on this Step.
   Example is.

   Trail TP is set to $350,
   Trail Step is set to $50,
   Profit in trades is at $350,
   Profit in trades falls back to $300.
   Trades close out.
   As profit rises then the step is rising with the profit at the same step level as the INPUT. SIMPLE.
   This is seen as trailing the high water mark.

   Break Even (IN $)
   This means that either basket or individual will close out at this level.

   Custom Indicator Name
   This is where the custom indicator will go for this EA to call from the folder.

   Buy Buffer
   This is the number for the buffer for buying

   Sell Buffer
   This is the number for the buffer for selling

   Use Break Even
   This means the option to use break even feature or not

   Use Trailing Stop
   This means the option to use trailing stop feature or not

   Use Close Out
   This means the option to close out feature or not

   Close Out Trades Level
   This means for the trades to be closed out at this level based on the “Close Out Trades Style” INPUT.
   I have added this feature because most brokers only allow a set amount of trades or pending orders.
   So in this case the trades will close out ONLY 2 at a time based on the STYLE INPUT BELOW.
   Obviously, trades will continue to be taken based on the entry criteria and in this case the trades will continue to close at this level as well.
   In this case we will have trades closing at this level and trades also being entered based on the entry criteria
   and trades also being closed out based on all the other INPUTS of TP/SL/Trailing/or Breakeven- based on basket or individual.

   Close Out Trades Level
   This is the level at which the 2 trades to close out will commence. This might be ranging from 10 to 500.
   Depending on broker and system I use this for. Point to make is that 2 trades close out at the same time based on the “CLOSE OUT STYLE” INPUT

   Close out Trades Style
   This is the STYLE in which the 2 trades will close out when the “CLOSE OUT TRADES LEVEL” is reached.

   Break Even. This means that the 2 trades to close should be the 2 trades closest to receiving a Break Even result. MUST BE A BUY AND SELL TRADE.
   So a positive trade of $ 1.95 should be paired with the closest trade to receive a Break Even result.
   This could be a negative trade of -$1.45. Either way the object is clear, the result to gain is that the 2 trades to close
   give the closest to break even as possible.

   Profit. This means the same as above INPUT yet the 2 trades to close out give the biggest profit. MUST BE A BUY AND SELL TRADE. Simple.
   Best 2 trades at the time of closing to give biggest PROFIT.

   Magic Number
   This is obvious.
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx*/
#property strict

double myPoint;
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
enum ENUM_TP_MODE { Basket = 0, Individual = 1 };
enum ENUM_CLOSE_OUT_STYLE { BE = 0/*Break_Even*/, Profit = 1 };
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx external variables xxx//
input string               _I_                 = "___ EA INPUTS ___";       //
input ENUM_TP_MODE         TP_Mode             = Individual;                // TP Mode
input double               Lot_Size            = 0.01;                      // Lot Size
input double               TP_money            = 100.0;                     // TP ( IN $ )
input double               SL_money            = 100.0;                     // SL ( IN $ )
input double               Trail_TP            = 250.0;                     // Trail TP ( IN $ )
input double               Trail_Step          = 50.0;                      // Trail Step ( IN $ )
input double               Break_Even          = 100.0;                     // Break Even ( IN $ )
input string               Custom_Ind_Name     = "SuperArrow";              // Custom Indicator Name
input int                  Buy_Buffer_NO       = 0;                         // Buy Buffer NO
input int                  Sell_Buffer_NO      = 1;                         // Sell Buffer NO
input bool                 UseBreakEven        = false;                     // Use Break Even
input bool                 UseTrailingStop     = false;                     // Use Trailing Stop
input bool                 UseCloseOnOppSign   = false;                     // Use Close On Opposite Signal
input bool                 UseCloseOut         = false;                     // Use Close Out
input int                  CloseOutTradesLevel = 200;                       // Close Out Trades Level
input ENUM_CLOSE_OUT_STYLE CloseOutStyle       = BE;                        // Close Out Style
input int                  Magic               = 777;                       // Magic Number
input int                  maxPos              = 2;                         // Max sell-buy positions at same time (0=unlimited)
input int                  maxBuyPos           = 1;                         // Max buy positions at same time (0=unlimited)
input int                  maxSellPos          = 1;                         // Max sell positions at same time (0=unlimited)
/*input*/ int              Slippage            = 10;                        //
/*input*/ ENUM_TIMEFRAMES  Tf                  = PERIOD_CURRENT;            //


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx global variables xxx//

extern double  StopLoss = 100;          // Maximum pips willing to lose per position.

extern string  tsp0 = "--Trailing Stop Types--";
extern string  tsp1 = " 1 = Trail immediately";
extern string  tsp2 = " 2 = Wait to trail";
extern string  tsp3 = " 3 = Uses 3 levels before trail";
extern string  tsp4 = " 4 = Breakeven + Lockin";
extern string  tsp5 = " 5 = Step trail";
extern string  tsp6 = " 6 = MA trail";
extern string  tsp7 = " 7 = pSAR trail";
extern int     TrailingStopType = 4;

extern string  ts2 = "Settings for Type 2";
extern double  TrailingStop = 15;      // Change to whatever number of pips you wish to trail your position with.

extern string  ts3 = "Settings for Type 3";
extern double  FirstMove = 20;        // Type 3  first level pip gain
extern double  FirstStopLoss = 50;    // Move Stop to Breakeven
extern double  SecondMove = 30;       // Type 3 second level pip gain
extern double  SecondStopLoss = 30;   // Move stop to lock is profit
extern double  ThirdMove = 40;        // type 3 third level pip gain
extern double  TrailingStop3 = 20;    // Move stop and trail from there

extern string  ts4 = "Settings for Type 4";
extern double  BreakEven = 30;
extern int     LockInPips = 1;        // Profit Lock in pips

extern string  ts5 = "Settings for Type 5";
extern int     eTrailingStop   = 10;
extern int     eTrailingStep   = 2;

extern string  ts6 = "Settings for Type 6";
extern int     TrailMA_TimeFrame    =  15;
extern int     TrailMA_Period       = 10;
extern int     TrailMA_Shift        =  0;    
extern string  t3="--Moving Average settings--";
extern string  tm = "--Moving Average Types--";
extern string  tm0 = " 0 = SMA";
extern string  tm1 = " 1 = EMA";
extern string  tm2 = " 2 = SMMA";
extern string  tm3 = " 3 = LWMA";
extern int     TrailMA_Type = 1;
extern string  tp = "--Applied Price Types--";
extern string  tp0 = " 0 = close";
extern string  tp1 = " 1 = open";
extern string  tp2 = " 2 = high";
extern string  tp3 = " 3 = low";
extern string  tp4 = " 4 = median(high+low)/2";
extern string  tp5 = " 5 = typical(high+low+close)/3";
extern string  tp6 = " 6 = weighted(high+low+close+close)/4";
extern int     TrailMA_AppliedPrice = 0;
extern int     InitialStop     =  0;
 
extern string  ts7 = "Settings for Type 7";
extern double  StepParabolic = 0.02;
extern double  MaxParabolic  = 0.2;
extern int     Interval      = 5;






//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx global variables xxx//
datetime
timePrev;
double
SL, TP, MaxProfitTrail,
TickSize, TickValue, Spread, StopLevel, MinLot, MaxLot, LotStep, Pnt;
int
order_type, T, nT, T_CloseOut,
            nBO, nSO, nBS, nSS, nBL, nSL, nO, nS, nL, _nBO, _nSO, _nBS, _nSS, _nBL, _nSL, _nO, _nS, _nL, Slip;
bool
IsProfitBE, CloseContinue,
            Ans, _Ans, Activate, FatalError, FreeMarginAlert, IsModify, IsTester, IsVisual;
int
tickets[];

#define Section_Partial_Close
#ifdef Section_Partial_Close

input string tpartials       = "== Partial Close =="; // ------------
input bool   partialCloseOn  = false; // Partial Close On:
input double percentToClose  = 25;                    // Percent to close %
input double partial_profit1 = 20;                    // Partial 1 $:
input double partial_profit2 = 30;                    // Partial 2 $:
input double partial_profit3 = 40;                    // Partial 3 $:
input double partial_profit4 = 20;                    // Partial 4 $:

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PartialClose
  {
   double            originalLot;
   int               _magic;
   int               tkPartial1[];
   int               tkPartial2[];
   int               tkPartial3[];
   int               tkPartial4[];

public:
                     PartialClose() { ; }
                    ~PartialClose() { ; }

   void              setMagic(int m) { _magic = m; }
   void              setOriginalLot(double l) { originalLot = l; }

   double            lots()
     {
      return NormalizeDouble((originalLot * percentToClose / 100), 2);
     }

   double            price()
     {
      double ask = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
      double bid = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
      if(OrderType() == OP_BUY)
        {
         return bid;
        }
      if(OrderType() == OP_SELL)
        {
         return ask;
        }
      return 0;
     }

   bool              takePartial()
     {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
           {
            int    tk     = OrderTicket();
            double profit = OrderProfit() + OrderCommission() + OrderSwap();
            if(profit >= partial_profit1 && partial_profit1 > 0)
               if(!CheckList(tk, 1))
                  if(OrderClose(tk, lots(), price(), 10000, Yellow))
                    {
                     savetk(newtk(tk), 1);
                     break;
                    }
            if(profit >= partial_profit2 && partial_profit2 > 0)
               if(!CheckList(tk, 2))
                  if(OrderClose(OrderTicket(), lots(), price(), 10000, Pink))
                    {
                     savetk(newtk(tk), 1);
                     savetk(newtk(tk), 2);
                     break;
                    }
            if(profit >= partial_profit3 && partial_profit3 > 0)
               if(!CheckList(tk, 3))
                  if(OrderClose(OrderTicket(), lots(), price(), 10000, Lime))
                    {
                     savetk(newtk(tk), 1);
                     savetk(newtk(tk), 2);
                     savetk(newtk(tk), 3);
                     break;
                    }
            if(profit >= partial_profit4 && partial_profit4 > 0)
               if(!CheckList(tk, 4))
                  if(OrderClose(OrderTicket(), lots(), price(), 10000, Black))
                    {
                     savetk(newtk(tk), 1);
                     savetk(newtk(tk), 2);
                     savetk(newtk(tk), 3);
                     savetk(newtk(tk), 4);
                     break;
                    }
           }
        }
      return false;
     }

   bool              CheckList(int tk, int list)
     {
      int p = 0;
      if(list == 1)
        {
         p = ArrayBsearch(tkPartial1, tk);
         if(p < 0)
            return false;
         return tkPartial1[p] == tk;
        }
      if(list == 2)
        {
         p = ArrayBsearch(tkPartial2, tk);
         if(p < 0)
            return false;
         return tkPartial2[p] == tk;
        }
      if(list == 3)
        {
         p = ArrayBsearch(tkPartial3, tk);
         if(p < 0)
            return false;
         return tkPartial3[p] == tk;
        }
      if(list == 4)
        {
         p = ArrayBsearch(tkPartial4, tk);
         if(p < 0)
            return false;
         return tkPartial4[p] == tk;
        }
      return false;
     }

   void              savetk(int tk, int list)
     {
      if(list == 1)
        {
         int t = ArraySize(tkPartial1);
         if(ArrayResize(tkPartial1, t + 1))
           {
            tkPartial1[t] = tk;
           }
        }
      if(list == 2)
        {
         int t = ArraySize(tkPartial2);
         if(ArrayResize(tkPartial2, t + 1))
           {
            tkPartial2[t] = tk;
           }
        }
      if(list == 3)
        {
         int t = ArraySize(tkPartial3);
         if(ArrayResize(tkPartial3, t + 1))
           {
            tkPartial3[t] = tk;
           }
        }
      if(list == 4)
        {
         int t = ArraySize(tkPartial4);
         if(ArrayResize(tkPartial4, t + 1))
           {
            tkPartial4[t] = tk;
           }
        }
     }

   int               newtk(int tk)
     {
      if(OrderSelect(tk, SELECT_BY_TICKET))
        {
         datetime dt     = OrderCloseTime();
         string   coment = OrderComment();
         int      pos    = StringFind(coment, "#") + 1;
         string   ntk    = StringSubstr(coment, pos, StringLen(coment));
         return (int)ntk;
        }
      return 0;
     }
  };

PartialClose partialClose;
void OnInit_PartialClose()
  {
   partialClose.setMagic(Magic);
   partialClose.setOriginalLot(Lot_Size);
  }

#endif

#define MARTINGALE_ON
#ifdef MARTINGALE_ON

enum Martingale_mode
  {
   last_was_loss, // if Last was Loss
   last_was_win   // if Last Was Win
  };

input string          tMatingale                = "== Matingale Setup =="; // == Matingale Setup ==
input bool            MartingaleON              = true;                    // Use Martingale:
input Martingale_mode martingaleMode            = last_was_loss;           // Martingale Mode:
input int             MartingaleUser_maxCount   = 5;                       // Max attempts:
input double          MartingaleUser_maxLot     = 10;                      // Max lot value:
input double          MartingaleUser_multiplier = 2;                       // Multiplier:

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MartingaleIncrementLot
  {
   int               _lastTk;
   double            _lastProfit;
   double            _lastLot;
   int               _count;
   int               _magic;
   string            _symbol;
   int               _maxCount;
   double            _maxLot;
   double            _multiplier;

public:
                     MartingaleIncrementLot(int magic, string symbol)
     {
      _maxCount   = MartingaleUser_maxCount;
      _maxLot     = MartingaleUser_maxLot;
      _multiplier = MartingaleUser_multiplier;
      _magic      = magic;
      _symbol     = symbol;
     }
                    ~MartingaleIncrementLot() { ; }

   double            Lot()
     {
      setLastValues();
      double next = NormalizeDouble(_lastLot * _multiplier, 2);
      if(next > _maxLot)
         return _maxLot;
      if(count() == _maxCount)
         return 0;
      return next;
     }

   void              setLastValues()
     {
      int i = OrdersHistoryTotal() - 1;
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic)
        {
         double last_profit = OrderProfit() + OrderCommission() + OrderSwap();
         if(martingaleMode == last_was_loss)
            if(last_profit < 0)
              {
               _lastTk     = OrderTicket();
               _lastProfit = last_profit;
               _lastLot    = OrderLots();
              }
            else
              {
               _lastTk     = 0;
               _lastProfit = 0;
               _lastLot    = 0;
               _count      = 0;
              }
         if(martingaleMode == last_was_win)
            if(last_profit > 0)
              {
               _lastTk     = OrderTicket();
               _lastProfit = last_profit;
               _lastLot    = OrderLots();
              }
            else
              {
               _lastTk     = 0;
               _lastProfit = 0;
               _lastLot    = 0;
               _count      = 0;
              }
        }
     }

   int               count()
     {
      int count = 0;
      for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic)
           {
            double last_profit = OrderProfit() + OrderCommission() + OrderSwap();
            if(martingaleMode == last_was_loss)
               if(last_profit < 0)
                 {
                  count++;
                 }
               else
                  if(last_profit >= 0)
                    {
                     break;
                    }
            if(martingaleMode == last_was_win)
               if(last_profit > 0)
                 {
                  count++;
                 }
               else
                  if(last_profit <= 0)
                    {
                     break;
                    }
           }
        }
      _count = count - 1;
      return _count;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MartingaleIncrementLot martingale(Magic, _Symbol);
#endif


interface iConditions { bool evaluate(); };

#define Section_2Emas_trend
#ifdef Section_2Emas_trend
// Mark: Section_2Emas_trend

input string             ma_title          = "== Moving Average 1 Setup =="; // ————————————————————————
input bool trendFilterOn = true; // Trend Filter On ?
input ENUM_TIMEFRAMES ma1_tf = 0; // TimeFrame:
input int                ma1_period        = 20;                             // Periods:
input ENUM_MA_METHOD     ma1_method        = MODE_EMA;                       // Method:
input int                ma1_shift         = 0;                              // Shift:
input ENUM_APPLIED_PRICE ma1_applied_price = PRICE_CLOSE;                    // Applied Price:

double ma1(int shift) { return iMA(NULL, ma1_tf, ma1_period, ma1_shift, ma1_method, ma1_applied_price, shift); }

input string             ma2_title         = "== Moving Average 2 Setup =="; // ————————————————————————
input ENUM_TIMEFRAMES ma2_tf = 0; // TimeFrame:
input int                ma2_period        = 50;                             // Periods:
input ENUM_MA_METHOD     ma2_method        = MODE_EMA;                       // Method:
input int                ma2_shift         = 0;                              // Shift:
input ENUM_APPLIED_PRICE ma2_applied_price = PRICE_CLOSE;                    // Applied Price:

double ma2(int shift) { return iMA(NULL, ma2_tf, ma2_period, ma2_shift, ma2_method, ma2_applied_price, shift); }

class ConditionEmasTrendUp : public iConditions
{
  public:
    bool evaluate() { return ma1(1) > ma2(1); }
};
ConditionEmasTrendUp cdEmasTrendUp;

class ConditionEmasTrendDn : public iConditions
{
  public:
    bool evaluate() { return ma1(1) < ma2(1); }
};
ConditionEmasTrendDn cdEmasTrendDn;

#endif

input string filter_title          = "== Filter Indicator Setup =="; // ————————————————————————
input bool filter_on = false; // Filter entry by indicator On ?
input string Custom_Ind_Name_filter = "filter_indicator"; // Filter Indicator Name:
input int buf_filter_buy = 0;  // Buffer to filter Buy:
input int buf_filter_sell = 1; // Buffer to filter Sell:

input string title_close_reversal         = "== Close by reversals =="; // ————————————————————————
input bool cl_by_reversal_ema_on = false; // Close by reversal EMAS Trend ?
input bool cl_by_reversal_filter_on = false; // Close by reversal FILTER indicator ?

void close_by_reversals()
{
   int current_ema_trend = 0;
   if(cl_by_reversal_ema_on)
   {
      if(cdEmasTrendUp.evaluate())current_ema_trend=1; 
      if(cdEmasTrendDn.evaluate())current_ema_trend=-1;    
   }

   int current_filter_side = 0;
   if (cl_by_reversal_filter_on)
   {
      double indi_buy = i_custom_filter(buf_filter_buy, 0);
      double indi_sell = i_custom_filter(buf_filter_sell, 0);
      if (indi_buy != EMPTY_VALUE && indi_buy != 0)   { current_filter_side =  1; }    
      if (indi_sell != EMPTY_VALUE && indi_sell != 0) { current_filter_side = -1; }    
   }
   

   for(int i=OrdersTotal()-1;i>=0;i--)
   {
       if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber()== Magic )
       {
         int type = OrderType();
         if(cl_by_reversal_ema_on)
         {
            if(type == OP_BUY && current_ema_trend==-1) int r = OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrBlack);
            if(type == OP_SELL && current_ema_trend==1) int r = OrderClose(OrderTicket(), OrderLots(), Ask, 0, clrBlack);            
         }

         if (cl_by_reversal_filter_on)
         {
            if(type == OP_BUY && current_filter_side==-1) int r= OrderClose(OrderTicket(), OrderLots(), Bid, 0, clrBlack);
            if(type == OP_SELL && current_filter_side==1) int r= OrderClose(OrderTicket(), OrderLots(), Ask, 0, clrBlack);            
         }         
       }
   }

}


double SetPoint()
{
   double mPoint;
   
   if (Digits < 4)
      mPoint = 0.01;
   else
      mPoint = 0.0001;
   
   return(mPoint);
}

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx The initialization function of the expert xxx//

int OnInit()
  {
   OnInit_PartialClose();
   myPoint = SetPoint();
   Activate = false;
   FatalError = false;
//if( TimeCurrent() >= StringToTime( "2021.12.20 00:00" ) ) { Alert("The EA has expired !");  return( INIT_SUCCEEDED ); }
   if(IsTesting() || IsOptimization() || IsVisualMode())
      IsTester = true;
   else
      IsTester = false;
   if(IsOptimization() || (IsTesting() && !IsVisualMode()))
      IsVisual = false;
   else
      IsVisual = true;
   Pnt = Point();
   Slip = Slippage;
   GetMarketInfo();
   HistoryCheck();
   timePrev = iTime(_Symbol, Tf, 0);
   if(IsTester || !GVC("CloseContinue"))
     {
      CloseContinue = false;
      T_CloseOut = -1;
      MaxProfitTrail = 0.0;
      IsProfitBE = false;
      if(!IsTester)
        {
         GVS("MaxProfitTrail", MaxProfitTrail);
         GVS("CloseContinue", (double)CloseContinue);
         GVS("T_CloseOut", (double)T_CloseOut);
         GVS("IsProfitBE", (double)IsProfitBE);
        }
     }
   Activate = true;
   return(INIT_SUCCEEDED);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx The deinitialization function of the expert xxx//
void OnDeinit(const int reason)
  {
   Comment("");
   if(!IsTester)
     {
      if(reason == 0 || reason == 1)
        {
         GVD("MaxProfitTrail");
         GVD("CloseContinue");
         GVD("T_CloseOut");
         GVD("IsProfitBE");
         if(ObjectFind(0, "TSL_lev") >= 0)
           {
            ObjectDelete(0, "TSL_lev");
            ChartRedraw();
           }
         ArrayFree(tickets);
        }
     }
  }

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx The main function of the expert xxx//
void OnTick()
  {
   if(!Activate || FatalError)
      return;
   if(!IsTester)
      GetMarketInfo();
   HistoryCheck(3, 333);
//xxxxx
   if(!IsTester)
      CloseContinue = (bool)GVG("CloseContinue");
   if(CloseContinue)
     {
      if(ClosePos())
        {
         CloseContinue = false;
         if(!IsTester)
           {
            GVS("CloseContinue", (double) CloseContinue);
            GlobalVariablesFlush();
           }
        }
      else
         return;
     }
//xxxxx
   if(!IsTester)
      T_CloseOut = (int)GVG("T_CloseOut");
   if(T_CloseOut != -1)
     {
      if(CloseByTicket(T_CloseOut))
        {
         T_CloseOut = -1;
         if(!IsTester)
           {
            GVS("T_CloseOut", (double) T_CloseOut);
            GlobalVariablesFlush();
           }
        }
     }
//xxxxx
   Trade();
//xxxxx
   getTickets();
   _numbOrders();
//xxxxx
   if(nO > 0)
     {
      if(UseCloseOut)
         CloseOut();
      //xxxxx
      if(TP_Mode == Individual)
        {
         if(SL_money > 0.0 || TP_money > 0.0)
            Check_SL_TP();
         if(UseBreakEven)
            Breakeven();
         if(UseTrailingStop)
            Trail();
        }
      //xxxxx
      else
         if(TP_Mode == Basket)
           {
            if(SL_money > 0.0 || TP_money > 0.0)
              {
               Check_SL_TP_basket();
               if(CloseContinue || nO <= 0)
                  return;
              }
            if(UseBreakEven)
              {
               Breakeven_basket();
               if(CloseContinue || nO <= 0)
                  return;
              }
            if(UseTrailingStop)
              {
               Trail_basket();
               if(CloseContinue || nO <= 0)
                  return;
              }
           }
     }
//xxxxx
   else
      if(nO <= 0)
        {
         if(TP_Mode == Basket)
           {
            if(UseBreakEven && !IsTester)
               IsProfitBE = (bool)GVG("IsProfitBE");
            if(UseBreakEven && IsProfitBE)
              {
               IsProfitBE = false;
               if(!IsTester)
                 {
                  GVS("IsProfitBE", (double) IsProfitBE);
                  GlobalVariablesFlush();
                 }
              }
            if(UseTrailingStop && !IsTester)
               MaxProfitTrail = GVG("MaxProfitTrail");
            if(UseTrailingStop && MaxProfitTrail > 0.0)
              {
               MaxProfitTrail = 0.0;
               if(!IsTester)
                 {
                  GVS("MaxProfitTrail", MaxProfitTrail);
                  GlobalVariablesFlush();
                 }
              }
           }
        }
//xxxxx
   if(IsVisual && TP_Mode == Basket && UseTrailingStop)
      TSL_info();
   if(partialCloseOn)
      partialClose.takePartial();
//xxxxx
   close_by_reversals();






//+------------------------------------------------------------------+
//| Check for Open Position                                          |
//+------------------------------------------------------------------+

   HandleOpenPositions();

  }


//+------------------------------------------------------------------+
//| Handle Open Positions                                            |
//| Check if any open positions need to be closed or modified        |
//+------------------------------------------------------------------+
void HandleOpenPositions()
{
   int cnt;
   
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != Magic)  continue;
      
      if(OrderType() == OP_BUY)
      {
         HandleTrailingStop(OP_BUY,OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
      }

      if(OrderType() == OP_SELL)
      {
         HandleTrailingStop(OP_SELL,OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
      }
   }
}

//+------------------------------------------------------------------+
//| HandleTrailingStop                                               |
//| Type 1 moves the stoploss without delay.                         |
//| Type 2 waits for price to move the amount of the trailStop       |
//| before moving stop loss then moves like type 1                   |
//| Type 3 uses up to 3 levels for trailing stop                     |
//|      Level 1 Move stop to 1st level                              |
//|      Level 2 Move stop to 2nd level                              |
//|      Level 3 Trail like type 1 by fixed amount other than 1      |
//| Type 4 Move stop to breakeven + Lockin, no trail                 |
//| Type 5 uses steps for 1, every step pip move moves stop 1 pip    |
//| Type 6 Uses EMA to set trailing stop                             |
//+------------------------------------------------------------------+
int HandleTrailingStop(int type, int ticket, double op, double os, double tp)
{
   switch (TrailingStopType)
   {
     case 1 : Immediate_TrailingStop (type, ticket, op, os, tp);
              break;
     case 2 : Delayed_TrailingStop (type, ticket, op, os, tp);
              break;
     case 3 : ThreeLevel_TrailingStop (type, ticket, op, os, tp);
              break;
     case 4 : BreakEven_TrailingStop (type, ticket, op, os, tp);
              break;
	  case 5 : eTrailingStop (type, ticket, op, os, tp);
              break;
	  case 6 : MA_TrailingStop (type, ticket, op, os, tp);
              break;
	  case 7 : pSAR_TrailingStop (type, ticket, op, os, tp);
              break;
	}
   return(0);
}


void ModifyOrder(int ord_ticket,double op, double price,double tp, color mColor)
{
    int CloseCnt, err;
    
    CloseCnt=0;
    while (CloseCnt < 3)
    {
       if (OrderModify(ord_ticket,op,price,tp,0,mColor))
       {
         CloseCnt = 3;
       }
       else
       {
          err=GetLastError();
          Print(CloseCnt," Error modifying order : (", err , ") " + ErrorDescription(err));
         if (err>0) CloseCnt++;
       }
    }
}

double ValidStopLoss(int type, double price, double SL)
{

   double mySL;
   double minstop;
   
   minstop = MarketInfo(Symbol(),MODE_STOPLEVEL);
   if (Digits == 3 || Digits == 5) minstop = minstop / 10;
   
   mySL = SL;
   if (type == OP_BUY)
   {
		 if((price - mySL) < minstop*myPoint) mySL = price - minstop*myPoint;
   }
   if (type == OP_SELL)
   {
       if((mySL-price) < minstop*myPoint)  mySL = price + minstop*myPoint;  
   }

   return(NormalizeDouble(mySL,MarketInfo(Symbol(), MODE_DIGITS)));   
}

//+------------------------------------------------------------------+
//|                                       Immediate_TrailingStop.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by MrPip,robydoby314@yahoo.com   |
//|                                                                  |   
//| Moves the stoploss without delay.                                |
//+------------------------------------------------------------------+
void Immediate_TrailingStop(int type, int ticket, double op, double os, double tp)
{

   int digits;
   double pt, pBid, pAsk, BuyStop, SellStop;

   digits = MarketInfo(Symbol( ), MODE_DIGITS);
   
   if (type==OP_BUY)
   {
     pBid = MarketInfo(Symbol(), MODE_BID);
     pt = StopLoss * myPoint;
     if(pBid-os > pt)
     {
       BuyStop = pBid - pt;
       if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
		 BuyStop = ValidStopLoss(OP_BUY,pBid, BuyStop);   
       if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
		 return;
	  }
   }
   if (type==OP_SELL)
   {
     pAsk = MarketInfo(Symbol(), MODE_ASK);
     pt = StopLoss * myPoint;
     if(os - pAsk > pt)
     {
       SellStop = pAsk + pt;
       if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
       SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
       if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
		 return;
     }
   }   
}

//+------------------------------------------------------------------+
//|                                         Delayed_TrailingStop.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by MrPip,robydoby314@yahoo.com   |
//|                                                                  |   
//| Waits for price to move the amount of the TrailingStop           |
//| Moves the stoploss pip for pip after delay.                      |
//+------------------------------------------------------------------+
void Delayed_TrailingStop(int type, int ticket, double op, double os, double tp)
{
   int digits;
   double pt, pBid, pAsk, BuyStop, SellStop;

   pt = TrailingStop * myPoint;
   digits = MarketInfo(Symbol(), MODE_DIGITS);
   
   if (type==OP_BUY)
   {
     pBid = MarketInfo(Symbol(), MODE_BID);
     BuyStop = pBid - pt;
     if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
	  BuyStop = ValidStopLoss(OP_BUY,pBid, BuyStop);   
     if (pBid-op > pt && os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
	  return;
   }
   if (type==OP_SELL)
   {
     pAsk = MarketInfo(Symbol(), MODE_ASK);
     pt = TrailingStop * myPoint;
     SellStop = pAsk + pt;
     if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
     if (op - pAsk > pt && os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
	  return;
   }   
}

//+------------------------------------------------------------------+
//|                                      ThreeLevel_TrailingStop.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by MrPip,robydoby314@yahoo.com   |   
//|                                                                  |
//| Uses up to 3 levels for trailing stop                            |
//|      Level 1 Move stop to 1st level                              |
//|      Level 2 Move stop to 2nd level                              |
//|      Level 3 Trail like type 1 by fixed amount other than 1      |
//+------------------------------------------------------------------+
void ThreeLevel_TrailingStop(int type, int ticket, double op, double os, double tp)
{

   int digits;
   double pBid, pAsk, BuyStop, SellStop;

   digits = MarketInfo(Symbol(), MODE_DIGITS) ;

   if (type == OP_BUY)
   {
      pBid = MarketInfo(Symbol(), MODE_BID);
      if (pBid - op > FirstMove * myPoint)
      {
         BuyStop = op + FirstMove*myPoint - FirstStopLoss * myPoint;
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		   BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
         if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
      }
              
      if (pBid - op > SecondMove * myPoint)
      {
         BuyStop = op + SecondMove*myPoint - SecondStopLoss * myPoint;
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		   BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
         if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
      }
                
      if (pBid - op > ThirdMove * myPoint)
      {
         BuyStop = pBid  - TrailingStop3*myPoint;
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		   BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
         if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
      }
   }
       
    if (type ==  OP_SELL)
    {
        pAsk = MarketInfo(Symbol(), MODE_ASK);
        if (op - pAsk > FirstMove * myPoint)
        {
           SellStop = op - FirstMove * myPoint + FirstStopLoss * myPoint;
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
           if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        }
        if (op - pAsk > SecondMove * myPoint)
        {
           SellStop = op - SecondMove * myPoint + SecondStopLoss * myPoint;
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
           if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        }
        if (op - pAsk > ThirdMove * myPoint)
        {
           SellStop = pAsk + TrailingStop3 * myPoint;               
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
           if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        }
    }

}

void BreakEven_TrailingStop(int type, int ticket, double op, double os, double tp)
{

   int digits;
   double pBid, pAsk, BuyStop, SellStop;

   digits = MarketInfo(Symbol(), MODE_DIGITS);
   
  if (type==OP_BUY)
  {
    pBid = MarketInfo(Symbol(), MODE_BID);
    if ( pBid-op > myPoint*BreakEven ) 
    {
       BuyStop = op + LockInPips * myPoint;
       if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
		 BuyStop = ValidStopLoss(OP_BUY,pBid, BuyStop);   
       if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
		 return;
	 }
  }
  if (type==OP_SELL)
  {
    pAsk = MarketInfo(Symbol(), MODE_ASK);
    if ( op - pAsk > myPoint*BreakEven ) 
    {
       SellStop = op - LockInPips * myPoint;
       if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
       SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
       if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
		 return;
    }
  }   

}

void eTrailingStop(int type, int ticket, double op, double os, double tp)
{

  int digits;
  double pBid, pAsk, BuyStop, SellStop;

  digits = MarketInfo(Symbol(), MODE_DIGITS) ;
  if (type==OP_BUY)
  {
    pBid = MarketInfo(Symbol(), MODE_BID);
    if ((pBid-op)>eTrailingStop*myPoint)
    {
      if (os<pBid-(eTrailingStop+eTrailingStep-1)*myPoint)
      {
        BuyStop = pBid-eTrailingStop*myPoint;
        if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
		  BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
        ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
        return;
      }
    }
  }
  if (type==OP_SELL)
  {
    pAsk = MarketInfo(Symbol(), MODE_ASK);
    if (op - pAsk > eTrailingStop*myPoint)
    {
      if (os > pAsk + (eTrailingStop + eTrailingStep-1)*myPoint || os==0)
      {
        SellStop = pAsk + eTrailingStop * myPoint;
        if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
        SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
        ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        return;
      }
    }
  }

}

void MA_TrailingStop(int type, int ticket, double op, double os, double tp)
{
   int digits;
   double pBid, pAsk, BuyStop, SellStop, ema;

   digits = MarketInfo(Symbol(), MODE_DIGITS) ;
   ema = iMA(Symbol(),TrailMA_TimeFrame,TrailMA_Period,0,TrailMA_Type,TrailMA_AppliedPrice,TrailMA_Shift);
   
   if (type==OP_BUY) 
   {
	   BuyStop = ema;
      pBid = MarketInfo(Symbol(),MODE_BID);
		if(os == 0 && InitialStop>0 ) BuyStop = pBid-InitialStop*myPoint;
		if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
		if ((op <= BuyStop && BuyStop > os) || os==0) 
		{
          ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
			 return;
      }
   }   

   if (type==OP_SELL)
   {
	   SellStop = ema;
      pAsk = MarketInfo(Symbol(),MODE_ASK);
      if (os==0 && InitialStop > 0) SellStop = pAsk+InitialStop*myPoint;
		if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);
      if( (op >= SellStop && os > SellStop) || os==0) 
      {
          ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
			 return;
      }
   }
}

//+------------------------------------------------------------------+
void pSAR_TrailingStop(int type, int ticket, double op, double os, double tp)
{
   int digits;
   double pBid, pAsk, BuyStop, SellStop, spr;
   double sar1, sar2;
  
   digits = MarketInfo(Symbol(), MODE_DIGITS) ;
   pBid = MarketInfo(Symbol(), MODE_BID);
   pAsk = MarketInfo(Symbol(), MODE_ASK);
   sar1=iSAR(NULL, 0, StepParabolic, MaxParabolic, 1);
   sar2=iSAR(NULL, 0, StepParabolic, MaxParabolic, 2);
   spr = pAsk - pBid;
   if (digits > 0) spr = NormalizeDouble(spr, digits); 
   
   if (type==OP_BUY)
   {
     pBid = MarketInfo(Symbol(), MODE_BID);
     if (sar2 < sar1)
     {
        BuyStop = sar1-Interval*myPoint;
        if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
	     BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
        if (os<BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
     }
   }
   if (type==OP_SELL)
   {
     if (sar2 > sar1)
     {
        SellStop = sar1 + Interval * myPoint + spr;
        if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
	     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
        if (os>SellStop || os==0) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
     }
   }
}


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Trade()
  {
   int sign = GetSign();
   if(sign == 1)
      order_type = OP_BUY;
   else
      if(sign == -1)
         order_type = OP_SELL;
      else
         return;
   
   if(UseCloseOnOppSign)
     {
      getTickets();
      _numbOrders();
      if((sign == 1 && nSO > 0)  || (sign == -1 && nBO > 0))
        {
         if(!ClosePos(sign == 1  ?  OP_SELL  :  OP_BUY))
            return;
        }
     }
   

   if(MO(order_type, Lot_Size) == -1)
      return;

   timePrev = iTime(_Symbol, Tf, 0);
   if(TP_Mode == Individual  && (SL_money > 0.0 || TP_money > 0.0))
      if(tickValue() > 0.0  &&  tickSize() > 0.0  &&  point() > 0.0)
        {
         double comm = fabs(commission(T));
         if(SL_money > 0.0)
            SL = (SL_money - comm) / (tickValue() * Lot_Size) * (tickSize() / point())/* + 1.0*/;
         else
            SL = 0.0;
         if(TP_money > 0.0)
            TP = (TP_money + comm) / (tickValue() * Lot_Size) * (tickSize() / point())/* + 1.0*/;
         else
            TP = 0.0;
         ModifyByTicket(T);
        }
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
int GetSign()
  {
   
   bool trendUp = false;
   bool trendDn = false;
   if (trendFilterOn)
   {
      trendUp = cdEmasTrendUp.evaluate();
      trendDn = cdEmasTrendDn.evaluate();
   }
   
   bool filter_buy = false;
   bool filter_sell = false;
   if (filter_on) {
      double indi_buy = i_custom_filter(buf_filter_buy, 0);
      double indi_sell = i_custom_filter(buf_filter_sell, 0);
      if (indi_buy != EMPTY_VALUE && indi_buy != 0) { filter_buy = true; }    
      if (indi_sell != EMPTY_VALUE && indi_sell != 0) { filter_sell = true; }    
   }


   if(timePrev == iTime(_Symbol, Tf, 0))
      return(0);
   
   double i_val = 0.0;
   i_val = i_custom(Buy_Buffer_NO,  1);
   if(i_val > 0.0  &&  i_val != EMPTY_VALUE)
   {
      if (filter_on && !filter_buy)
         return(0);
      
      if (trendFilterOn && trendUp)   
         return(1);
      else
         return(0);
   }
   
   i_val = i_custom(Sell_Buffer_NO, 1);
   if(i_val > 0.0  &&  i_val != EMPTY_VALUE)
   {
      if (filter_on && !filter_sell)
         return(0);

      if (trendFilterOn && trendDn)   
         return(-1);
      else
         return(0);
   }
   
   timePrev = iTime(_Symbol, Tf, 0);
   return(0);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double i_custom(int buf, int bar) { return(iCustom(_Symbol, Tf, Custom_Ind_Name, buf, bar)); }

double i_custom_filter(int buf, int bar) { return(iCustom(_Symbol, Tf, Custom_Ind_Name_filter, buf, bar)); }

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void CloseOut()
  {
   if(nO < CloseOutTradesLevel || nBO <= 0 || nSO <= 0)
      return;
   int
   i = 0, j = 0, t_buy = -1, t_sell = -1;
   double
   pf = 0.0, pf_buy = 0.0, pf_sell = 0.0;
   if(CloseOutStyle == BE)
     {
      for(i = 0; i < nT; i++)
        {
         if(!OrderSelect(tickets[ i ], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() != OP_BUY)
            continue;
         pf_buy = (OrderProfit() + OrderCommission() + OrderSwap());
         for(j = 0; j < nT; j++)
           {
            if(! OrderSelect(tickets[ j ], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() != OP_SELL)
               continue;
            pf_sell = (OrderProfit() + OrderCommission() + OrderSwap());
            if(pf == 0 || fabs(pf_buy + pf_sell) < pf)
              {
               pf = fabs(pf_buy + pf_sell);
               t_buy  = tickets[ i ];
               t_sell = tickets[ j ];
              }
           }//for
        }//for
     }
   else
      if(CloseOutStyle == Profit)
        {
         for(i = 0; i < nT; i++)
           {
            if(! OrderSelect(tickets[ i ], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() > 1)
               continue;
            pf = (OrderProfit() + OrderCommission() + OrderSwap());
            if(OrderType() == OP_BUY && (pf_buy == 0.0 || pf > pf_buy))
              {
               pf_buy = pf;
               t_buy = tickets[ i ];
              }
            else
               if(OrderType() == OP_SELL && (pf_sell == 0.0 || pf > pf_sell))
                 {
                  pf_sell = pf;
                  t_sell = tickets[ i ];
                 }
           }
        }
   if(t_buy != -1 && t_sell != -1)
     {
      if(CloseByTicket(t_buy))
        {
         if(CloseByTicket(t_sell))
           {
            if(T_CloseOut != -1)
               T_CloseOut = -1;
           }
         else
            T_CloseOut = t_sell;
         if(!IsTester)
           {
            GVS("T_CloseOut", (double) T_CloseOut);
            GlobalVariablesFlush();
           }
         getTickets();
         _numbOrders();
        }
     }
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Check_SL_TP_basket()
  {
   double curr_result = GetCurrResultBasket();
   if((SL_money != 0.0 && curr_result <= -fabs(SL_money))  || (TP_money > 0.0 && curr_result >= TP_money))
     {
      CloseContinue = true;
      if(ClosePos())
         CloseContinue = false;
      if(!IsTester)
        {
         GVS("CloseContinue", (double) CloseContinue);
         GlobalVariablesFlush();
        }
      getTickets();
      _numbOrders();
     }
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Breakeven_basket()
  {
   if(!IsTester)
      IsProfitBE = (bool)GVG("IsProfitBE");
   if(!IsProfitBE && GetCurrResultBasket() >= Break_Even)
     {
      IsProfitBE = true;
      if(!IsTester)
        {
         GVS("IsProfitBE", (double) IsProfitBE);
         GlobalVariablesFlush();
        }
     }
   else
      if(IsProfitBE)
        {
         double money_lev_be = 0.0, lots_diff = CurrLotsDiffBuySell_basket();
         if(lots_diff > 0.0 && tickValue() > 0.0)
            money_lev_be = tickValue() * lots_diff;
         if(GetCurrResultBasket() <= money_lev_be)
           {
            CloseContinue = true;
            if(ClosePos())
               CloseContinue = false;
            if(!CloseContinue)
              {
               IsProfitBE = false;
               if(!IsTester)
                 {
                  GVS("IsProfitBE", (double) IsProfitBE);
                  GlobalVariablesFlush();
                 }
              }
            if(!IsTester)
              {
               GVS("CloseContinue", (double) CloseContinue);
               GlobalVariablesFlush();
              }
            getTickets();
            _numbOrders();
           }
        }
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Trail_basket()
  {
   if(!IsTester)
      MaxProfitTrail = GVG("MaxProfitTrail");
   double curr_result_basket = GetCurrResultBasket();
   if(MaxProfitTrail <= 0.0 && curr_result_basket >= Trail_TP)
     {
      MaxProfitTrail = curr_result_basket;
      if(!IsTester)
        {
         GVS("MaxProfitTrail", MaxProfitTrail);
         GlobalVariablesFlush();
        }
     }
   else
      if(MaxProfitTrail > 0.0 && curr_result_basket > MaxProfitTrail)
        {
         MaxProfitTrail = curr_result_basket;
         if(!IsTester)
           {
            GVS("MaxProfitTrail", MaxProfitTrail);
            GlobalVariablesFlush();
           }
        }
      else
         if(MaxProfitTrail > 0.0 && curr_result_basket <= MaxProfitTrail - Trail_Step)
           {
            CloseContinue = true;
            if(ClosePos())
               CloseContinue = false;
            if(!CloseContinue)
              {
               MaxProfitTrail = 0.0;
               if(!IsTester)
                 {
                  GVS("MaxProfitTrail", MaxProfitTrail);
                  GlobalVariablesFlush();
                 }
              }
            if(!IsTester)
              {
               GVS("CloseContinue", (double) CloseContinue);
               GlobalVariablesFlush();
              }
            getTickets();
            _numbOrders();
           }
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void Check_SL_TP()
  {
   int
   i = 0;
   color
   c = clrNONE;
   double
   sl = 0.0, tp = 0.0, sl_lev = 0.0, tp_lev = 0.0, comm_and_swap = 0.0, comm_swap_pnt = 0.0;
   for(i = 0; i < nT; i++)
     {
      if(!OrderSelect(tickets[ i ], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() > 1)
         continue;
      comm_and_swap = (OrderCommission() + OrderSwap());
      comm_swap_pnt = 0.0;
      if(comm_and_swap < 0.0  &&  tickValue() > 0.0  &&  tickSize() > 0.0  &&  point() > 0.0)
        {
         comm_swap_pnt = fabs(comm_and_swap) / (tickValue() * OrderLots()) * (tickSize() / point());
         comm_swap_pnt = MathCeil(comm_swap_pnt);
        }
      if(SL_money > 0.0)
         sl = SL_money / (tickValue() * OrderLots()) * (tickSize() / point()) - comm_swap_pnt;
      else
         sl = 0.0;
      if(TP_money > 0.0)
         tp = TP_money / (tickValue() * OrderLots()) * (tickSize() / point()) + comm_swap_pnt;
      else
         tp = 0.0;
      if(OrderType() == OP_BUY)
        {
         if(OrderStopLoss() > 0.0 && OrderStopLoss() >= OrderOpenPrice())
            sl_lev = OrderStopLoss();
         else
            sl_lev = sl > 0.0 ? OrderOpenPrice() - sl * Pnt : 0.0;
         tp_lev = tp > 0.0 ? OrderOpenPrice() + tp * Pnt : 0.0;
         if((tp_lev > 0.0 && tp_lev - Bid < _stopLevel())  || (sl_lev > 0.0 && Bid - sl_lev < _stopLevel()))
            continue;
         c = clrBlue;
        }
      else
         if(OrderType() == OP_SELL)
           {
            if(OrderStopLoss() > 0.0 && OrderStopLoss() <= OrderOpenPrice())
               sl_lev = OrderStopLoss();
            else
               sl_lev = sl > 0.0 ? OrderOpenPrice() + sl * Pnt : 0.0;
            tp_lev = tp > 0.0 ? OrderOpenPrice() - tp * Pnt : 0.0;
            if((tp_lev > 0.0 && Ask - tp_lev < _stopLevel())  || (sl_lev > 0.0 && sl_lev - Ask < _stopLevel()))
               continue;
            c = clrRed;
           }
      if(fabs(sl_lev - OrderStopLoss()) >= Pnt  ||  fabs(tp_lev - OrderTakeProfit()) >= Pnt)
        {
         F_ord_mod(sl_lev, tp_lev, -1.0, c);
        }
     }
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
int getTickets()
  {
   int
   j = 0, n = 0, pos = 0;
   ArrayResize(tickets, 1, 10);
   ArrayInitialize(tickets, -1);
   for(pos = OrdersTotal() - 1; pos >= 0; pos--)
     {
      for(j = 0; j < 10; j++)
        {
         if(OrderSelect(pos, SELECT_BY_POS))
            break;/*=>*/if(j < 9)
            Sleep(100);
        }/*for =>*/if(j == 10)
         continue;
      if(OrderSymbol() != _Symbol || OrderMagicNumber() != Magic)
         continue;
      ArrayResize(tickets, n + 1, 10);
      tickets[n] = OrderTicket();
      n++;
     }//for
   nT = n;
   return(n);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void _numbOrders(int i = 0)
  {
   nBO = 0;
   nSO = 0;
   nBS = 0;
   nSS = 0;
   nBL = 0;
   nSL = 0;
   nO = 0;
   nS = 0;
   nL = 0;
   int
   j = 0, pos = 0;
   nT = getTickets();
   for(pos = 0; pos < nT; pos++)
     {
      for(j = 0; j < 10; j++)
        {
         if(OrderSelect(tickets[pos], SELECT_BY_TICKET))
            break;/*=>*/if(j < 9)
            Sleep(100);
        }/*for =>*/if(j == 10)
         continue;
      if(OrderCloseTime() != 0)
         continue;
      switch(OrderType())
        {
         case 0:
            nBO++;
            break;
         case 1:
            nSO++;
            break;
         case 2:
            nBL++;
            break;
         case 3:
            nSL++;
            break;
         case 4:
            nBS++;
            break;
         case 5:
            nSS++;
            break;
        }/*switch*/
     }//for
   nO = nBO + nSO;
   nS = nBS + nSS;
   nL = nBL + nSL;
   if(i == 0)
      return;
   else
      if(i == 1)
        {
         _nBO = nBO;
         _nSO = nSO;
         _nBS = nBS;
         _nSS = nSS;
         _nBL = nBL;
         _nSL = nSL;
         _nO = nO;
         _nS = nS;
         _nL = nL;
        }
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double GetCurrResultBasket()
  {
   double curr_profit_basket = 0.0;
   for(int i = 0; i < nT; i++)
     {
      if(! OrderSelect(tickets[ i ], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() > 1)
         continue;
      curr_profit_basket += (OrderProfit() + OrderCommission() + OrderSwap());
     }
   return(curr_profit_basket);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double CurrLotsDiffBuySell_basket()
  {
   double curr_lots_buy = 0.0, curr_lots_sell = 0.0;
   for(int i = 0; i < nT; i++)
     {
      if(! OrderSelect(tickets[ i ], SELECT_BY_TICKET) || OrderCloseTime() > 0)
         continue;
      if(OrderType() == OP_BUY)
         curr_lots_buy  += OrderLots();
      else
         if(OrderType() == OP_SELL)
            curr_lots_sell += OrderLots();
     }
   return(fabs(curr_lots_buy - curr_lots_sell));
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double op(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderOpenPrice());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cp(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderClosePrice());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double lot(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderLots());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double sl(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderStopLoss());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double tp(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderTakeProfit());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double profit(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderProfit());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double swap(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderSwap());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double commission(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderCommission());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double result(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderProfit() + OrderSwap() + OrderCommission());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int type(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderType());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int id(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return(OrderMagicNumber());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ot(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return((int)OrderOpenTime());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ct(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(0.0); else return((int)OrderCloseTime());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string comm(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(""); else return(OrderComment());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string symb(int t = -1) {if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))return(""); else return(OrderSymbol());}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool Trail(int type_ord = -1)
  {
//xxxxx
   bool _ans = true;
   for(int pos = 0; pos < nT; pos++)
     {
      if(!OrderSelect(tickets[ pos ], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() > 1)
         continue;
      if(type_ord > -1 && type_ord != OrderType())
         continue;
      if(!trailByTicket())
        {
         if(_ans)
            _ans = false;
        }
     }//for
//xxxxx
   return(_ans);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool trailByTicket(int t = -1)
  {
   if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))
      return(false);
//xxxxx
   double sl_lev = 0.0, profit = 0.0, trail_step_pnt = 0.0;
   color c = clrNONE;
   profit = (profit() + commission() + swap());
   if(profit < Trail_TP)
      return(true);
   if(tickValue() > 0.0  &&  tickSize() > 0.0  &&  point() > 0.0)
     {
      trail_step_pnt = Trail_Step / (tickValue() * OrderLots()) * (tickSize() / point());
      trail_step_pnt = MathCeil(trail_step_pnt);
     }
   else
      return(false);
//xxxxx
   if(OrderType() == OP_BUY)
     {
      if(sl() != 0.0 && ND(Bid - sl()) <= trail_step_pnt * Pnt)
         return(true);
      sl_lev = Bid - trail_step_pnt * Pnt;
      if(ND(Bid - sl_lev) < StopLevel)
         return(false);
      c = clrBlue;
     }
//xxxxx
   else
      if(OrderType() == OP_SELL)
        {
         if(sl() != 0.0 && ND(sl() - Ask) <= trail_step_pnt * Pnt)
            return(true);
         sl_lev = Ask + trail_step_pnt * Pnt;
         if(ND(sl_lev - Ask) < StopLevel)
            return(false);
         c = clrRed;
        }
//xxxxx
   return(F_ord_mod(sl_lev, -1.0, -1.0, c));
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool Breakeven(int type_ord = -1)
  {
//xxxxx
   bool _ans = true;
   for(int pos = 0; pos < nT; pos++)
     {
      if(!OrderSelect(tickets[ pos ], SELECT_BY_TICKET) || OrderCloseTime() > 0 || OrderType() > 1)
         continue;
      if(type_ord > -1 && type_ord != OrderType())
         continue;
      if(!beByTicket())
        {
         if(_ans)
            _ans = false;
        }
     }//for
//xxxxx
   return(_ans);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool beByTicket(int t = -1)
  {
   if(t != -1 && !OrderSelect(t, SELECT_BY_TICKET))
      return(false);
//xxxxx
   double sl_lev = 0.0, comm_and_swap = 0.0, comm_swap_pnt = 0.0, profit = 0.0;
   color c = clrNONE;
   comm_and_swap = (commission() + swap());
   profit = (profit() + comm_and_swap);
   if(profit < Break_Even)
      return(true);
   if(comm_and_swap < 0.0  &&  tickValue() > 0.0  &&  tickSize() > 0.0  &&  point() > 0.0)
     {
      comm_swap_pnt = fabs(comm_and_swap) / (tickValue() * OrderLots()) * (tickSize() / point());
      comm_swap_pnt = MathCeil(comm_swap_pnt);
     }
//xxxxx
   if(OrderType() == OP_BUY)
     {
      sl_lev = op() + comm_swap_pnt * Pnt;
      if(sl() != 0.0 && ND(sl() - sl_lev) >= 0.0)
         return(true);
      if(ND(Bid - sl_lev) < StopLevel)
         return(false);
      c = clrBlue;
     }
//xxxxx
   else
      if(OrderType() == OP_SELL)
        {
         sl_lev = op() - comm_swap_pnt * Pnt;
         if(sl() != 0.0 && ND(sl_lev - sl()) >= 0.0)
            return(true);
         if(ND(sl_lev - Ask) < StopLevel)
            return(false);
         c = clrRed;
        }
//xxxxx
   return(F_ord_mod(sl_lev, -1.0, -1.0, c));
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool F_ord_mod(double sl_lev = -1.0, double tp_lev = -1.0, double op_lev = -1.0, color c = clrNONE)
  {
   if(sl_lev == -1.0)
      sl_lev = sl();
   if(tp_lev == -1.0)
      tp_lev = tp();
   if(op_lev == -1.0)
      op_lev = op();
   if(ND(sl_lev - sl()) == 0.0 && ND(tp_lev - tp()) == 0.0 && ND(op_lev - op()) == 0.0)
      return(true);
//xxxxx
   int i = 0;
   bool ans = false;
   while(!ans && i < 5)
     {
      ans = OrderModify(OrderTicket(), NT(op_lev), NT(sl_lev), NT(tp_lev), NULL, c);
      if(!ans)
        {
         if(!Errors(GetLastError()))
            break;
        }
      i++;
     }//while
//xxxxx
   return(ans);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
int numberOfPositions(int dir, string sym)
  {
   int countPos = 0;
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      bool s = OrderSelect(pos, SELECT_BY_POS, MODE_TRADES);
      if((OrderSymbol() == sym || sym == "") && OrderMagicNumber() == (int)Magic && Magic > 0)
        {
         if(OrderType() == OP_BUY)
            if(dir == 1 || dir == 0)
               countPos++;
         if(OrderType() == OP_SELL)
            if(dir == 2 || dir == 0)
               countPos++;
        }
     }
   return countPos;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MO(int type, double lot, string comment = "") // market order
  {
   double price;
   color c;
   int i = 0;
   T = -1;
   if(numberOfPositions(0, Symbol()) >= maxPos && maxPos > 0)
      return(T);
   RefreshRates();
   if(type == OP_BUY)
     {
     if(numberOfPositions(1, Symbol()) >= maxBuyPos && maxBuyPos > 0)
      return(T);
      c = clrBlue;
      price = Ask;
     }
   else
      if(type == OP_SELL)
        {
        if(numberOfPositions(2, Symbol()) >= maxSellPos && maxSellPos > 0)
      return(T);
         c = clrRed;
         price = Bid;
        }
      else
         return(T);
   if(AccountFreeMarginCheck(Symbol(), type, NL(lot)) <= 0.0 || GetLastError() == 134)
     {
      if(!FreeMarginAlert)
        {
         Alert("Not enough money to send the order. Free Margin = ", DoubleToStr(AccountFreeMargin(), 2));
         FreeMarginAlert = true;
        }
      return(T);
     }
   FreeMarginAlert = false;
   if(MartingaleON)
     {
      double lm = martingale.Lot();
      if(lm > 0)
        {
         lot = lm;
        }
     }
   while(T < 0 && i < 5)
     {
      T = OrderSend(Symbol(), type, NL(lot), NT(price), 2 * (int)MarketInfo(Symbol(), MODE_SPREAD), NULL, NULL, comment, Magic, NULL, c);
      if(T < 0)
        {
         if(!Errors(GetLastError()))
            return(T);
        }
      i++;
     } /*while*/ return(T);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool ModifyByTicket(int ticket, int slType = 0, int tpType = 0)
  {
   if(SL == 0.0 && TP == 0.0)
      return(true);
   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return(false);
   double sl = 0.0, tp = 0.0, _sl = OrderStopLoss(), _tp = OrderTakeProfit(), op = OrderOpenPrice();
   int i = 0;
   color c = clrNONE;
   RefreshRates();
   if(OrderType() == OP_BUY)
     {
      if(TP > 0.0)
        {
         if(tpType == 0)
            tp = op + fmax(TP * Pnt, StopLevel);
         else
            if(tpType == 1)
               tp = TP;
         if(ND(tp - Bid) < StopLevel)
            tp = Bid + 1.5 * StopLevel;
        }
      if(SL > 0.0)
        {
         if(slType == 0)
            sl = op - fmax(SL * Pnt, StopLevel);
         else
            if(slType == 1)
               sl = SL;
         if(ND(Bid - sl) < StopLevel)
            sl = Bid - 1.5 * StopLevel;
        }
      c = clrBlue;
     }
   else
      if(OrderType() == OP_SELL)
        {
         if(TP > 0.0)
           {
            if(tpType == 0)
               tp = op - fmax(TP * Pnt, StopLevel);
            else
               if(tpType == 1)
                  tp = TP;
            if(ND(Ask - tp) < StopLevel)
               tp = Ask - 1.5 * StopLevel;
           }
         if(SL > 0.0)
           {
            if(slType == 0)
               sl = op + fmax(SL * Pnt, StopLevel);
            else
               if(slType == 1)
                  sl = SL;
            if(ND(sl - Ask) < StopLevel)
               sl = Ask + 1.5 * StopLevel;
           }
         c = clrRed;
        }
   if(ND(sl - _sl) == 0.0 && ND(tp - _tp) == 0.0)
      return(true);
   i = 0;
   Ans = false;
   while(!Ans && i < 5)
     {
      Ans = OrderModify(ticket, NT(op), NT(sl), NT(tp), 0, c);
      if(!Ans)
        {
         if(!Errors(GetLastError()))
            break;
        }
      i++;
     } /*while*/ return(Ans);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool ClosePos(int type = -1)
  {
   double price;
   int i;
   color c;
   _Ans = true;
   for(int pos = OrdersTotal() - 1; pos >= 0; pos--)
     {
      if(!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) || OrderSymbol() != Symbol() || OrderMagicNumber() != Magic)
         continue;
      if(OrderType() > 1 || (type >= 0 && type != OrderType()))
         continue;
      RefreshRates();
      i = 0;
      Ans = false;
      while(!Ans && i < 5)
        {
         if(OrderType() == OP_BUY)
           {
            price = Bid;
            c = clrBlue;
           }
         else
           {
            price = Ask;
            c = clrRed;
           }
         Ans = OrderClose(OrderTicket(), OrderLots(), NT(price), 2 * (int)MarketInfo(Symbol(), MODE_SPREAD), c);
         if(!Ans)
           {
            if(!Errors(GetLastError()))
               break;
           }
         i++;
        } /*while*/ if(!Ans)
         _Ans = false;
     } /*for*/ return(_Ans);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool CloseByTicket(int ticket, double lot = 0.0)
  {
   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return(false);
   if(OrderCloseTime() > 0)
      return(true);
   if(lot <= 0.0)
      lot = OrderLots();
   double price;
   int i;
   color c;
   RefreshRates();
   i = 0;
   Ans = false;
   while(!Ans && i < 5)
     {
      if(OrderType() == OP_BUY)
        {
         price = Bid;
         c = clrBlue;
        }
      else
        {
         price = Ask;
         c = clrRed;
        }
      Ans = OrderClose(OrderTicket(), NL(lot), NT(price), 2 * (int)MarketInfo(Symbol(), MODE_SPREAD), c);
      if(!Ans)
        {
         if(!Errors(GetLastError()))
            break;
        }
      i++;
     } /*while*/ return(Ans);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool HistoryCheck(int n = 10, int sleep = 1000)
  {
   int i = 0;
   while(i < n)
     {
      if(TimeCurrent() - iTime(NULL, Tf, 0) < PeriodSeconds(Tf))
        {
         break;
        }
      Comment("Loading history of quotes ...");
      Sleep(sleep);
      i++;
     }//while
   if(i == n) { /*Comment("Update failed. Go to the next attempt.");*/Comment(""); return(false); }
   Comment("");
   return(true);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void GetMarketInfo()
  {
   TickSize = tickSize();
   TickValue = tickValue();
   Spread = _spread();
   StopLevel = _stopLevel();
   MinLot = minLot();
   MaxLot = maxLot();
   LotStep = lotStep();
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double tickSize(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_TICKSIZE));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double tickValue(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_TICKVALUE));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double spread(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_SPREAD));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _spread(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_SPREAD) * point());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double stopLevel(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_STOPLEVEL));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _stopLevel(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_STOPLEVEL) * point());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double freezeLevel(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_FREEZELEVEL));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double _freezeLevel(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_FREEZELEVEL) * point());}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double minLot(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_MINLOT));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double maxLot(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_MAXLOT));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double lotStep(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_LOTSTEP));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double bid(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_BID));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ask(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_ASK));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double point(string symb = "") {if(symb == "")symb = Symbol(); return(MarketInfo(symb, MODE_POINT));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int digits(string symb = "") {if(symb == "")symb = Symbol(); return((int)MarketInfo(symb, MODE_DIGITS));}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double NL(double L)
  {
   return(MathRound(MathMin(MathMax(L, MinLot), MaxLot) / LotStep) * LotStep);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double ND(double A, int digits = 0)
  {
   if(digits <= 0)
      digits = Digits();
   return(NormalizeDouble(A, digits));
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
double NT(double A, int direction = 0)
  {
   double _A = MathRound(A / TickSize) * TickSize;
   if(direction == 1)
     {
      if(ND(A - _A) > 0.0)
         _A += TickSize;
     }
   else
      if(direction == -1)
        {
         if(ND(A - _A) < 0.0)
            _A -= TickSize;
        }
   return(_A);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
datetime GVS(string name, double value) {return(GlobalVariableSet(name + Name(), value));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GVZ(string name) {return(GlobalVariableSet(name + Name(), 0.0));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GVG(string name) {return(GlobalVariableGet(name + Name()));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GVD(string name) {return((bool)GlobalVariableDel(name + Name()));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GVC(string name) {return(GlobalVariableCheck(name + Name()));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Name() {if(IsTester)return("_" + IntegerToString(Magic) + "_" + Symbol() + "_" + "Tester"); else return("_" + IntegerToString(Magic) + "_" + Symbol());}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
bool Errors(int Error)
  {
   if(Error == 0)
      return(false); // No error
   switch(Error)
     {
      // Crucial errors:
      case 4: // Trade server is busy
         Sleep(3000);
         RefreshRates();
         return(true); // Avoidable error
      case 129: // Wrong price
      case 135: // Price changed
         RefreshRates(); // Refresh data
         return(true); // Avoidable error
      case 136: // No prices. Waiting for a new tick.
         while(!RefreshRates())
            Sleep(1);
         return(true); // Avoidable error
      case 137: // Broker is busy
         Sleep(3000);
         RefreshRates();
         return(true); // Avoidable error
      case 146: // Trading subsystem is busy
         Sleep(500);
         RefreshRates();
         return(true); // Avoidable error
      // Fatal error:
      case 2 :  // Generic error
      case 5 :  // The old version of the client terminal
      case 64:  // Account blocked
      case 133: // Trading is prohibited
         Alert("A fatal error - expert stopped!");
         FatalError = true;
         return(false); // Fatal error
      default:  // Other variants
         return(false);
     } /*switch*/
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void TSL_info()
  {
   if(!IsTester)
      MaxProfitTrail = GVG("MaxProfitTrail");
   if(MaxProfitTrail > 0.0)
     {
      drawLbl("TSL_lev", "TSL LEVEL : " + DoubleToString(MaxProfitTrail - Trail_Step, 2) + " " + AccountCurrency(),
              CORNER_LEFT_UPPER, 20, 20, 12, "Tahoma", clrGold);
     }
   else
      if(MaxProfitTrail <= 0.0)
        {
         if(ObjectFind(0, "TSL_lev") >= 0)
            ObjectDelete(0, "TSL_lev");
        }
   ChartRedraw();
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
void drawLbl(string name, string s, ENUM_BASE_CORNER corner, int DX, int DY, int FSize, string Font, color c, bool bg = false)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
     }
   ObjectSetInteger(0, name, OBJPROP_CORNER,     corner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  DX);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  DY);
   ObjectSetInteger(0, name, OBJPROP_BACK,       bg);
   ObjectSetString(0, name, OBJPROP_TEXT,       s);
   ObjectSetString(0, name, OBJPROP_FONT,       Font);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE,   FSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      c);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,     true);
  }
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//
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
