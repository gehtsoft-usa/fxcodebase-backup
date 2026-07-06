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

enum Modalidad { Automatic,
                 Mannual };
enum CompraVenta { Compra,
                   Venta,
                   Ambos };

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
int       TKOperacionInicial;
double    PrecioCobVenta, PrecioCobCompra;
bool      HabilitadoParaIniciar, HayCobertura;

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
  if (ControlHorario())
  {
    MostrarHorarios();
    AbrirOperacion();
    HabilitarCiclo();
    modificarOperaciones();

  } else
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
  if (Modo == Mannual)
  {
    return;
  }

  // points=MarketInfo(Symbol(),MODE_POINT);
  double ema = iMA(Symbol(), 0, MM, 0, MODE_EMA, PRICE_CLOSE, 1);
  double C1  = iClose(Symbol(), 0, 1);
  double O1  = iOpen(Symbol(), 0, 1);
  // double C2 = iClose(Symbol(), 0, 2);
  double O2 = iOpen(Symbol(), 0, 2);
  double TPauto, SLauto;

  // cuando cierre una vela arriba de la ema Compra:
  if (tipo == Ambos || tipo == Compra)
  {
    if (HabilitadoParaIniciar)
    {
      if ((C1 > ema && O1 < ema) || (C1 > ema && O2 < ema))
      {
        // calcular TP automático
        TPauto = Ask + pipAuto * _Point * 10;
        // calcular SL auto
        SLauto = Ask - pipAuto * 2 * _Point * 10;
        // mando la orden
        int tk = OrderSend(Symbol(), OP_BUY, LoteAuto, Ask, 25, SLauto, TPauto, NULL, 0, 0, clrNONE);
        // HabilitarCiclo();
        if (tk > 0) HabilitadoParaIniciar = false;
        bool sel = OrderSelect(tk, SELECT_BY_TICKET);
        // calcular precios de coberturas:
        if (sel)
        {
          PrecioCobVenta  = OrderOpenPrice() - pipAuto * _Point * 10;
          PrecioCobCompra = OrderOpenPrice();
        }
      }
    }
  }
  // cuando cierre una vela abajo de la ema Venta:
  if (tipo == Ambos || tipo == Venta)
  {
    if (HabilitadoParaIniciar)
    {
      if ((C1 < ema && O1 > ema) || (C1 < ema && O2 > ema))
      {
        // calcular TP automático
        TPauto = Bid - pipAuto * _Point * 10;
        // calcular SL auto
        SLauto = Bid + pipAuto * 2 * _Point * 10;
        // mando la orden
        int tk = OrderSend(Symbol(), OP_SELL, LoteAuto, Bid, 25, SLauto, TPauto, NULL, 0, 0, clrNONE);
        // HabilitarCiclo();
        if (tk > 0) HabilitadoParaIniciar = false;
        bool sel = OrderSelect(tk, SELECT_BY_TICKET);
        // calcular precios de coberturas:
        if (sel)
        {
          PrecioCobVenta  = OrderOpenPrice();
          PrecioCobCompra = OrderOpenPrice() + pipAuto * _Point * 10;
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
  // si hay operaciones en el par, poner HabilitadoParaIniciar en false (para evitar Inicio de Ciclo)
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
    {
      HabilitadoParaIniciar = false;
      break;
    }
  }
}

// Cuando el Usuario abre un trade vá a colocar solo el TP
// Cuando detecte un cambio en el TP <<<<
// esta función tiene que poner el Stop al doble de la distancia del TP
//+------------------------------------------------------------------+
void modificarOperaciones()
{
  if (HabilitadoParaIniciar == true)
  {
    return;
  }  // no tengo operaciones abiertas

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
            // si la pudo modificar recalcula los precios de cobertura
            PrecioCobVenta  = OrderOpenPrice() - pipsTP * _Point;
            PrecioCobCompra = OrderOpenPrice();
          }
        }
        if (OrderType() == OP_SELL)
        {
          double SL = OrderOpenPrice() + (pipsSL * _Point);
          if (OrderModify(OrderTicket(), OrderOpenPrice(), SL, OrderTakeProfit(), 0, clrNONE))
          {
            // si la pudo modificar recalcula los precios de cobertura
            PrecioCobCompra = OrderOpenPrice() + pipsTP * _Point;
            PrecioCobVenta  = OrderOpenPrice();
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

  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
    {
      if (OrderType() != OP_BUY && OrderType() != OP_SELL)
      {
        HayCobertura = true;
      }
    }
  }

  // Buscar si la cobertura es la primera para calcular el lotaje
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
    {
      contar++;
    }
  }

  // si no hay cobertura tiene que abrirla
  if (!HayCobertura)
  {
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
      {
        double multiplicadorLotaje;
        // contar == 1 ? multiplicadorLotaje = 3 : multiplicadorLotaje = 2;
        contar == 1 ? multiplicadorLotaje = uMultiplyFirst : multiplicadorLotaje = uMultiply;
        // si contar es 1, es la primera del ciclo, tomo el tk para controlar fin del ciclo
        if (contar == 1)
        {
          TKOperacionInicial = OrderTicket();
        }
        // abro la cobertura
        if (OrderType() == OP_BUY)
        {
          if (!OrderSend(Symbol(), OP_SELLSTOP, OrderLots() * multiplicadorLotaje, PrecioCobVenta, 25, OrderTakeProfit(), OrderStopLoss(), "cobertura", 0, 0, clrNONE))
          {
          }
          break;
        }
        if (OrderType() == OP_SELL)
        {
          if (!OrderSend(Symbol(), OP_BUYSTOP, OrderLots() * multiplicadorLotaje, PrecioCobCompra, 25, OrderTakeProfit(), OrderStopLoss(), "cobertura", 0, 0, clrNONE))
          {
          }
          break;
        }
      }
    }
  }
}

// Cierra un ciclo si saltan stops o TP de la orden original
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
// Control de Horario con ingreso de datos en formato INTEGER
//+------------------------------------------------------------------+
bool ControlHorario()
{
  if (!ControlaHora)
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

  if (MinutoActual > MinutoInicial && MinutoActual < MinutoFinal)
  {
    return true;
  }

  return false;
}

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
// Controlar si alguna orden del array se cierra
// en caso de true, llamar a cerrar todas
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