//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76093

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
enum  history_type
  {
   day_wise,      //  Day Wise
   weekly_wise,  //  Weekly Wise
   monthly_wise  //  Monthly Wise
  };

enum   mapping_symbol
  {
   ALL_SYMBOL,       //  All Symbol
   CURRENT_SYMBOL  //  Current Symbol


  };

double peak_equity = 0.0;
double max_drawdown = 0.0;
double max_floating_drawdown = 0.0;
double current_dd = 0.0;

extern   mapping_symbol   filter_type    =    CURRENT_SYMBOL   ;
extern   history_type     filter_history     =     monthly_wise     ;




string  history_array[] ;



string ROW_6[] = {"Time ", "Total Trade", "Long Position", "Short Position", "Profit Trades", "Loss Trades", "Gross Profit", "Gross Loss", "Net Loss", "Net Profit", "Profit Loss"};
color ROW_5[] = {clrDarkBlue, clrRoyalBlue, clrRoyalBlue, clrRoyalBlue, clrRoyalBlue, clrRoyalBlue, clrRoyalBlue, clrRoyalBlue, clrRoyalBlue, clrDarkBlue, clrDarkBlue};

string ROW_7[] = {"Symbol", "Balance", "Equity", "Total Open Trades", "Open Trade Buy", "Open Trade Sell", "Max DD", "Max Float DD", "Current DD"};
color ROW_8[] = {clrMaroon, clrDarkGreen, clrDarkGreen, clrDarkGreen, clrDarkGreen, clrDarkGreen, clrDarkRed, clrDarkRed, clrDarkRed};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int XOffset=2;                  //Horizontal offset (pixels)
int YOffset=2;                  //Vertical offset (pixels)

string current_symbol_mapping;
string balance_sheet;
string equ_sheet;
int total_open_trade_mapping;
int total_open_buy_trade_mapping;
int total_open_sell_trade_mapping;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(10);
   peak_equity = AccountEquity();
   fx_history_selector();
   CreatePanel("RightMenu", 2, 0, 330, 400, clrNONE, CORNER_LEFT_UPPER);
   fx_history_report();
   fx_live_panel();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   fx_history_selector() ;
   fx_history_report();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   for(int i = 0; i < ArraySize(ROW_7); i++)
     {
      ObjectDelete("PanelLabel_1" + ROW_7[i]);
      ObjectDelete("PanelLabel" + ROW_7[i]);
      ObjectDelete("PanelLabel_2" + ROW_7[i]);
      ObjectDelete("PanelLabel_3" + ROW_7[i]);
     }

   for(int i = 0; i < ArraySize(ROW_6); i++)
     {
      ObjectDelete("PanelLabel_1" + ROW_6[i]);
      ObjectDelete("PanelLabel" + ROW_6[i]);
     }
   ObjectDelete("ObjName_" + "name");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
// Update drawdown metrics
   double current_equity = AccountEquity();

// Update equity peak
   if(current_equity > peak_equity)
     {
      peak_equity = current_equity;
     }

// Calculate current drawdown
   current_dd = peak_equity - current_equity;
   if(current_dd < 0)
      current_dd = 0.0;

// Update max drawdown
   if(current_dd > max_drawdown)
     {
      max_drawdown = current_dd;
     }

// Update max floating drawdown when positions are open
   if(OrdersTotal() > 0)
     {
      if(current_dd > max_floating_drawdown)
        {
         max_floating_drawdown = current_dd;
        }
     }

// Update live panel
   fx_live_panel();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreatePanel(string name,int x,int y,int width,int height,color clr,int corner)
  {
   name="ObjName"+"_"+"name";
   ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
//--- set label coordinates
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
//--- set label size
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);

   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
//--- set background color
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_history_report()
  {

   string  current_date      =    TimeToString(TimeCurrent(), TIME_DATE);
   string   time_minute   =   TimeToString(TimeCurrent(), TIME_MINUTES);
   int count_buy   =   0   ;
   int  count_sell     = 0 ;
   int    profit_trades    =   0  ;
   int  loss_trades    =   0 ;
   double  gross_profit   =   0   ;
   double  gross_loss  =  0 ;
   double  net_loss    =   0   ;
   double   net_profit   =  0 ;
   double  p_l = 0;

   for(int   fx   =     OrdersHistoryTotal() -  1  ;    fx  >=  0   ;  fx--)
     {
      if(OrderSelect(fx,  SELECT_BY_POS, MODE_HISTORY))
        {
         for(int    j   = 0    ;   j    <   ArraySize(history_array)    ;   j++)
           {

            if(StringCompare(TimeToString(OrderOpenTime(), TIME_DATE),     history_array[j])    == 0)
              {

               if(OrderType()   ==  0  && (OrderSymbol()  == Symbol()   ||  filter_type  ==  ALL_SYMBOL)   &&  fx_order_type_finder(OrderType()))
                 {
                  count_buy    =  count_buy  +  1  ;

                 }
               if(OrderType()  ==  1 && (OrderSymbol()   == Symbol()   ||  filter_type     ==  ALL_SYMBOL  &&  fx_order_type_finder(OrderType())))
                 {
                  count_sell    =  count_sell   + 1;

                 }

               if(OrderProfit()   >=0 && (OrderSymbol()  ==  Symbol()   ||  filter_type   ==  ALL_SYMBOL  &&  fx_order_type_finder(OrderType())))
                 {
                  profit_trades    = profit_trades   +1;



                 }

               if(OrderProfit()  < 0 && (OrderSymbol()   == Symbol()   ||   filter_type    ==  ALL_SYMBOL   &&  fx_order_type_finder(OrderType())))
                 {
                  loss_trades    =   loss_trades    +1;


                 }

               if(OrderProfit()  >=0  && (OrderSymbol()   == Symbol()   ||  filter_type    ==  ALL_SYMBOL  &&  fx_order_type_finder(OrderType())))
                 {
                  gross_profit    =  gross_profit   +   OrderProfit()   ;


                 }
               if(OrderProfit()   <0 && (OrderSymbol()   == Symbol()   ||  filter_type   ==  ALL_SYMBOL  &&  fx_order_type_finder(OrderType())))
                 {

                  gross_loss    =   gross_loss   +   OrderProfit()    +  OrderCommission()    +  OrderSwap();


                 }

               if(OrderSymbol()   == Symbol()   ||  filter_type   ==  ALL_SYMBOL  &&  fx_order_type_finder(OrderType()))
                 {

                  p_l    =   p_l   +   OrderProfit()   +   OrderCommission()   +   OrderSwap()   ;

                 }

              }


            if(fx ==   0)
              {
               if(gross_profit     + gross_loss    >=  0)
                 {
                  net_profit   = gross_profit     +  gross_loss  ;
                 }
               if(gross_loss  + gross_profit    <=   0)
                 {
                  net_loss     =  gross_profit     + gross_loss  ;
                 }
               for(int   i  =    0  ;   i  <    ArraySize(ROW_6)   ;  i++)
                 {
                  int        x_size    =   150  ;
                  int    y_size  =     23;
                  ObjectCreate(0,"PanelLabel"+  ROW_6[i],OBJ_EDIT,0,0,0);
                  ObjectSet("PanelLabel"+  ROW_6[i],OBJPROP_XDISTANCE,XOffset+2  +  176*0);
                  ObjectSet("PanelLabel"+  ROW_6[i],OBJPROP_YDISTANCE, 20*i  +   10*i);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_XSIZE,x_size);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_YSIZE,y_size);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_BORDER_TYPE,BORDER_FLAT);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_STATE,false);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_HIDDEN,true);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_READONLY,true);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_ALIGN,ALIGN_CENTER);
                  ObjectSetString(0,"PanelLabel"+  ROW_6[i],OBJPROP_TEXT, (i  ==   0  ?    fx_current_date_mapping(current_date)   :     ROW_6[i]));
                  ObjectSetString(0,"PanelLabel"+  ROW_6[i],OBJPROP_FONT,"Arial");
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_FONTSIZE,12);
                  ObjectSet("PanelLabel"+  ROW_6[i],OBJPROP_SELECTABLE,true);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_COLOR,clrWhite);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_BGCOLOR,ROW_5[i]);
                  ObjectSetInteger(0,"PanelLabel"+  ROW_6[i],OBJPROP_BORDER_COLOR,clrBlack);
                 }
               for(int   i  =    0  ;   i  <    ArraySize(ROW_6)   ;  i++)
                 {
                  int        x_size    =   150  ;
                  int    y_size  =     23;
                  ObjectCreate(0,"PanelLabel_1"+  ROW_6[i],OBJ_EDIT,0,0,0);
                  ObjectSet("PanelLabel_1"+  ROW_6[i],OBJPROP_XDISTANCE,XOffset+2  +  176*1);
                  ObjectSet("PanelLabel_1"+  ROW_6[i],OBJPROP_YDISTANCE, 20*i  +   10*i);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_XSIZE,x_size);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_YSIZE,y_size);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_BORDER_TYPE,BORDER_FLAT);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_STATE,false);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_HIDDEN,true);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_READONLY,true);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_ALIGN,ALIGN_CENTER);
                  ObjectSetString(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_TEXT, (i   ==   0    ?    time_minute      : (i  ==  1    ?     count_buy +  count_sell   : (i    == 2 ?   count_buy   : (i  == 3  ? count_sell    : (i  == 4  ?
                                  profit_trades    : (i  ==   5     ? loss_trades       : (i  ==  6     ?  DoubleToString(gross_profit,3)    : (i  ==   7  ? DoubleToString(gross_loss, 3)      : (i  ==  8  ?   DoubleToString(net_loss, 3)   : (i == 9   ? DoubleToString(net_profit,3) : (DoubleToString(p_l,  3)))))))))))));
                  ObjectSetString(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_FONT,"Arial");
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_FONTSIZE,12);
                  ObjectSet("PanelLabel_1"+  ROW_6[i],OBJPROP_SELECTABLE,true);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_COLOR,clrWhite);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_BGCOLOR,  ROW_5[i]);
                  ObjectSetInteger(0,"PanelLabel_1"+  ROW_6[i],OBJPROP_BORDER_COLOR,clrBlack);
                 }

              }


           }


        }


     }

   return    0    ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string    fx_current_date_mapping(string data)
  {
   string output[];
   StringSplit(data, StringGetCharacter(".", 0),output);
   if(ArraySize(output)  == 3)
     {
      return (output[2] + "." +   output[1]  +  "."   +    output[0]);
     }
   return  "";
   return   "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_history_selector()
  {



   if(filter_history   ==   day_wise)
     {
      ArrayResize(history_array,   0) ;
      ArrayResize(history_array,ArraySize(history_array)+1);

      history_array[ArraySize(history_array) -1]  =   TimeToString(iTime(Symbol(), PERIOD_D1,     0),  TIME_DATE);



     }






   if(filter_history     ==  weekly_wise)
     {
      ArrayResize(history_array,   0) ;
      for(int i  =   TimeDayOfWeek(TimeCurrent())     ;    i  >=1 ;    i--)
        {

         if(TimeMonth(TimeCurrent()) ==   TimeMonth(iTime(Symbol(), PERIOD_D1,  i-1)))
           {

            string local_time      =  TimeToString(iTime(Symbol(),   PERIOD_D1,   i-1),   TIME_DATE)   ;
            ArrayResize(history_array,ArraySize(history_array)+1);

            history_array[ArraySize(history_array) -1]  =   local_time;

           }


        }


     }



   if(filter_history   == monthly_wise)
     {
      ArrayResize(history_array,    0);
      for(int i  =   TimeDay(TimeCurrent())     ;    i  >=1 ;    i--)
        {
         if(TimeMonth(TimeCurrent()) ==   TimeMonth(iTime(Symbol(), PERIOD_D1,  i-1)))
           {
            string local_time      =  TimeToString(iTime(Symbol(),   PERIOD_D1,   i-1),   TIME_DATE)   ;
            ArrayResize(history_array,ArraySize(history_array)+1);
            history_array[ArraySize(history_array) -1]  =   local_time;
           }

        }


     }


   return    0 ;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_live_panel()
  {
   fx_live_data_panel();

   for(int i = 0; i < ArraySize(ROW_7); i++)
     {
      int x_size = 150;
      int y_size = 23;

      // Left column (labels)
      ObjectCreate(0, "PanelLabel_2" + ROW_7[i], OBJ_EDIT, 0, 0, 0);
      ObjectSet("PanelLabel_2" + ROW_7[i], OBJPROP_XDISTANCE, XOffset + 2);
      ObjectSet("PanelLabel_2" + ROW_7[i], OBJPROP_YDISTANCE, 300 + 30 * i);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_XSIZE, x_size);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_YSIZE, y_size);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_STATE, false);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_READONLY, true);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_ALIGN, ALIGN_CENTER);
      ObjectSetString(0, "PanelLabel_2" + ROW_7[i], OBJPROP_TEXT, ROW_7[i]);
      ObjectSetString(0, "PanelLabel_2" + ROW_7[i], OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_FONTSIZE, 12);
      ObjectSet("PanelLabel_2" + ROW_7[i], OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_BGCOLOR, ROW_8[i]);
      ObjectSetInteger(0, "PanelLabel_2" + ROW_7[i], OBJPROP_BORDER_COLOR, clrBlack);

      // Right column (values)
      ObjectCreate(0, "PanelLabel_3" + ROW_7[i], OBJ_EDIT, 0, 0, 0);
      ObjectSet("PanelLabel_3" + ROW_7[i], OBJPROP_XDISTANCE, XOffset + 2 + 176 * 1);
      ObjectSet("PanelLabel_3" + ROW_7[i], OBJPROP_YDISTANCE, 300 + 30 * i);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_XSIZE, x_size);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_YSIZE, y_size);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_STATE, false);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_READONLY, true);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_ALIGN, ALIGN_CENTER);

      // Add drawdown values to display
      string value_text = "";
      switch(i)
        {
         case 0:
            value_text = current_symbol_mapping;
            break;
         case 1:
            value_text = balance_sheet;
            break;
         case 2:
            value_text = equ_sheet;
            break;
         case 3:
            value_text = string(total_open_trade_mapping);
            break;
         case 4:
            value_text = string(total_open_buy_trade_mapping);
            break;
         case 5:
            value_text = string(total_open_sell_trade_mapping);
            break;
         case 6:
            value_text = DoubleToString(max_drawdown, 2);
            break;
         case 7:
            value_text = DoubleToString(max_floating_drawdown, 2);
            break;
         case 8:
            value_text = DoubleToString(current_dd, 2);
            break;
        }

      ObjectSetString(0, "PanelLabel_3" + ROW_7[i], OBJPROP_TEXT, value_text);
      ObjectSetString(0, "PanelLabel_3" + ROW_7[i], OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_FONTSIZE, 12);
      ObjectSet("PanelLabel_3" + ROW_7[i], OBJPROP_SELECTABLE, true);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_BGCOLOR, ROW_8[i]);
      ObjectSetInteger(0, "PanelLabel_3" + ROW_7[i], OBJPROP_BORDER_COLOR, clrBlack);
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_live_data_panel()
  {
   current_symbol_mapping = filter_type == CURRENT_SYMBOL ? Symbol() : "ALL SYMBOL";
   balance_sheet = DoubleToString(AccountBalance(), 2);
   equ_sheet = DoubleToString(AccountEquity(), 2);
   total_open_trade_mapping = 0;
   total_open_buy_trade_mapping = 0;
   total_open_sell_trade_mapping = 0;

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderSymbol() == Symbol() || filter_type == ALL_SYMBOL)
           {
            total_open_trade_mapping++;
           }
         if((OrderSymbol() == Symbol() || filter_type == ALL_SYMBOL) && OrderType() == OP_BUY)
           {
            total_open_buy_trade_mapping++;
           }
         if((OrderSymbol() == Symbol() || filter_type == ALL_SYMBOL) && OrderType() == OP_SELL)
           {
            total_open_sell_trade_mapping++;
           }
        }
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool    fx_order_type_finder(int   order_type_map)
  {
   if(order_type_map    == 0   ||   order_type_map  ==  1)
     {
      return  true;
     }
   return   false    ;
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76093

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 