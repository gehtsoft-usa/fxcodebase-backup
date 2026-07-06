// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71813
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
//|                                                                       https://mario-jemic.com/ |
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
input  string  setting_trail  = "==== Setting Trail ===";
input bool  trailiing  =   false ; // Trailling  Enable / Disable
input  int  WhenToTrail = 10;   // When To Trail  
input int where_to_trail  =  6; // Where to trail
input    bool   useBreakEven    =  false   ; //Stop Loss To Breakeven Active
input   double  when_to_trail_l1   =    7      ;//  Acive When Onside X Pips
input  double    where_to_trail_l1  =     1;//  Break Even Plus X Pips
enum tradePair
  {
   CURRENT_PAIR   =    0,
   ALL_SYMBOL  = 1

  };

input    tradePair  TradePairMethod  =     ALL_SYMBOL   ;

input   int  MAGIC_NUMBER   =   3232982;
input   double   take_profit    = 0 ;   
input   double   stop_loss    = 0 ;
input   double     Lots    =  0.10 ;


double   get_fractal_upper    =     0  ;
double   get_fractal_lower    =     0    ;

double    previous_get_fractal_upper    =  0    ;
double    previous_get_fractal_lower    =    0 ;
input  bool reverse_trade_option  =  false ;   //   Reverse trade Option on Fractal
input  bool reverse_trade  =  false ;  //  Close On Reverse True
string capture_recent_time  =  0 ;
	#include <Trade\Trade.mqh> //Instatiate Trades Execution Library
  #include <Trade\OrderInfo.mqh> //Instatiate Library for Orders Information
  #include <Trade\PositionInfo.mqh> //Instatiate Library for Positions Information
  CTrade         m_trade; // Trades Info and Executions library
  COrderInfo     m_order; //Library for Orders information
  CPositionInfo  m_position; // Library for all position features and information
int OnInit()
  {
//---
   capture_recent_time   =   iTime(Symbol()  , PERIOD_CURRENT ,   1);
//---
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








bool isExistBuying()
  {
   bool  exist_buy   =  false;
   for(int r  =  0   ;   r <   (int)PositionsTotal()   ; r++)
     {
       ulong ticket=PositionGetTicket(r);
         if(PositionSelectByTicket(ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER  && PositionGetInteger(POSITION_TYPE)  ==  0 &&  PositionGetString(POSITION_SYMBOL)  ==  Symbol())
           {
            return    exist_buy    =  true;

           }
        }

     }

   return   false ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  isExistSelling()
  {
   bool  exist_sell   =  false;
         for(int r = PositionsTotal() - 1; r>= 0; r--)
     {
          ulong ticket=PositionGetTicket(r);
         if(PositionSelectByTicket(ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER  && PositionGetInteger(POSITION_TYPE)  ==  1 &&  PositionGetString(POSITION_SYMBOL)   ==  Symbol())
           {
            return    exist_sell    =  true;

           }
        }

     }

   return   false ;
  }
void OnTick()
  {
//---
   double get_fractal_upper[];
   double get_fractal_lower[];
   ArraySetAsSeries(get_fractal_upper,  true);
   ArraySetAsSeries(get_fractal_lower, true);


   double fractal  =  iFractals(Symbol(),PERIOD_CURRENT);



//We fill  the array with price data
   CopyBuffer(fractal,  0,0,100, get_fractal_upper);
   CopyBuffer(fractal,  1,0,100, get_fractal_lower);

  for  (   int    i   =   0     ;     i    <  ArraySize(get_fractal_upper )   ;    i++)  {
      if(get_fractal_upper[i]      !=   EMPTY_VALUE)
        {
         if(get_fractal_upper[i]    !=   previous_get_fractal_upper)
           {
            previous_get_fractal_upper    =  get_fractal_upper[i] ;
            if(isExistBuying()  ==  true  && reverse_trade  ==  true  &&  reverse_trade_option     ==  false )
              {
              fx_close_mode(true,  0);
              }
              if(isExistSelling()  ==  true  && reverse_trade  ==  true  &&  reverse_trade_option     ==  true )
              {
              fx_close_mode(true,  1);
              }
            string  capture_time =    iTime(Symbol()  , PERIOD_CURRENT , i );
            if(StringCompare(capture_recent_time,  capture_time) == -1)
              {
               if(reverse_trade_option   ==  true)
                 {
                  fx_take_trade_order(0) ;
                 }
               if(reverse_trade_option    == false)
                 {
                  fx_take_trade_order(1) ;
                 }  
              }
           }

         break   ;
        }
      if(get_fractal_lower[i] !=   EMPTY_VALUE)
        {
         if(get_fractal_lower[i]    !=     previous_get_fractal_lower)
           {
            previous_get_fractal_lower    =  get_fractal_lower[i]   ;
            if(isExistSelling()   ==  true   &&  reverse_trade   ==true  && reverse_trade_option   ==  false)
              {
               fx_close_mode(true,  1);
              }
              if(isExistBuying()   ==  true   &&  reverse_trade   ==true  && reverse_trade_option   ==  true)
              {
               fx_close_mode(true,  0);
              }
            string   capture_time =    iTime(Symbol() , PERIOD_CURRENT  , i );
            if(StringCompare(capture_recent_time,  capture_time) == -1)
              {
               if(reverse_trade_option     ==   true)
                 {
                  fx_take_trade_order(1);
                 }
               if(reverse_trade_option   ==  false)
                 {
                  fx_take_trade_order(0) ;
                 }
              }
           }
         break ;
        }
  }
if(trailiing == true)
     {
      mql5_adjust_to_trail();
     }

   if(useBreakEven    ==  true)
     {
      fx_trail_breakeven();
     }

  }




  int mql5_adjust_to_trail()
  {
   for(int i=0; i<(int)PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(TradePairMethod  ==   CURRENT_PAIR)
        {
         if(PositionGetString(POSITION_SYMBOL) ==  _Symbol  && (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)  ==  0  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {
            double bid_price  =  fx_bidder(PositionGetString(POSITION_SYMBOL)) ;
            if(bid_price -  PositionGetDouble(POSITION_PRICE_OPEN) >     WhenToTrail*fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {

               double   local_strage  =   bid_price -  where_to_trail* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)   <  local_strage)
                 {
                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE",  PositionGetInteger(POSITION_MAGIC));
                 }
              }

            if(PositionGetDouble(POSITION_SL)  == 0.0)
              {
              }
           }


         if(PositionGetString(POSITION_SYMBOL) ==  _Symbol  && (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)  ==  1  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            if(PositionGetDouble(POSITION_PRICE_OPEN) - ask_price  >  WhenToTrail*fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double  local_strage   =  ask_price +where_to_trail* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)  >  local_strage)
                 {
                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN), local_strage,PositionGetDouble(POSITION_TP), 0, "NONE", PositionGetInteger(POSITION_MAGIC));


                 }

              }

           }


        }

      if(TradePairMethod  ==   ALL_SYMBOL)
        {
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)  ==  0)
           {
            double bid_price  =  fx_bidder(PositionGetString(POSITION_SYMBOL)) ;
            if(bid_price -  PositionGetDouble(POSITION_PRICE_OPEN) >    WhenToTrail*fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {

               double   local_strage  =   bid_price -  where_to_trail* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)   <  local_strage)
                 {



                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE",  PositionGetInteger(POSITION_MAGIC));

                 }

              }

            if(PositionGetDouble(POSITION_SL)  == 0.0)
              {
              }


           }


         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)  ==  1)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            if(PositionGetDouble(POSITION_PRICE_OPEN) - ask_price  > WhenToTrail*fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double  local_strage   =  ask_price +where_to_trail* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)  >  local_strage)
                 {

                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN), local_strage,PositionGetDouble(POSITION_TP), 0, "NONE", PositionGetInteger(POSITION_MAGIC));


                 }

              }

           }




        }


     }
   return 0;
  }
//+------------------------------------------------------------------+


int  fx_trail_breakeven()
  {

   for(int i=0; i<(int)PositionsTotal(); i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(TradePairMethod  ==  CURRENT_PAIR  && PositionGetString(POSITION_SYMBOL)   ==  Symbol())
        {
         if(PositionGetInteger(POSITION_TYPE) ==  0  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            double   bid_price    =    fx_bidder(PositionGetString(POSITION_SYMBOL)) ;




            if(bid_price  -  PositionGetDouble(POSITION_PRICE_OPEN)  >  when_to_trail_l1 *fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double   local_strage  =   PositionGetDouble(POSITION_PRICE_OPEN)  +  where_to_trail_l1* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)   <   PositionGetDouble(POSITION_PRICE_OPEN)  && ask_price  >PositionGetDouble(POSITION_PRICE_OPEN))
                 {



                  fx_order_modification(ticket,  PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE", PositionGetInteger(POSITION_MAGIC));

                 }






              }


           }


         if(PositionGetInteger(POSITION_TYPE) ==  1  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {

            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            double   bid_price    =    fx_bidder(PositionGetString(POSITION_SYMBOL)) ;



            if(PositionGetDouble(POSITION_PRICE_OPEN) - ask_price  >  when_to_trail_l1 * fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double  local_strage   =   PositionGetDouble(POSITION_PRICE_OPEN)  - where_to_trail_l1   * fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT);

               if(PositionGetDouble(POSITION_SL)   > PositionGetDouble(POSITION_PRICE_OPEN) &&  bid_price  < PositionGetDouble(POSITION_PRICE_OPEN))
                 {



                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE",  PositionGetInteger(POSITION_MAGIC));


                 }

              }




           }


        }





      if(TradePairMethod  ==  ALL_SYMBOL)
        {
         if(PositionGetInteger(POSITION_TYPE) ==  0  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            double   bid_price    =    fx_bidder(PositionGetString(POSITION_SYMBOL)) ;
            if(bid_price  -  PositionGetDouble(POSITION_PRICE_OPEN)  >  when_to_trail_l1 *fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {

               double   local_strage  =   PositionGetDouble(POSITION_PRICE_OPEN)  +  where_to_trail_l1* fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT) ;
               if(PositionGetDouble(POSITION_SL)   <   PositionGetDouble(POSITION_PRICE_OPEN)  && ask_price  >PositionGetDouble(POSITION_PRICE_OPEN))
                 {
                  fx_order_modification(ticket,  PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE", PositionGetInteger(POSITION_MAGIC));
                 }

              }


           }


         if(PositionGetInteger(POSITION_TYPE) ==  1  &&  PositionGetInteger(POSITION_MAGIC)   ==  MAGIC_NUMBER)
           {
            double  ask_price  = fx_asker(PositionGetString(POSITION_SYMBOL));
            double   bid_price    =    fx_bidder(PositionGetString(POSITION_SYMBOL)) ;
            if(PositionGetDouble(POSITION_PRICE_OPEN) - ask_price  >  when_to_trail_l1 * fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT))
              {
               double  local_strage   =   PositionGetDouble(POSITION_PRICE_OPEN)  - where_to_trail_l1   * fx_pips_evaluation_2(PositionGetString(POSITION_SYMBOL)) *  SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_POINT);

               if(PositionGetDouble(POSITION_SL)   > PositionGetDouble(POSITION_PRICE_OPEN) &&  bid_price  < PositionGetDouble(POSITION_PRICE_OPEN))
                 {


                  fx_order_modification(ticket, PositionGetDouble(POSITION_PRICE_OPEN),local_strage,PositionGetDouble(POSITION_TP), 0, "NONE",  PositionGetInteger(POSITION_MAGIC));


                 }

              }




           }


        }







     }



   return   0 ;
  }



 int fx_pips_evaluation()
  {
   if(_Digits == 2)
     {
      return   10;
     }
   else
      if(_Digits ==  1)
        {
         return  10 ;
        }
      else
         if(_Digits ==  4  ||  _Digits == 5 ||  _Digits == 3)
           {
            return 10;
           }
         else
           {
            return  1;
           }

   return 0;
  }




  int fx_pips_evaluation_2(string  symbol_mapping)
  {
  int digits = SymbolInfoInteger( (symbol_mapping) , SYMBOL_DIGITS) ;
  if(digits == 2)
  { 
  return   10;
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


   double  fx_asker( string  symbol_mapping){
MqlTick last_tick= {};
   SymbolInfoTick(symbol_mapping,last_tick);
  return   NormalizeDouble(last_tick.ask,SymbolInfoInteger( (symbol_mapping) , SYMBOL_DIGITS));
}


double  fx_bidder( string symbol_mapping){
MqlTick last_tick= {};
   SymbolInfoTick(symbol_mapping,last_tick);
  return   NormalizeDouble(last_tick.bid, SymbolInfoInteger( (symbol_mapping) , SYMBOL_DIGITS));
}


 double  fx_stop_profit_calculation( int order_type  ){
if ( stop_loss   ==  0   ||  stop_loss   ==    0.0)  {
   return   0 ; 
}else {
  if (order_type   == 0){
      return   fx_bidder(_Symbol)  -  fx_pips_evaluation() *  stop_loss* _Point ;
  }
  else  if(  order_type   ==  1){
    return   fx_asker(_Symbol)   +  fx_pips_evaluation() *  stop_loss* _Point;
  }
}
  return 0  ; 
}

   double  fx_take_profit_calculation( int order_type  ){
 if    (  take_profit    ==   0     ||  take_profit   ==  0.0)  {
   return   0  ; 
 }
 else   {
  if (order_type   == 0){
      return    fx_asker(_Symbol) +  fx_pips_evaluation() *  take_profit* _Point;
  }
  else  if(  order_type   ==  1){
    return  fx_bidder(_Symbol) -  fx_pips_evaluation() *  take_profit* _Point;
  }
 }


  return 0  ; 
}




double  fx_order_modification(int ticket,  double  order_open_price, double order_stop_loss,  double  order_take_profit, int expiration,  string color_value,  double  magic_number)
  {
MqlTradeRequest request= {};
request.action=TRADE_ACTION_SLTP;         // setting a pending order
request.magic=magic_number;                  // ORDER_MAGIC
request.position=ticket;
request.symbol=_Symbol;                       // symbol
request.sl=order_stop_loss ;
request.tp=order_take_profit;
MqlTradeResult result= {};
OrderSend(request,result);
   return  0 ;
  }
    int fx_take_trade_order( int  order_type)
  {
MqlTradeRequest request= {};
request.action=TRADE_ACTION_DEAL;         
request.magic=MAGIC_NUMBER;                  
request.symbol=_Symbol;                      
request.volume= Lots;                          
request.sl= NormalizeDouble(fx_stop_profit_calculation(order_type), _Digits);                                
request.tp=NormalizeDouble(fx_take_profit_calculation(order_type), _Digits);                                 
request.type= order_type;                
request.type_filling =ORDER_FILLING_IOC;
MqlTick last_tick= {};
SymbolInfoTick(_Symbol,last_tick);
double price=  NormalizeDouble( order_type   ==  0   ? last_tick.ask :  last_tick.bid , _Digits);
request.price=  price; // open price
request.comment = "d";
MqlTradeResult result= {};
if(OrderSend(request,result))
     {
        
     }
   return   0 ;
  }
  int  fx_close_mode(bool  type, int  order_type_mapping)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--) // loop all Open Positions
     {
      if(m_position.SelectByIndex(i)   &&   PositionGetInteger(POSITION_TYPE)  ==  order_type_mapping  &&  PositionGetString(POSITION_SYMBOL)   ==  Symbol()  && PositionGetInteger(POSITION_MAGIC)   == MAGIC_NUMBER)  // select a position
        {
         m_trade.PositionClose(m_position.Ticket()); // then delete it --period
         Sleep(100); // Relax for 100 ms

        }
     }
   return 0  ;
  }