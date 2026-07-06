// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72070

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
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
#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
#property show_inputs
#include <WinUser32.mqh>
input double lot = 0.01; // lot
input int slippage = 100000000000; // max slippage
datetime tlast;





enum EnableDisable
  {
   Enable = 0,
   Disable = 1
  };

extern    string   initial_lots    =   "Initial Trade TP/SL"    ;

extern  EnableDisable  take_profit_enable     =   Enable  ;    //  Take  Profit    Enable /Disable

extern   double   take_profit   = 10   ;      //   Take Profit

extern  EnableDisable  stop_loss_enable     =   Enable  ;   //  Stop Loss Enable  /Disable
extern  double    stop_loss   =  10   ;   //  Stop Loss




extern string descr   = "*** Modify SELL orders ***";
extern double SLpip   = 0;
extern double TPpip   = 0;
extern double SLprice = 0;
extern double TPprice = 0;

double pips2dbl, pips2point, minDistance,
       slPoints, tpPoints,
       itotal,
       sl, tp;

// script modifies stop loss and take profit
int OnInit()
  {
   tlast = 0;
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   start2();
   if(Time[0] > tlast)
     {
      if(Open[1] < Close[1])
         bool res = OrderSend(_Symbol, OP_BUY, lot, Bid, slippage,fx_stop_profit_calculation(0),fx_take_profit_calculation(0));
      else
         if(Open[1] > Close[1])
            bool res = OrderSend(_Symbol, OP_SELL, lot, Ask, slippage, fx_stop_profit_calculation(1), fx_take_profit_calculation(1));
      tlast = Time[0];
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start2()
  {
   minDistance=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;

   if(Digits == 5 || Digits == 3)     // Adjust for five (5) digit brokers.
     {
      pips2dbl = Point*10;
      pips2point = 10;
     }
   else
     {
      pips2dbl = Point;
      pips2point = 1;
     }

   slPoints=SLpip*pips2dbl;
   tpPoints=TPpip*pips2dbl;

   itotal=OrdersTotal();
   for(int icnt=itotal-1; icnt>=0; icnt--)
     {
      OrderSelect(icnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderType()==OP_SELL)
        {
         RefreshRates();
         sl=0;
         tp=0;
         if(slPoints>0)
            sl=Ask+slPoints;
         else
            if(SLprice>0)
               sl=SLprice;
            else
               sl=OrderStopLoss();

         if(tpPoints>0)
            tp=Ask-tpPoints;
         else
            if(TPprice>0)
               tp=TPprice;
            else
               tp=OrderTakeProfit();

         if(sl-Ask<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && sl>0) // check broker stop levels
           {
            Alert("Stop Loss is too close to market price or on wrong side!!!");
            return(0);
           }

         if(Ask-tp<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && tp>0)
           {
            Alert("Take Profit is too close to market price or on wrong side!!!");
            return(0);
           }

         if(OrderTakeProfit()!=tp || OrderStopLoss()!=sl)
           {
            while(OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,Green)==false)
              {
               if(sl-Ask<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && sl>0) // check broker stop levels
                 {
                  Alert("Stop Loss is too close to market price or on wrong side!!!");
                  return(0);
                 }

               if(Ask-tp<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && tp>0)
                 {
                  Alert("Take Profit is too close to market price or on wrong side!!!");
                  return(0);
                 }
              }
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_take_profit_calculation(int order_type)
  {
   if(take_profit_enable    ==  Enable)
     {
      if(order_type   == 0)
        {
         return   Ask  +  fx_pips_evaluation() *  take_profit* Point;
        }
      else
         if(order_type   ==  1)
           {
            return   Ask   -  fx_pips_evaluation() *  take_profit* Point;
           }

     }




   return 0  ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_stop_profit_calculation(int order_type)
  {
   if(stop_loss_enable     == Enable)
     {
      if(order_type   == 0)
        {
         return   Bid  -  fx_pips_evaluation() *  stop_loss* Point;
        }
      else
         if(order_type   ==  1)
           {
            return   Ask   +  fx_pips_evaluation() *  stop_loss* Point;
           }


     }

   return 0  ;
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation()
  {
   if(Digits() == 2)
     {
      return   100;
      //LotSize =  0.01;
     }
   else
      if(Digits() ==  1)
        {
         return  10 ;
        }
      else
         if(Digits() ==  4  ||  Digits() == 5 ||  Digits() == 3)
           {
            return 10;
           }
         else
           {
            return  1;
           }

   return 0;
  }
//+------------------------------------------------------------------+
