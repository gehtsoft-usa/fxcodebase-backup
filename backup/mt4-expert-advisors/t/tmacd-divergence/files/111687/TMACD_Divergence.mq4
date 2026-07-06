// Id: 17873
//+------------------------------------------------------------------+
//|                                             TMACD_Divergence.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_width1 2
#property indicator_color1 clrRed
#property indicator_width2 2
#property indicator_color2 clrLime
#property indicator_width3 2
#property indicator_color3 clrOrange
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrWhite

enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern int     Fast_Length = 7;
extern int     Slow_Length = 14;
input  e_price Price       = CLOSE;
extern color   Up_Color    = clrLime;
extern color   Down_Color  = clrOrange;

double TMACD[];
double F_WMA[], S_WMA[];
int    len_F, len_S;

double Up[];
double Dn[];

string Indi_Name;
int    TMACD_Window;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init(){
   
   IndicatorName = GenerateIndicatorName("TMACD Divergence");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   Indi_Name = IndicatorName;

   IndicatorDigits(Digits);
   IndicatorBuffers(5);
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,TMACD);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,Up);
   SetIndexArrow(1,234);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,Dn);
   SetIndexArrow(2,233);
   
   SetIndexBuffer(3,F_WMA);
   SetIndexBuffer(4,S_WMA);
   
   len_F=MathFloor(Fast_Length/2)+1;
   len_S=MathFloor(Slow_Length/2)+1;
   
   SetLevelValue(0,0);
   
   TMACD_Window = WindowFind(Indi_Name);

   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start(){

   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;

   for (i=limit; i>=0; i--){
      F_WMA[i]=iMA(NULL, 0, len_F, 0, MODE_SMA, ENUM_APPLIED_PRICE(Price), i)*Point;
      S_WMA[i]=iMA(NULL, 0, len_S, 0, MODE_SMA, ENUM_APPLIED_PRICE(Price), i)*Point;
   } 
   
   double F_TMA, S_TMA;
   for (i=limit; i>=0; i--){
      F_TMA=iMAOnArray(F_WMA, 0, len_F, 0, MODE_SMA, i);
      S_TMA=iMAOnArray(S_WMA, 0, len_S, 0, MODE_SMA, i);
      TMACD[i]=(F_TMA-S_TMA)/Point;
   }
   
   int    PRICEUPPREV   = limit;
   int    PRICEDOWNPREV = limit;
   int    UPPREV        = limit;
   int    DOWNPREV      = limit;
   
   double curr;
   
   for (i=limit; i>=0; i--){
   
      curr = High[i + 2];
      
      if (curr > High[i + 4] && curr > High[i + 3] && curr > High[i + 1] && curr > High[i]){
   			
         if (High[PRICEUPPREV] < High[i+2]){
         
            Trend_Line("RPU_"+i, Time[PRICEUPPREV], High[PRICEUPPREV], Time[i+2], High[i+2], Up_Color, 1, STYLE_SOLID, 0);

         }
   			
         PRICEUPPREV=i+2;
   	 
   	}
   	
   	curr = Low[i + 2];
      
      if (curr < Low[i + 4] && curr < Low[i + 3] && curr < Low[i + 1] && curr < Low[i]){
   			
         if (Low[PRICEDOWNPREV] > Low[i+2]){
         
            Trend_Line("RPD_"+i, Time[PRICEDOWNPREV], Low[PRICEDOWNPREV], Time[i+2], Low[i+2], Down_Color, 1, STYLE_SOLID, 0);

         }
   			
         PRICEDOWNPREV=i+2;
   	 
   	}
      
      curr = TMACD[i + 2];
      if (curr > TMACD[i + 4] && curr > TMACD[i + 3] &&  curr > TMACD[i + 1] && curr > TMACD[i] && TMACD[i + 2] > 0){
      
         if (TMACD[UPPREV] > TMACD[i + 1]){
      
            Trend_Line("OU_"+i, Time[UPPREV], TMACD[UPPREV], Time[i+2], TMACD[i+2], Up_Color, 1, STYLE_SOLID, TMACD_Window);
            Up[i+2] = TMACD[i+2];
      
         }
      
         UPPREV = i + 2;	
      
      }
      
      if (curr < TMACD[i + 4] && curr < TMACD[i + 3] &&  curr < TMACD[i + 1] && curr < TMACD[i] && TMACD[i + 2] < 0){
      
         if (TMACD[DOWNPREV] < TMACD[i + 1]){
      
            Trend_Line("OD_"+i, Time[DOWNPREV], TMACD[DOWNPREV], Time[i+2], TMACD[i+2], Down_Color, 1, STYLE_SOLID, TMACD_Window);
            Dn[i+2] = TMACD[i+2];
      
         }
      
         DOWNPREV = i + 2;	
      
      }
   	
   }
   
 return(0);
}

void Trend_Line(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, double precio2, color bpcolor, int ancho, int style, int window){
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_TREND, window, tiempo1, precio1, tiempo2, precio2);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, bpcolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_RAY, False);
   ObjectSet(IndicatorObjPrefix +  Nombre, OBJPROP_BACK, true );
}