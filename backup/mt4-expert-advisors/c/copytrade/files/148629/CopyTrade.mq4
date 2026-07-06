// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73031

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


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property strict
// Includes
// Inputs:
//+------------------------------------------------------------------+
enum ModoDeTrabajo {EMITTER, RECEIVER};
input ModoDeTrabajo Modo = EMITTER; //Modo de Trabajo:
input string Modo_Emisor   = "<< Emitter mode setup >>";  // -----------------
input string inpReceptores = "1,2";                            // Number Receivers (separated with commas):
input string Modo_Receptor = "<< setup Receiver Mode: >>";  // -----------------
input int    NroID = 1;                                // Receiver No.:
input string UserEqIndices;                            // Index Equivalent Names:
input string UserEqGold;                               // Gold Equivalent Names:
input string UserEqOtras;                              // Other Equivalent Names:
input double inpLotIndices;                            // Lotage Equivalences Indices:
input double inpLotOro;                                // Gold Equivalencies lottery:
input double inpLotOtras;                              // Lotage Equivalences Others:
input double inpLotbyDefault;                          // Default Lotage:

datetime horaInicio;

//--- Clase CEmisor
//+------------------------------------------------------------------+
class CEmisor
{
 private:
  struct TradeData {
    int             tk;
    string          par;
    double          entry;
    double          sl;
    double          tp;
    ENUM_ORDER_TYPE tipo;
    double          lots;
    string          coment;
    bool            enviado;
    string          accion;
    double          percentToClose;
  };
  TradeData Trades[];
  int       Receptores[];

 public:
  CEmisor();
  ~CEmisor();
  void   Reiniciar(void) { GetReceptores(); }  // para cuando se reinicia el EA
  void   ReconocerTrade(void);
  void   BorrarDatos(void);
  bool   BuscarTicket(int tk);
  void   AgregarTrade(int index);
  void   DeleteTrade(int index);
  void   PrintTrade(int index);
  bool   DetectarCambios(void);
  void   GetReceptores(void);
  void   EnviarTrades(void);
  bool   HayCambios(void);
  bool   HayCierres(void);
  void   CambiarTrade(int index, string action);
  double CalcularLote(int i);
  void   BorrarTradesCerrados(void);
  void   Emitir(void);
  bool   ComentarioTieneTo(string coment);
  bool   vieneDeParcial(string coment);
  void   ReemplazarTk(int index);
  bool   tengoEseTk(int tk);
  void   ModificarTrades(int index, string atributo, int value);
  int    ticketFrom(string coment, int tk);
  int    BuscarIndex(int tk);
  bool   esTradeAMercado(int tk);
  double PercentToClose(int index, double lotsFinal);
  void   setIniTime(void) { horaInicio = TimeCurrent(); }

};

CEmisor::CEmisor()
{
  GetReceptores();
  setIniTime();
}

CEmisor::~CEmisor() {}

// Flujo de Trabajo del Emisor
//+------------------------------------------------------------------+
void CEmisor::Emitir()
{
  ReconocerTrade();
  EnviarTrades();
  if (HayCambios()) { EnviarTrades(); }
  if (HayCierres()) {
    ReconocerTrade();
    EnviarTrades();
    BorrarTradesCerrados();
  }
}

// Reconoce si hay un trade nuevo en la plataforma
//+------------------------------------------------------------------+
void CEmisor::ReconocerTrade()
{
  for (int i = 0; i <= OrdersTotal() - 1; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      int tk     = OrderTicket();
      int Magico = OrderMagicNumber();
      if (OrderOpenTime() < horaInicio) { continue; }
      if (esTradeAMercado(tk))
        if (!BuscarTicket(tk)) {
          if (!vieneDeParcial(OrderComment())) {
            AgregarTrade(i);
            PrintTrade(i);
          } else {
            int index = BuscarIndex(ticketFrom(OrderComment(), tk));
            if (index != -1) {
              Trades[index].coment = (string)Trades[index].tk;  //*guardo el tk original en el comentario
              Trades[index].tk     = tk;
              CambiarTrade(index, "Parcial");
            }
            if (index == -1) {
              AgregarTrade(i);
              PrintTrade(i);
            }
          }
        }
    }
  }
}

//+------------------------------------------------------------------+
bool CEmisor::esTradeAMercado(int tk)
{
  if (OrderSelect(tk, SELECT_BY_TICKET)) {
    if (OrderType() == OP_BUY || OrderType() == OP_SELL) { return true; }
  }
  return false;
}

// detectar cuando un trade guardado el usuario cambió TP, SL ó type
//+------------------------------------------------------------------+
bool CEmisor::DetectarCambios()
{
  int t = ArraySize(Trades);
  for (int i = 0; i < t; i++) {
    if (OrderSelect(Trades[i].tk, SELECT_BY_TICKET)) {
      if (OrderCloseTime() != 0) continue;

      ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderType();

      if (OrderTakeProfit() != Trades[i].tp) {
        Trades[i].tp = OrderTakeProfit();  // cambio el tp guardado
        return true;
      }
      if (OrderStopLoss() != Trades[i].sl) {
        Trades[i].sl = OrderStopLoss();  // cambio el sl guardado
        return true;
      }
    }
  }
  return false;
}

// Borra todos los datos del array Trades
//+------------------------------------------------------------------+
void CEmisor::BorrarDatos() { ArrayFree(Trades); }

// busca el tk en los trades guardados
//+------------------------------------------------------------------+
bool CEmisor::BuscarTicket(int tk)
{
  for (int i = 0; i < ArraySize(Trades); i++) {
    if (Trades[i].tk == tk) { return true; }
  }
  return false;
}

// Agrega un trade que no está en el array
//+------------------------------------------------------------------+
void CEmisor::AgregarTrade(int index)
{
  int j = ArraySize(Trades);
  ArrayResize(Trades, j + 1);

  if (OrderSelect(index, SELECT_BY_POS)) {
    Trades[j].tk         = OrderTicket();
    Trades[j].par        = OrderSymbol();
    Trades[j].entry      = OrderOpenPrice();
    Trades[j].sl         = OrderStopLoss();
    Trades[j].tp         = OrderTakeProfit();
    ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderType();
    Trades[j].tipo       = type;
    Trades[j].lots       = OrderLots();
    Trades[j].coment     = OrderComment();
    Trades[j].enviado    = false;
    // v1.0
    Trades[j].accion = "Abrir";
  }
}
//+------------------------------------------------------------------+
void CEmisor::BorrarTradesCerrados()
{
  int qntTrades = ArraySize(Trades);
  for (int i = 0; i < qntTrades; i++) {
    if (Trades[i].accion == "Cerrar") {
      DeleteTrade(i);
      qntTrades--;
      i--;
    }
  }
}

// Eliminar un trade en cualquier posición y ordenar el array
//+------------------------------------------------------------------+
void CEmisor::DeleteTrade(int index)
{
  int t = ArraySize(Trades);
  if (t == 1) {
    BorrarDatos();
    return;
  }
  // tiene que pasar una posición abajo todos los trades siguientes al que borraste
  for (int i = index; i < t; i++) {
    if (ArraySize(Trades) > i + 1) Trades[i] = Trades[i + 1];
    PrintTrade(i);
  }
  // achicar el array borrando la última posición:
  ArrayResize(Trades, t - 1);
}

//+------------------------------------------------------------------+
void CEmisor::PrintTrade(int index)
{
  if (ArraySize(Trades) == 0) { return; }
  //--- controlar desborde
  int t = ArraySize(Trades);
  if (index > t - 1) { index = t - 1; }
  if (index < 0) { return; }
  //---
  Print((string)index + " par: " + (string)Trades[index].par);
  Print((string)index + " tk: " + (string)Trades[index].tk);
  Print((string)index + " entry: " + (string)Trades[index].entry);
  Print((string)index + " sl: " + (string)Trades[index].sl);
  Print((string)index + " tp: " + (string)Trades[index].tp);
  Print((string)index + " lots: " + (string)Trades[index].lots);
  Print((string)index + " tipo: " + (string)Trades[index].tipo);
  Print((string)index + " comment: " + (string)Trades[index].coment);
  Print((string)index + " enviado: " + (string)Trades[index].enviado);
}

// Get Receptores
//+------------------------------------------------------------------+
void CEmisor::GetReceptores()
{
  string stringReceptores[];
  string sep = ",";
  ushort u_sep;
  u_sep = StringGetCharacter(sep, 0);
  int k = StringSplit(inpReceptores, u_sep, stringReceptores);
  ArrayResize(Receptores, ArrayRange(stringReceptores, 0), 0);
  for (int i = 0; i < ArrayRange(stringReceptores, 0); i++) {
    Receptores[i] = (int)stringReceptores[i];
  }
  if (ArrayRange(Receptores, 0) > 0) {
    ArraySort(Receptores, WHOLE_ARRAY, 0, MODE_ASCEND);
  }
}

// Envia los trades al archivo para que los levanten los receptores
//+------------------------------------------------------------------+
void CEmisor::EnviarTrades()
{
  int    qntTrades = ArraySize(Trades);
  string Data[500][10];
  int    qntReceptores = ArraySize(Receptores);
  int    file          = 0;

  // paso todos los trades no enviados al array data
  for (int i = 0; i < qntTrades; i++) {
    if (Trades[i].enviado == false) {
      Data[i, 0] = (string)Trades[i].tk;
      Data[i, 1] = (string)Trades[i].par;
      Data[i, 2] = (string)Trades[i].entry;
      Data[i, 3] = (string)Trades[i].sl;
      Data[i, 4] = (string)Trades[i].tp;
      Data[i, 5] = (string)Trades[i].tipo;
      Data[i, 6] = (string)CalcularLote(i);
      Data[i, 7] = (string)Trades[i].coment;
      Data[i, 8] = (string)Trades[i].accion;
      Data[i, 9] = (string)Trades[i].percentToClose;
    }
  }
  // genero un archivo para cada receptor con los datos "Trades\Receptor1.csv"
  for (int j = 0; j < qntReceptores; j++) {
    // si alguno de los trades no está enviado, crea el archivo
    for (int i = 0; i < qntTrades; i++) {
      if (!Trades[i].enviado) {
        string nameFile = "Receptor" + (string)Receptores[j] + ".csv";
        file            = FileOpen(nameFile, FILE_COMMON | FILE_WRITE | FILE_READ | FILE_CSV);
        break;
      }
    }

    // va a escribir en el archivo todos los trades no enviados
    for (int i = 0; i < qntTrades; i++) {
      if (!Trades[i].enviado) {
        FileWrite(file,
                  Data[i, 0], Data[i, 1], Data[i, 2], Data[i, 3], Data[i, 4],
                  Data[i, 5], Data[i, 6], Data[i, 7], Data[i, 8], Data[i, 9]);
        // swith flag enviado:
        if (j == qntReceptores - 1) { Trades[i].enviado = true; }
      }
    }
    FileClose(file);
  }
}

//+------------------------------------------------------------------+
double CEmisor::CalcularLote(int i)
{
  //--- Recalcula los lotes de los que tienen comentarios:
  if (Trades[i].coment != "" && Trades[i].accion != "Parcial") {
    double LotsToSend = NormalizeDouble(Trades[i].lots * (double)Trades[i].coment, 2);
    Trades[i].coment  = "";
    Print("Nuevo lots de trade", i, " es ", Trades[i].lots);
    return LotsToSend;
  }
  return Trades[i].lots;
}

// Reconocer las modificaciones a las operaciones cargadas
//+------------------------------------------------------------------+
bool CEmisor::HayCambios()
{
  bool HayCambios = false;
  for (int i = 0; i < ArraySize(Trades); i++) {
    if (OrderSelect(Trades[i].tk, SELECT_BY_TICKET)) {
      if (Trades[i].tp != OrderTakeProfit() ||
          Trades[i].sl != OrderStopLoss() ||
          Trades[i].entry != OrderOpenPrice()) {
        CambiarTrade(i, "Cambio");
        HayCambios = true;
      }
      if (Trades[i].tipo != OrderType()) {
        CambiarTrade(i, "Abrir");  // una pendiente que se abre
        HayCambios = true;
      }
    }
  }
  if (HayCambios) return true;
  return false;
}
//+------------------------------------------------------------------+
bool CEmisor::HayCierres()
{
  bool HayCierres = false;

  for (int i = 0; i < ArraySize(Trades); i++) {
    // Print("Buscando Cierre de tk: ", Trades[i].tk);
    if (OrderSelect(Trades[i].tk, SELECT_BY_TICKET)) {
      if (OrderCloseTime() != 0) {
        if (!ComentarioTieneTo(OrderComment())) {
          CambiarTrade(i, "Cerrar");
          HayCierres = true;
        }
      }
    } else {
      Print("No pude seleccionar el tk error: ", GetLastError());
    }
  }

  if (HayCierres) return true;
  return false;
}
//+------------------------------------------------------------------+
bool CEmisor::ComentarioTieneTo(string coment)
{
  if (StringFind(coment, "to", 0) != -1) return true;
  return false;
}

// Actualiza los datos un trade,
//+------------------------------------------------------------------+
void CEmisor::CambiarTrade(int index, string action)
{
  if (OrderSelect(Trades[index].tk, SELECT_BY_TICKET)) {
    Trades[index].par            = OrderSymbol();
    Trades[index].tk             = OrderTicket();
    Trades[index].entry          = OrderOpenPrice();
    Trades[index].sl             = OrderStopLoss();
    Trades[index].tp             = OrderTakeProfit();
    Trades[index].tipo           = (ENUM_ORDER_TYPE)OrderType();
    Trades[index].percentToClose = action == "Parcial" ? PercentToClose(index, OrderLots()) : 0;
    Trades[index].lots           = OrderLots();
    if (action != "Parcial") { Trades[index].coment = ""; }
    Trades[index].enviado = false;
    Trades[index].accion  = action;
    Print("cambio tipo: ", action, " en: ", Trades[index].tk);
  }
}
//+------------------------------------------------------------------+
double CEmisor::PercentToClose(int index, double lotsFinal)
{
  double percent = NormalizeDouble(1 - (lotsFinal / Trades[index].lots), 2);
  Print(__FUNCTION__, " ", "percent", " ", percent);
  return percent;
}

/*

*******************************************************
TERMINADO (probar)
*******************************************************
****** control de los symbolos que no son iguales ******
1. armar una table para que el usuario ingrese las equivalencias
2. cada ves que venga info del emisor hay que controlar la equivalencia

*/
//+------------------------------------------------------------------+
void CEmisor::ReemplazarTk(int index)
{
  for (int i = 0; i < OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      int tk = OrderTicket();
      if (!tengoEseTk(tk)) {
        ModificarTrades(index, "tk", tk);
        PrintTrade(index);
      }
      // }
    }
  }
}
//+------------------------------------------------------------------+
bool CEmisor::tengoEseTk(int tk)
{
  for (int i = 0; i < ArraySize(Trades); i++) {
    if (Trades[i].tk == tk) { return true; }
  }
  return false;
}
//+------------------------------------------------------------------+
bool CEmisor::vieneDeParcial(string coment)
{
  if (StringFind(coment, "from", 0) != -1) return true;
  return false;
}
//+------------------------------------------------------------------+
void CEmisor::ModificarTrades(int index, string atributo, int value)
{
  //--- controlar desborde
  int t = ArraySize(Trades);
  if (index > t - 1) { index = t - 1; }
  if (index < 0) { return; }
  //---
  if (atributo == "tk") { Trades[index].tk = value; }
  Print("en Trade: " + (string)index + " nuevo " + atributo + ": " + (string)value);
  PrintTrade(index);
}
// le pasas el tk y te devuelve el index o -1
//+------------------------------------------------------------------+
int CEmisor::BuscarIndex(int tk)
{
  for (int i = 0; i < ArraySize(Trades); i++) {
    if (Trades[i].tk == tk) { return i; }
  }
  return -1;
}

// te busca en el comentario cual es el tk original (cuando hay cierres parciales)
//+------------------------------------------------------------------+
int CEmisor::ticketFrom(string coment, int tk)
{
  string partes[];
  string sep = "#";
  ushort u_sep;
  u_sep = StringGetCharacter(sep, 0);
  int k = StringSplit(coment, u_sep, partes);
  Print(__FUNCTION__, " ", "El ticket de Origen es", " ", partes[1]);

  //---
  return (int)partes[1];
}



//--- Class CReceptor
//+------------------------------------------------------------------+
class CReceptor {
  private:
   struct TradeInfo {
      int             tkEmisor;
      string          par;
      double          entry;
      double          sl;
      double          tp;
      ENUM_ORDER_TYPE tipo;
      double          lots;
      string          coment;
      bool            enviado;
      int             tkReceptor;
   };
   TradeInfo Trades[];
   int       id;

   struct NombreEquivalencia {
      string enEmisor;
      string enReceptor;
      double lotEq;
   };
   NombreEquivalencia equivalencia[];

  public:
   CReceptor();
   ~CReceptor();
   void   Reiniciar(void) { controlarID(); GetEquivalenciasyLots(); } // para cuando se reinicia el EA
   void   idReceptor(int Id) { id = Id; }
   int    idReceptor(void) { return id; }
   bool   controlarID(void);
   void   GetEquivalencias(void);
   void   GetEquivalenciasyLots(void);
   void   LeerArchivo(void);
   void   ProcesarInfo(string& array[][]);
   bool   isNewTrade(int tkParaControlar);
   void   AgregarTrade(int index, string& data[][]);
   void   ModificarTrade(int i, string& data[][]);
   void   ActualizarDatosTrade(int index);
   void   CerrarTrade(int tkEmisor);
   void   EjecutarTrades(void);
   int    EjecutarTrade(int index);
   void   DetectarCerradas(void);
   void   PrintTrade(int index);
   string ParEquivalente(string parAControlar);
   double LotEquivalente(string parRecibido, double lotEmisor);
   double DefinirLotaje(int index,int i,double lotEmisor);


   //--- TOMAR PARCIAL
   int  BuscarIndex(int tk);
   bool tengoEseTk(int tk);
   void ModificarTrades(int index, string atributo, int value);
   void ReemplazarTk(int index);
   bool CerrarLots(int index, double percent, double price);
   void CerrarParcial(int tkViejo, double percent, int tkNuevo);
};

CReceptor::CReceptor() {
   controlarID();
   GetEquivalenciasyLots();
}
CReceptor::~CReceptor() {}

//+------------------------------------------------------------------+
bool CReceptor::controlarID() {
   idReceptor(NroID);
   if (NroID == 0) {
      MessageBox("Cambiar Nro de Receptor", NULL);
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+
void CReceptor::LeerArchivo(void) {
   string nameFile = "Receptor" + (string)id + ".csv";
   if (!FileIsExist(nameFile, FILE_COMMON)) { return; }
   int    file = FileOpen(nameFile, FILE_COMMON | FILE_WRITE | FILE_READ | FILE_CSV);
   string Data[][10];
   int    row = 0;

   while (!FileIsEnding(file)) {
      ArrayResize(Data, ArrayRange(Data, 0) + 1);
      for (int column = 0; column < 10; column++) {
         string a = FileReadString(file);
         Data[row, column] = a;
         Print("Receptor" + (string)id + Data[row, column]);
      }
      row++;
   }
   FileClose(file);
   FileDelete(nameFile, FILE_COMMON);
   ProcesarInfo(Data);
}

//+------------------------------------------------------------------+
void CReceptor::ProcesarInfo(string& data[][]) {
   //--- paso toda la info al array de Trades
   for (int i = 0; i < ArrayRange(data, 0); i++) {
      if (data[i, 8] == "Abrir")
         if (isNewTrade((int)data[i, 0])) {
            AgregarTrade(i, data);
         } else {
            ActualizarDatosTrade(i);
         }

      if (data[i, 8] == "Cambio") { ModificarTrade(i, data); }
      if (data[i, 8] == "Cerrar") { CerrarTrade((int)data[i, 0]); }
      if (data[i, 8] == "Parcial") { CerrarParcial((int)data[i, 7], (double)data[i, 9], (int)data[i, 0]); }
   }
   EjecutarTrades();
}
//+------------------------------------------------------------------+
bool CReceptor::isNewTrade(int tkParaControlar) {
   for (int i = 0; i < ArraySize(Trades); i++) {
      if (Trades[i].tkEmisor == tkParaControlar) { return false; }
   }

   return true;
}
//+------------------------------------------------------------------+
void CReceptor::AgregarTrade(int i, string& data[][]) {
   if (data[i, 8] != "Abrir") return;

   int index = ArraySize(Trades);
   ArrayResize(Trades, ArraySize(Trades) + 1);

   Trades[index].tkEmisor = (int)data[i, 0];
   Trades[index].par = ParEquivalente(data[i, 1]);
   Trades[index].entry = (double)data[i, 2];
   Trades[index].sl = (double)data[i, 3];
   Trades[index].tp = (double)data[i, 4];
   Trades[index].tipo = (ENUM_ORDER_TYPE)(int)data[i, 5];
   Trades[index].lots = LotEquivalente(data[i, 1],(double)data[i,6]);
   Trades[index].coment = data[i, 7];
   //---
   Print(__FUNCTION__, " ", "Agregando ", Trades[index].tkEmisor);
   PrintTrade(i);
}

//+------------------------------------------------------------------+
void CReceptor::ModificarTrade(int i, string& data[][]) {
   int tk = (int)data[i, 0];

   for (int index = 0; index < ArraySize(Trades); index++) {
      if (Trades[index].tkEmisor == tk) {
         Trades[index].entry = (double)data[i, 2];
         Trades[index].sl = (double)data[i, 3];
         Trades[index].tp = (double)data[i, 4];

         if (OrderModify(Trades[index].tkReceptor, Trades[index].entry, Trades[index].sl, Trades[index].tp, 0, clrNONE)) {
            Print(__FUNCTION__, " Modificando ", Trades[index].tkReceptor, " ", Trades[index].par);
            PrintTrade(index);
         }
      }
   }
}
//+------------------------------------------------------------------+
void CReceptor::CerrarTrade(int tkToClose) {
   for (int index = 0; index < ArraySize(Trades); index++) {
      if (Trades[index].tkEmisor == tkToClose) {
         double precio = Trades[index].entry;
         Print(__FUNCTION__, " TRADE TIPO: ", (string)Trades[index].tipo);

         //--- si es un trade abierto:
         if (Trades[index].tipo == OP_BUY || Trades[index].tipo == OP_SELL) {
            if (Trades[index].tipo == OP_BUY) { precio = SymbolInfoDouble(Trades[index].par, SYMBOL_BID); }
            if (Trades[index].tipo == OP_SELL) { precio = SymbolInfoDouble(Trades[index].par, SYMBOL_ASK); }
            Print(__FUNCTION__, " ", "Trades[index].lots", " ", Trades[index].lots);
            if (OrderClose(Trades[index].tkReceptor, Trades[index].lots, precio, 20, clrNONE)) {
               Print(__FUNCTION__, " Cerrando Trade: ", Trades[index].tkReceptor, " ", Trades[index].par);
               return;
            }
         }

         //--- si es un trade pendiente:
         if (Trades[index].tipo != OP_BUY || Trades[index].tipo != OP_SELL) {
            if (OrderDelete(Trades[index].tkReceptor, clrNONE)) {
               Print(__FUNCTION__, " Borrando Trade: ", Trades[index].tkReceptor, " ", Trades[index].par);
               return;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//|      * Funciones de CERRAR PARCIAL *
//+------------------------------------------------------------------+

void CReceptor::CerrarParcial(int tkViejo, double percent, int tkNuevo) {
   int i = BuscarIndex(tkViejo);
   if (i == -1) { return; }

   if (Trades[i].tipo == OP_BUY) {
      double mBid = SymbolInfoDouble(Trades[i].par, SYMBOL_BID);
      double mPoint = SymbolInfoDouble(Trades[i].par, SYMBOL_POINT);
      if (CerrarLots(i, percent, mBid)) {
         Trades[i].tkEmisor = tkNuevo;
         ReemplazarTk(i);
      }
   }
   if (Trades[i].tipo == OP_SELL) {
      double mAsk = SymbolInfoDouble(Trades[i].par, SYMBOL_ASK);
      double mPoint = SymbolInfoDouble(Trades[i].par, SYMBOL_POINT);
      if (CerrarLots(i, percent, mAsk)) {
         Trades[i].tkEmisor = tkNuevo;
         ReemplazarTk(i);
      }
   }
}

// cierra el porcentaje de lotes indicado por emisor
//+------------------------------------------------------------------+
bool CReceptor::CerrarLots(int index, double percent, double price) {
   if (OrderSelect(Trades[index].tkReceptor, SELECT_BY_TICKET)) {
      double LotsToClose = NormalizeDouble((OrderLots() * percent), 2);
      Print(__FUNCTION__, " ", "LotsToClose", " ", LotsToClose);

      if (OrderClose(Trades[index].tkReceptor, LotsToClose, price, 20, clrNONE)) { return true; }
   }
   return false;
}
//+------------------------------------------------------------------+
void CReceptor::ReemplazarTk(int index) {
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         int tk = OrderTicket();
         // int Magico = OrderMagicNumber();
         // if(ControlMagico(OrderMagicNumber())){
         if (!tengoEseTk(tk)) {
            Trades[index].tkReceptor = tk;
            ActualizarDatosTrade(index);
            // Trades[index].tipo = (ENUM_ORDER_TYPE)OrderType();
            // Trades[index].entry = (double)OrderOpenPrice();
            // Trades[index].sl = (double)OrderStopLoss();
            // Trades[index].tp = (double)OrderTakeProfit();
            // Trades[index].lots = (double)OrderLots();
            // Trades[index].tkReceptor = tk;
            // ModificarTrades(index,"tkReceptor",tk);
            Print(__FUNCTION__, "en Trade: " + (string)index + " nuevo Tk Receptor:" + (string)tk);
            PrintTrade(index);
         }
         // }
      }
   }
}
//+------------------------------------------------------------------+
void CReceptor::ActualizarDatosTrade(int index) {
   if (OrderSelect(Trades[index].tkReceptor, SELECT_BY_TICKET)) {
      Trades[index].tipo = (ENUM_ORDER_TYPE)OrderType();
      Trades[index].entry = (double)OrderOpenPrice();
      Trades[index].sl = (double)OrderStopLoss();
      Trades[index].tp = (double)OrderTakeProfit();
      Trades[index].lots = (double)OrderLots();
      Trades[index].coment = (string)OrderComment();

   } else {
      Print(__FUNCTION__, " ", "No se pudo actualizar los datos TK:", Trades[index].tkReceptor, " ", GetLastError());
   }
}
//+------------------------------------------------------------------+
void CReceptor::ModificarTrades(int index, string atributo, int value) 
{
   //--- controlar desborde
   int t = ArraySize(Trades);
   if (index > t - 1) { index = t - 1; }
   if (index < 0) { return; }
   //---
   if (atributo == "tkReceptor") { Trades[index].tkReceptor = value; }
   Print("en Trade: " + (string)index + " nuevo " + atributo + ": " + (string)value);
   PrintTrade(index);
}
//+------------------------------------------------------------------+
bool CReceptor::tengoEseTk(int tk) 
{
   for (int i = 0; i < ArraySize(Trades); i++) {
      if (Trades[i].tkReceptor == tk) { return true; }
   }
   return false;
}
// le pasas el tk y te devuelve el index
//+------------------------------------------------------------------+
int CReceptor::BuscarIndex(int tk) 
{
   for (int i = 0; i < ArraySize(Trades); i++) {
      if (Trades[i].tkEmisor == tk) { return i; }
   }

   Print(__FUNCTION__, " ", "tk", tk, "No Encontrado");
   return -1;
}

//+------------------------------------------------------------------+
void CReceptor::EjecutarTrades(void) 
{
   //--- recorrer los trades
   for (int i = 0; i < ArraySize(Trades); i++) {
      if (Trades[i].tkReceptor == 0) {
         int tk = EjecutarTrade(i);
         if (tk != -1) { Trades[i].tkReceptor = tk; }
      }
   }
}
//+------------------------------------------------------------------+
int CReceptor::EjecutarTrade(int index) 
{
   int    i = index;
   double precio = Trades[i].entry;
   if (Trades[i].tipo == OP_BUY) { precio = SymbolInfoDouble(Trades[i].par, SYMBOL_ASK); }
   if (Trades[i].tipo == OP_SELL) { precio = SymbolInfoDouble(Trades[i].par, SYMBOL_BID); }

   int tk = OrderSend(Trades[i].par, Trades[i].tipo, Trades[i].lots, precio, 30, Trades[i].sl, Trades[i].tp, Trades[i].coment, 0, 0, clrNONE);
   //---
   return tk;
}
//+------------------------------------------------------------------+
void CReceptor::DetectarCerradas(void) { }
//+------------------------------------------------------------------+
void CReceptor::PrintTrade(int index) 
{
   if (ArraySize(Trades) == 0) { return; }
   //--- controlar desborde
   int t = ArraySize(Trades);
   if (index > t - 1) { index = t - 1; }
   if (index < 0) { return; }
   //---
   Print((string)index + " tk: " + (string)Trades[index].tkEmisor);
   Print((string)index + " par: " + (string)Trades[index].par);
   Print((string)index + " entry: " + (string)Trades[index].entry);
   Print((string)index + " sl: " + (string)Trades[index].sl);
   Print((string)index + " tp: " + (string)Trades[index].tp);
   Print((string)index + " lots: " + (string)Trades[index].lots);
   Print((string)index + " tipo: " + (string)Trades[index].tipo);
   Print((string)index + " comment: " + (string)Trades[index].coment);
   Print((string)index + " enviado: " + (string)Trades[index].enviado);
}
//+------------------------------------------------------------------+
// Get Equivalencias
//+------------------------------------------------------------------+
void CReceptor::GetEquivalenciasyLots() {
   // hay que hacer 2 divisiones de cadenas
   // 1. TODAS las separadas por ","
   ArrayFree(equivalencia);
   for (int j = 0; j < 3; j++) {
     string CortePorComa[];
     string sep = ",";
     ushort u_sep;
     u_sep = StringGetCharacter(sep, 0);
     int k;
     if (j == 0) { 
        k = StringSplit(UserEqIndices, u_sep, CortePorComa);
        if (UserEqIndices == "") continue;
      }
     if (j == 1) { 
        k = StringSplit(UserEqGold, u_sep, CortePorComa); 
        if (UserEqGold == "") continue;
        }
     if (j == 2) { 
        k = StringSplit(UserEqOtras, u_sep, CortePorComa); 
        if (UserEqOtras == "") continue;
        }
        
        int t = ArraySize(equivalencia);
        ArrayResize(equivalencia, t + ArraySize(CortePorComa), 0);

        for (int i = 0; i < ArraySize(CortePorComa); i++) {
          // 2. dividir la cadena separada por "="
          string CortePorIgual[];
          sep   = "=";
          u_sep = StringGetCharacter(sep, 0);
          k     = StringSplit(CortePorComa[i], u_sep, CortePorIgual);

          // 3. guardar en el array equivalencias:
          equivalencia[t+i].enEmisor   = CortePorIgual[0];
          equivalencia[t+i].enReceptor = CortePorIgual[1];
          // 4. agrego el lotaje para esa equivalencia
          if (j == 0) { equivalencia[t+i].lotEq = inpLotIndices; }
          if (j == 1) { equivalencia[t+i].lotEq = inpLotOro; }
          if (j == 2) { equivalencia[t+i].lotEq = inpLotOtras; }
     }
   }
     //--- print
   for (int p = 0; p < ArraySize(equivalencia); p++) {
      Print(equivalencia[p].enEmisor);
      Print(equivalencia[p].enReceptor);
   }
}


string CReceptor::ParEquivalente(string parRecibido) {
   for (int i = 0; i < ArraySize(equivalencia); i++) {
      if (equivalencia[i].enEmisor == parRecibido)
         return equivalencia[i].enReceptor;
   }

   return parRecibido;
}


double CReceptor::LotEquivalente(string parRecibido, double lotEmisor) {
   for (int i = 0; i < ArraySize(equivalencia); i++) {
      if (equivalencia[i].enEmisor == parRecibido)
         return equivalencia[i].lotEq;
   }
   
   if (inpLotbyDefault == 0) { return lotEmisor; }
   
   return inpLotbyDefault;
}


int      deIniReason;

// Clase CProgram
//+------------------------------------------------------------------+
class CProgram {
protected:
 CEmisor   emisor;
 CReceptor receptor;

private:
 
public:
   CProgram(void);
   ~CProgram(void);
   virtual void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
   int  OnInitEvent(void);
   void OnDeinitEvent(const int reason);
   void OnTimerEvent(void);
   bool         BuscarInstancia();

};
 
CProgram::CProgram(void) {}
CProgram::~CProgram(void) {}

int CProgram::OnInitEvent(void) 
{
   // inicio normal:
   if (deIniReason != REASON_PARAMETERS){
      if (!BuscarInstancia()) { return INIT_FAILED; }
      Comment("CopyTrade");
      EventSetMillisecondTimer(500);
      emisor.setIniTime();      
   }

   // reinicio por parametros
   if (deIniReason == REASON_PARAMETERS){
      if (Modo == EMITTER) { emisor.Reiniciar(); }
      if(Modo==RECEIVER) { receptor.Reiniciar();}
   }

   return INIT_SUCCEEDED;
}

void CProgram::OnDeinitEvent(const int reason) 
{
   deIniReason = reason;
   if (deIniReason != REASON_PARAMETERS){ Comment("");}
}

void CProgram::OnTimerEvent(void) 
{
   if(Modo==EMITTER) {
      emisor.Emitir();
      }
   if(Modo==RECEIVER){
      receptor.LeerArchivo();
   }
}

bool CProgram::BuscarInstancia()
{ 
   long actual=ChartFirst();

   while(actual!=-1) { 
    string comentario;
    if(ChartGetString(actual, CHART_COMMENT, comentario)){
       if(comentario=="CopyTrade"){
         Alert("EL COPIADOR YA ESTÁ INICIADO! CHART: ", ChartSymbol(actual));
         return false;
         }
      }
    actual=ChartNext(actual);
   }
   return true;
}

CProgram program;

// Gobal Variables
//+------------------------------------------------------------------+
 
// Expert initialization function                                   
//+------------------------------------------------------------------+
int OnInit() { return(program.OnInitEvent()); }

// Expert deinitialization function                                 
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { program.OnDeinitEvent(reason); } 
// Expert tick function                                             
//+------------------------------------------------------------------+
void OnTick() {}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(void) { program.OnTimerEvent(); }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade(void) {}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int     id,
const long&   lparam,
const double& dparam,
const string& sparam) {
// program.ChartEvent(id, lparam, dparam, sparam);
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