// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72707

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

bool LONG,SHORT;
int buys,sells;
bool trade;
int buy_candle,sell_candle;

extern int MagicNumber           = 5050;

extern double Lots               = 0.01;
extern int Max_spread_points     = 12;
extern bool Use_lot_reduction    = false;
extern bool Use_acct_pct_for_lots = false;
extern double lot_acct_multi     = 0.5;
extern double StopLossPoints     = 0;
double sl;
extern bool Use_prev_hi_low_sl   = true;
extern double TakeProfitPoints   = 50;
double tp;
extern double TrailingStopPoints = 0;
extern bool Use_squeeze          = false;
extern bool Squeeze_only_in_profit = false;
extern int max_trades            = 1;
extern int bars_between_trades   = 1;
extern int seconds_between_trades = 120;
int LastBuyTime, LastSellTime;
extern bool Use_reverse          = false;
extern bool Use_close_on_reverse = false;

extern color color_long = clrBlue;
extern color color_short = clrDarkOrange;
extern int line_width = 2;
extern int arrow_size = 3;
extern int arrow_code_up = 233;


double atr,spread;

int      size=0;
double   fractal[10000];
int      fractal_candle[10000];
int      fractal_dir[10000];
   
string cmt;
string id="quazi";
   
datetime time;
datetime alert_time;

      bool B,S;
      
void init(){

   EventSetTimer(1);
   time=0;
   
   StopLossPoints*=MarketInfo(ChartSymbol(),MODE_POINT);
   TakeProfitPoints*=MarketInfo(ChartSymbol(),MODE_POINT);
   TrailingStopPoints*=MarketInfo(ChartSymbol(),MODE_POINT);
   //seconds_between_trades*=1000;
   
   Comment("");
   return;
}
void deinit(){
   Comment("");
   remove_objects();
   time=0;
   return;
}

void remove_objects()
{
   string name;
   for(int i=ObjectsTotal()-1;i>=0;i--)
   {
      name=ObjectName(0,i);
      if(StringFind(name,id)>=0)ObjectDelete(0,name);
   }
   
   return;
}

#include <WinUser32.mqh>
#import "user32.dll"
  int GetAncestor(int, int);
#import
void PauseTest(){   datetime now = TimeCurrent();   static datetime oncePerTick;
    if (IsTesting() && IsVisualMode() && IsDllsAllowed() && oncePerTick != now){
        oncePerTick = now;
        for(int i=0; i<200000; i++){        // Delay required for speed=32 (max)
            int main = GetAncestor(WindowHandle(Symbol(), Period()), 2/*GA_ROOT*/);
            if (i==0) PostMessageA(main, WM_COMMAND, 0x57a, 0); // 1402. Pause
    }   }
}

//void OnTimer()
//  {
//   checkTrade();
//  }
  
void start()
{
   for(int i=OrdersTotal();i>=0;i--)
   { 
      buys=0;
      sells=0;
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber()==MagicNumber && OrderSymbol()==ChartSymbol())
      {
         if(OrderType()==OP_BUY)buys++;
         if(OrderType()==OP_SELL)sells++;
      }
   }
   
   if(buys+sells>0)
   {
      if(TrailingStopPoints>0 )trailing_stop();
      if(Use_squeeze && OrderTakeProfit()!=0)squeeze(OrderSymbol());
   }
   
   atr=iATR(ChartSymbol(),0,14,0);
   spread = MarketInfo(ChartSymbol(),MODE_ASK)-MarketInfo(ChartSymbol(),MODE_BID);
   if(spread > Max_spread_points*MarketInfo(ChartSymbol(),MODE_POINT))
   {
      Comment("spread "+NormalizeDouble(spread/MarketInfo(ChartSymbol(),MODE_POINT),MarketInfo(ChartSymbol(),MODE_DIGITS))
      +"  no trades spread > "+Max_spread_points);
   }
   
   if(spread>Max_spread_points*MarketInfo(ChartSymbol(),MODE_POINT))return;
   
   //if(Time[0]!=time)
   { 
      
   
      check_fractals2();
      tp=0;
      sl=0;
         
      check_long_short(0);
          
      if(LONG && buys<max_trades && Bars-buy_candle>=bars_between_trades && int(TimeCurrent())-LastBuyTime > seconds_between_trades)
      {
         if(Use_close_on_reverse && sells>0)close_all_trades_of_type(OP_SELL);
         
         if(TakeProfitPoints!=0)tp=MarketInfo(ChartSymbol(),MODE_ASK)+TakeProfitPoints;
         
         if(Use_prev_hi_low_sl)sl=fractal[1]-2*spread;
         else
         if(StopLossPoints!=0)sl=MarketInfo(ChartSymbol(),MODE_BID)-StopLossPoints;
                  
         sl=NormalizeDouble(sl,MarketInfo(ChartSymbol(),MODE_DIGITS));
         
         double lots,LOT;
         
         if(Use_acct_pct_for_lots && lot_acct_multi!=0)LOT=AccountBalance()*lot_acct_multi/1000;
         else
         LOT = Lots;
         
         if(Use_lot_reduction && AccountFreeMarginCheck(ChartSymbol(),OP_BUY,LOT)<0)
         {
            while(AccountFreeMarginCheck(ChartSymbol(),OP_BUY,LOT)<0 && LOT>MarketInfo(ChartSymbol(),MODE_MINLOT))
            {
               LOT-=MarketInfo(ChartSymbol(),MODE_MINLOT);
               LOT=NormalizeDouble(LOT,2);
            }
         }
         lots=LOT;
        
         B=OrderSend(ChartSymbol(),OP_BUY,lots,MarketInfo(ChartSymbol(),MODE_ASK),0,sl,tp,WindowExpertName(),MagicNumber,0,clrBlue);
        
         if(B)
         { 
            LastBuyTime=int(TimeCurrent());
            buy_candle=Bars;
            LONG=FALSE;  
            //PauseTest();
         }
      }
      
      if(SHORT && sells<max_trades && Bars-sell_candle>=bars_between_trades && int(TimeCurrent())-LastSellTime > seconds_between_trades)
      {
         if(Use_close_on_reverse && buys>0)close_all_trades_of_type(OP_BUY);
         
         if(TakeProfitPoints!=0)tp=MarketInfo(ChartSymbol(),MODE_BID)-TakeProfitPoints;
         
         if(Use_prev_hi_low_sl)sl=fractal[1]+2*spread;
         else
         if(StopLossPoints!=0)sl=MarketInfo(ChartSymbol(),MODE_ASK)+StopLossPoints;
         
         sl=NormalizeDouble(sl,MarketInfo(ChartSymbol(),MODE_DIGITS));
         
         double lots,LOT;   
         
         if(Use_acct_pct_for_lots && lot_acct_multi!=0)LOT=AccountBalance()*lot_acct_multi/1000;
         else
         LOT = Lots;
         
         if(Use_lot_reduction && AccountFreeMarginCheck(ChartSymbol(),OP_SELL,LOT)<0)
         {
            while(AccountFreeMarginCheck(ChartSymbol(),OP_SELL,LOT)<0 && LOT>MarketInfo(ChartSymbol(),MODE_MINLOT))
            {
               LOT-=MarketInfo(ChartSymbol(),MODE_MINLOT);
               LOT=NormalizeDouble(LOT,2);
            }
         }
         lots=LOT;
     
     
         S=OrderSend(ChartSymbol(),OP_SELL,lots,MarketInfo(ChartSymbol(),MODE_BID),0,sl,tp,WindowExpertName(),MagicNumber,0,clrRed);
         
         if(S)
         {
            LastSellTime=int(TimeCurrent());
            sell_candle=Bars;
            SHORT=FALSE;
            //PauseTest();
         }
      }
      time=Time[0];
   }
   return;
}
  
//+------------------------------------------------------------------+

void check_fractals2()
{
   size=0;
   
   for(int f=0;f<100;f++)
   {
      if(iFractals(ChartSymbol(),0,MODE_UPPER,f)!=0)
      {
         size++;
         
         fractal[size-1]=iFractals(ChartSymbol(),0,MODE_UPPER,f);
         fractal_candle[size-1]=f;
         fractal_dir[size-1]=1;
         //make_arrow("fract "+f,1,fractal[size-1],Time[f],4,241,clrCyan);
      }

      if(iFractals(ChartSymbol(),0,MODE_LOWER,f)!=0)
      {
      
         size++;
         
         fractal[size-1]=iFractals(ChartSymbol(),0,MODE_LOWER,f);
         fractal_candle[size-1]=f;
         fractal_dir[size-1]=-1;
         //make_arrow("fract "+f,-1,fractal[size-1],Time[f],4,241,clrMagenta);
      }
   }
   
   return;
}


int check_long_short(int shift)
{
    
      LONG=FALSE;
      SHORT=FALSE;
      bool up=false;
      bool dn=false;
      
      
      up=  
      (
      fractal_dir[shift]==1 && 
      fractal_dir[shift+1]==-1 && 
      fractal_dir[shift+2]==1 &&
      fractal_dir[shift+3]==-1 &&
      //fractal_dir[shift+4]==-1 &&
      
      iClose(ChartSymbol(),0,0)<fractal[shift] &&
      iClose(ChartSymbol(),0,0)>fractal[shift+1] &&
      iClose(ChartSymbol(),0,0)<fractal[shift+2] &&
      iClose(ChartSymbol(),0,0)>fractal[shift+3] &&
            
      fractal[shift]>fractal[shift+1] &&
      fractal[shift]>fractal[shift+2] &&
      fractal[shift]>fractal[shift+3] &&
      //fractal[shift]<fractal[shift+4] &&
      
      fractal[shift+1]<fractal[shift+2] &&
      fractal[shift+1]<fractal[shift+3]);// &&
      //fractal[shift+1]>fractal[shift+4]);
      
     
      dn=
      (  
      fractal_dir[shift]==-1 && 
      fractal_dir[shift+1]==1 && 
      fractal_dir[shift+2]==-1 &&
      fractal_dir[shift+3]==1 &&
      //fractal_dir[shift+4]==1 &&
      
      iClose(ChartSymbol(),0,0)>fractal[shift] &&
      iClose(ChartSymbol(),0,0)<fractal[shift+1] &&
      iClose(ChartSymbol(),0,0)>fractal[shift+2] &&
      iClose(ChartSymbol(),0,0)<fractal[shift+3] &&
      
      fractal[shift]<fractal[shift+1] &&
      fractal[shift]<fractal[shift+2] &&
      fractal[shift]<fractal[shift+3] &&
      //fractal[shift]>fractal[shift+4] &&
      
      fractal[shift+1]>fractal[shift+2] &&
      fractal[shift+1]>fractal[shift+3]);// &&
      //fractal[shift+1]<fractal[shift+4]);
        
      color c;
      int style;
      if(up){c=color_long;}
      else
      if(dn){c=color_short;}
      else
      c=clrNONE; 
        
      if(up || dn)
      {
        
         for(int t=shift;t<shift+3;t++)
         {
            make_trend(
            IntegerToString(Time[fractal_candle[t]]),
            Time[fractal_candle[t]],         
            fractal[t],
            Time[fractal_candle[t+1]],        
            fractal[t+1],
            
            c,line_width,style);
             
         }   
         
         make_trend(IntegerToString(Time[1]),
               Time[0],iClose(ChartSymbol(),0,0),
               Time[fractal_candle[0]],fractal[0],
               c,1,STYLE_DASH);
      }
         
    
      if(
         (!Use_reverse && up)// && fractal_candle[shift]<2)
         ||
         (Use_reverse && dn)// && fractal_candle[shift]<2)
      )
      {
         LONG=TRUE;
         
         make_arrow(
            "BUY "+IntegerToString(Time[fractal_candle[shift]]),
            1,
            iClose(Symbol(),0,0),
            Time[0],arrow_size,arrow_code_up,color_long
         );
         
         if(alert_time !=Time[0])// && fractal_candle[shift]<3)
         {
            Alert(ChartSymbol()+"  LONG CANDLE "+fractal_candle[shift]+"  Period() "+Period()+"  Time "+Time[shift]+"  TRADE LONG NOW");
            PlaySound("alert");
            alert_time=Time[0];
         }
      }
      
          
      if(
         (!Use_reverse && dn)
         ||
         (Use_reverse && up)
      )
      {
         SHORT=TRUE;
         
         make_arrow(
            "SELL "+IntegerToString(Time[fractal_candle[shift]]),
            -1,
            iClose(Symbol(),0,0),
            Time[0],arrow_size,arrow_code_up,color_short
         );
        
         if(alert_time!=Time[0])// && fractal_candle[shift]<3)
         {
            
            Alert(ChartSymbol()+"  SHORT CANDLE "+fractal_candle[shift]+"  Period() "+Period()+"  Time "+Time[shift]+"  TRADE SHORT NOW");
            PlaySound("alert");
            alert_time=Time[0];
         }
      }
            
      return(0);
         
}

void trailing_stop()
{
   for(int pos=OrdersTotal()-1;pos>=0;pos--)
   {
      bool t = OrderSelect(pos,SELECT_BY_POS,MODE_TRADES);
      
      if(t && OrderSymbol()==ChartSymbol() && OrderMagicNumber()==MagicNumber)
      {
         if(t)
         {
            if(OrderType()==OP_BUY && (OrderStopLoss()==0 || OrderStopLoss()<MarketInfo(ChartSymbol(),MODE_BID)-TrailingStopPoints))
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(ChartSymbol(),MODE_BID)-TrailingStopPoints,OrderTakeProfit(),0,clrBlue);
            }
         }
         
         if(t)
         {
            if(OrderType()==OP_SELL && (OrderStopLoss()==0 || OrderStopLoss()>MarketInfo(ChartSymbol(),MODE_ASK)+TrailingStopPoints))
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),MarketInfo(ChartSymbol(),MODE_ASK)+TrailingStopPoints,OrderTakeProfit(),0,clrRed);
            }
         }
      }
   }


   return;
}

void squeeze(string sym)
{
   double squeeze_stop;
   double new_tp;
   //if(Use_TP==false)return;
   
   for(int i=0;i<OrdersTotal();i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==sym && OrderMagicNumber()==MagicNumber)
      {         
         if(OrderType()==OP_BUY && OrderTakeProfit()!=0)
         {
            squeeze_stop = (OrderTakeProfit()-MarketInfo(OrderSymbol(),MODE_BID));
            double sq_sl = MarketInfo(OrderSymbol(),MODE_ASK)-squeeze_stop;
            sq_sl = NormalizeDouble(sq_sl,MarketInfo(OrderSymbol(),MODE_DIGITS));
            
            if( OrderStopLoss()<sq_sl || OrderStopLoss()==0)
            {
               if(  (Squeeze_only_in_profit && sq_sl>OrderOpenPrice())|| !Squeeze_only_in_profit)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),sq_sl,OrderTakeProfit(),0,Blue);
               }
            
               
            }
         }
      
         if(OrderType()==OP_SELL && OrderTakeProfit()!=0)
         
         {
            squeeze_stop = (MarketInfo(OrderSymbol(),MODE_ASK)-OrderTakeProfit()); 
            double sq_sl = MarketInfo(OrderSymbol(),MODE_ASK)+squeeze_stop;
            sq_sl = NormalizeDouble(sq_sl,MarketInfo(OrderSymbol(),MODE_DIGITS));
            
            if( OrderStopLoss()>sq_sl || OrderStopLoss()==0 )
            {
               if(  (Squeeze_only_in_profit && sq_sl<OrderOpenPrice()) || !Squeeze_only_in_profit)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),sq_sl,OrderTakeProfit(),0,Red);  
               }
                  
            }
         }
      }
   }
   return;
}


bool close_all_trades_of_type(int type)
{
   double closePrice=0;
   bool closed=false;
   
   if(type == OP_BUY && buys>0)closePrice=MarketInfo(ChartSymbol(),MODE_BID);
   if(type == OP_SELL && sells>0)closePrice=MarketInfo(ChartSymbol(),MODE_ASK); 
   
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if
      (
         OrderType()==type && type<2 &&
         OrderMagicNumber()==MagicNumber &&
         OrderSymbol()==ChartSymbol()
      )
      closed = OrderClose(OrderTicket(),OrderLots(),closePrice,0,Gold);
      
      if
      (
         OrderType()==type && type>1 &&
         OrderMagicNumber()==MagicNumber &&
         OrderSymbol()==ChartSymbol()
      )
      OrderDelete(OrderTicket());
      
   }
   
   return(closed);
}

void make_hline(string name,int t1,double p1,color c,int width, int style)
{
   name=id+name;
   ObjectCreate(0,name,OBJ_HLINE,0,0,0);
   ObjectSet(name,OBJPROP_COLOR,c);
   ObjectSet(name,OBJPROP_WIDTH,width);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectSetText(name,name);
   ObjectMove(name,0,t1,p1);
   return;
}

void make_text(string name,string text,double p1,color c, datetime t1,double angle, int size)
{
   name=id+name;
   ObjectCreate(0,name,OBJ_TEXT,0,0,0);
   ObjectSetText(name,text,size,"",c);
   ObjectSet(name,OBJPROP_ANGLE,angle);
   ObjectMove(0,name,0,t1,p1);
   return;
}


void make_vline(string name,int t1,double p1,color c,int width, int style)
{
   name=id+name;
   ObjectCreate(0,name,OBJ_VLINE,0,0,0);
   ObjectSet(name,OBJPROP_COLOR,c);
   ObjectSet(name,OBJPROP_WIDTH,width);
   ObjectSet(name,OBJPROP_STYLE,style);
   ObjectMove(name,0,t1,p1);
   return;
}


void make_trend(string name, int t1, double p1, int t2, double p2,color c, int w, int s)
{
   name=id+name;
   ObjectCreate(name,OBJ_TREND,0,t1,p1,t2,p2);
   ObjectMove(name,0,t2,p2);
   ObjectMove(name,1,t1,p1);
   ObjectSet(name,OBJPROP_RAY,0);
   ObjectSet(name,OBJPROP_COLOR,c);
   ObjectSet(name,OBJPROP_WIDTH,w);
   ObjectSet(name,OBJPROP_STYLE,s);
   ObjectSetText(name,name);

   return;
}

void make_label(string name,int x,int y,color c,string text,string font_type, int font_size,int cnr)
{
   name=id+name;
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_COLOR,c);
   ObjectSet(name,OBJPROP_CORNER,cnr);
   ObjectSetText(name,text,font_size,font_type,c);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   return;
}

/*
void make_arrow(string name,int dir, double p1, datetime t1,int size, color c)
{
   int object_type=-1;
   if(dir>0)object_type=OBJ_ARROW_UP;
   if(dir<0)object_type=OBJ_ARROW_DOWN;
   
   name=id+name;
      ObjectCreate(0,name,object_type,0,0,0);
      ObjectSet(name,OBJPROP_COLOR,c);
      ObjectSet(name,OBJPROP_WIDTH,size);
      ObjectMove(0,name,0,t1,p1);
      
   return;
}
*/
void make_arrow(string name,int dir, double p1, datetime t1,int size, int code, color c)
{
   int ac;
   int object_type=-1;
   if(dir>0)ac=code;
   if(dir<0)ac=code+1;
   
   if(dir>0)object_type=OBJ_ARROW_UP;
   if(dir<0)object_type=OBJ_ARROW_DOWN;
   
   name=id+name;
      ObjectCreate(0,name,object_type,0,0,0);
      ObjectSet(name,OBJPROP_ARROWCODE,ac);
      if(dir<0)ObjectSet(name,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      ObjectSet(name,OBJPROP_COLOR,c);
      ObjectSet(name,OBJPROP_WIDTH,size);
      ObjectMove(0,name,0,t1,p1);
      
   return;
}

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