// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71965

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

#property indicator_chart_window
extern  bool  magic  =    false ;  //   MAGIC Enable/ Disable
extern  double  MAGIC_NUMBER   = 1234544;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
string ROW_5[]    =  {"Account: ",  "Equity:",  "MAXDD",  "WINRATE", "Total Lots",  "Total Order", "Total Buy ", "Total Sell",  "Profit", "Loss"    };
string ROW_6[]   =  {"Account:zz ",  "Equity:zz",  "MAXDDzz",  "WINRATEzz", "Total Lotszz",  "Total Orderzz", "Total Buy zz", "Total Sellzz",  "Profitzz", "Losszz"   };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern int XOffset=2;                  //Horizontal offset (pixels)
extern int YOffset=2;                  //Vertical offset (pixels)

double count_total_lots_mapping  = 0 ;
int  count_total_order_mapping= 0 ;
double  count_total_buy_mapping = 0 ;
double  count_total_sell_mapping  = 0;
double  count_account_profit_mapping    =0 ;
double   count_account_loss_mapping   =   0 ;
double   MAX_DEFAULT_DD    =   0 ;
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   fx_object_handling();
   fx_mapping_account_info();
   return(rates_total);
  }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int    fx_object_handling()
  {

   for(int   i  =    0  ;   i  <    ArraySize(ROW_5)   ;  i++)
     {
      int        x_size    =   87  ;
      int    y_size  =     23;
      ObjectCreate(0,"PanelLabel"+  ROW_5[i],OBJ_EDIT,0,0,0);
      ObjectSet("PanelLabel"+  ROW_5[i],OBJPROP_XDISTANCE,XOffset+2  +  85);
      ObjectSet("PanelLabel"+  ROW_5[i],OBJPROP_YDISTANCE,YOffset+2   +   20*i  +   10*i);
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_XSIZE,x_size);
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_YSIZE,y_size);
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_STATE,false);
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_READONLY,true);
      //   ObjectSetString(0,"PanelLabel"+  ROW_5[i],OBJPROP_TOOLTIP,"Drag to Move");
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_ALIGN,ALIGN_CENTER);
      ObjectSetString(0,"PanelLabel"+  ROW_5[i],OBJPROP_TEXT,   i  ==    0  ?    ROW_5[i  ] :   ROW_5[i  ]);
      ObjectSetString(0,"PanelLabel"+  ROW_5[i],OBJPROP_FONT,"Consolas");
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_FONTSIZE,9);
      ObjectSet("PanelLabel"+  ROW_5[i],OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_BGCOLOR,clrWhite);
      ObjectSetInteger(0,"PanelLabel"+  ROW_5[i],OBJPROP_BORDER_COLOR,clrBlack);



     }




   for(int   j  =    0  ;   j  <    ArraySize(ROW_6)   ;  j++)
     {
      int        x_size    =   87  ;
      int    y_size  =     23;
      ObjectCreate(0,"PanelLabelData"+  ROW_6[j],OBJ_EDIT,0,0,0);
      ObjectSet("PanelLabelData"+  ROW_6[j],OBJPROP_XDISTANCE,XOffset+2  +  176);
      ObjectSet("PanelLabelData"+  ROW_6[j],OBJPROP_YDISTANCE,YOffset+2   +   20*j  +   10*j);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_XSIZE,x_size);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_YSIZE,y_size);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_STATE,false);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_READONLY,true);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_ALIGN,ALIGN_CENTER);
      ObjectSetString(0,"PanelLabelData"+  ROW_6[j],OBJPROP_TEXT, (j  ==  0   ?    DoubleToStr(AccountBalance(),  3)   : (j   == 1    ?   DoubleToStr(AccountEquity(), 3)  : (j   ==  2    ?   DoubleToStr(fx_max_dd(),  3)   : (j ==  3 ?   fx_win_rate()   : (j==  4 ? count_total_lots_mapping  : (j ==  5 ?   count_total_order_mapping : (j == 6  ?  count_total_buy_mapping :  j==  7  ?  count_total_sell_mapping : (j  == 8  ?     DoubleToStr(fx_account_equity_profit(),  3)  : DoubleToStr(fx_account_equity_loss(), 3))))))))));
      ObjectSetString(0,"PanelLabelData"+  ROW_6[j],OBJPROP_FONT,"Consolas");
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_FONTSIZE,9);
      ObjectSet("PanelLabelData"+  ROW_6[j],OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_BGCOLOR,clrWhite);
      ObjectSetInteger(0,"PanelLabelData"+  ROW_6[j],OBJPROP_BORDER_COLOR,clrBlack);
     }

   return    0 ;
  }
//+------------------------------------------------------------------+




//   Max Default Condition Goes Here
double  fx_max_dd()
  {
   fx_account_equity();
   if(OrdersTotal() ==  0)
     {
      MAX_DEFAULT_DD =  0;
     }
   double  value_p_l = AccountEquity()-  AccountBalance();
   if(value_p_l <   0)
     {
      if(MAX_DEFAULT_DD  >  value_p_l)
        {
         MAX_DEFAULT_DD   =  value_p_l;
        }
      return  MAX_DEFAULT_DD  ;
     }
   else
     {
      return MAX_DEFAULT_DD;
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fx_win_rate()
  {
   datetime  current_open_time   =  iTime(NULL, PERIOD_D1,  0)  ;
   datetime  previous_open_time   =  iTime(NULL, PERIOD_D1,  1)  ;
   double count_positive_order  = 0 ;
   double count_number_of_trade_per_day   =   0 ;
   for(int  i   =  0   ;  i <  OrdersHistoryTotal()   ;  i++)
     {
      if(OrderSelect(i,  SELECT_BY_POS, MODE_HISTORY)  == true)
        {
         if(magic   == true)
           {
            if(StringCompare(TimeToString(OrderOpenTime(), TIME_DATE),TimeToString(current_open_time, TIME_DATE))   ==   0 && OrderMagicNumber()   ==  MAGIC_NUMBER)
              {
               if(OrderProfit()  >=0)
                 {

                  count_positive_order    =  count_positive_order    +1;
                 }
               count_number_of_trade_per_day++;
              }


            if(OrdersHistoryTotal()-1   ==   i)
              {

               return           count_number_of_trade_per_day   ==  0     ?    0  :   DoubleToStr((((double)count_positive_order/ count_number_of_trade_per_day)*100),3);
              }

           }
         if(magic   == false)
           {

            if(StringCompare(TimeToString(OrderOpenTime(), TIME_DATE),TimeToString(current_open_time, TIME_DATE))   ==   0)
              {
               if(OrderProfit()  >=0)
                 {
                  count_positive_order    =  count_positive_order    +1;
                 }
               count_number_of_trade_per_day++;
              }
            if(OrdersHistoryTotal()-1   ==   i)
              {
               return   count_number_of_trade_per_day   ==   0    ?   0    :  DoubleToStr((((double)count_positive_order/ count_number_of_trade_per_day)*100),3);
              }
           }
        }
     }
   return  0 ;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_account_equity()
  {
   double  count_account_equity   = 0  ;
   double count_account_profit   =    0;
   double  count_account_loss   =  0 ;
   for(int  i  = 0    ;  i <   OrdersTotal()  ;  i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(magic   == true)
           {
            if(MAGIC_NUMBER  == OrderMagicNumber())
              {
               count_account_equity    =   count_account_equity  +   AccountProfit()  ;
               if(AccountProfit()    >    0)
                 {
                  count_account_profit   = count_account_profit   +    AccountProfit();
                 }
               else
                  if(AccountProfit()  < 0)
                    {
                     count_account_loss    =   count_account_loss    +  AccountProfit()  ;
                    }
              }
            if(OrdersTotal()  -1    == i)
              {
               count_account_profit_mapping     = 0 ;
               count_account_loss_mapping  = 0 ;
               count_account_profit_mapping     =  count_account_profit;
               count_account_loss_mapping  =   count_account_loss  ;
               return   count_account_equity;
              }
           }

         if(magic  == false)
           {
            count_account_equity    =   count_account_equity  +   AccountProfit()  ;
            if(AccountProfit()    >    0)
              {
               count_account_profit   = count_account_profit   +    AccountProfit();
              }
            else
               if(AccountProfit()  < 0)
                 {
                  count_account_loss    =   count_account_loss    +  AccountProfit()  ;
                 }
           }
         if(OrdersTotal()  -1    == i)
           {
            count_account_profit_mapping   =  count_account_profit;
            count_account_loss_mapping    =  count_account_loss;
            return   count_account_equity;
           }
        }
     }
   if(OrdersTotal()  ==  0)
     {
      count_account_profit_mapping  = 0;
      count_account_loss_mapping    = 0;
      return count_account_equity;
     }
   return  0 ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_account_equity_profit()
  {
   double count_account_profit   =    0;
   for(int  i  = 0    ;  i <   OrdersTotal()  ;  i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {

         if(magic   == true)
           {

            if(MAGIC_NUMBER  == OrderMagicNumber())
              {

               if(OrderProfit()    >    0)
                 {
                  count_account_profit   = count_account_profit   +    OrderProfit();
                 }

              }
            if(OrdersTotal()  -1    == i)
              {
               return  count_account_profit;

              }


           }

         if(magic  == false)
           {
            if(OrderProfit()    >    0)
              {
               count_account_profit   = count_account_profit   +    OrderProfit();
              }

           }
         if(OrdersTotal()  -1    == i)
           {
            return  count_account_profit;
           }
        }



     }

   return  0 ;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  fx_account_equity_loss()
  {
   double  count_account_equity   = 0  ;
   double count_account_profit   =    0;
   double  count_account_loss   =  0 ;
   for(int  i  = 0    ;  i <   OrdersTotal()  ;  i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {

         if(magic   == true)
           {

            if(MAGIC_NUMBER  == OrderMagicNumber())
              {
               if(OrderProfit()  < 0)
                 {
                  count_account_loss    =   count_account_loss    +  OrderProfit()  ;
                 }
              }
            if(OrdersTotal()  -1    == i)
              {
               return   count_account_loss  ;
              }
           }

         if(magic  == false)
           {

            if(OrderProfit()  < 0)
              {
               count_account_loss    =   count_account_loss    +  OrderProfit()  ;
              }
           }
         if(OrdersTotal()  -1    == i)
           {
            return  count_account_loss;
           }
        }



     }

   return  0 ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int   fx_mapping_account_info()
  {

   double  count_balance  = 0  ;
   double  count_equity   =  0  ;
   double count_total_lots  = 0 ;
   int  count_total_order= 0 ;
   double  count_total_buy = 0 ;
   double  count_total_sell  = 0;
   double  count_total_profit  =   0 ;  
   double  count_total_loss  = 0 ;  
   if(magic   == true)
     {
      for(int i  =0  ; i <   OrdersTotal()  ;  i++)
        {
         if(OrderSelect(i, SELECT_BY_POS))
           {
            if(OrderMagicNumber()   ==   MAGIC_NUMBER)
              {
               count_total_lots   = count_total_lots  +  OrderLots();
               count_total_order   = count_total_order   +  1;
              }
            if(OrderType()   == OP_BUY  &&  OrderMagicNumber()   ==   MAGIC_NUMBER)
              {
               count_total_buy  =  count_total_buy  +  1;
              }
            if(OrderType()  == OP_SELL && OrderMagicNumber()   ==   MAGIC_NUMBER)
              {
               count_total_sell    =  count_total_sell  + 1;
              }
           }

         if(OrdersTotal()  -1 ==  i)
           {
            count_total_lots_mapping   = count_total_lots ;
            count_total_order_mapping   = count_total_order ;
            count_total_buy_mapping  =  count_total_buy  ;
            count_total_sell_mapping    =  count_total_sell ;
           }
        }


     }
   else
     {
      for(int i  =0  ; i <   OrdersTotal()  ;  i++)
        {
         if(OrderSelect(i, SELECT_BY_POS))
           {
            count_total_lots   = count_total_lots  +  OrderLots();
            count_total_order   = count_total_order   +  1;
            if(OrderType()   == OP_BUY)
              {
               count_total_buy  =  count_total_buy  +  1;
              }
            if(OrderType()  == OP_SELL)
              {
               count_total_sell    =  count_total_sell  + 1;
              }

           }
         if(OrdersTotal()  -1 ==  i)
           {
            count_total_lots_mapping   = count_total_lots ;
            count_total_order_mapping   = count_total_order ;
            count_total_buy_mapping  =  count_total_buy  ;
            count_total_sell_mapping    =  count_total_sell ;
           }
        }
     }




   if(OrdersTotal()   ==     0)
     {
      count_total_lots_mapping   =   0 ;
      count_total_order_mapping   = 0 ;
      count_total_buy_mapping   =    0 ;
      count_total_sell_mapping    = 0 ;
     }
   return  0 ;
  }

int  deinit()
  {
   for(int k =  0 ;    k <ArraySize(ROW_5)  ; k++)
     {
      ObjectDelete("PanelLabelData"+  ROW_6[k]);
      ObjectDelete("PanelLabel"+  ROW_5[k]);

     }

   return  0;

  }