// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72749

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
#property description "Mannual Mode: You open a trade and the EA make the Hedge"
#property description "Automatic Mode: The EA open the first trade, when some candle broke a moving average, then continue making hedge"
#property strict

#define MODE_ASCEND 0
#define MODE_DESCEND 1

enum Modalidad { Automatic,
                 Mannual
               };
enum CompraVenta { Compra,
                   Venta,
                   Ambos
                 };

// Gobal Variables
//+------------------------------------------------------------------+
input Modalidad Modo           = Mannual;   // Mode:
CompraVenta     tipo           = Ambos;     // Tipo de operación en Modo Automatic:
input int       MM             = 30;        // EMA Periods automátic mode:
input double    LoteAuto       = 0.10;      // Initial Lots:
input int       pipAuto        = 40;        // Pips Take Profit:
input double    uMultiplyFirst = 3;         // Multiply Lots First Time:
input double    uMultiply      = 2;         // Multiply Lots Second and after:
input string    s1             = "Timer:";  //******
input bool      ControlaHora   = false;     // Time Control:
extern int      HoraIni        = 0000;      // Initial Time (format hhmm) =
extern int      HoraFin        = 0000;      // End Time (format hhmm) =
// extern string     HoraIni = "00:00";        //Hora Inicio (formato hh:mm) =
// extern string     HoraFin = "00:00";        //Hora fin (formato hh:mm) =
input int AjusteHora;  // Adjust Server Time  (+/- Hrs):
ulong       TKOperacionInicial;
double    PrecioCobVenta, PrecioCobCompra;
bool      HabilitadoParaIniciar, HayCobertura;
MqlTradeResult result = {};
MqlTradeRequest request = {};
MqlTick p = {};
double TicketsCiclo[];
// Expert initialization function
//+------------------------------------------------------------------+
int OnInit() { return (INIT_SUCCEEDED); }

// Expert deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

// Expert tick function
//+------------------------------------------------------------------+
void OnTick()
  {
   if(ControlHorario())
     {
      MostrarHorarios();
      AbrirOperacion();
      HabilitarCiclo();
      modificarOperaciones();
     }
   else
     {
      Comment(" Out of time / EA Off");
     }
   AbrirCobertura();
   ControlCiclo();
   CargarAlArray();
   ControlarOrdenesDelCiclo();
  }

//+------------------------------------------------------------------+
void AbrirOperacion()
  {
   if(Modo == Mannual)
     {
      return;
     }
// points=MarketInfo(Symbol(),MODE_POINT);
   double ema = iMAa(Symbol(), 0, MM, 0, MODE_EMA, PRICE_CLOSE, 1);
   double C1  = iClose(Symbol(), 0, 1);
   double O1  = iOpen(Symbol(), 0, 1);
// double C2 = iClose(Symbol(), 0, 2);
   double O2 = iOpen(Symbol(), 0, 2);
   double TPauto, SLauto;
   int tk;
// cuando cierre una vela arriba de la ema Compra:
   SymbolInfoTick(Symbol(), p);
   if(tipo == Ambos || tipo == Compra)
     {
      if(HabilitadoParaIniciar)
        {
         if((C1 > ema && O1 < ema) || (C1 > ema && O2 < ema))
           {
            // calcular TP automático
            TPauto = p.ask + pipAuto * _Point * 10;
            // calcular SL auto
            SLauto = p.ask - pipAuto * 2 * _Point * 10;
            // mando la orden
            ZeroMemory(result);
            ZeroMemory(request);
            request.action = TRADE_ACTION_DEAL;
            request.symbol = Symbol();
            request.type = ORDER_TYPE_BUY;
            request.volume = LoteAuto;
            request.price = p.ask;
            request.deviation = 25;
            request.sl = SLauto;
            request.tp = TPauto;
            tk = OrderSend(request, result);
            // HabilitarCiclo();
            if(result.order > 0)
               HabilitadoParaIniciar = false;
            bool sel = PositionSelectByTicket(result.order);
            // calcular precios de coberturas:
            if(sel)
              {
               PrecioCobVenta  = PositionGetDouble(POSITION_PRICE_OPEN) - pipAuto * _Point * 10;
               PrecioCobCompra = PositionGetDouble(POSITION_PRICE_OPEN);
              }
           }
        }
     }
// cuando cierre una vela abajo de la ema Venta:
   if(tipo == Ambos || tipo == Venta)
     {
      if(HabilitadoParaIniciar)
        {
         if((C1 < ema && O1 > ema) || (C1 < ema && O2 > ema))
           {
            // calcular TP automático
            TPauto = p.bid - pipAuto * _Point * 10;
            // calcular SL auto
            SLauto = p.bid + pipAuto * 2 * _Point * 10;
            // mando la orden
            ZeroMemory(result);
            ZeroMemory(request);
            request.action = TRADE_ACTION_DEAL;
            request.symbol = Symbol();
            request.type = ORDER_TYPE_SELL;
            request.volume = LoteAuto;
            request.price = p.bid;
            request.deviation = 25;
            request.sl = SLauto;
            request.tp = TPauto;
            tk = OrderSend(request, result);
            // HabilitarCiclo();
            if(result.order > 0)
               HabilitadoParaIniciar = false;
            bool sel = PositionSelectByTicket(result.order);
            // calcular precios de coberturas:
            if(sel)
              {
               PrecioCobVenta  = PositionGetDouble(POSITION_PRICE_OPEN);
               PrecioCobCompra = PositionGetDouble(POSITION_PRICE_OPEN) + pipAuto * _Point * 10;
              }
           }
        }
     }
   Comment("ema: ", ema, " C1: ", C1, " hab: ", HabilitadoParaIniciar);
  }

//+------------------------------------------------------------------+
void HabilitarCiclo()
  {
// reinicio el HabilitadoParaIniciar
   HabilitadoParaIniciar = true;
   ulong ticket;
// si hay operaciones en el par, poner HabilitadoParaIniciar en false (para evitar Inicio de Ciclo)
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if((ticket = PositionGetTicket(i)) > 0)
        {
         PositionSelectByTicket(ticket);
         if(PositionGetString(POSITION_SYMBOL) ==  Symbol())
           {
            HabilitadoParaIniciar = false;
            break;
           }
        }
     }
  }
// Cuando el Usuario abre un trade vá a colocar solo el TP
// Cuando detecte un cambio en el TP <<<<
// esta función tiene que poner el Stop al doble de la distancia del TP
//+------------------------------------------------------------------+
void modificarOperaciones()
  {
   ulong ticket, succ;
   if(HabilitadoParaIniciar == true)
     {
      return;
     }  // no tengo operaciones abiertas
   bool sel;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if((ticket = PositionGetTicket(i)) > 0)
        {
         PositionSelectByTicket(ticket);
         if(PositionGetString(POSITION_SYMBOL) == Symbol())
           {
            if(PositionGetDouble(POSITION_TP) != 0 && PositionGetDouble(POSITION_SL) == 0)
              {
               double pipsTP = fabs(PositionGetDouble(POSITION_TP) - PositionGetDouble(POSITION_PRICE_OPEN)) / _Point;
               double pipsSL = pipsTP * 2;
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                 {
                  double SL = PositionGetDouble(POSITION_PRICE_OPEN) - (pipsSL * _Point);
                  ZeroMemory(result);
                  ZeroMemory(request);
                  request.position = ticket;
                  request.sl = SL;
                  request.tp = PositionGetDouble(POSITION_TP);
                  request.action = TRADE_ACTION_SLTP;
                  succ = OrderSend(request, result);
                  sel = PositionSelectByTicket(result.order);
                  if(sel)
                    {
                     // si la pudo modificar recalcula los precios de cobertura
                     PrecioCobVenta  = PositionGetDouble(POSITION_PRICE_OPEN) - pipsTP * _Point;
                     PrecioCobCompra = PositionGetDouble(POSITION_PRICE_OPEN);
                    }
                 }
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                 {
                  double SL = PositionGetDouble(POSITION_PRICE_OPEN) + (pipsSL * _Point);
                  ZeroMemory(result);
                  ZeroMemory(request);
                  request.position = ticket;
                  request.sl = SL;
                  request.tp = PositionGetDouble(POSITION_TP);
                  request.action = TRADE_ACTION_SLTP;
                  succ = OrderSend(request, result);
                  sel = PositionSelectByTicket(result.order);
                  if(sel)
                    {
                     // si la pudo modificar recalcula los precios de cobertura
                     PrecioCobCompra = PositionGetDouble(POSITION_PRICE_OPEN) + pipsTP * _Point;
                     PrecioCobVenta  = PositionGetDouble(POSITION_PRICE_OPEN);
                    }
                 }
              }
           }
        }
     }
  }
// Vá a cubrir la última operación con el determinado lotaje
// siempre tiene que haber una operación pendiente, que es cobertura de la última
// de modo que si no tengo ninguna pendiente, significa que tiene que abrir una cobertura
//+------------------------------------------------------------------+
void AbrirCobertura()
  {
   HayCobertura = false;
   int contar   = 0;
   ulong ticket;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if((ticket = OrderGetTicket(i)) > 0)
        {
         OrderSelect(ticket);
         if(OrderGetString(ORDER_SYMBOL) == Symbol())
           {
            HayCobertura = true;
           }
        }
     }
// Buscar si la cobertura es la primera para calcular el lotaje
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if((ticket = PositionGetTicket(i)) > 0)
        {
         PositionSelectByTicket(ticket);
         if(PositionGetString(POSITION_SYMBOL) == Symbol())
           {
            contar++;
           }
        }
     }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if((ticket = OrderGetTicket(i)) > 0)
        {
         OrderSelect(ticket);
         if(OrderGetString(ORDER_SYMBOL) == Symbol())
           {
            contar++;
           }
        }
     }
// si no hay cobertura tiene que abrirla
   if(!HayCobertura)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         if((ticket = PositionGetTicket(i)) > 0)
           {
            PositionSelectByTicket(ticket);
            if(PositionGetString(POSITION_SYMBOL) == Symbol())
              {
               double multiplicadorLotaje;
               // contar == 1 ? multiplicadorLotaje = 3 : multiplicadorLotaje = 2;
               contar == 1 ? multiplicadorLotaje = uMultiplyFirst : multiplicadorLotaje = uMultiply;
               // si contar es 1, es la primera del ciclo, tomo el tk para controlar fin del ciclo
               if(contar == 1)
                 {
                  TKOperacionInicial = ticket;
                 }
               // abro la cobertura
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
                 {
                  ZeroMemory(result);
                  ZeroMemory(request);
                  request.action = TRADE_ACTION_PENDING;
                  request.symbol = Symbol();
                  request.type = ORDER_TYPE_SELL_STOP;
                  request.volume = PositionGetDouble(POSITION_VOLUME) * multiplicadorLotaje;
                  request.price = PrecioCobVenta;
                  request.deviation = 25;
                  request.sl = PositionGetDouble(POSITION_TP);
                  request.tp = PositionGetDouble(POSITION_SL);
                  request.comment =  "cobertura";
                  OrderSend(request, result);
                  Print("price: " + p.bid + " p: " + PrecioCobVenta + " ticket: " + ticket);
                  break;
                 }
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                 {
                  ZeroMemory(result);
                  ZeroMemory(request);
                  request.action = TRADE_ACTION_PENDING;
                  request.symbol = Symbol();
                  request.type = ORDER_TYPE_BUY_STOP;
                  request.volume = PositionGetDouble(POSITION_VOLUME) * multiplicadorLotaje;
                  request.price = PrecioCobCompra;
                  request.deviation = 25;
                  request.sl = PositionGetDouble(POSITION_TP);
                  request.tp = PositionGetDouble(POSITION_SL);
                  request.comment =  "cobertura";
                  OrderSend(request, result);
                  Print("price: " + p.ask + " p: " + PrecioCobVenta + " ticket: " + ticket);             //   if(OrderSend(request, result))
                  break;
                 }
              }
           }
        }
     }
  }
// Cierra un ciclo si saltan stops o TP de la orden original
//+------------------------------------------------------------------+
void ControlCiclo()
  {
   if(OrderClosed(TKOperacionInicial))
      CloseAll();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   bool succ;
   ulong ticket;
   SymbolInfoTick(Symbol(), p);
   for(int pos = PositionsTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = PositionGetTicket(pos)) > 0)
        {
         PositionSelectByTicket(ticket);
         string sym = PositionGetString(POSITION_SYMBOL);
         double vol = PositionGetDouble(POSITION_VOLUME);
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(sym ==  Symbol() && (type == POSITION_TYPE_BUY || type == POSITION_TYPE_SELL))
           {
            ZeroMemory(result);
            ZeroMemory(request);
            request.position = ticket;
            request.action = TRADE_ACTION_DEAL;
            request.symbol   = sym;
            request.volume   = vol;
            request.deviation = 30;
            if(type == POSITION_TYPE_BUY)
              {
               request.price = p.bid;
               request.type = ORDER_TYPE_SELL;
              }
            else
              {
               request.price = p.ask;
               request.type = ORDER_TYPE_BUY;
              }
            succ = OrderSend(request, result);
           }
        }
     }
   for(int pos = OrdersTotal() - 1; pos >= 0 ; pos--)
     {
      if((ticket = OrderGetTicket(pos)) > 0)
        {
         OrderSelect(ticket);
         if(OrderGetString(ORDER_SYMBOL) ==  Symbol())
           {
            ZeroMemory(result);
            ZeroMemory(request);
            request.order = ticket;
            request.action = TRADE_ACTION_REMOVE;
            OrderSend(request, result);
           }
        }
     }
   ArrayFree(TicketsCiclo);
  }
//+------------------------------------------------------------------+
// Control de Horario con ingreso de datos en formato INTEGER
//+------------------------------------------------------------------+
bool ControlHorario()
  {
   if(!ControlaHora)
     {
      return true;
     }
   int iniHora       = (HoraIni - (HoraIni % 100)) / 100;
   int iniMin        = HoraIni % 100;
   int MinutoInicial = iniHora * 60 + iniMin;
   int finHora       = (HoraFin - (HoraFin % 100)) / 100;
   int finMin        = HoraFin % 100;
   int MinutoFinal   = finHora * 60 + finMin;
   int MinutoActual = TimeHour(TimeCurrent() + AjusteHora * 3600) * 60;
   MinutoActual += TimeMinute(TimeCurrent());
   if(MinutoActual > MinutoInicial && MinutoActual < MinutoFinal)
     {
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeHour(datetime time)
  {
   MqlDateTime tm;
   TimeToStruct(time, tm);
   return(tm.hour);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMinute(datetime time)
  {
   MqlDateTime tm;
   TimeToStruct(time, tm);
   return(tm.min);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MostrarHorarios()
  {
   int h = TimeHour(TimeCurrent() + AjusteHora * 3600);
   int m = TimeMinute(TimeCurrent());
   int iniHora = (HoraIni - (HoraIni % 100)) / 100;
   int iniMin  = HoraIni % 100;
   int finHora = (HoraFin - (HoraFin % 100)) / 100;
   int finMin  = HoraFin % 100;
   Comment("EA Coberturas: Encendido", "\n",
           "Hora Actual: ", h, ":", m, "\n",
           "Hora Inicio: ", iniHora, ":", iniMin, "\n",
           "Hora Fin: ", finHora, ":", finMin, "\n");
  }
//+------------------------------------------------------------------+
// tiene que cargar operaciones nueva abiertas al array
//+------------------------------------------------------------------+
int ArraySortt(double &array[], int count = WHOLE_ARRAY, int start = 0, int sort_dir = MODE_ASCEND)
  {
   switch(sort_dir)
     {
      case MODE_ASCEND:
         ArraySetAsSeries(array, true);
      case MODE_DESCEND:
         ArraySetAsSeries(array, false);
      default:
         ArraySetAsSeries(array, true);
     }
   ArraySort(array);
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CargarAlArray()
  {
   ulong tk;
   int    size = ArraySize(TicketsCiclo);
   if(size > 0)
     {
      ArraySortt(TicketsCiclo, WHOLE_ARRAY, 0, MODE_ASCEND);
     }
   ulong ticket;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if((ticket = PositionGetTicket(i)) > 0)
        {
         PositionSelectByTicket(ticket);
         if(PositionGetString(POSITION_SYMBOL) == Symbol())
           {
            tk = ticket;
            if(size == 0)
              {
               ArrayResize(TicketsCiclo, 1);
               TicketsCiclo[0] = tk;
              }
            else
              {
               int j = ArrayBsearch(TicketsCiclo, tk);
               if(TicketsCiclo[j] != tk)
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
// Controlar si alguna orden del array se cierra
// en caso de true, llamar a cerrar todas
//+------------------------------------------------------------------+
void ControlarOrdenesDelCiclo()
  {
   double tk;
   int    p = ArraySize(TicketsCiclo) - 1;
   if(p <= 0)
     {
      return;
     }
   while(p != 0)
     {
      tk = TicketsCiclo[p];
      if(OrderClosed(tk))
        {
         CloseAll();
         break;
        }
      p--;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderClosed(ulong ticket)
  {
   if(PositionSelectByTicket(ticket))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAa(string symbol, int tf, int period, int ma_shift, int method, int price, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   ENUM_MA_METHOD ma_method = MethodMigrate(method);
   ENUM_APPLIED_PRICE applied_price = PriceMigrate(price);
   int handle = iMA(symbol, timeframe, period, ma_shift,
                    ma_method, applied_price);
   if(handle < 0)
     {
      Print("The iMA object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferr(handle, 0, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferr(int handle, int index, int shift)
  {
   double buf[];
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0:
         return(MODE_SMA);
      case 1:
         return(MODE_EMA);
      case 2:
         return(MODE_SMMA);
      case 3:
         return(MODE_LWMA);
      default:
         return(MODE_SMA);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 1:
         return(PRICE_CLOSE);
      case 2:
         return(PRICE_OPEN);
      case 3:
         return(PRICE_HIGH);
      case 4:
         return(PRICE_LOW);
      case 5:
         return(PRICE_MEDIAN);
      case 6:
         return(PRICE_TYPICAL);
      case 7:
         return(PRICE_WEIGHTED);
      default:
         return(PRICE_CLOSE);
     }
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

//+------------------------------------------------------------------+
