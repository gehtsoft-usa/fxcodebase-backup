// More information about this indicator can be found at:
// http://fxcodebase.com/ 

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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


datetime   NewCandleTimeCurrent;

 extern string  s1 =  " === Setting  Moving Average gadis SMA Indicator  === "; //  Setting Indicator
input int inpPeriod = 3;                        // Moving Average Period
input ENUM_APPLIED_PRICE inpPrice = PRICE_CLOSE; //Moving Average ApplyTo/Price  
input ENUM_MA_METHOD inpMethod = MODE_SMA;       //Moving Average Method

// Due to repainting Added this value 

extern  string  s2  = " ===  Setting Candle Index Detection === ";  //  Setting Candle 
  int intial_index_point  =  0; // Current Index Point Candle
  int  previous_index_point =1 ;// Previous Index Point Candle
extern  int  MAGIC_NUMBER    = 12369;  //   Magic Number
extern  double lot_size  = 0.01;   //  Lot Size

extern   string s3   =  " ===  Setting Martingle === "; //  Martingle
extern  bool martingle_true  =  false ;  //  Martingle Enable/ Disable
extern  double  lot_multiplier =  2; // Lot Multiplier
extern int maximum_level_order  = 6; // Maximum Level  Lot Multiplier

extern  string  s4  =   " === Trade  Execution  ====";  //  Setting  Trading Execution 
extern  bool trade_excecution   = true; // Trade Execution 
extern bool alert_notification  = true ; // Alert 

double   initial_account_balanace   =  0  ; 
double   previous_account_balance   = 0; 
double   account_balanace_mapping   = 0 ;
double  initial_lot   =   lot_size;
double  previous_amount =   0;
int count_level =  0;



string  upcommingsignal    =  "WAITING";

//  Certain  Profit  Close  All  Trade 
//  Money Management

extern bool   percentage_profit_lock  =  false ;  // Enable Percentage Profit  Lock


extern double   balance_profit  =   1 ;  //  Percentage Profit to close all trade



int index    = 0 ; 
extern   bool   useTrailling   =  false;  //TRAILLING ACTIVE
extern  double when_to_trail_l4      =   20 ;  // ACTIVE WHEN ONSIDE X PIPS
extern  double where_to_trail_l4   =   10 ;  //  TRAIL EVEN PLUS X PIPS

extern    bool   useBreakEven    =  false   ; //STOP LOSS TO BREAKEVEN ACTIVE
extern   double  when_to_trail_l1   =    7      ;//  ACTIVE WHEN ONSIDE X PIPS
extern  double    where_to_trail_l1  =     1;//  BREAK EVEN PLUS X PIPS
int OnInit()
  {

       initial_account_balanace   = AccountBalance();
     previous_account_balance  =AccountBalance();
    account_balanace_mapping   = AccountBalance();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---


   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int start ()
  {

     if(  percentage_profit_lock   == true){

      fx_balance_profit();

     }

 
 double custom_indicator_zero_index   =   iCustom(NULL, PERIOD_CURRENT, "gadis SMA", inpPeriod, inpPrice,inpMethod,2, intial_index_point);
 double custom_indicator_first_index   =   iCustom(NULL, PERIOD_CURRENT, "gadis SMA", inpPeriod, inpPrice,inpMethod,2, previous_index_point);
double custom_indicator_zero_index_gadis   =   iCustom(NULL, PERIOD_CURRENT, "gadis SMA", inpPeriod, inpPrice,inpMethod,1, intial_index_point);
double custom_indicator_first_index_gadis   =   iCustom(NULL, PERIOD_CURRENT, "gadis SMA", inpPeriod, inpPrice,inpMethod,1, previous_index_point);

 Comment (   custom_indicator_zero_index  ,   "custom_indicator_zero_index 1"  , custom_indicator_first_index , "custom_indicator_zero_index 2"   );
  


if  (                         custom_indicator_first_index == 2147483647.0  &&   (upcommingsignal    ==  "WAITING" )  ){

  upcommingsignal    =    "BUY";
}



if  (                         custom_indicator_first_index == 2147483647.0  &&   (   upcommingsignal   ==  "SELL")  ){

  upcommingsignal    =    "BUY";
       if  (  alert_notification   == true ){

      Alert ( "=== Red to Green ===");
      SendNotification ("=== Red to Green ===");

       }
       if  (  trade_excecution   == true ){

      fx_close_mode(  true ,  1);
     fx_take_trade_order(  0 );


       }
}



if  (     custom_indicator_first_index   ==  custom_indicator_first_index_gadis  &&  (upcommingsignal    == "WAITING") ){
  upcommingsignal   =  "SELL";

}


if  (     custom_indicator_first_index   ==  custom_indicator_first_index_gadis  &&  ( upcommingsignal   =="BUY") ){
  upcommingsignal   =  "SELL";

 if ( alert_notification   ==  true ){


  Alert ( "=== Green to Red ===" );
  SendNotification ( "=== Green to Red ===");
    

  }
  if (   trade_excecution   ==  true  ){

  fx_close_mode(true ,  0);
  fx_take_trade_order(  1 );

  }



}


if(useTrailling   == true)
     {
      fx_trail();
     }



   if(useBreakEven    ==  true)
     {
      fx_trail_breakeven();
      
     }

return  0 ; 
 }


   int  fx_take_trade_order(int order_type  ){
    
bool  response_order  =  OrderSend(Symbol(),order_type,   martingle_true == true   ?  fx_lots_calculation( lot_size)   :  lot_size   ,order_type ==  0  ?  Ask :  Bid,10,  0   ,0  ,"comment",MAGIC_NUMBER,0,clrNONE);

  if ( !response_order) {
    Print(  GetLastError() ,   "GetLastError()========================");
  }
  else   { 
  Print("Testing Of Take Trade");
     
  }




  return 0 ;
}
  

 bool IsNewCandleCurrent()
  {


   if(NewCandleTimeCurrent == iTime(Symbol(), PERIOD_CURRENT, 1))
      return false;
   else
     {
      NewCandleTimeCurrent = iTime(Symbol(), PERIOD_CURRENT, 1);
      return true;
     }





  }



   int  fx_close_mode(bool  type,   int order_type_mapping)
  {

//  if( )

 RefreshRates();
   // Log in the terminal the total of orders, current and past.
   Print(OrdersTotal());
      
   // Start a loop to scan all the orders.
   // The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
   for (int i = (OrdersTotal() - 1); i >= 0; i--)
   {
      // If the order cannot be selected, throw and log an error.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
          {
         Print("ERROR - Unable to select the order - ", GetLastError());
         break;
      } 
      bool res = false;
      int Slippage = 0;
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
 
  if(  order_type_mapping ==  -1 ){

     if (OrderType() == OP_BUY  &&  OrderSymbol()  ==  Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER   )
          {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
      }
     if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber()  ==  MAGIC_NUMBER )
          {
         res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
      }
  }

else 
  {
      if (OrderType() == OP_BUY  &&  OrderSymbol()  ==  Symbol()  && OrderMagicNumber()  ==  MAGIC_NUMBER  && order_type_mapping  ==  0  )
          {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
      }
     if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber()  ==  MAGIC_NUMBER && order_type_mapping   == 1)
          {
         res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
      }
   } 
      
      if (res == false) Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
   }


  

   
   return 0  ;
  }



  double fx_lots_calculation(double lot){

   if(previous_amount <  AccountBalance())
     {
      count_level   =  0;
      previous_amount  = AccountBalance();
    initial_lot  =    lot_size;
    return  initial_lot;
     }

 else   if  (previous_amount   >  AccountBalance() + AccountProfit()  ||(  AccountEquity() !=00  &&  previous_amount >  AccountEquity())){

  
     if ( count_level <= maximum_level_order )
{
     count_level   =  count_level   +  1; 
    initial_lot   =   initial_lot* lot_multiplier   ;
      return  initial_lot;
      }

      else  {
         count_level =  0; 
         initial_lot  =    lot_size;
    return  initial_lot;

      }

   }
   else  {
    count_level   =  0;
    previous_amount  = AccountBalance();
    initial_lot  =    lot_size;
    return  initial_lot;

   }


  return 0;
}



  int  fx_balance_profit( ){

    
   if (OrdersTotal() == 0 ){
   }


    double floating_profit  = 0 ;
    int total_orders =   OrdersTotal() ;
    double calculation_profit  = balance_profit;
    for (   int   fx   = 0    ;  fx   <   OrdersTotal()  ;  fx++){
      
         if(OrderSelect(fx, SELECT_BY_POS) == true )
           {
             floating_profit  =    floating_profit + OrderProfit()  +  OrderSwap()  +  OrderCommission()   ;  
              if  ( fx ==   total_orders -1){
                if  (  floating_profit + AccountBalance() > AccountBalance() +   ((AccountBalance()*calculation_profit)/100)){
                  fx_close_mode( true   , -1);

                }

              }

           }
    }



    return  0 ; 
    
  }





  int  fx_trail_breakeven()
  {

   for(int b = OrdersTotal() -1  ;  b>=  0   ;   b--)
     {

      if(OrderSelect(b,  SELECT_BY_POS))
        {

         if(OrderType()   ==  0   &&  OrderSymbol()    == Symbol())
           {
            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;




            if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l1 *fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               //   {
               double   local_strage  =   OrderOpenPrice()  +  where_to_trail_l1* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss()   <   OrderOpenPrice()  && ask_price  >OrderOpenPrice())
                 {



                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());

                 }

              }


           }


         if(OrderType()  ==  1   &&   OrderSymbol()    == Symbol())
           {
            double  ask_price  = fx_asker(OrderSymbol());
            double   bid_price    =    fx_bidder(OrderSymbol()) ;
            if(OrderOpenPrice() - ask_price  >  when_to_trail_l1 * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {

               double  local_strage   =   OrderOpenPrice()  - where_to_trail_l1   * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
               if(OrderStopLoss()  > OrderOpenPrice() &&  bid_price  < OrderOpenPrice())
                 {

                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());


                 }

              }

          
           }




        }


     }


   return   0 ;
  }



  int  fx_trail()
  {

   for(int b = OrdersTotal() -1  ;  b>=  0   ;   b--)
     {

      if(OrderSelect(b,  SELECT_BY_POS))
        {


         if(OrderType()   ==  0   &&  OrderSymbol()    == Symbol())
           {
            double   bid_price    =    fx_bidder(OrderSymbol()) ;


            if(bid_price  -  OrderOpenPrice()  >  when_to_trail_l4* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               
               double   local_strage  =   bid_price -  where_to_trail_l4* fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT) ;
               if(OrderStopLoss() <  local_strage)
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }
              }






           }


         if(OrderType()  ==  1  &&  OrderSymbol()    == Symbol())
           {
            double  ask_price  = fx_asker(OrderSymbol());
            if(OrderOpenPrice() - ask_price  >  when_to_trail_l4 * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT))
              {
               double  local_strage   =  ask_price + where_to_trail_l4  * fx_pips_evaluation_2(OrderSymbol()) *  MarketInfo(OrderSymbol(), MODE_POINT);
               if(OrderStopLoss()  >  local_strage)
                 {
                  fx_order_modification(OrderTicket(), OrderOpenPrice(),local_strage,OrderTakeProfit(), 0, "NONE",  OrderMagicNumber());
                 }

              }

           }

        }


     }


   return   0 ;
  }





  int fx_pips_evaluation_2(string  symbol_mapping)
  {
   int digits = (int)MarketInfo(symbol_mapping, MODE_DIGITS);
   if(digits == 2)
     {
      return   100;
     }
   else
      if(digits ==  4  ||  digits == 5)
        {
         return 10;
        }
      else
        {
         return  1;
        }

   return 0;
  }


  double    fx_bidder(string symbol_mapping)
  {


   return  MarketInfo(symbol_mapping, MODE_BID);

   return   0 ;
  }


  double    fx_asker(string symbol_mapping)
  {


   return  MarketInfo(symbol_mapping, MODE_ASK);

   return   0 ;
  }





int   fx_order_modification(int ticket,  double  order_open_price,    double  local_storage_stop_loss,  double   order_take_profit,   int expiration, string additional,   int order_magic_number)
  {
//OrderTicket()  , OrderOpenPrice() ,local_strage ,OrderTakeProfit(), 0 , "NONE" ,  OrderMagicNumber()

// OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-(StopLoss*pips),OrderOpenPrice()+(TakeProfit*pips), 0, CLR_NONE); // OP_BUY
   bool    res   =    OrderModify(ticket,  order_open_price,  local_storage_stop_loss,  order_take_profit,   expiration,CLR_NONE);
   if(!res)
     {
      Alert("Error in OrderModify. Error code=",GetLastError());
     }

   return    0 ;
  }