// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71660

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

//+------------------------------------------------------------------------------------------------+
//|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
//|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
//|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
//|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
// #include <FrameWork/Schedule/ScheduleController.mqh>

enum enumDays { sunday, monday, tuesday, wednesday, thursday, friday, saturday, EA_OFF};

// Inputs
//+------------------------------------------------------------------+
input int    Magico    = 527;    // Magic Number:
input int    maxTrades = 1;      // Trades By Session:
input double userLot   = 0.10;   // Initial Lot:
input int    pipBuy    = 10;     // Pip to Buy Stop :
input int    pipSell   = 10;     // Pip to Sell Stop :
input int    pipTP     = 15;     // Pips Take Profit:
input int    pipSL     = 15;     // Pips Stop Loss:

// Martingale:
input string   TMartingale = "Martingale Setup";  // ** Martingale **
enum Martingale_Type { Not_Use_Martingale, Hedge, Lot_Multiplier };
input Martingale_Type martingale = Not_Use_Martingale; // Martingale Type
input double multi1   = 2;      // Lot Multiplier 1st Hedge or Martingale:
input double multi2   = 1.5;    // Lot Multiplier next Hedges:

// global variables:
int qntTrades              = 0;

//--- Schedule Control
enumDays       days[14];
string         iniTm[14];
string         endTm[14];

input string   THorarios = "Daily Control";  // ** Daily Control **
input enumDays days0       = "sunday";         // Day:
input string   iniTm0    = "00:00";          // Initial Time:
input string   endTm0     = "00:00";          // End Time:
input enumDays days1       = "sunday";         // Day:
input string   iniTm1    = "00:00";          // Initial Time:
input string   endTm1     = "00:00";          // End Time:
input enumDays days2       = "sunday";         // Day:
input string   iniTm2    = "00:00";          // Initial Time:
input string   endTm2     = "00:00";          // End Time:
input enumDays days3       = "sunday";         // Day:
input string   iniTm3    = "00:00";          // Initial Time:
input string   endTm3     = "00:00";          // End Time:
input enumDays days4       = "sunday";         // Day:
input string   iniTm4    = "00:00";          // Initial Time:
input string   endTm4     = "00:00";          // End Time:
input enumDays days5       = "sunday";         // Day:
input string   iniTm5    = "00:00";          // Initial Time:
input string   endTm5     = "00:00";          // End Time:
input enumDays days6       = "sunday";         // Day:
input string   iniTm6    = "00:00";          // Initial Time:
input string   endTm6     = "00:00";          // End Time:
input enumDays days7       = "sunday";         // Day:
input string   iniTm7    = "00:00";          // Initial Time:
input string   endTm7     = "00:00";          // End Time:
input enumDays days8       = "sunday";         // Day:
input string   iniTm8    = "00:00";          // Initial Time:
input string   endTm8     = "00:00";          // End Time:
input enumDays days9       = "sunday";         // Day:
input string   iniTm9    = "00:00";          // Initial Time:
input string   endTm9    = "00:00";          // End Time:
input enumDays days10       = "sunday";         // Day:
input string   iniTm10    = "00:00";          // Initial Time:
input string   endTm10    = "00:00";          // End Time:
input enumDays days11       = "sunday";         // Day:
input string   iniTm11    = "00:00";          // Initial Time:
input string   endTm11    = "00:00";          // End Time:
input enumDays days12       = "sunday";         // Day:
input string   iniTm12    = "00:00";          // Initial Time:
input string   endTm12    = "00:00";          // End Time:
input enumDays days13       = "sunday";         // Day:
input string   iniTm13    = "00:00";          // Initial Time:
input string   endTm13    = "00:00";          // End Time:

//--- Global var:
//+------------------------------------------------------------------+
enum Modalidad { Automatic,
                 SemiAutomatic };
enum CompraVenta { Buy, Sell, Both };

//--- zone:
double      PrecioBuy;
double      PrecioSell;
int         timeSetZone;
int         daySetZone;
Modalidad   Modo = Automatic;  // Mode:
CompraVenta tipo = Both;       // First Operation in Automatic Mode:

int         MM   = 30;         // Media Móvil para Modo automático:
double      TicketsCiclo[];
int         TKOperacionInicial;
double      PrecioCobVenta, PrecioCobCompra;
bool        HabilitadoParaIniciar, HayCobertura;
//---


// Expert initialization function
//+------------------------------------------------------------------+
int OnInit()
{
   SetZone();
   schedule = new ScheduleController();
   setSchedules();
   schedule.PrintDays();

   return (INIT_SUCCEEDED);
}

// Expert deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   schedule.ClearShchedules();
   delete schedule;
}

// Expert tick function
//+------------------------------------------------------------------+
void OnTick()
{
   if (schedule.doDailyControl())
   {
      if(timeSetZone > schedule.at().endTime() || timeSetZone < schedule.at().iniTime()){
         Print(__FUNCTION__," ","schedule.at().iniTime()"," ",schedule.at().iniTime());
         SetZone();         
         showLines(true);
      }
      
      if(qntTrades < maxTrades){ 
         AbrirOperacion();
         HabilitarCiclo();
      }
   } else 
   {
      showLines(false);
      if(qntTrades > 0){ releaseTrades(); }
   }

   if(martingale == Hedge)
   { 
      AbrirCobertura();
      ControlCiclo();
      CargarAlArray();
      ControlarOrdenesDelCiclo();
   }
}

//+------------------------------------------------------------------+
void SetZone()
{
   PrecioBuy  = Ask + (pipBuy * 10 * _Point);
   PrecioSell = Bid - (pipSell * 10 * _Point);

   // time:
   timeSetZone  = TimeHour(TimeGMT()) * 3600 + TimeMinute(TimeGMT()) * 60;
   daySetZone   = TimeDayOfWeek(TimeGMT());
   
   
}

//+------------------------------------------------------------------+
void AbrirOperacion()
{
   if (Modo == SemiAutomatic) { return; }

   double TPauto, SLauto;

   //cuando cierre una vela arriba de la ema Buy:
   if (tipo == Both || tipo == Buy)
   {
      if (HabilitadoParaIniciar)
      {
         if (Ask >= PrecioBuy && Ask <= PrecioBuy + 20 * _Point)
         {
            TPauto = Ask + pipTP * _Point * 10;
            SLauto = Ask - pipSL * _Point * 10;
            int tk = OrderSend(Symbol(), OP_BUY, Lots(), Ask, 25, SLauto, TPauto, NULL, Magico, 0, clrNONE);
            if (tk > 0) 
            {
               HabilitadoParaIniciar = false;
               sumTrade();
               deleteHLine("BuyStop");
            }

            bool sel = OrderSelect(tk, SELECT_BY_TICKET);
            if (sel)
            {
               PrecioCobVenta  = OrderOpenPrice() - pipSell * _Point * 10;
               PrecioCobCompra = OrderOpenPrice();
            }
         }
      }
   }
   //cuando cierre una vela abajo de la ema Sell:
   if (tipo == Both || tipo == Sell)
   {
      if (HabilitadoParaIniciar)
      {
         if (Bid <= PrecioSell && Bid >= PrecioSell - 20 * _Point)
         {
            TPauto = Bid - pipTP * _Point * 10;
            SLauto = Bid + pipSL * _Point * 10;
            int tk = OrderSend(Symbol(), OP_SELL, Lots(), Bid, 25, SLauto, TPauto, NULL, Magico, 0, clrNONE);

            // HabilitarCiclo();
            if (tk > 0) {
               HabilitadoParaIniciar = false;
               sumTrade();
               deleteHLine("SellStop");
            }
            
            bool sel = OrderSelect(tk, SELECT_BY_TICKET);
            if (sel)
            {
               PrecioCobVenta  = OrderOpenPrice();
               PrecioCobCompra = OrderOpenPrice() + pipBuy * _Point * 10;
            }
         }
      }
   }
}

double Lots()
{
   double lotLastTrade;
   if(martingale == Lot_Multiplier){
      if(LastTradeWasLosser(lotLastTrade))
      {
         return lotLastTrade * multi1;
      }
   }

   return userLot;
}

bool LastTradeWasLosser(double &lotLastTrade)
{
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magico) {
        if (OrderProfit() < 0) 
        {
           lotLastTrade = OrderLots();
           return true; 
         } else { return false; }
      }
   }

   return false;
}

//+------------------------------------------------------------------+
void HabilitarCiclo()
{
   //reinicio el HabilitadoParaIniciar
   HabilitadoParaIniciar = true;

   //si hay operaciones en el par, poner HabilitadoParaIniciar en false (para evitar Inicio de Ciclo)
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
      {
         HabilitadoParaIniciar = false;
         break;
      }
   }

   
}

//Cuando el Usuario abre un trade vá a colocar solo el TP
//Cuando detecte un cambio en el TP <<<<
//esta función tiene que poner el Stop al doble de la distancia del TP
//+------------------------------------------------------------------+
void modificarOperaciones()
{
   if (HabilitadoParaIniciar == true)
   {
      return;
   }  //no tengo operaciones abiertas

   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
      {
         if (OrderTakeProfit() != 0 && OrderStopLoss() == 0)
         {
            double pipsTP = fabs(OrderTakeProfit() - OrderOpenPrice()) / _Point;
            double pipsSL = pipsTP * 2;
            if (OrderType() == OP_BUY)
            {
               double SL = OrderOpenPrice() - (pipsSL * _Point);
               if (OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), 0, clrNONE))
               {
                  //si la pudo modificar recalcula los precios de cobertura
                  PrecioCobVenta  = OrderOpenPrice() - pipTP * _Point;
                  PrecioCobCompra = OrderOpenPrice();
               }
            }
            if (OrderType() == OP_SELL)
            {
               double SL = OrderOpenPrice() + (pipsSL * _Point);
               if (OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), 0, clrNONE))
               {
                  //si la pudo modificar recalcula los precios de cobertura
                  PrecioCobCompra = OrderOpenPrice() + pipTP * _Point;
                  PrecioCobVenta  = OrderOpenPrice();
               }
            }
         }
      }
   }
}

//Vá a cubrir la última operación con el determinado lotaje
//siempre tiene que haber una operación pendiente, que es cobertura de la última
//de modo que si no tengo ninguna pendiente, significa que tiene que abrir una cobertura
//+------------------------------------------------------------------+
void AbrirCobertura()
{
   int contar   = 0;
   HayCobertura = false;

   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magico)
      {
         if (OrderType() != OP_BUY && OrderType() != OP_SELL)
         {
            HayCobertura = true;
         }
      }
   }

   //Buscar si la cobertura es la primera para calcular el lotaje
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magico)
      {
         contar++;
      }
   }

   //si no hay cobertura tiene que abrirla
   if (!HayCobertura)
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magico)
         {
            double multiplicadorLotaje;
            contar == 1 ? multiplicadorLotaje = multi1 : multiplicadorLotaje = multi2;
            //si contar es 1, es la primera del ciclo, tomo el tk para controlar fin del ciclo
            if (contar == 1)
            {
               TKOperacionInicial = OrderTicket();               
            }
            //abro la cobertura
            if (OrderType() == OP_BUY)
            {
               double TPcob = PrecioCobVenta - (pipTP * 10 * _Point);
               if (!OrderSend(Symbol(), OP_SELLSTOP, OrderLots() * multiplicadorLotaje, PrecioCobVenta, 50, 0, TPcob, "cobertura", 0, 0, clrNONE)) {}
               break;
            }
            if (OrderType() == OP_SELL)
            {
               double TPcob = PrecioCobCompra + (pipTP * 10 * _Point);
               if (!OrderSend(Symbol(), OP_BUYSTOP, OrderLots() * multiplicadorLotaje, PrecioCobCompra, 50, 0, TPcob, "cobertura", 0, 0, clrNONE)) {}
               break;
            }
         }
      }
   }
}

//Cierra un ciclo si saltan stops o TP de la orden original
//+------------------------------------------------------------------+
void ControlCiclo()
{
   if (OrderSelect(TKOperacionInicial, SELECT_BY_TICKET))
   {
      if (OrderCloseTime() > 0)
      {
         CloseAll();
      }
   }
}

//+------------------------------------------------------------------+
void sumTrade()
{
   qntTrades = qntTrades + 1 ;
   Print(__FUNCTION__," ","qntTrades"," ",qntTrades);
}

int qntTrades()
{
   return qntTrades;
}

void releaseTrades()
{
   qntTrades=0;
   Print(__FUNCTION__," ","qntTrades"," ",qntTrades);
}

//+------------------------------------------------------------------+



void CloseAll()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
      {
         if (OrderType() != OP_BUY && OrderType() != OP_SELL)
         {
            OrderDelete(OrderTicket());
         }
         if (OrderType() == OP_BUY)
         {
            OrderClose(OrderTicket(), OrderLots(), Bid, 30, clrNONE);
         }
         if (OrderType() == OP_SELL)
         {
            OrderClose(OrderTicket(), OrderLots(), Ask, 30, clrNONE);
         }
      }
   }
   ArrayFree(TicketsCiclo);
   
}

//+------------------------------------------------------------------+
// tiene que cargar operaciones nueva abiertas al array
//+------------------------------------------------------------------+
void CargarAlArray()
{
   double tk;
   int    size = ArraySize(TicketsCiclo);

   if (size > 0)
   {
      ArraySort(TicketsCiclo, WHOLE_ARRAY, 0, MODE_ASCEND);
   }

   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
      {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL)
         {
            tk = OrderTicket();
            if (size == 0)
            {
               ArrayResize(TicketsCiclo, 1);
               TicketsCiclo[0] = tk;
            } else
            {
               int j = ArrayBsearch(TicketsCiclo, tk, WHOLE_ARRAY, 0, MODE_ASCEND);
               if (TicketsCiclo[j] != tk)
               {
                  ArrayResize(TicketsCiclo, size + 1);
                  TicketsCiclo[size] = tk;
                  Print("Agregué al Array el tk: ", tk);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//Controlar si alguna orden del array se cierra
//en caso de true, llamar a cerrar todas
//+------------------------------------------------------------------+
void ControlarOrdenesDelCiclo()
{
   double tk;
   int    p = ArraySize(TicketsCiclo) - 1;
   if (p <= 0)
   {
      return;
   }

   while (p != 0)
   {
      tk = TicketsCiclo[p];
      OrderSelect(tk, SELECT_BY_TICKET);
      if (OrderCloseTime() > 0)
      {
         CloseAll();
         break;
      }
      p--;
   }
}

//+------------------------------------------------------------------+                 
bool drawHLine(  double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const string          name="HLine",      // line name 
                 const long            chart_ID=0,        // chart's ID 
                 const int             sub_window=0,      // subwindow index 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=false)   // highlight to move 
{ 
   //--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a horizontal line! Error code = ",GetLastError()); 
      return(false); 
     } 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   return(true); 
} 
//+------------------------------------------------------------------+
void showLines(bool state)
{
   if(state){
      drawHLine(PrecioBuy, clrBlue, "BuyStop");
      drawHLine(PrecioSell, clrRed, "SellStop");
   } else {
      deleteHLine("BuyStop");
      deleteHLine("SellStop");
   }
}
//+------------------------------------------------------------------+
bool deleteHLine(string name)
{
   if(ObjectDelete(0,name)){ return true;
   } else { Print("Error: can't delete Hline #",GetLastError()); } 

   return false;
}

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// Sessions Controller
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

void setSchedules()
{
   days[0]  = days0  ;
   iniTm[0] = iniTm0 ;
   endTm[0] = endTm0 ;
   days[1]  = days1  ;
   iniTm[1] = iniTm1 ;
   endTm[1] = endTm1 ;
   days[2]  = days2  ;
   iniTm[2] = iniTm2 ;
   endTm[2] = endTm2 ;
   days[3]  = days3  ;
   iniTm[3] = iniTm3 ;
   endTm[3] = endTm3 ;
   days[4]  = days4  ;
   iniTm[4] = iniTm4 ;
   endTm[4] = endTm4 ;
   days[5]  = days5  ;
   iniTm[5] = iniTm5 ;
   endTm[5] = endTm5 ;
   days[6]  = days6  ;
   iniTm[6] = iniTm6 ;
   endTm[6] = endTm6 ;
   days[7]  = days7  ;
   iniTm[7] = iniTm7 ;
   endTm[7] = endTm7 ;
   days[8]  = days8  ;
   iniTm[8] = iniTm8 ;
   endTm[8] = endTm8 ;
   days[9]  = days9  ;
   iniTm[9] = iniTm9 ;
   endTm[9] = endTm9 ;
   days[10] = days10 ;
   iniTm[10]= iniTm10;
   endTm[10]= endTm10;
   days[11] = days11 ;
   iniTm[11]= iniTm11;
   endTm[11]= endTm11;
   days[12] = days12 ;
   iniTm[12]= iniTm12;
   endTm[12]= endTm12;
   days[13] = days13 ;
   iniTm[13]= iniTm13;
   endTm[13]= endTm13;
 
 
   for(int i=0;i < 14;i++)
   {
      int day = (int)days[i];
      schedule.AddSession(day, iniTm[i], endTm[i]);   
   }  
   
}




class Session
{
   int _dayNumber;
   int _iniTime; // second from 00:00 hr of the day
   int _endTime;

  public:
   // receive time in format 00:00
   Session(int dayNumber, string iniTime, string endTime)
   {
      _dayNumber = dayNumber;
      _iniTime   = secondsFromZeroHour(iniTime); 
      _endTime   = secondsFromZeroHour(endTime); 
   };
   
   ~Session() {}

	int      dayNumber(){return _dayNumber;}
   int      iniTime()  {return _iniTime;}
   int      endTime()  {return _endTime;}

   int secondsFromZeroHour(string time)
   {
      int hh     = (int)StringSubstr(time, 0, 2);
      int mm     = (int)StringSubstr(time, 3, 2);
      
      return (hh * 3600) + (mm * 60);
   }

};

//--- v 2.0
class ScheduleController
{
   Session* schedules[];
   int      _actualIndex;
   Session* _actualSession;

  public:
   ScheduleController(){};
   ~ScheduleController() { 
      ClearShchedules();
   }

   Session* at() { return _actualSession; }

   //+------------------------------------------------------------------+
   void setActualSession(int index)
   {
      _actualIndex  = index;
      
      if(index > -1){
         _actualSession = schedules[index];
      }
   }   
   //+------------------------------------------------------------------+
   int qnt()
   {
      return ArraySize(schedules);
   }

        //+------------------------------------------------------------------+
	bool AddSession(int day, string ini, string end)
	{
      Session* sc = new Session(day, ini, end);
      int       t  = qnt();
      if (ArrayResize(schedules, t + 1))
      {
         schedules[t] = sc;
         return true;
      }

      return false;
	}
	
   //+------------------------------------------------------------------+
	bool ClearShchedules()
	{
      for(int i=0;i < qnt();i++)
      {
         delete schedules[i];
      }
      ArrayFree(schedules);
   
      return true;
   }
   
   //+------------------------------------------------------------------+
   bool doDailyControl()
   {
      Comment("Daily Control - EA OFF");
      
      int actual = (TimeHour(TimeGMT()) * 3600) + (TimeMinute(TimeGMT()) * 60);

      for (int i = 0; i < qnt(); i++) 
      {
         if(schedules[i].dayNumber() == EA_OFF) {return false;}
         
         if (schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT()))
         {
            if (( actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime() )
            {
               setActualSession(i);
               Comment("Daily Control - EA ON");
               return true;
            }
         }
      }

      //---
      setActualSession(-1);
      return false;
   }

   //+------------------------------------------------------------------+
   void PrintDays()
   {
      for (int i = 0; i < qnt(); i++)
      {
         PrintDay(i);
      }
   }

   //+------------------------------------------------------------------+
   void PrintDay(int i)
   {
      Print("Day Nr: ",       schedules[i].dayNumber());
      Print("Day Ini Time: ", schedules[i].iniTime());
      Print("Day End Time: ", schedules[i].endTime());
   }


};

ScheduleController* schedule;

