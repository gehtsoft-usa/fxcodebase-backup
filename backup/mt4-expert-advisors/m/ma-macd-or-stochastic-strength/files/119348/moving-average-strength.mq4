
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2    //two buffers, one for above zero line, one for below
#property indicator_color1 Green // above zero line color
#property indicator_color2 Red   // below zero line color


//---- input parameters
extern bool      MA_Power=true;  // MA Indicator Strength ON/OFF
extern bool      MACD_Power=false;  // MACD Indicator Strength ON/OFF
extern bool      Stochastic_Power=false; // Stochastic Indicator Strength ON/OFF
extern int       MA_Fast=13;  // default indicator values
extern int       MA_Slow=21;
extern int       MACD_Fast=12;
extern int       MACD_Slow=26;
extern int       MACD_Signal=9;
extern int       Sto_K=14;
extern int       Sto_D=3;
extern int       Sto_Slowing=3;
extern int       Back_Bars=500;  // history limit
extern bool      Set_Levels=true;   // average pos/neg indicator levels ON/OFF


//---- buffers
double Power_Buffer_Pos[]; // Pos indicator values
double Power_Buffer_Neg[]; // Neg indicator values



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
   {
   
   //====================================
   // Checking Inputs & Set Window Labels
   //====================================
   
   if (MA_Power == true && MACD_Power == false && Stochastic_Power == false) 
      {
      IndicatorShortName("Moving Average Strength ("+DoubleToStr(MA_Fast,0)+","+DoubleToStr(MA_Slow,0)+")");
      }
   else if (MA_Power == false && MACD_Power == true && Stochastic_Power == false) 
      {
      IndicatorShortName("MACD Strength ("+DoubleToStr(MACD_Fast,0)+","+DoubleToStr(MACD_Slow,0)+","+DoubleToStr(MACD_Signal,0)+")");
      }
   else if (MA_Power == false && MACD_Power == false && Stochastic_Power == true) 
      {
      IndicatorShortName("Stochastic Strength ("+DoubleToStr(Sto_K,0)+","+DoubleToStr(Sto_D,0)+","+DoubleToStr(Sto_Slowing,0)+")");
      }
   else if (MA_Power == false && MACD_Power == false && Stochastic_Power == false) 
      {
      IndicatorShortName("Invalid Parameters");
      Alert("One Power Indicator must be set to True");
      return;
      }      
   else 
      {
      IndicatorShortName("Invalid Parameters");
      Alert("Only one Power Indicator can be set to True");
      return;
      }
 
   
  
  
   //=================
   // Indicator Setup
   //=================
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,2); // Pos indicator type and width
   SetIndexBuffer(0,Power_Buffer_Pos); //binds buffer to Power_Buffer_Pos
   SetIndexDrawBegin(0, Back_Bars); // not sure if necessary but is used to set starting point of indicator (bars back)
   SetIndexLabel(0, "Positive Strength"); // sets mouse-over label
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,2);  // Neg indicator type and width
   SetIndexBuffer(1,Power_Buffer_Neg); //binds buffer to Power_Buffer_Neg
   SetIndexDrawBegin(1, Back_Bars); // not sure if necessary but is used to set starting point of indicator (bars back)
   SetIndexLabel(1, "Negative Strength"); // sets mouse-over label
   
 

   return(0);
  }
  
  
  
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {


   return(0);
  }
  
  
  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
   {
   
   //======================
   // variable declarations
   //======================
   int limit;  // not used!!
   int Bar_Index=0; // bar tracker
   int Pos_Bar_Count=0; // pos bar count  (needed for averaging)
   int Neg_Bar_Count=0; // neg bar count  (needed for averaging)
   double Total_Pos_Power=0;  // stores total pos power/strength value   (needed for averaging)
   double Average_Pos_Power=0;   // current average pos power/strength value   
   double Total_Neg_Power=0;  // stores total neg power/strength value   (needed for averaging)
   double Average_Neg_Power=0;  // current average neg power/strength value
   int counted_bars=IndicatorCounted();   // not used!! (yet)


   for (Bar_Index = Back_Bars; Bar_Index >=0; Bar_Index--) //  MAIN INDICATOR FOR LOOP
      {
      
      //=======================
      // Indicator Calculations
      //=======================
      double MA_Fast1 = iMA(Symbol(),0,MA_Fast,0,MODE_EMA,PRICE_CLOSE,Bar_Index);
      double MA_Slow1 = iMA(Symbol(),0,MA_Slow,0,MODE_EMA,PRICE_CLOSE,Bar_Index);
      double MA_Diff = MA_Fast1 - MA_Slow1;
      double MACD_Main = iMACD(Symbol(),0,MACD_Fast,MACD_Slow,MACD_Signal,PRICE_CLOSE,MODE_MAIN,Bar_Index);
      double MACD_Signal1 = iMACD(Symbol(),0,MACD_Fast,MACD_Slow,MACD_Signal,PRICE_CLOSE,MODE_SIGNAL,Bar_Index);
      double MACD_Diff = MACD_Main - MACD_Signal1;
      double Sto_Main = iStochastic(Symbol(),0,Sto_K,Sto_D,Sto_Slowing,MODE_EMA,0,MODE_MAIN,Bar_Index);    
      double Sto_Signal = iStochastic(Symbol(),0,Sto_K,Sto_D,Sto_Slowing,MODE_EMA,0,MODE_SIGNAL,Bar_Index);
      double Sto_Diff = Sto_Main - Sto_Signal;         
      
      
      //=================
      // MA Strength
      //=================
      if (MA_Power == true && MA_Diff > 0)
         {
         Power_Buffer_Pos[Bar_Index] = MA_Diff; // pos indicator value
         Power_Buffer_Neg[Bar_Index] = 0; // neg indicator value
         Pos_Bar_Count = Pos_Bar_Count + 1;
         Total_Pos_Power = Total_Pos_Power + MA_Diff;
         }
      else if (MA_Power == true && MA_Diff < 0)
         {
         Power_Buffer_Pos[Bar_Index] = 0; // pos indicator value
         Power_Buffer_Neg[Bar_Index] = MA_Diff; // neg indicator value
         Neg_Bar_Count = Neg_Bar_Count + 1;
         Total_Neg_Power = Total_Neg_Power + MA_Diff;        
         }   
      else if (MA_Power == true && MA_Diff == 0)
         {
         Power_Buffer_Pos[Bar_Index] = 0;
         Power_Buffer_Neg[Bar_Index] = 0;
         }            
         
      //=================
      // MACD Strength
      //=================         
      if (MACD_Power == true && MACD_Diff > 0) 
         {
         Power_Buffer_Pos[Bar_Index] = MACD_Diff;  // pos indicator value
         Power_Buffer_Neg[Bar_Index] = 0; // neg indicator value
         Pos_Bar_Count = Pos_Bar_Count + 1;
         Total_Pos_Power = Total_Pos_Power +  MACD_Diff;
         }
      else if (MACD_Power == true && MACD_Diff < 0)    
         {
         Power_Buffer_Pos[Bar_Index] = 0; // pos indicator value
         Power_Buffer_Neg[Bar_Index] = MACD_Diff;  // neg indicator value
         Neg_Bar_Count = Neg_Bar_Count + 1;
         Total_Neg_Power = Total_Neg_Power + MACD_Diff;
         }
      else if (MACD_Power == true && MACD_Diff == 0)    
         {
         Power_Buffer_Pos[Bar_Index] = 0;
         Power_Buffer_Neg[Bar_Index] = 0;
         }         
         
      //====================
      // Stochastic Strength
      //====================      
      if (Stochastic_Power == true && Sto_Diff > 0) 
         {
         Power_Buffer_Neg[Bar_Index] = 0; // neg indicator value
         Power_Buffer_Pos[Bar_Index] = Sto_Diff;   // pos indicator value
         Pos_Bar_Count = Pos_Bar_Count + 1;
         Total_Pos_Power = Total_Pos_Power + Sto_Diff;
         }
      else if (Stochastic_Power == true && Sto_Diff < 0)
         {   
         Power_Buffer_Pos[Bar_Index] = 0; // pos indicator value
         Power_Buffer_Neg[Bar_Index] = Sto_Diff;   // neg indicator value
         Neg_Bar_Count = Neg_Bar_Count + 1;         
         Total_Neg_Power = Total_Neg_Power + Sto_Diff;
         }
      else if (Stochastic_Power == true && Sto_Diff == 0)
         {   
         Power_Buffer_Neg[Bar_Index] = 0;
         Power_Buffer_Pos[Bar_Index] = 0;
         }      
         
         
      } // CLOSE OF FOR LOOP
      
      
   //==============================
   // Average Strength Calculations
   //==============================   
   Average_Pos_Power = Total_Pos_Power/Pos_Bar_Count;
   Average_Neg_Power = Total_Neg_Power/Neg_Bar_Count;
   
   
   //=======================
   // Setting Average Levels
   //=======================
   if (Set_Levels == true) // displaying levels 
      {
      SetLevelStyle( EMPTY, 1, Blue) ;      
      SetLevelValue(1, Average_Pos_Power);
      SetLevelValue(2, Average_Neg_Power);
      }
   else if (Set_Levels == false) // needed to erase old levels if setting Set_Levels to False  
      {
      SetLevelStyle( EMPTY, 1, Gray) ;
      SetLevelValue(1, 0);
      SetLevelValue(2, 0);
      }      
   
   
   return(0);
   }
//+------------------------------------------------------------------+