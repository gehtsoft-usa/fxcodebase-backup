 
#property description"Correlate"
#property version    "1.30"
#property strict
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   9
//--- plot AUD
#property indicator_label1  "AUD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot CAD
#property indicator_label2  "CAD"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrAqua
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot CHF
#property indicator_label3  "CHF"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrFireBrick
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot EUR
#property indicator_label4  "EUR"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRoyalBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- plot GBP
#property indicator_label5  "GBP"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSilver
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2
//--- plot JPY
#property indicator_label6  "JPY"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrYellow
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2
//--- plot NZD
#property indicator_label7  "NZD"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDarkViolet
#property indicator_style7  STYLE_SOLID
#property indicator_width7  2
//--- plot XAU
#property indicator_label8  "XAU"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrGold
#property indicator_style8  STYLE_SOLID
#property indicator_width8  2
//--- plot USD
#property indicator_label9  "USD"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrLimeGreen
#property indicator_style9  STYLE_SOLID
#property indicator_width9  2
//---
#define indicator_handles 8
//---
#property indicator_levelcolor clrLightSlateGray
double indicator_level1=  0;
double indicator_level2= .2;
double indicator_level3= 20;
double indicator_level4= 30;
double indicator_level5=100;
//+------------------------------------------------------------------+
//| Class for indicator and index buffers                            |
//+------------------------------------------------------------------+
/*class CSymbol
  {
private:
   //---             indicator handles
   int               m_handle;
   int               m_size;
   //---             buffers
   double            m_buffer[];
public:
   //---             constructor
                     CSymbol(void):m_handle(INVALID_HANDLE) {  ArraySetAsSeries(true);  }
   //---             destructor
                    ~CSymbol(void)  {  IndicatorRelease();  }
   //---             set indicator handle
   int               Handle(int handle)   {  return(m_handle=handle);   }
   //---             get symbol/indicator value
   double            Close(int index)  const {  return(index>=0 && index<m_size ? this.m_buffer[index]:0.0); }
   //---             copy symbol/indicator data
   int               CopyBuffer(const int start,const int count)  {  return(m_size=CopyBuffer(m_handle,0,start,count,m_buffer));  }
   //---             previously calculated bars
   int               BarsCalculated(void) {  return(BarsCalculated(m_handle));   }
   //---             release indicator handles
   bool              IndicatorRelease(void)  {  return(IndicatorRelease(m_handle)); }
   //---             index buffer series flag
   bool              ArraySetAsSeries(bool flag) { return(ArraySetAsSeries(m_buffer,flag));   }
  };*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBuffer
  {
private:
   int               m_size;
   //---             buffers
   double            m_buffer[];
public:
   //---             constructor
                     CBuffer(void)  {}
   //---             destructor
                    ~CBuffer(void)  {}
   //---             assign index buffers
   bool              SetIndexBuffer(int index,ENUM_INDEXBUFFER_TYPE buffer_mode=INDICATOR_DATA) {  return(SetIndexBuffer(index,m_buffer,buffer_mode));   }
   //---             index buffer series flag
   bool              ArraySetAsSeries(bool flag)   {  return(ArraySetAsSeries(m_buffer,flag));  }
   //---             initialize index buffers 
   bool              ArrayInitialize(double value) {  return(ArrayInitialize(m_buffer,value));  }
   //---             detach index buffers
   void              ArrayFree(void)   {  ArrayFree(m_buffer); return;  }
   //---             set index buffer value
   double            Close(int index,double value) { return(this.m_buffer[index]=value); }
   //---             copy last value
   bool              CopyLast() { return(this.m_buffer[0]=this.m_buffer[1]); }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum indicators
  {
   INDICATOR_MA,           //Moving Average
   INDICATOR_MACD,         //Moving Average Convergence/Divergence
   INDICATOR_STOCHASTIC,   //Stochastic Oscillator
   INDICATOR_RSI,          //Relative Strength Index
   INDICATOR_CCI,          //Commodity Channel Index
   INDICATOR_RVI,          //Relative Vigour Index
   INDICATOR_DEMARKER,     //DeMarker Oscillator
   INDICATOR_MOMENTUM,     //Momentum Oscillator
   INDICATOR_MFI           //Money Flow Index
  };
//--- indicator to display
input indicators  Indicator=INDICATOR_MA;
//--- indicator parameters
input string MA;
input ushort MAPeriod=14;                       //MA Period
input ENUM_MA_METHOD MAMethod=MODE_SMA;         //MA Method
input ENUM_APPLIED_PRICE MAPrice=PRICE_CLOSE;   //MA Price
//---
input string MACD;
input ushort FastEMA=12;                        //Fast EMA Period
input ushort SlowEMA=26;                        //Slow EMA Period
input ENUM_APPLIED_PRICE MACDPrice=PRICE_CLOSE; //MACD Price
//---
input string Stochastic;
input ushort Kperiod=7;                         //K Period
input ushort Slowing=3;
input ENUM_STO_PRICE PriceField=STO_LOWHIGH;    //Price Field
//---
input string RSI;
input ushort RSIPeriod=14;                      //RSI Period
input ENUM_APPLIED_PRICE RSIPrice=PRICE_CLOSE;  //RSI Price
//---
input string CCI;
input ushort CCIPeriod=14;                      //CCI Period
input ENUM_APPLIED_PRICE CCIPrice=PRICE_CLOSE;  //CCI Price
//---
input string RVI;
input ushort RVIPeriod=14;                      //RVI Period
//---
input string DeMarker;
input ushort DeMarkerPeriod=14;                 //DeMarker Period
//---
input string Momentum;
input ushort MomentumPeriod=14;                 //Momentum Period
input ENUM_APPLIED_PRICE MomentumPrice=PRICE_CLOSE;   //Momentum Price
//---
input string MFI;
input ushort MFIPeriod=14;                      //MFI Period
//---
input string _;                                 //---
input string Sfix="";                           //Symbol Suffix
//--- currencies to display
input bool Auto=false;                          //Display chart currencies
input bool Aud=true;                            //Display Aussie
input bool Cad=true;                            //Display Loonie
input bool Chf=true;                            //Display Swissy
input bool Eur=true;                            //Display Fiber
input bool Gbp=true;                            //Display Sterling
input bool Jpy=true;                            //Display Yen
input bool Nzd=true;                            //Display Kiwi
input bool Xau=true;                            //Display Gold
input bool Usd=true;                            //Display Greenback
//--- indicator and index objects                            
//CSymbol *symbol[indicator_handles];
CBuffer *currency[indicator_buffers];
//--- chart properties
long chartID;
short window;
bool IsVisible[indicator_buffers];
//--- on tick handlers
//int Handle[indicator_handles];
//--- symbols to use
string Symbols[indicator_handles]={"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD","XAUUSD"};
//--- currency names
string Currency[indicator_buffers];
//--- symbols for indicators
string Symbol[indicator_handles];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   chartID=ChartID();
//--- get necessary symbols
   for(int i=0;i<indicator_handles;i++)
     {
      Symbol[i]=Symbols[i]+Sfix;
      if(!IsTesting())
         if(!SymbolSelect(Symbol[i],true)/* || 
            !SymbolIsSynchronized(Symbol[i])*/)
           {
            Alert(Symbol[i]," not available in Market Watch.\nInitialization Failed.");
            return(INIT_FAILED);
           }
      ::iCustom(Symbol[i],PERIOD_CURRENT,"OnTick.ex4",chartID,i,0,0);
     }
   string shortName;
//--- set indicator properties
   switch(Indicator)
     {
      case INDICATOR_MA:
         /*for(int i=0;i<indicator_handles;i++)
            if(!CheckPointer(symbol[i]=new CSymbol) || symbol[i].Handle(iMA(Symbol[i],0,MAPeriod,PERIOD_CURRENT,MAMethod,MAPrice))==INVALID_HANDLE)
               return(INIT_FAILED);*/
         shortName=StringFormat("Correl8 %s(%d)",StringSubstr(EnumToString(MAMethod),5),MAPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,5);
         IndicatorSetInteger(INDICATOR_LEVELS,1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         break;
      case INDICATOR_MACD:
         /*for(int i=0;i<indicator_handles;i++)
            if(!CheckPointer(symbol[i]=new CSymbol) || symbol[i].Handle(iMACD(Symbol[i],PERIOD_CURRENT,FastEMA,SlowEMA,SignalSMA,MACDPrice))==INVALID_HANDLE)
               return(INIT_FAILED);*/
         shortName=StringFormat("Correl8 MACD(%d,%d)",FastEMA,SlowEMA);
         IndicatorSetInteger(INDICATOR_DIGITS,5);
         IndicatorSetInteger(INDICATOR_LEVELS,1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         break;
      case INDICATOR_STOCHASTIC:
         /*for(int i=0;i<indicator_handles;i++)
            if(!CheckPointer(symbol[i]=new CSymbol) || symbol[i].Handle(iStochastic(Symbol[i],PERIOD_CURRENT,Kperiod,Dperiod,Slowing,MODE_SMA,PriceField))==INVALID_HANDLE)
               return(INIT_FAILED);*/
         shortName=StringFormat("Correl8 Stochastic(%d,%d)",Kperiod,Slowing);
         IndicatorSetInteger(INDICATOR_DIGITS,1);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level4);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level4);
         break;
      case INDICATOR_RSI:
         /*for(int i=0;i<indicator_handles;i++)
            if(!CheckPointer(symbol[i]=new CSymbol) || symbol[i].Handle(iRSI(Symbol[i],PERIOD_CURRENT,RSIPeriod,RSIPrice))==INVALID_HANDLE)
               return(INIT_FAILED);*/
         shortName=StringFormat("Correl8 RSI(%d)",RSIPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,1);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level3);
         break;
      case INDICATOR_CCI:
         /*for(int i=0;i<indicator_handles;i++)
            if(!CheckPointer(symbol[i]=new CSymbol) || symbol[i].Handle(iCCI(Symbol[i],PERIOD_CURRENT,CCIPeriod,CCIPrice))==INVALID_HANDLE)
               return(INIT_FAILED);*/
         shortName=StringFormat("Correl8 CCI(%d)",CCIPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,0);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level5);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level5);
         break;
      case INDICATOR_RVI:
         /*for(int i=0;i<indicator_handles;i++)
            if(!CheckPointer(symbol[i]=new CSymbol) || symbol[i].Handle(iRVI(Symbol[i],PERIOD_CURRENT,RVIPeriod))==INVALID_HANDLE)
               return(INIT_FAILED);*/
         shortName=StringFormat("Correl8 RVI(%d)",RVIPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,3);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level2);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level2);
         break;
      case INDICATOR_DEMARKER:
         /*for(int i=0;i<indicator_handles;i++)
            if(!CheckPointer(symbol[i]=new CSymbol) || symbol[i].Handle(iDeMarker(Symbol[i],PERIOD_CURRENT,DeMarkerPeriod))==INVALID_HANDLE)
               return(INIT_FAILED);*/
         shortName=StringFormat("Correl8 DeMarker(%d)",DeMarkerPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,3);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level2);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level2);
         break;
      case INDICATOR_MOMENTUM:
         /*for(int i=0;i<indicator_handles;i++)
            if(!CheckPointer(symbol[i]=new CSymbol) || symbol[i].Handle(iMomentum(Symbol[i],PERIOD_CURRENT,MomentumPeriod,MomentumPrice))==INVALID_HANDLE)
               return(INIT_FAILED);*/
         shortName=StringFormat("Correl8 Momentum(%d)",MomentumPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,3);
         IndicatorSetInteger(INDICATOR_LEVELS,1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         break;
      case INDICATOR_MFI:
         /*for(int i=0;i<indicator_handles;i++)
            if(!CheckPointer(symbol[i]=new CSymbol) || symbol[i].Handle(iTriX(Symbol[i],PERIOD_CURRENT,TrixPeriod,TrixPrice))==INVALID_HANDLE)
               return(INIT_FAILED);*/
         shortName=StringFormat("Correl8 MFI(%d)",MFIPeriod);
         IndicatorSetInteger(INDICATOR_DIGITS,1);
         IndicatorSetInteger(INDICATOR_LEVELS,3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,0,indicator_level1);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,1,indicator_level3);
         IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-indicator_level3);
     }
//--- set name & create labels
   IndicatorSetString(INDICATOR_SHORTNAME,shortName);
   window=(short)ChartWindowFind(chartID,shortName);
//--- indicator buffers mapping
   for(int i=0;i<indicator_plots;i++)
     {
      if((currency[i]=new CBuffer)==NULL)
         return(INIT_FAILED);
      currency[i].SetIndexBuffer(i,INDICATOR_DATA);
      //currency[i].ArraySetAsSeries(true);
      SetIndexEmptyValue(i,EMPTY_VALUE);
     }
//--- currency labels
   string label;
   Currency[0]=label=indicator_label1;
   Currency[1]=label=indicator_label2;
   Currency[2]=label=indicator_label3;
   Currency[3]=label=indicator_label4;
   Currency[4]=label=indicator_label5;
   Currency[5]=label=indicator_label6;
   Currency[6]=label=indicator_label7;
   Currency[7]=label=indicator_label8;
   Currency[8]=label=indicator_label9;
//--- currencies to display
   IsVisible[0]=Aud;
   IsVisible[1]=Cad;
   IsVisible[2]=Chf;
   IsVisible[3]=Eur;
   IsVisible[4]=Gbp;
   IsVisible[5]=Jpy;
   IsVisible[6]=Nzd;
   IsVisible[7]=Xau;
   IsVisible[8]=Usd;
//--- display chart currencies
   if(Auto)
     {
      for(int i=0;i<indicator_plots;i++)
        { 
         IsVisible[i]=false;
         if(StringFind(_Symbol,Currency[i])!=-1)
            IsVisible[i]=true;
        }
     }
   CreateLabels();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])  {
//---
   int limit=rates_total-prev_calculated,toCount;
//--- set initial bars to count and get bars/indicator calculated
   if(!prev_calculated)
     {
      int barsTotal=MathMin((int)ChartGetInteger(chartID,CHART_VISIBLE_BARS)+20,rates_total);
      /*for(int i=0;i<indicator_handles;i++)
        {
         if(barsTotal>Bars(Symbols[i],PERIOD_CURRENT))
            barsTotal=Bars(Symbols[i],PERIOD_CURRENT);
        }*/
      /*for(int i=0;i<indicator_handles;i++)
         if(!CheckPointer(symbol[i]) || symbol[i].BarsCalculated()<barsTotal)
            return(0);*/
      for(int i=0;i<indicator_buffers;i++)
         if(CheckPointer(currency[i]))
            currency[i].ArrayInitialize(EMPTY_VALUE);
      limit=barsTotal-1;
     }
//--- elements to copy/copied
   if(OnTick(toCount=limit+1)!=toCount)
      return(0);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(chartID,window,OBJ_LABEL);
//---
   /*for(int i=0;i<indicator_handles;i++)
      if(CheckPointer(symbol[i]))
         delete symbol[i];*/
   for(int i=0;i<indicator_buffers;i++)
      if(CheckPointer(currency[i]))
         delete currency[i];
   return;
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define USDCAD 1
#define USDCHF 2
#define USDJPY 5
#define XAUUSD 7
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnTick(int to_count)
  {
   //--- copy indicator values to arrays
   /*for(int i=0;i<indicator_handles;i++)
      if(!CheckPointer(symbol[i]) || symbol[i].CopyBuffer(0,to_count)!=to_count)
        {
         printf("Insufficient or incorrect data in history for %s",Symbols[i]);
         return(0);
        }*/
//--- main loop for indicator calculation
   double ExtSymbol[indicator_handles]={0};
   for(int i=to_count-1;i>=0 && !_StopFlag;i--)
     {
      switch(Indicator)
        {
         case INDICATOR_MA:
            for(int h=0;h<indicator_handles;h++)
               //--- get value for each symbol
               ExtSymbol[h]=iMA(Symbol[h],_Period,MAPeriod,0,MAMethod,MAPrice,i)-iMA(Symbols[h],PERIOD_CURRENT,MAPeriod,0,MAMethod,MAPrice,i+1);
            ExtSymbol[USDJPY]/=100;
            ExtSymbol[XAUUSD]/=1000;
            break;
         case INDICATOR_MACD:
            for(int h=0;h<indicator_handles;h++)
               //--- get value for each symbol
               ExtSymbol[h]=iMACD(Symbol[h],_Period,FastEMA,SlowEMA,9,MACDPrice,MODE_MAIN,i);
            ExtSymbol[USDJPY]/=100;
            ExtSymbol[XAUUSD]/=1000;
            break;
         case INDICATOR_STOCHASTIC:
            for(int h=0;h<indicator_handles;h++)
               //--- get value for each symbol
               ExtSymbol[h]=iStochastic(Symbol[h],_Period,Kperiod,2,Slowing,MODE_SMA,PriceField,MODE_MAIN,i)-50;
            break;
         case INDICATOR_RSI:
            for(int h=0;h<indicator_handles;h++)
               //--- get value for each symbol
               ExtSymbol[h]=iRSI(Symbol[h],_Period,RSIPeriod,RSIPrice,i)-50;
            break;
         case INDICATOR_CCI:
            for(int h=0;h<indicator_handles;h++)
               //--- get value for each symbol
               ExtSymbol[h]=iCCI(Symbol[h],_Period,CCIPeriod,CCIPrice,i);
            break;
         case INDICATOR_RVI:
            for(int h=0;h<indicator_handles;h++)
               //--- get value for each symbol
               ExtSymbol[h]=iRVI(Symbol[h],_Period,RVIPeriod,MODE_MAIN,i);
            break;
         case INDICATOR_DEMARKER:
            for(int h=0;h<indicator_handles;h++)
               //--- get value for each symbol
               ExtSymbol[h]=iDeMarker(Symbol[h],_Period,DeMarkerPeriod,i)-.5;
            break;
         case INDICATOR_MOMENTUM:
            for(int h=0;h<indicator_handles;h++)
               //--- get value for each symbol
               ExtSymbol[h]=iMomentum(Symbol[h],_Period,MomentumPeriod,MomentumPrice,i)-100;
            break;
         case INDICATOR_MFI:
            for(int h=0;h<indicator_handles;h++)
               //--- get value for each symbol
               ExtSymbol[h]=iMFI(Symbol[h],_Period,MFIPeriod,i)-50;
        }
      //--- invert USD based values
      ExtSymbol[USDCAD]*=-1;
      ExtSymbol[USDCHF]*=-1;
      ExtSymbol[USDJPY]*=-1;
      //--- calculate each currency's value
      double SumSymbol[indicator_buffers];
      ArrayInitialize(SumSymbol,0.0);
      for(int a=0;a<indicator_handles;a++)
         SumSymbol[indicator_handles]+=-ExtSymbol[a];
      SumSymbol[indicator_handles]/=indicator_handles;
      for(int a=0;a<indicator_handles;a++)
         SumSymbol[a]=SumSymbol[indicator_handles]+ExtSymbol[a];
      //--- assign currency value to buffer
      for(int a=0;a<indicator_buffers;a++)
         currency[a].Close(i,IsVisible[a]?SumSymbol[a]:EMPTY_VALUE);
     }
   return(to_count);
//---
  }
//+------------------------------------------------------------------+
//| On chart event function                                          |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam) // Parameter of type string events 
  {
//--- check for incoming ticks
   if(id>=CHARTEVENT_CUSTOM)
      OnTick(int(dparam+1));
//---
  }
//+-------------------------------------------------------------------+
//| Create colored currency labels                                    |
//+-------------------------------------------------------------------+
void CreateLabels()
  {
//--- currency colors
   color Color[indicator_buffers]=
     {
      indicator_color1,indicator_color2,indicator_color3,
      indicator_color4,indicator_color5,indicator_color6,
      indicator_color7,indicator_color8,indicator_color9
     };
//--- x coordinates
   int xStart=4;
   int xIncrement=24;
//--- y coordinates
   int yStart=16;
   int yIncrement=0;
//--- create all labels
   for(int i=0;i<indicator_buffers;i++)
     {
      if(!IsVisible[i])
        { 
         SetIndexLabel(i,NULL);
         continue; 
        }  
      SetIndexLabel(i,Currency[i]);
      ObjectCreate(Currency[i],xStart,yStart,Color[i]);
      xStart += xIncrement;
      yStart += yIncrement;
     }
  }
//+------------------------------------------------------------------+
//| Create label objects at coordinates                              |
//+------------------------------------------------------------------+
void ObjectCreate(string label,int x,int y,int clr)
  {
   string name=label+(string)window;
   ObjectCreate(chartID,name,OBJ_LABEL,window,0,0);
   ObjectSetString(chartID,name,OBJPROP_TEXT,label);
   ObjectSetString(chartID,name,OBJPROP_FONT,"Arial Bold");
   ObjectSetInteger(chartID,name,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chartID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chartID,name,OBJPROP_YDISTANCE,y);
  }
//+------------------------------------------------------------------+
