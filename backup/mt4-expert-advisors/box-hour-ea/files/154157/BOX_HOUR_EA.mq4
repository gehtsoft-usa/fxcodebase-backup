// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74558

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property description "Expert Advisor"
#property strict
// Includes

// Gobal Variables
//+------------------------------------------------------------------+
input string tbox        = "== Box Setup =="; // ————————————
input string hrIni       = "00:00";           // Time Start Box:
input string hrFin       = "04:00";           // Time End Box:
bool         ctrlVentana = false;             // Controla hora del rompimiento?
datetime     HoraInicio;
datetime     HoraFin;
input bool   ctrlSize = false; // Control Box Size?
input int    maxSize  = 500;   // Maximum Box Size:

//--- Modos de Rompimiento:
enum ModosRompi { CruceLimite, // Instant
                  VelaCerrada  // Close Candle
};
input ModosRompi TipoRompi     = CruceLimite; // Mode Breackout:
input bool       ctrlDistancia = false;       // Control distance of close out?
input int        extraPips     = 0;           // Pips extra out of box:
input double     distanciaMax  = 20;          // Percent max to close candle out of box:

// Box Style:
color clrCaja      = RoyalBlue; // Color Caja:
int   grosorCaja   = 2;         // Grosor Borde Caja:
bool  rellenoCaja  = false;     // Relleno Caja:
color clrLineas    = Gray;      // Color Lineas:
int   grosorLineas = 1;         // Grosor Lineas:


input string ttrade   = "== Trade Setup =="; // ————————————
input double userLots = 0.01;                // Lots:

//--- SL y TP
enum Modos { Porcentaje, // Percent
             Puntos      // Pips
};
input Modos  ModoTP=Porcentaje; // Mode TP
input double TpPer    = 100; // Percent of Box to TP:
input int    TpPuntos = 50;  // Pips TP:
input Modos  ModoSL=Porcentaje; // Mode SL
input double SlPer    = 100; // Percent of Box to SL:
input int    SlPuntos = 50;  // Pips SL:

//--- Magic Number
input int magico = 4321; // Magic Number:

// precios máximo y minimo:
double MaxCaja = 0;
double MinCaja = 0;

bool     habilitado; // bandera para bloquear que si ya abrió una operación hoy, no vuelva a abrir hasta mañana
bool     ActualizarCaja = true;
datetime diaActual;



#define COBERTURA_OLD
#ifdef COBERTURA_OLD

// Modo Cobertura
bool CoberturaON = false; // Activar Cobertura:
enum TIPO_COBERTURA { Tipica,
                      ConRompimiento,
                      Reversa };
TIPO_COBERTURA tipoCobertura;            // Tipo de Martingala:
double         PorcentajeDeEntrada = 10; // Porcentaje de ingreso a la zona (para modo ConRompimiento):
enum ModoCobertura { Breakeven,
                     Winner };
ModoCobertura modoCobertura; // Modo Lotaje:
// Flag que cambia el flujo de trabajo para modo normal o cobertura:
enum ModoOperacionEA { Normal,
                       Cobertura };
ModoOperacionEA ModoOperacion = Normal;
// int n = 0;  // Contador de Coberturas;

// para Cobertura con Rompimiento:
bool habilitadoParaAbrirLaNuevaCobertura = false;

//--- Version 2.0
int userQntMax = 5; // Cantidad de trades a la vez:
struct Trade {
    int tkOriginal;  // ticket original del trade cubierto
    int tkCobertura; // ultimo tk de cobertura
    int contador;    // cuenta las coberturas que se van abriendo, es igual a la var n
};
Trade trades[];

#endif

#define MARTINGALE_ON
#ifdef MARTINGALE_ON

input string tMatingale                = "== Martingale Setup =="; // ————————————
input bool   MartingaleON              = true;                    // Use Martingale:
input int    MartingaleUser_maxCount   = 5;                       // Max attempts:
input double MartingaleUser_maxLot     = 10;                      // Max lot value:
input double MartingaleUser_multiplier = 2;                       // Multiplier:

class MartingaleIncrementLot
{
    int    _lastTk;
    double _lastProfit;
    double _lastLot;
    int    _count;
    int    _magic;
    string _symbol;
    int    _maxCount;
    double _maxLot;
    double _multiplier;

  public:
    MartingaleIncrementLot(int magic, string symbol)
    {
        _maxCount   = MartingaleUser_maxCount;
        _maxLot     = MartingaleUser_maxLot;
        _multiplier = MartingaleUser_multiplier;
        _magic      = magic;
        _symbol     = symbol;
    }
    ~MartingaleIncrementLot() { ; }

    double Lot()
    {
        setLastValues();
        double next = NormalizeDouble(_lastLot * _multiplier, 2);
        if (next > _maxLot || count() == _maxCount) {
            return 0;
        }
        return next;
    }

    void setLastValues()
    {
        int i = OrdersHistoryTotal() - 1;
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic) {
            if (OrderProfit() < 0) {
                _lastTk     = OrderTicket();
                _lastProfit = OrderProfit() + OrderCommission() + OrderSwap();
                _lastLot    = OrderLots();
            } else {
                _lastTk     = 0;
                _lastProfit = 0;
                _lastLot    = 0;
                _count      = 0;
            }
        }
    }

    int count()
    {
        int count = 0;

        for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic) {
                if (OrderProfit() < 0) {
                    count++;
                }
                if (OrderProfit() >= 0) {
                    break;
                }
            }
        }

        _count = count - 1;

        return _count;
    }
};
MartingaleIncrementLot martingale(magico, _Symbol);
#endif

//+------------------------------------------------------------------+
//| EA
//+------------------------------------------------------------------+
int OnInit()
{
    Print(__FUNCTION__, " ", "TimeGMT:", " ", TimeGMT());
    getHoras();
    EventSetTimer(1);
    resetearCaja();
    setHabilitado(true);
    diaActual = iTime(Symbol(), PERIOD_D1, 0);
    Print(__FUNCTION__, " ", "diaActual", " ", diaActual);

    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    CleanChart();
}

void OnTick()
{
    FlujoNormal();
    FlujoCobertura();
}

//+------------------------------------------------------------------+

void FlujoNormal()
{
    RegistrarMaxMin();

    int tipo = hayRompimiento();
    if (tipo != -1) {
        if (!hizoOperacionesHoy())
            // if (!hayUnTradeAbierto())
            if (qntDeTradesOk(userQntMax))
                if (okSizeCaja())
                    if (okHoraOperacion())
                        AbrirTrade(tipo, Lots());
    }

    Reiniciar();
}

double Lots()
{
    double l = userLots;
    if (MartingaleON) {
        double ml = martingale.Lot();
        l         = ml == 0 ? l : ml;
    }
    return l;
}

// recorrer los trades y mandar a abrir coberturas a los que haga falta
void FlujoCobertura()
{
    if (!CoberturaON) {
        return;
    }

    for (int i = 0; i < ArraySize(trades); i++) {
        if (!generarCobertura(i)) {
            continue;
        }

        if (tipoCobertura == Reversa) {
            int tipo = tipoTradeCobertura(i); // tiene que ser el contrario al último trade
            if (tipo != -1) {
                if (AbrirTrade(tipo, LotajeDeCobertura(i), true, i)) {
                    trades[i].contador += 1;
                }
            }
        }

        if (tipoCobertura == Tipica) {
            int tipo = tipoTradeCobertura(i); // tiene que ser igual al último trade
            if (tipo != -1) {
                if (AbrirTrade(tipo, LotajeDeCobertura(i), true, i)) {
                    trades[i].contador += 1;
                }
            }
        }

        if (tipoCobertura == ConRompimiento) {

            if (hizoOperacionesHoy())
                return;

            // tiene que entrar nuevamente a la caja, o a la nueva caja
            if (!habilitadoParaAbrirLaNuevaCobertura) {
                ControlarEntradaALaZona();
            }

            if (habilitadoParaAbrirLaNuevaCobertura) {
                int tipo = hayRompimiento();
                if (tipo != -1) {
                    if (AbrirTrade(tipo, LotajeDeCobertura(i), true, i)) {
                        trades[i].contador += 1;
                        habilitadoParaAbrirLaNuevaCobertura = false;
                    }
                }
            }
        }
    }

    Reiniciar();
    RegistrarMaxMin();
}

bool generarCobertura(int index)
{
    //--- si tiene cobertura, selecciono ese tk, sino el original:
    int tk = trades[index].tkCobertura == 0 ? trades[index].tkOriginal : trades[index].tkCobertura;

    //--- controlo que esa orden esté cerrada y haya sido perdedora:
    if (OrderSelect(tk, SELECT_BY_TICKET)) {
        if (OrderCloseTime() > 0 && OrderProfit() < 0) {
            return true;
        }
    }

    return false;
}

void ControlarEntradaALaZona()
{
    // el precio tiene que "tocar" la zona interna de la caja, significa que el precio tiene q ser mayor a la banda inferior y menor a la banda superior (la banda inferior será MinCaja+% y la superior MaxCaja-%)
    // tiene que entrar un cierto % que es seteable
    double mPoint    = MarketInfo(Symbol(), MODE_POINT);
    double size      = (MaxCaja - MinCaja);
    double ptosExtra = size * (PorcentajeDeEntrada / 100);
    double maxZona   = MaxCaja - ptosExtra;
    double minZona   = MinCaja + ptosExtra;

    if (Bid < maxZona && Bid > minZona) {
        if (habilitadoParaAbrirLaNuevaCobertura == false) {
            habilitadoParaAbrirLaNuevaCobertura = true;
            Print(__FUNCTION__, " ", "Habilita Nuevo Cobertura");
        }
    }
}

int tipoTradeCobertura(int index)
{
    ENUM_ORDER_TYPE Type;
    int             tk = trades[index].tkCobertura == 0 ? trades[index].tkOriginal : trades[index].tkCobertura;
    if (OrderSelect(tk, SELECT_BY_TICKET)) {
        Type = OrderType();
    }

    // devulve el trade contrario al anterior
    if (tipoCobertura == Reversa) {
        if (Type == OP_BUY) {
            return 1;
        }
        if (Type == OP_SELL) {
            return 0;
        }
    }

    // devuelve el trade igual al anterior
    if (tipoCobertura == Tipica) {
        if (Type == OP_BUY) {
            return 0;
        }
        if (Type == OP_SELL) {
            return 1;
        }
    }

    return -1;
}

double LotajeDeCobertura(int index)
{
    // inicio el contador de coberturas:
    if (trades[index].contador == 0) {
        trades[index].contador = 1;
    }
    int n = trades[index].contador;

    if (modoCobertura == Breakeven) {
        double lotes = userLots * pow(2, (n - 1));
        return lotes;
    }

    if (modoCobertura == Winner) {
        double lotes = userLots * pow(2, n);
        return lotes;
    }

    return userLots;
}

bool elUltimoTradeFueGanador()
{
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
            if (OrderProfit() > 0) {
                return true;
            } else {
                return false;
            }
        }
    }

    return true;
}

// cambia entre modo Normal y Modo Cobertura
void determinarModoDeOperacion()
{
    //   ModoOperacionEA modoAnterior = ModoOperacion;

    //   if(elUltimoTradeFueGanador()==false && CoberturaON==true){
    //       ModoOperacion = Cobertura;
    //    } else {
    //       ModoOperacion = Normal;
    //       n             = 0;      // reinicio el contador de coberturas
    //    }
    //    // imprime si se cambió el modo:
    //    if (modoAnterior != ModoOperacion) { Print(__FUNCTION__, " El Modo Cambio a: ", ModoOperacion); }
}

void getHoras()
{
    // desarmar la hora string y convertirla en datetime
    HoraInicio = StringToTime(hrIni);
    HoraFin    = StringToTime(hrFin);

    Print(__FUNCTION__, " ", "HoraInicio", " ", HoraInicio);
    Print(__FUNCTION__, " ", "HoraFin", " ", HoraFin);
}

void RegistrarMaxMin()
{
    double ctrlMax = MaxCaja; // es el máximo de la caja antes de aplicar la función. Lo uso como punto de control, si los valores cambian imprime, sino no

    if (TimeGMT() > HoraFin && ActualizarCaja == true) {
        // buscar max y min:
        int minutos = ((int)HoraFin - (int)HoraInicio) / 60;
        Print(__FUNCTION__, " ", "minutos", " ", minutos);
        Print(__FUNCTION__, " ", "iHigh(NULL, 1, 1)", " ", iHigh(Symbol(), 1, 1));
        Print(__FUNCTION__, " ", "iHigh(NULL, 1, 2)", " ", iHigh(Symbol(), 1, 2));
        Print(__FUNCTION__, " ", "iHigh(NULL, 1, 3)", " ", iHigh(Symbol(), 1, 3));
        // recorrer todos los minutos desde el fin al inicio de la caja y registrar max y min
        int barIni = iBarShift(NULL, 1, HoraFin);

        for (int i = barIni; i < barIni + minutos; i++) {
            if (MaxCaja == 0 || iHigh(NULL, 1, i) > MaxCaja) {
                MaxCaja = iHigh(NULL, 1, i);
            }
            if (MinCaja == 0 || iLow(NULL, 1, i) < MinCaja) {
                MinCaja = iLow(NULL, 1, i);
            }
        }
        ActualizarCaja = false;
        DrawBox();
    }

    if (MaxCaja != ctrlMax) {
        Print(__FUNCTION__, " ", "MaxCaja", " ", MaxCaja);
        Print(__FUNCTION__, " ", "MinCaja", " ", MinCaja);
    }
}

void resetearCaja()
{
    MaxCaja        = 0;
    MinCaja        = 0;
    ActualizarCaja = true;
}

void DrawBox()
{
    //   ObjectCreate(chart_ID, name, OBJ_RECTANGLE, sub_window, time1, price1, time2, price2);
    ObjectDelete(0, "Box");
    ObjectCreate(0, "Box", OBJ_RECTANGLE, 0, HoraInicio, MaxCaja, HoraFin, MinCaja);
    ObjectSetInteger(0, "Box", OBJPROP_COLOR, clrCaja);
    ObjectSetInteger(0, "Box", OBJPROP_WIDTH, grosorCaja);
    ObjectSetInteger(0, "Box", OBJPROP_FILL, rellenoCaja);
    ObjectSetInteger(0, "Box", OBJPROP_BACK, false);

    ObjectCreate(0, "Max", OBJ_HLINE, 0, 0, MaxCaja);
    ObjectSetInteger(0, "Max", OBJPROP_COLOR, clrLineas);
    ObjectSetInteger(0, "Max", OBJPROP_WIDTH, grosorLineas);
    ObjectSetInteger(0, "Max", OBJPROP_STYLE, STYLE_DOT);

    ObjectCreate(0, "Min", OBJ_HLINE, 0, 0, MinCaja);
    ObjectSetInteger(0, "Min", OBJPROP_COLOR, clrLineas);
    ObjectSetInteger(0, "Min", OBJPROP_WIDTH, grosorLineas);
    ObjectSetInteger(0, "Min", OBJPROP_STYLE, STYLE_DOT);
}

void CleanChart()
{
    ObjectDelete(0, "Box");
    ObjectDelete(0, "Max");
    ObjectDelete(0, "Min");
}

// retorna 0:(rompimieno por arriba = OP_BUY) 1:(rompimeinto por abajo = OP_SELL) -1:(no hay rompimiento)
int hayRompimiento()
{
    if (MaxCaja == 0 || MinCaja == 0) {
        return -1;
    }

    double mPoint = MarketInfo(Symbol(), MODE_POINT);
    //--- MODO VELA CERRADA -----
    if (TipoRompi == VelaCerrada) {
        double cierre = iClose(Symbol(), Period(), 1);
        double hi     = iHigh(Symbol(), Period(), 1);
        double low    = iLow(Symbol(), Period(), 1);

        //--- Rompimiento por Arriba:
        if (cierre > (MaxCaja + (extraPips * mPoint)) && low < MaxCaja) {
            // controla si está arriba del take profit
            if (Ask >= SetTP(Ask, OP_BUY)) {
                return false;
            }
            // controla distancia máxima
            if ((distanciaCierre(cierre, MaxCaja) > distanciaMax) && ctrlDistancia == true) {
                Print("La Distancia es mayor a la permitida: ", distanciaCierre(cierre, MaxCaja));
                return -1;
            }
            return 0;
        }

        //--- Rompimiento por Abajo:
        if (cierre < (MinCaja - (extraPips * mPoint)) && hi > MinCaja) {
            // controla si está abajo del take profit
            if (Bid <= SetTP(Bid, OP_SELL)) {
                return false;
            }
            // controla distancia máxima
            if ((distanciaCierre(cierre, MinCaja) > distanciaMax) && ctrlDistancia == true) {
                Print("La Distancia es mayor a la permitida: ", distanciaCierre(cierre, MinCaja));
                return -1;
            }
            return 1;
        }
    }

    //--- MODO CRUCE LIMITE -----
    if (TipoRompi == CruceLimite) {
        // PorArriba:
        if ((Ask > MaxCaja + (extraPips * mPoint)) && (Ask < MaxCaja + (50 * mPoint))) {
            return 0;
        }

        // Por Abajo:
        if ((Bid < MinCaja - (extraPips * mPoint)) && (Bid > MinCaja - (50 * mPoint))) {
            return 1;
        }
    }

    return -1;
}

bool hayUnTradeAbierto()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
            Print("hay un trade abierto");
            return true;
        }
    }

    return false;
}

bool qntDeTradesOk(int qnt)
{
    int contar = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
            contar += 1;
        }
    }

    if (contar < userQntMax) {
        return true;
    }

    return false;
}

bool okSizeCaja()
{
    double mPoint = MarketInfo(Symbol(), MODE_POINT);
    double size   = (MaxCaja - MinCaja) / mPoint;
    if (size > maxSize && ctrlSize == true) {
        Print("El tamaño de la caja es demasiado grande");
        return false;
    }

    return true;
}

bool okHoraOperacion()
{
    int VentanaDeOperacion = (HoraFin - HoraInicio);
    if ((TimeGMT() > HoraFin + VentanaDeOperacion) && ctrlVentana == true) {
        Print("El Rompimiento está fuera de la ventana de tiempo");
        return false;
    }

    return true;
}

double SetTP(double entryPrice, ENUM_ORDER_TYPE tipo)
{
    //--- tamaño:
    double mPoint = MarketInfo(Symbol(), MODE_POINT);
    double size   = (MaxCaja - MinCaja);

    if (ModoOperacion == Normal) {
        if (ModoTP == Porcentaje) {
            if (tipo == OP_BUY) {
                return MaxCaja + (size * (TpPer / 100));
            }
            if (tipo == OP_SELL) {
                return MinCaja - (size * (TpPer / 100));
            }
        }

        if (ModoTP == Puntos) {
            if (tipo == OP_BUY) {
                return entryPrice + TpPuntos * 10 * mPoint;
            }
            if (tipo == OP_SELL) {
                return entryPrice - TpPuntos * 10 * mPoint;
            }
        }
    }

    if (ModoOperacion == Cobertura) {
        if (tipo == OP_BUY) {
            return entryPrice + DistanciaCobertura("TP");
        }
        if (tipo == OP_SELL) {
            return entryPrice - DistanciaCobertura("TP");
        }
    }

    return 0;
}

double SetSL(double entryPrice, ENUM_ORDER_TYPE tipo)
{
    //--- tamaño:
    double mPoint = MarketInfo(Symbol(), MODE_POINT);
    double size   = (MaxCaja - MinCaja);

    if (ModoOperacion == Normal) {
        if (ModoSL == Porcentaje) {
            if (tipo == OP_BUY) {
                return MaxCaja - (size * (SlPer / 100));
            }
            if (tipo == OP_SELL) {
                return MinCaja + (size * (SlPer / 100));
            }
        }

        if (ModoSL == Puntos) {
            if (tipo == OP_BUY) {
                return entryPrice - SlPuntos * 10 * mPoint;
            }
            if (tipo == OP_SELL) {
                return entryPrice + SlPuntos * 10 * mPoint;
            }
        }
    }

    if (ModoOperacion == Cobertura) {
        if (tipo == OP_BUY) {
            return entryPrice - DistanciaCobertura("SL");
        }
        if (tipo == OP_SELL) {
            return entryPrice + DistanciaCobertura("SL");
        }
    }

    return 0;
}

double DistanciaCobertura(string tipo)
{
    //--- busco la distancia al stop del último trade
    double ptosUltimo = 0;
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico) {
            ptosUltimo = fabs(OrderOpenPrice() - OrderStopLoss());
        }
    }

    double mPoint = MarketInfo(Symbol(), MODE_POINT);
    if (tipo == "TP") {
        return ptosUltimo + 5 * mPoint;
    }
    if (tipo == "SL") {
        return ptosUltimo;
    }

    return -1;
}

void Reiniciar()
{
    datetime nuevoDia = iTime(Symbol(), PERIOD_D1, 0);
    if (diaActual != nuevoDia) {
        setHabilitado(true);
        CleanChart();
        resetearCaja();
        diaActual = nuevoDia;
        getHoras();

        // Print(__FUNCTION__, " ", "Comienza un nuevo día:", " ", TimeGMT());
    }
}

// devuelve la distancia hasta el min o máx (como poercentaje de la caja)
double distanciaCierre(double cierre, double PrecioControl)
{
    //   Print(__FUNCTION__," ","return:"," ",fabs((cierre - PrecioControl)/(MaxCaja-MinCaja)));
    return fabs((cierre - PrecioControl) / (MaxCaja - MinCaja));
}

//--- setea Flag On / Off para abrir operaciones
void setHabilitado(bool active)
{
    habilitado = active;
    if (active) {
        Print(__FUNCTION__, " ", "Habilitado = true");
    }
}

bool Habilitado()
{
    return habilitado;
}

// si abrió alguna operación hoy devuelve true
bool hizoOperacionesHoy()
{
    // si en las abiertas tengo una orden de hoy
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico && OrderComment() != "cobertura") {
            if ((TimeDay(OrderOpenTime()) == TimeDay(diaActual)) && (TimeMonth(OrderOpenTime()) == TimeMonth(diaActual)) && (TimeYear(OrderOpenTime()) == TimeYear(diaActual))) {
                Print("Hay un trade abierto de hoy");
                return true;
            }
        }
    }

    // recorrer el historial
    // si hay alguna con el magico de este ea, devolver true
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderComment() != "cobertura") {
            // si llegó a ordenes de ayer, salir:
            if (TimeDay(OrderOpenTime()) != TimeDay(diaActual)) {
                break;
            }

            // comparar día,mes,año:
            if ((TimeDay(OrderOpenTime()) == TimeDay(diaActual)) && (TimeMonth(OrderOpenTime()) == TimeMonth(diaActual)) && (TimeYear(OrderOpenTime()) == TimeYear(diaActual))) {
                if (OrderMagicNumber() == magico) {
                    Print("Hoy ya se abrió un trade");
                    return true;
                }
            }
        }
    }

    return false;
}

bool AbrirTrade(int tipo, double lotes, bool esCobertura = false, int index = 0)
{
    int clr = -1;
    if (tipo == OP_BUY) {
        if (!esCobertura) {
            clr = OrderSend(Symbol(), OP_BUY, lotes, Ask, 1000, SetSL(Ask, OP_BUY), SetTP(Ask, OP_BUY), NULL, magico, 0, clrNONE);
        }
        if (esCobertura) {
            clr = OrderSend(Symbol(), OP_BUY, lotes, Ask, 1000, SetSL(Ask, OP_BUY), SetTP(Ask, OP_BUY), "cobertura", magico, 0, clrNONE);
        }
        if (clr != -1) {
            if (!esCobertura) {
                agregarTrade(clr);
                return true;
            }
            if (esCobertura) {
                trades[index].tkCobertura = clr;
                return true;
            }
        }
    }

    if (tipo == OP_SELL) {
        if (!esCobertura) {
            clr = OrderSend(Symbol(), OP_SELL, lotes, Bid, 1000, SetSL(Bid, OP_SELL), SetTP(Bid, OP_SELL), NULL, magico, 0, clrNONE);
        }
        if (esCobertura) {
            clr = OrderSend(Symbol(), OP_SELL, lotes, Bid, 1000, SetSL(Bid, OP_SELL), SetTP(Bid, OP_SELL), "cobertura", magico, 0, clrNONE);
        }
        if (clr != -1) {
            if (!esCobertura) {
                agregarTrade(clr);
                return true;
            }
            if (esCobertura) {
                trades[index].tkCobertura = clr;
                return true;
            }
        }
    }

    return false;
}

//+------------------------------------------------------------------+
void agregarTrade(int tk)
{
    int t = ArraySize(trades);
    ArrayResize(trades, t + 1);
    trades[t].tkOriginal = tk;
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+