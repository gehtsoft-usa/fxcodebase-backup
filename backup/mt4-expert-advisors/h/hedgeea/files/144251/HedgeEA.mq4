// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71642


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


// Inputs
//+------------------------------------------------------------------+
input int         Magico       = 0;               // Magic Number:
input double      LoteAuto     = 0.10;            // Initial Lot:
input int         pipZone      = 5;               // Pips Zone:
input int         pipTP        = 15;              // Pips Take Profit:
input double      multi1       = 2;               // Lot Multiplier 1st Hedge:
input double      multi2       = 1.5;             // Lot Multiplier next Hedges:

//--- daily control
//+------------------------------------------------------------------+
input string THorarios    = "Daily Control";  // ** Daily Control **
input bool   SundayOn     = false;            // Sunday ON:
input string SundayIni    = "00:00";          // Sunday Start Time (format hh:mm):
input string SundayFin    = "00:00";          // Sunday Finish Time:
input bool   MondayOn     = false;            // Monday ON:
input string MondayIni    = "00:00";          // Monday Start Time:
input string MondayFin    = "00:00";          // Monday Finish Time:
input bool   TuesdayOn    = false;            // Tuesday ON:
input string TuesdayIni   = "00:00";          // Tuesday Start Time:
input string TuesdayFin   = "00:00";          // Tuesday Finish Time:
input bool   WednesdayOn  = false;            // Wednesday ON:
input string WednesdayIni = "00:00";          // Wednesday Start Time:
input string WednesdayFin = "00:00";          // Wednesday Finish Time:
input bool   ThursdayOn   = false;            // Thursday ON:
input string ThursdayIni  = "00:00";          // Thursday Start Time:
input string ThursdayFin  = "00:00";          // Thursday Finish Time:
input bool   FridayOn     = false;            // Friday ON:
input string FridayIni    = "00:00";          // Friday Start Time:
input string FridayFin    = "00:00";          // Friday Finish Time:
input bool   SaturdayOn   = false;            // Saturday ON:
input string SaturdayIni  = "00:00";          // Saturday Start Time:
input string SaturdayFin  = "00:00";          // Saturday Finish Time:

//--- Global var:
//+------------------------------------------------------------------+
enum Modalidad { Automatic,
                 SemiAutomatic };
enum CompraVenta { Buy,
                   Sell,
                   Both };
//--- zone:
double PrecioBuy;
double PrecioSell;
Modalidad   Modo         = Automatic;       // Mode:
CompraVenta tipo         = Both;            // First Operation in Automatic Mode:
int         MM           = 30;              // Media Móvil para Modo automático:
double TicketsCiclo[];
int       TKOperacionInicial;
double    PrecioCobVenta, PrecioCobCompra;
bool      HabilitadoParaIniciar, HayCobertura;

// Expert initialization function
//+------------------------------------------------------------------+
int OnInit() 
{
   SetZone();
   ctrlHorarios.setDailyControl();
   ctrlHorarios.PrintDays();

   return (INIT_SUCCEEDED); 
}

// Expert deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

// Expert tick function
//+------------------------------------------------------------------+
void OnTick() {
   if (ctrlHorarios.doDailyControl()) {
      // MostrarHorarios();
      AbrirOperacion();
      HabilitarCiclo();
      // modificarOperaciones();
      
   }else{
      Comment("Out of hourly - EA Off");   
   }

   AbrirCobertura();
   ControlCiclo();
   CargarAlArray();
   ControlarOrdenesDelCiclo();
}


//+------------------------------------------------------------------+
void SetZone()
{
   PrecioBuy = Ask + (pipZone * 10 * _Point);
   PrecioSell = Bid - (pipZone * 10 * _Point);
}

//+------------------------------------------------------------------+
void AbrirOperacion() {
   if (Modo == SemiAutomatic) { return; }

   double TPauto, SLauto;

   //cuando cierre una vela arriba de la ema Buy:
   if (tipo == Both || tipo == Buy) {
      if (HabilitadoParaIniciar) {
         if (Ask >= PrecioBuy) {
            //calcular TP automático
            TPauto = Ask + pipTP * _Point * 10;
            //calcular SL auto
            // SLauto = Ask - pipAuto * 2 * _Point * 10;
            //mando la orden
            int tk = OrderSend(Symbol(), OP_BUY, LoteAuto, Ask, 25, 0, TPauto, NULL, 0, 0, clrNONE);
            // HabilitarCiclo();
            if (tk > 0) HabilitadoParaIniciar = false;
            bool sel = OrderSelect(tk, SELECT_BY_TICKET);
            //calcular precios de coberturas:
            if (sel) {
               PrecioCobVenta = OrderOpenPrice() - pipZone * _Point * 10;
               PrecioCobCompra = OrderOpenPrice();
            }
         }
      }
   }
   //cuando cierre una vela abajo de la ema Sell:
   if (tipo == Both || tipo == Sell) {
      if (HabilitadoParaIniciar) {
         if (Bid <= PrecioSell) {
            //calcular TP automático
            TPauto = Bid - pipTP * _Point * 10;
            //calcular SL auto
            // SLauto = Bid + pipAuto * 2 * _Point * 10;
            //mando la orden
            int tk = OrderSend(Symbol(), OP_SELL, LoteAuto, Bid, 25, 0, TPauto, NULL, 0, 0, clrNONE);
            // HabilitarCiclo();
            if (tk > 0) HabilitadoParaIniciar = false;
            bool sel = OrderSelect(tk, SELECT_BY_TICKET);
            //calcular precios de coberturas:
            if (sel) {
               PrecioCobVenta = OrderOpenPrice();
               PrecioCobCompra = OrderOpenPrice() + pipZone * _Point * 10;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
void HabilitarCiclo() {
   //reinicio el HabilitadoParaIniciar
   HabilitadoParaIniciar = true;
   //si hay operaciones en el par, poner HabilitadoParaIniciar en false (para evitar Inicio de Ciclo)
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
         HabilitadoParaIniciar = false;
         break;
      }
   }
}

//Cuando el Usuario abre un trade vá a colocar solo el TP
//Cuando detecte un cambio en el TP <<<<
//esta función tiene que poner el Stop al doble de la distancia del TP
//+------------------------------------------------------------------+
void modificarOperaciones() {
   if (HabilitadoParaIniciar == true) { return; }  //no tengo operaciones abiertas

   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
         if (OrderTakeProfit() != 0 && OrderStopLoss() == 0) {
            double pipsTP = fabs(OrderTakeProfit() - OrderOpenPrice()) / _Point;
            double pipsSL = pipsTP * 2;
            if (OrderType() == OP_BUY) {
               double SL = OrderOpenPrice() - (pipsSL * _Point);
               if (OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), 0, clrNONE)) {
                  //si la pudo modificar recalcula los precios de cobertura
                  PrecioCobVenta = OrderOpenPrice() - pipTP * _Point;
                  PrecioCobCompra = OrderOpenPrice();
               }
            }
            if (OrderType() == OP_SELL) {
               double SL = OrderOpenPrice() + (pipsSL * _Point);
               if (OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), 0, clrNONE)) {
                  //si la pudo modificar recalcula los precios de cobertura
                  PrecioCobCompra = OrderOpenPrice() + pipTP * _Point;
                  PrecioCobVenta = OrderOpenPrice();
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
void AbrirCobertura() {
   HayCobertura = false;
   int contar = 0;

   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magico) {
         if (OrderType() != OP_BUY && OrderType() != OP_SELL) {
            HayCobertura = true;
         }
      }
   }

   //Buscar si la cobertura es la primera para calcular el lotaje
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()&& OrderMagicNumber() == Magico) {
         contar++;
      }
   }

   //si no hay cobertura tiene que abrirla
   if (!HayCobertura) {
      for (int i = OrdersTotal() - 1; i >= 0; i--) {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()&& OrderMagicNumber() == Magico) {
            double multiplicadorLotaje;
            contar == 1 ? multiplicadorLotaje = multi1 : multiplicadorLotaje = multi2;
            //si contar es 1, es la primera del ciclo, tomo el tk para controlar fin del ciclo
            if (contar == 1) { TKOperacionInicial = OrderTicket(); }
            //abro la cobertura
            if (OrderType() == OP_BUY) {
               double TPcob = PrecioCobVenta - (pipTP * 10 * _Point);
               if (!OrderSend(Symbol(), OP_SELLSTOP, OrderLots() * multiplicadorLotaje, PrecioCobVenta, 50, 0, TPcob, "cobertura", 0, 0, clrNONE)) {}
               break;
            }
            if (OrderType() == OP_SELL) {
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
void ControlCiclo() {
   if (OrderSelect(TKOperacionInicial, SELECT_BY_TICKET)) {
      if (OrderCloseTime() > 0) { CloseAll(); }
   }
}

void CloseAll() {
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol()) {
         if (OrderType() != OP_BUY && OrderType() != OP_SELL) { OrderDelete(OrderTicket()); }
         if (OrderType() == OP_BUY) { OrderClose(OrderTicket(), OrderLots(), Bid, 30, clrNONE); }
         if (OrderType() == OP_SELL) { OrderClose(OrderTicket(), OrderLots(), Ask, 30, clrNONE); }
      }
   }
   ArrayFree(TicketsCiclo);
}


//+------------------------------------------------------------------+
// tiene que cargar operaciones nueva abiertas al array
//+------------------------------------------------------------------+
void CargarAlArray() {
   double tk;
   int    size = ArraySize(TicketsCiclo);

   if (size > 0) { ArraySort(TicketsCiclo, WHOLE_ARRAY, 0, MODE_ASCEND); }

   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            tk = OrderTicket();
            if (size == 0) {
               ArrayResize(TicketsCiclo, 1);
               TicketsCiclo[0] = tk;
            } else {
               int j = ArrayBsearch(TicketsCiclo, tk, WHOLE_ARRAY, 0, MODE_ASCEND);
               if (TicketsCiclo[j] != tk) {
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
void ControlarOrdenesDelCiclo() {
   double tk;
   int    p = ArraySize(TicketsCiclo) - 1;
   if (p <= 0) { return; }

   while (p != 0) {
      tk = TicketsCiclo[p];
      OrderSelect(tk, SELECT_BY_TICKET);
      if (OrderCloseTime() > 0) {
         CloseAll();
         break;
      }
      p--;
   }
}


////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// CONTROL DE HORARIO
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

class cControlDeHorarios
{
  private:
   struct DiaHora
   {
      string   name;
      int      dayOfWeek;
      bool     on;
      datetime horaIni;
      datetime horaFin;
   };
   DiaHora days[7];

  public:
   cControlDeHorarios();
   ~cControlDeHorarios();
   void setDailyControl();
   bool doDailyControl();
   void PrintDay(int i);
   void PrintDays();
};
cControlDeHorarios::cControlDeHorarios() {}
cControlDeHorarios::~cControlDeHorarios() {}

void cControlDeHorarios::setDailyControl()
{
   for (int i = 0; i < 7; i++)
   {
      switch (i)
      {
         case 0:
            days[i].name      = "Sunday";
            days[i].dayOfWeek = 0;
            days[i].on        = SundayOn;
            days[i].horaIni   = StringToTime(SundayIni);
            days[i].horaFin   = StringToTime(SundayFin);
            break;
         case 1:
            days[i].name      = "Monday";
            days[i].dayOfWeek = 1;
            days[i].on        = MondayOn;
            days[i].horaIni   = StringToTime(MondayIni);
            days[i].horaFin   = StringToTime(MondayFin);
            break;
         case 2:
            days[i].name      = "Tuesday";
            days[i].dayOfWeek = 2;
            days[i].on        = TuesdayOn;
            days[i].horaIni   = StringToTime(TuesdayIni);
            days[i].horaFin   = StringToTime(TuesdayFin);
            break;
         case 3:
            days[i].name      = "Wednesday";
            days[i].dayOfWeek = 3;
            days[i].on        = WednesdayOn;
            days[i].horaIni   = StringToTime(WednesdayIni);
            days[i].horaFin   = StringToTime(WednesdayFin);
            break;
         case 4:
            days[i].name      = "Thursday";
            days[i].dayOfWeek = 4;
            days[i].on        = ThursdayOn;
            days[i].horaIni   = StringToTime(ThursdayIni);
            days[i].horaFin   = StringToTime(ThursdayFin);
            break;
         case 5:
            days[i].name      = "Friday";
            days[i].dayOfWeek = 5;
            days[i].on        = FridayOn;
            days[i].horaIni   = StringToTime(FridayIni);
            days[i].horaFin   = StringToTime(FridayFin);
            break;
         case 6:
            days[i].name      = "Saturday";
            days[i].dayOfWeek = 6;
            days[i].on        = SaturdayOn;
            days[i].horaIni   = StringToTime(SaturdayIni);
            days[i].horaFin   = StringToTime(SaturdayFin);
            break;
      }
   }
}

//+------------------------------------------------------------------+
bool cControlDeHorarios::doDailyControl()
{
   Comment("Daily Control - EA OFF");
   
	for (int i = 0; i < 7; i++)
   {
      if(days[i].on)
      {
         if (days[i].dayOfWeek == TimeDayOfWeek(TimeGMT()))      
         {
               Print(__FUNCTION__," ","TimeDayOfWeek(TimeGMT()"," ",TimeDayOfWeek(TimeGMT()));
               Print(__FUNCTION__," ","TimeHour(TimeGMT()"," ",TimeHour(TimeGMT()));
               Print(__FUNCTION__," ","days[i].horaIni"," ",days[i].horaIni);

            if (TimeHour(TimeGMT()) >= TimeHour(days[i].horaIni) && TimeHour(TimeGMT()) <= TimeHour(days[i].horaFin))
            {
               Print(__FUNCTION__," ","TimeHour(TimeGMT()"," ",TimeHour(TimeGMT()));
               Print(__FUNCTION__," ","days[i].horaIni"," ",days[i].horaIni);
            if (TimeMinute(TimeGMT()) >= TimeMinute(days[i].horaIni) && TimeMinute(TimeGMT()) <= TimeMinute(days[i].horaFin))
            {
               Print(__FUNCTION__," ","TimeMinute(TimeGMT()"," ",TimeMinute(TimeGMT()));
               Print(__FUNCTION__," ","days[i].horaIni"," ",days[i].horaIni);
               Comment("Daily Control - EA ON");
               return true;
            }
            }
         }
      }
   }

   //--- 
   return false;
}

//+------------------------------------------------------------------+
void cControlDeHorarios::PrintDays()
{
   for (int i = 0; i < ArraySize(days); i++)
   {
      PrintDay(i);
   }
}

//+------------------------------------------------------------------+
void cControlDeHorarios::PrintDay(int i)
{
   Print("Day Name: ", days[i].name);
   Print("Day Nr: ", days[i].dayOfWeek);
   Print("Day On: ", days[i].on);
   Print("Day Hora Ini: ", days[i].horaIni);
   Print("Day Hora Fin: ", days[i].horaFin);
}

cControlDeHorarios ctrlHorarios;