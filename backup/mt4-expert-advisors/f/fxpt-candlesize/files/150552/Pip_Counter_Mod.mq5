// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73637

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_NONE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1


//--- indicator buffers
double ArrowUp[];

// NOTE: Objects
// ------------------------------------------------------------------
class CNewCandle
{
 private:
  int             _initialCandles;
  string          _symbol;
  ENUM_TIMEFRAMES _tf;

 public:
  CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
  CNewCandle()
  {
    // toma los valores del chart actual
    _initialCandles = iBars(Symbol(), Period());
    _symbol         = Symbol();
    _tf             = Period();
  }
  ~CNewCandle() { ; }

  bool IsNewCandle()
  {
    int _currentCandles = iBars(_symbol, _tf);
    if (_currentCandles > _initialCandles) {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();
class DrawLabel
{
  long              _chart_ID;
  string            _name;
  string            _prefix;
  int               _sub_window;
  int               _x;
  int               _y;
  ENUM_BASE_CORNER  _corner;
  string            _text;
  string            _font;
  int               _font_size;
  color             _clr;
  double            _angle;
  ENUM_ANCHOR_POINT _anchor;
  bool              _back;
  bool              _selection;
  bool              _hidden;
  long              _z_order;

 public:
  DrawLabel() { ;}
  ~DrawLabel() { ;}

  void DefaultValues()
  {
    _prefix = "label-";  // Prefijo para borrar muchos
    // _name       = _prefix;            // nombre de la etiqueta
    _chart_ID   = 0;              // ID del gráfico
    _sub_window = 0;              // número de subventana
    _x          = 0;              // coordenada por el eje X
    _y          = 0;              // coordenada por el eje Y
    _text       = _name;          // texto
    _font       = "Arial";        // fuente
    _font_size  = 8;              // tamaño de la fuente
    _clr        = clrBlack;       // color
    _angle      = 0;              // inclinación del texto
    _anchor     = ANCHOR_CENTER;  // modo de anclaje
    _back       = false;          // al fondo
    _selection  = false;          // seleccionar para mover
    _hidden     = true;           // ocultar en la lista de objetos
    _z_order    = 0;              // prioridad para el clic del ratón  ;
  }
  bool Create(string name, datetime tm = 0, double pr = 0)
  {
    DefaultValues();
    _name = _prefix + name;

    ResetLastError();

    if (!ObjectCreate(_chart_ID, _name, OBJ_TEXT, _sub_window, tm, pr)) {
      Print(__FUNCTION__, ": ¡Fallo al crear la etiqueta de texto! Código del error = ", GetLastError());
      return (false);
    }

    ObjectSetString(_chart_ID, _name, OBJPROP_TEXT, _text);
    ObjectSetString(_chart_ID, _name, OBJPROP_FONT, _font);
    ObjectSetInteger(_chart_ID, _name, OBJPROP_FONTSIZE, _font_size);
    ObjectSetDouble(_chart_ID, _name, OBJPROP_ANGLE, _angle);
    ObjectSetInteger(_chart_ID, _name, OBJPROP_ANCHOR, _anchor);
    ObjectSetInteger(_chart_ID, _name, OBJPROP_COLOR, _clr);
    ObjectSetInteger(_chart_ID, _name, OBJPROP_BACK, _back);
    ObjectSetInteger(_chart_ID, _name, OBJPROP_SELECTABLE, _selection);
    ObjectSetInteger(_chart_ID, _name, OBJPROP_SELECTED, _selection);
    ObjectSetInteger(_chart_ID, _name, OBJPROP_HIDDEN, _hidden);
    ObjectSetInteger(_chart_ID, _name, OBJPROP_ZORDER, _z_order);

    return (true);
  }
  void Anchor(string anchor)
  {
    if (anchor == "up")
      _anchor = ANCHOR_UPPER;
    else
      _anchor = ANCHOR_LOWER;

    ObjectSetInteger(_chart_ID, _name, OBJPROP_ANCHOR, _anchor);
  }
  void Color(color clr)
  {
    _clr = clr;
    ObjectSetInteger(_chart_ID, _name, OBJPROP_COLOR, _clr);
  }
  bool Move(datetime time, double price)
  {
    ResetLastError();
    //--- movemos el punto de anclaje
    if (!ObjectMove(_chart_ID, _name, _sub_window, time, price)) {
      Print(__FUNCTION__, ": ¡Fallo al mover el punto de anclaje! Código del error = ", GetLastError());
      return (false);
    }
    //--- ejecución con éxito
    return (true);
  }
  bool Text(const string text = "Text")
  {
    //--- anulamos el valor del error
    ResetLastError();

    if (!ObjectSetString(_chart_ID, _name, OBJPROP_TEXT, text)) {
      Print(__FUNCTION__, ": ¡Fallo al cambiar el texto! Código del error = ", GetLastError());
      return (false);
    }

    return (true);
  }
  bool Delete()
  {
    //--- anulamos el valor del error
    ResetLastError();
    //--- eliminamos la etiqueta
    if (!ObjectDelete(_chart_ID, _name)) {
      Print(__FUNCTION__, ": ¡Fallo al eliminar la etiqueta de texto! Código del error = ", GetLastError());
      return (false);
    }
    return (true);
  }
  bool DeleteAll()
  {
    ResetLastError();

    if (!ObjectsDeleteAll(_chart_ID, _prefix)) {
      Print(__FUNCTION__, ": ¡Fallo al eliminar la etiqueta de texto! Código del error = ", GetLastError());
      return (false);
    }

    return (true);
  }
};
DrawLabel label();

// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{
  SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);

  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
  label.DeleteAll();
}

// NOTE: OnCalculate
// ------------------------------------------------------------------
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  int i, start;

  start = iBars(NULL, 0) - 100;
  if (prev_calculated > 1) start = prev_calculated - 1;

  for (i = start; i < rates_total && !IsStopped(); i++) {
    double distance = close[i]-open[i];

    double pips = NormalizeDouble(fabs(distance) / (_Point * 10), 2);
    string spips = DoubleToString(pips, 1);

    if (distance > 0) {
      label.Create((string)i, time[i], high[i]);
      label.Anchor("dn");
      label.Color(Green);
    } else {
      label.Create((string)i, time[i], low[i]);
			label.Anchor("up");
      label.Color(Red);
    }
    label.Text(spips);

  }

  return (rates_total);
}
//+------------------------------------------------------------------+

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