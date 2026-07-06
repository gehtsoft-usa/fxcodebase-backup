// Id: 22997
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67009

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };
enum order_type{ Both=1, Only_Buy=2, Only_Sell=3 };
enum e_risk { Automatic=1, Manual=2 };

enum bb_actions{ No_Action=1, Buy=2, Sell=3, Close_Buy_Positions=4, Close_Sell_Positions=5, Close_All_Positions=6, Produce_Alert=7 };
enum bb_price{ CLOSE=1, HIGH_LOW=2};

extern string     Comment1                      = "- Strategy Parameters -";
extern bool       EA_Activated                  = true;
input  e_cycles   TimeFrame                     = Min_60;
input  order_type Order_Type                    = Both;
extern int        Maximum_Trades_Open           = 5;
extern int        Wait_Mins_For_Next_Trade      = 30;
extern int        Look_Back_Length       = 20;
input  bb_actions Top_Line_Touch       = No_Action;
input  bb_actions Center_Line_Cross_Over     = Buy;
input  bb_actions Center_Line_Cross_Under    = Sell;
input  bb_actions Bottom_Line_Touch     = No_Action;
extern string     Comment2                      = "- Order magic number. May be used as user defined identifier -";
extern int        Magic_N                       = 123456;
extern string     Comment3                      = "- AutoLots True will calculate Lots automatically -";
input  e_risk     Risk_Management               = Automatic;
extern string     Comment4                      = "- Automatic Risk, For ex: 2.5 means 2.5% -";
extern double     Auto_Risk_Percent             = 2;
extern double     Auto_Max_Risk_in_Total_Orders = 7;
extern string     Comment5                      = "- Manual Number of Lots (if not Automatic Risk) -";
extern double     Manual_Lots                   = 0.3;
extern double     Manual_Maximum_Lots           = 3.0;
extern string     Comment6                      = "- Maximum price slippage for buy or sell orders -";
extern double     Slippage                      = 3;
extern string     Comment7                      = "- Stop loss in Pips -";
extern double     StopLoss                      = 20;
extern string     Comment8                      = "- Take profit in Pips -";
extern double     TakeProfit                    = 50;
extern string     Comment9                      = "- Trailing Stop in Pips -";
extern double     TrailingStop                  = 15;
extern double     TrailingStep                  = 5;
extern string     Comment10                     = "- Should the EA use alerts -";
extern bool       Sound_Alert                   = true;
extern bool       Email_Alert                   = false;
extern string     Comment11                     = "- Optional EA actions -";
extern bool       EASounds                      = true;
extern bool       Show_Profit_Comments          = true;

double Emergency_SL = 2000;

string EA_Name = "Highly Adaptable Donchian Channel";
string CommentOrder = EA_Name+" Order";

double Lots;

int Open_Long, Open_Short, Close_Long, Close_Short;
double Side, Open_Level, TP_Level, SL_Level, TSL_Level = 0;
double Profit;
string Calculation_Comments, Orders_Comments, Profit_Comments;
datetime LastClose, LastOpen;

// Ongoing Risk
double Equity_Risked=0;
double Order_SL;
double Orders_Lots;

datetime LastAlert;

int init(){
   
   // Trader sets Levels in pips but broker could work for ex. with 5 digits for EURUSD instead of 4
   if(Digits == 3 || Digits == 5) {
      Slippage     *= 10;
      StopLoss     *= 10;
      TakeProfit   *= 10;
      TrailingStop *= 10;
      TrailingStep *= 10;
   }
   double temp = iCustom(NULL, 0, "DNC", Look_Back_Length, 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'averages' indicator");
      return INIT_FAILED;
   }
   return(0);
}

int start(){

   int i;
   int total = OrdersTotal();
   string Order_Label;
   
   Side = -1;
   Open_Level = 0;
   Orders_Comments = "";
   Profit_Comments = "";
   
      // Reset Levels
   TP_Level   = 0;
   SL_Level   = 0;
   TSL_Level  = 0;
   
   // Reset P/L
   Profit = 0;
   
   // Trades History
   for(i=0; i < OrdersHistoryTotal(); i++){
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
         if (i>OrdersHistoryTotal()-6) Profit_Comments+="Ticket: "+OrderTicket()+" P/L: "+OrderProfit()+ "\n";
         Profit+=OrderProfit();
         if (OrderCloseTime()    > LastClose
         &&  OrderMagicNumber()  == Magic_N
         &&  OrderSymbol()       == Symbol()
         &&  OrderType()         <= OP_SELL){
            LastClose    = OrderCloseTime();
         }
      }
   }
   
   Equity_Risked = 0;
   Orders_Lots   = 0;
   
   // Ongoing Trades
   for(i=0; i<total; i++) {
      
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
   
         if (   (Magic_N==0 || OrderMagicNumber () == Magic_N)
             && (OrderType()==OP_SELL || OrderType()==OP_BUY)
             && OrderSymbol()==Symbol()
             ){
            Side    = OrderType();
            if (Side==OP_BUY)  Order_Label = "Buy Order";
            if (Side==OP_SELL) Order_Label = "Sell Order";
            Open_Level = OrderOpenPrice();
            Set_Levels();
            // SL is still in the negative side, so the equity is handling risk
            if ((Side==OP_BUY && Open_Level > OrderStopLoss()) || (Side==OP_SELL && OrderStopLoss() > Open_Level)){
               if (Side==OP_BUY) Order_SL = Open_Level-OrderStopLoss(); else Order_SL = OrderStopLoss() - Open_Level;
               Equity_Risked+= (((Order_SL/Point) * OrderLots())/AccountInfoDouble(ACCOUNT_EQUITY))*100;
               Orders_Lots+=OrderLots();
            }else{
               Equity_Risked+= 0;
               Orders_Lots+=0;
            }
            Orders_Comments+=Order_Label+" #"+OrderTicket()+" @ "+Open_Level+" TP: "+TP_Level+" SL: "+SL_Level+" Lots: "+OrderLots()+"\n";
            
         }
   
      }
   
   }
   
   if(Risk_Management==1){
      LotSize(); // if Auto=true, risk is calculated here
   }else{
      Lots = Manual_Lots;
   }
   
   Orders_Comments+="=======================\n";
   // Automatic Risk (Lots)
   if (Risk_Management==1){
      if (Auto_Max_Risk_in_Total_Orders-Equity_Risked > Auto_Risk_Percent)
         string Still_Available_Risk = DoubleToStr(Auto_Max_Risk_in_Total_Orders-Equity_Risked,2)+"% still available";
      else 
         Still_Available_Risk = "No Available Risk for other trade";
      Orders_Comments+="Equity Risked: "+DoubleToStr(Equity_Risked,2)+"% ("+Still_Available_Risk+")\n";
   // Manual Risk
   }else{
      if (Manual_Maximum_Lots-Orders_Lots > Manual_Lots)
         Still_Available_Risk = DoubleToStr(Manual_Maximum_Lots-Orders_Lots,2)+" Lots still available";
      else 
         Still_Available_Risk = "No Available Lots for other trade";
      Orders_Comments+="Lots in Risk: "+DoubleToStr(Orders_Lots,2)+" ("+Still_Available_Risk+")\n";
   }
     
   // Reset Orders
   Open_Long   = 0;
   Open_Short  = 0;
   Close_Long  = 0;
   Close_Short = 0;
   
   EA_Calculations(); // The heart of this strategy
   
   // Opening Positions
   
   if(Open_Long == 1 && total < Maximum_Trades_Open && (Order_Type == 1 || Order_Type == 2) && TimeCurrent() > LastClose+(Wait_Mins_For_Next_Trade*60)){
      OpenPos(OP_BUY);
   }
   
   if(Open_Short == 1 && total < Maximum_Trades_Open && (Order_Type == 1 || Order_Type == 3) && TimeCurrent() > LastClose+(Wait_Mins_For_Next_Trade*60)){
      OpenPos(OP_SELL);
   }
   
   // Closing Open Buy and Sell positions by Exit Rules (not SL or TP):
   if(Close_Long == 1){
      ClosePos(OP_BUY);
   }
   if(Close_Short == 1){
      ClosePos(OP_SELL);
   }
         
   EA_Notes(); // Error Messages
   
   return(0);

}

//+------------------------------------------------------------------+

// EA Buy and Sell calculations
void EA_Calculations(){
   
   // Initially all possibilities set to 0
   // If any condition applies to any of them change to 1
   Open_Long = 0;
   Open_Short = 0;
   Close_Long = 0;
   Close_Short = 0;
   
   int period     = Get_TimeFrame(TimeFrame);
   double Top0    = iCustom(NULL,period, "DNC", Look_Back_Length, 0, 0);
   double Top1    = iCustom(NULL,period, "DNC", Look_Back_Length, 0, 1);
   double Bottom0 = iCustom(NULL,period, "DNC", Look_Back_Length, 1, 0);
   double Bottom1 = iCustom(NULL,period, "DNC", Look_Back_Length, 1, 1);
   double Center0 = iCustom(NULL,period, "DNC", Look_Back_Length, 2, 0);
   double Center1 = iCustom(NULL,period, "DNC", Look_Back_Length, 2, 1);
   
   if (  (Risk_Management==1 && Auto_Max_Risk_in_Total_Orders-Equity_Risked > Auto_Risk_Percent)
      || (Risk_Management==2 && Manual_Maximum_Lots-Orders_Lots > Manual_Lots)
      )
      bool Risk_Allowed = true;
   else
      Risk_Allowed = false;
   
   if (High[0] >= Top0    && High[1] < Top1)    bool Top_Line_Touch_condition = true;     else Top_Line_Touch_condition = false;
   if (Close[0] > Center0 && Close[1] < Center1) bool Center_Line_Cross_Over_Condition = true;  else Center_Line_Cross_Over_Condition = false;
   if (Close[0] < Center0 && Close[1] > Center1) bool Center_Line_Cross_Under_Condition = true; else Center_Line_Cross_Under_Condition = false;
   if (Low[0] <= Bottom0 && Low[1] > Bottom1) bool Bottom_Line_Touch_condition = true;  else Bottom_Line_Touch_condition = false;
   
   // Open Buy
   if (   EA_Activated
       && Risk_Allowed
       && (Order_Type == 1 || Order_Type == 2)
       && TimeCurrent() > (LastOpen+(Wait_Mins_For_Next_Trade*60))
       && (  (Top_Line_Touch     == 2 && Top_Line_Touch_condition)
           ||(Center_Line_Cross_Over  == 2 && Center_Line_Cross_Over_Condition)
           ||(Center_Line_Cross_Under == 2 && Center_Line_Cross_Under_Condition)
           ||(Bottom_Line_Touch  == 2 && Bottom_Line_Touch_condition)
          )
      ){
      Open_Long = 1;
      LastOpen = TimeCurrent();
   }
   
   // Open Sell
   if (   EA_Activated
       && Risk_Allowed
       && (Order_Type == 1 || Order_Type == 3)
       && TimeCurrent() > (LastOpen+(Wait_Mins_For_Next_Trade*60))
       && (  (Top_Line_Touch     == 3 && Top_Line_Touch_condition)
           ||(Center_Line_Cross_Over  == 3 && Center_Line_Cross_Over_Condition)
           ||(Center_Line_Cross_Under == 3 && Center_Line_Cross_Under_Condition)
           ||(Bottom_Line_Touch  == 3 && Bottom_Line_Touch_condition)
          )
      ){
      Open_Short = 1;
      LastOpen = TimeCurrent();
   }
   
   // Close Buy Positions
   if (   EA_Activated
       && (Order_Type == 1 || Order_Type == 2)
       && (  ((Top_Line_Touch     == 4 || Top_Line_Touch     == 6) && Top_Line_Touch_condition)
           ||((Center_Line_Cross_Over  == 4 || Center_Line_Cross_Over  == 6) && Center_Line_Cross_Over_Condition)
           ||((Center_Line_Cross_Under == 4 || Center_Line_Cross_Under == 6) && Center_Line_Cross_Under_Condition)
           ||((Bottom_Line_Touch  == 4 || Bottom_Line_Touch  == 6) && Bottom_Line_Touch_condition)
          )
      ){
      Close_Long = 1;
   }
   
   // Close Buy Positions
   if (   EA_Activated
       && (Order_Type == 1 || Order_Type == 3)
       && (  ((Top_Line_Touch     == 5 || Top_Line_Touch     == 6) && Top_Line_Touch_condition)
           ||((Center_Line_Cross_Over  == 5 || Center_Line_Cross_Over  == 6) && Center_Line_Cross_Over_Condition)
           ||((Center_Line_Cross_Under == 5 || Center_Line_Cross_Under == 6) && Center_Line_Cross_Under_Condition)
           ||((Bottom_Line_Touch  == 5 || Bottom_Line_Touch  == 6) && Bottom_Line_Touch_condition)
          )
      ){
      Close_Short = 1;
   }
   
   // Events Alerts
   string Alertas = "";
   if (EA_Activated && Top_Line_Touch     == 7 && Top_Line_Touch_condition)    Alertas+= "Top Line Touch";
   if (EA_Activated && Center_Line_Cross_Over  == 7 && Center_Line_Cross_Over_Condition) Alertas+= "Center Line Cross Over";
   if (EA_Activated && Center_Line_Cross_Under == 7 && Center_Line_Cross_Under_Condition) Alertas+= "Center Line Cross Over";
   if (EA_Activated && Bottom_Line_Touch  == 7 && Bottom_Line_Touch_condition) Alertas+= "Bottom Line Touch";
   if (Time[0] > LastAlert && Alertas!=""){
      if (Sound_Alert) Alert(EA_Name+" "+Symbol() + "," + TFToStr(Period()) +": "+Alertas);
      if (Email_Alert) SendMail(EA_Name+" Alert", EA_Name+" "+Symbol() + "," + TFToStr(Period()) + ": "+Alertas);
      LastAlert = TimeCurrent();
   }
   
   if (Close[0] > Center0 && Close[0] < Top0){
      Calculation_Comments = "Price between Center and Top BBs\n";
      Calculation_Comments+= "Waiting for either:\n";
      Calculation_Comments+= "- Crossing over the Top Line\n";
      Calculation_Comments+= "- Crossing under the Center Line";
   }
   if (Close[0] < Center0 && Close[0] > Bottom0){
      Calculation_Comments = "Price between Center and Bottom BBs\n";
      Calculation_Comments+= "Waiting for either:\n";
      Calculation_Comments+= "- Crossing over the Center Line\n";
      Calculation_Comments+= "- Crossing under the Bottom Line";
   }
   if (Close[0] > Top0){
      Calculation_Comments = "Price above Top BBs\n";
      Calculation_Comments+= "Waiting to cross under this Line";
   }
   if (Close[0] < Bottom0){
      Calculation_Comments = "Price below Bottom BBs\n";
      Calculation_Comments+= "Waiting to cross over this Line";
   }
   
}

// Determining the TP, SL and TSL Levels
void Set_Levels(){
   
   double PP=MarketInfo(OrderSymbol(), MODE_POINT);
   double BID=MarketInfo(OrderSymbol(), MODE_BID);
   double ASK=MarketInfo(OrderSymbol(), MODE_ASK);
   double TP = PP*TakeProfit;
   double SL = PP*StopLoss;
   double BUY_TSL  = BID - (TrailingStop*PP);
   double SELL_TSL = ASK + (TrailingStop*PP);
   
   if(Side == -1) return;
   
   if (StopLoss==0) StopLoss = Emergency_SL;
   
   if(TakeProfit > 0){
      
      if(Side == OP_BUY  ) TP_Level = Open_Level + TP;
      if(Side == OP_SELL ) TP_Level = Open_Level - TP;
   
   }

   if(StopLoss > 0){
      
      if(Side == OP_BUY  ) SL_Level = Open_Level - SL;
      if(Side == OP_SELL ) SL_Level = Open_Level + SL;
   
   }
   
   bool Order_Modified = false;
   if ((OrderTakeProfit()==0 && TakeProfit > 0) || (OrderStopLoss()==0 && StopLoss > 0)){
      if (OrderModify(OrderTicket(),0,SL_Level,TP_Level,0,clrBlue)){ Order_Modified = true; }
   }
   
   if(TrailingStop){
      
      if(Side == OP_BUY){
         if ((BID-OrderOpenPrice())>TrailingStop*PP){
            if (OrderStopLoss()<BID-(TrailingStop+TrailingStep-1)*PP && BID-TrailingStop*PP>SL_Level) {
               if (OrderModify(OrderTicket(),OrderOpenPrice(),BID-TrailingStop*PP,OrderTakeProfit(),0,clrMagenta)){ Order_Modified = true; }
            }
         }
      }
      
      if(Side == OP_SELL){
         if (OrderOpenPrice()-ASK>TrailingStop*PP) {
            if (OrderStopLoss()>ASK+(TrailingStop+TrailingStep-1)*PP && ASK+TrailingStop*PP<SL_Level) {
               if (OrderModify(OrderTicket(),OrderOpenPrice(),ASK+TrailingStop*PP,OrderTakeProfit(),0,clrMagenta)){ Order_Modified = true; }
            }
         }
      }
   
   }
   
   return;
}

//+------------------------------------------------------------------+
//| // Automatic Lot Size
//+------------------------------------------------------------------+
double LotSize() {

    double minlot    = MarketInfo(Symbol(), MODE_MINLOT);
    double maxlot    = MarketInfo(Symbol(), MODE_MAXLOT);
    double tickVal   = MarketInfo(Symbol(), MODE_TICKVALUE);

    double Equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double _Risk = Auto_Risk_Percent / 100;
    double Risk_per_Trade   = Equity * _Risk;
    double Pips_Risked = StopLoss  * tickVal;

    if(Risk_per_Trade > 0 && Pips_Risked > 0 && (Risk_per_Trade / Pips_Risked) > 0) {
        double lots = (Risk_per_Trade / Pips_Risked);
        if(lots < minlot) {
            lots = minlot;
        } else if(lots > maxlot) {
            lots = maxlot;
        }
        Lots = lots;
    }
    return(0);
}

// Notes given by the Expert
void EA_Notes(){
   
   if (Digits==3||Digits==5){
      double sl = StopLoss/10;
      double tp = TakeProfit/10;
      double tsl = TrailingStop/10;
   }
   else{
      sl = StopLoss/10;
      tp = TakeProfit/10;
      tsl = TrailingStop/10;
   }
   string Currency = AccountCurrency();
   
   string Note = EA_Name+"\n";
   Note = Note + "Account Equity: "+AccountInfoDouble(ACCOUNT_EQUITY)+" "+Currency+"\n";
   Note = Note + "Risk per SL Pip: "+DoubleToStr(((AccountInfoDouble(ACCOUNT_EQUITY)*(Auto_Risk_Percent/100))/sl),2)+" "+Currency+"\n";
   Note = Note + "Total Risk per Trade: "+DoubleToStr((AccountInfoDouble(ACCOUNT_EQUITY)*(Auto_Risk_Percent/100)),2)+" "+Currency+"\n";
   Note = Note + "Lots: " + DoubleToStr(Lots,2);
   if(Risk_Management==1) Note = Note + " (Automatic "+Auto_Risk_Percent+"%)"; else Note = Note + " (Set Manually)";
   Note = Note + "\n";
   Note = Note + "SL:" + DoubleToStr(sl,0) + " pips | "; 
   Note = Note + "TP:" + DoubleToStr(tp,0) + " pips | ";
   Note = Note + "TSL:" + DoubleToStr(tsl,0) + " pips\n";   
   Note = Note + "=======================\n";  
   if (Show_Profit_Comments){
      Note = Note + "Last 5 Trades Results:\n";
      Note = Note + Profit_Comments;
   }
   Note = Note + "-----------------------\nTotal Profit: " + DoubleToStr(Profit,2) + "\n";
   Note = Note + "=======================\n"; 
   Note = Note + Calculation_Comments+"\n";
   Note = Note + "=======================\n"; 
   Note = Note + Orders_Comments;

   Comment(Note);
}

//+------------------------------------------------------------------+
// Opening positions
//+------------------------------------------------------------------+
int OpenPos(int direction){
   
   int    attempts = 0;
   int    order = 0;
   double price;
   string string_direction = "";
   
   for(attempts=0;attempts<3;attempts++){
      
      if (IsTradeContextBusy()){
         Sleep(1000);
      
      }else{
         
         RefreshRates();         

         if(direction == OP_BUY){
            price = Ask;
            string_direction = "Long";
         }else{
            price = Bid;
            string_direction = "Short";
         }        
         
         if(EASounds) PlaySound("alert.wav");

         order = OrderSend(Symbol(),direction,Lots,price,Slippage,0,0,CommentOrder,Magic_N,0,Red);
         
         if(order<=0) {
            
            Print("Error Occured : "+Errors(GetLastError()));
         
         }else{
            
            attempts = 3;
            Print("Order opened : "+Symbol()+" Price @ "+price+" SL @ "+StopLoss+" TP @"+TakeProfit+" order ="+order);
            Side = direction;
            Open_Level = OrderOpenPrice();
            TP_Level = 0;
            SL_Level = 0;
            TSL_Level = 0;
            Notifications("Open "+string_direction,price,StopLoss,TakeProfit,order);
            return(order);
         
         }
      }
   }
   return(-1);
}


//+------------------------------------------------------------------+
// Closing positions                                                 |
//+------------------------------------------------------------------+
int ClosePos(int direction){
   
   int    i        = 0;
   int    attempts = 0;
   int    order   = 0;
   double price;
   string string_direction = "";

   for(i=0; i<OrdersTotal(); i++) {
      
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
 
         if (OrderType()==direction && OrderSymbol()==Symbol() && ((OrderMagicNumber () == Magic_N) || Magic_N==0)) {
            
            for(attempts=0;attempts<3;attempts++){
               
               if (IsTradeContextBusy()){
                  
                  Sleep(1000);
               
               }else{
                  
                  RefreshRates();
   
                  if(direction == OP_BUY){
                     price = Bid;
                     string_direction = "Long";
                  }else{
                     price = Ask;
                     string_direction = "Short";
                  }
               
                  if(EASounds) PlaySound("alert.wav");
                    
                  order = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(price,Digits),Slippage,Red);
    
                  if(order==0){
                     Print("Error Occured : "+Errors(GetLastError()));
                  } 
                  else{
                     attempts = 3;
                     Print("Order closed : "+Symbol()+" Close @ "+price+" order ="+OrderTicket());
                     Profit = Profit + OrderProfit();
                     Side = -1;
                     Open_Level = 0;
                     Notifications("Close "+string_direction,price,0,0,OrderTicket());
                     return(order);
                  }
               }
            }
         }
         
      }
         
   }
   return(order);
}

//+------------------------------------------------------------------+
//| return error description                                         |
//+------------------------------------------------------------------+
string Errors(int error_code){
   
   string desc_error;
   
   switch(error_code){

      case 0:
      case 1:   desc_error="no error";                                                  break;
      case 2:   desc_error="common error";                                              break;
      case 3:   desc_error="invalid trade parameters";                                  break;
      case 4:   desc_error="trade server is busy";                                      break;
      case 5:   desc_error="old version of the client terminal";                        break;
      case 6:   desc_error="no connection with trade server";                           break;
      case 7:   desc_error="not enough rights";                                         break;
      case 8:   desc_error="too frequent requests";                                     break;
      case 9:   desc_error="malfunctional trade operation";                             break;
      case 64:  desc_error="account disabled";                                          break;
      case 65:  desc_error="invalid account";                                           break;
      case 128: desc_error="trade timeout";                                             break;
      case 129: desc_error="invalid price";                                             break;
      case 130: desc_error="invalid stops";                                             break;
      case 131: desc_error="invalid trade volume";                                      break;
      case 132: desc_error="market is closed";                                          break;
      case 133: desc_error="trade is disabled";                                         break;
      case 134: desc_error="not enough money";                                          break;
      case 135: desc_error="price changed";                                             break;
      case 136: desc_error="off quotes";                                                break;
      case 137: desc_error="broker is busy";                                            break;
      case 138: desc_error="requote";                                                   break;
      case 139: desc_error="order is locked";                                           break;
      case 140: desc_error="long positions only allowed";                               break;
      case 141: desc_error="too many requests";                                         break;
      case 145: desc_error="modification denied because order too close to market";     break;
      case 146: desc_error="trade context is busy";                                     break;
      // -----------------------------------------------------------------------------------///
      case 4000: desc_error="no error";                                                 break;
      case 4001: desc_error="wrong function pointer";                                   break;
      case 4002: desc_error="array index is out of range";                              break;
      case 4003: desc_error="no memory for function call stack";                        break;
      case 4004: desc_error="recursive stack overflow";                                 break;
      case 4005: desc_error="not enough stack for parameter";                           break;
      case 4006: desc_error="no memory for parameter string";                           break;
      case 4007: desc_error="no memory for temp string";                                break;
      case 4008: desc_error="not initialized string";                                   break;
      case 4009: desc_error="not initialized string in array";                          break;
      case 4010: desc_error="no memory for array\' string";                             break;
      case 4011: desc_error="too long string";                                          break;
      case 4012: desc_error="remainder from zero divide";                               break;
      case 4013: desc_error="zero divide";                                              break;
      case 4014: desc_error="unknown command";                                          break;
      case 4015: desc_error="wrong jump (never generated error)";                       break;
      case 4016: desc_error="not initialized array";                                    break;
      case 4017: desc_error="dll calls are not allowed";                                break;
      case 4018: desc_error="cannot load library";                                      break;
      case 4019: desc_error="cannot call function";                                     break;
      case 4020: desc_error="expert function calls are not allowed";                    break;
      case 4021: desc_error="not enough memory for temp string returned from function"; break;
      case 4022: desc_error="system is busy (never generated error)";                   break;
      case 4050: desc_error="invalid function parameters count";                        break;
      case 4051: desc_error="invalid function parameter value";                         break;
      case 4052: desc_error="string function internal error";                           break;
      case 4053: desc_error="some array error";                                         break;
      case 4054: desc_error="incorrect series array using";                             break;
      case 4055: desc_error="custom indicator error";                                   break;
      case 4056: desc_error="arrays are incompatible";                                  break;
      case 4057: desc_error="global variables processing error";                        break;
      case 4058: desc_error="global variable not found";                                break;
      case 4059: desc_error="function is not allowed in testing mode";                  break;
      case 4060: desc_error="function is not confirmed";                                break;
      case 4061: desc_error="send mail error";                                          break;
      case 4062: desc_error="string parameter expected";                                break;
      case 4063: desc_error="integer parameter expected";                               break;
      case 4064: desc_error="double parameter expected";                                break;
      case 4065: desc_error="array as parameter expected";                              break;
      case 4066: desc_error="requested history data in update state";                   break;
      case 4099: desc_error="end of file";                                              break;
      case 4100: desc_error="some file error";                                          break;
      case 4101: desc_error="wrong file name";                                          break;
      case 4102: desc_error="too many opened files";                                    break;
      case 4103: desc_error="cannot open file";                                         break;
      case 4104: desc_error="incompatible access to a file";                            break;
      case 4105: desc_error="no order selected";                                        break;
      case 4106: desc_error="unknown symbol";                                           break;
      case 4107: desc_error="invalid price parameter for trade function";               break;
      case 4108: desc_error="invalid ticket";                                           break;
      case 4109: desc_error="trade is not allowed";                                     break;
      case 4110: desc_error="longs are not allowed";                                    break;
      case 4111: desc_error="shorts are not allowed";                                   break;
      case 4200: desc_error="object is already exist";                                  break;
      case 4201: desc_error="unknown object property";                                  break;
      case 4202: desc_error="object is not exist";                                      break;
      case 4203: desc_error="unknown object type";                                      break;
      case 4204: desc_error="no object name";                                           break;
      case 4205: desc_error="object coordinates error";                                 break;
      case 4206: desc_error="no specified subwindow";                                   break;
      default:   desc_error="unknown error";
   }

   return(desc_error);
   
}  

//+------------------------------------------------------------------+
// Notifications (Sound & Email)                                                      |
//+------------------------------------------------------------------+
void Notifications(string _type, double _price, double _sl, double _tp, int _order) {
   
   string Alerta         = EA_Name;
   string Alerta_Subject = "";
   string Alerta_Body    = "";
   string CurDate        = TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);
 
   Alerta = Alerta + ": "+ _type +" @ "+DoubleToStr(_price,Digits)+"; P/L: "+DoubleToStr(Profit,2)+" SL: "+DoubleToStr(_sl,Digits)+"; TP: "+DoubleToStr(_tp,Digits)+" at "+CurDate+" Order:"+DoubleToStr(_order,0)+"."; 
   
   Alerta_Subject = EA_Name+" - "+Symbol() + " (" + TFToStr(Get_TimeFrame(TimeFrame)) +") Alert";
   Alerta_Body    = Symbol() + " (" + TFToStr(Get_TimeFrame(TimeFrame)) +") - "+Alerta;
      
   if (Sound_Alert) Alert(Alerta_Body);
   if (Email_Alert) SendMail(Alerta_Subject, Alerta_Body);

   return;
}

int Get_TimeFrame(int BTF, bool mins = false){
   int Periodo, Minutes;
   if (BTF==1){ Periodo = PERIOD_M5;  Minutes = 5;     }
   if (BTF==2){ Periodo = PERIOD_M15; Minutes = 15;    }
   if (BTF==3){ Periodo = PERIOD_M30; Minutes = 30;    }
   if (BTF==4){ Periodo = PERIOD_H1;  Minutes = 60;    }
   if (BTF==5){ Periodo = PERIOD_H4;  Minutes = 240;   }
   if (BTF==6){ Periodo = PERIOD_D1;  Minutes = 1440;  }
   if (BTF==7){ Periodo = PERIOD_W1;  Minutes = 10080; }
   if (BTF==8){ Periodo = PERIOD_MN1; Minutes = 43200; }
   if (mins) return(Minutes); else return(Periodo);
}

string TFToStr(int tf){
  if (tf == 0)        tf = Period();
  if (tf >= 43200)    return("MN");
  if (tf >= 10080)    return("W1");
  if (tf >=  1440)    return("D1");
  if (tf >=   240)    return("H4");
  if (tf >=    60)    return("H1");
  if (tf >=    30)    return("M30");
  if (tf >=    15)    return("M15");
  if (tf >=     5)    return("M5");
  if (tf >=     1)    return("M1");
  return("");
}

