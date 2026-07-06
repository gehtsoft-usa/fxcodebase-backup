// Id: 12638
// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+
//Looking for 2 consecutive K/D Crossovers-One in oversold range - 
//One in overbought range - In either order.
//Will test 4 different parameter settings:
//34,21,13,13  21,13,8,8   13,8,5,5    8,5,3,3
//And use the highest set that meets the criteria to draw indicator line
//If none of them meet the criteria, will alert not to trade.
//+------------------------------------------------------------------+
#property copyright "Copyright � 2014, Dream Reality Productions LLC"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2                //Draw_K[],Draw_D[],K[],D[],RSI[],SKI[]
#property indicator_color1 Green             //Draw_K Line
#property indicator_color2 Red               //Draw_D Line

//--------------------------------------Setting settings and buffers---
static int RSI_Length=8;
static int K_Stochastic_Length=5;
static int K_Slowing_Length=3;
static int D_Slowing_Stochastic_Length=3;
extern int Price=0;       

double Draw_K[], Draw_D[];             //Buffers to Draw K and D values
double K[], D[];                       //Buffers to Test K and D values
double RSI[], SKI[];                   //Buffers to calculate RSI and Stochastic of RSI

 static int C=1;                        //Number of Crossover being tested
 static int L;                         //Long Indicator
 static int S;                         //Short Indicator
 static int T;                         //Number of Tests
 static int pos;                       //Bar numbers to calculate...
 static int limit;                     //K,D,Rsi and SKI moving forward in time
 static int Bar=1;                     //Bar numbers to Test values moving backward in time

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

//------------------------------------------
//Set Line characteristics
//------------------------------------------
int init()
{
 IndicatorName = GenerateIndicatorName("Adaptive Stochastic RSI");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
 IndicatorBuffers(6);
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Draw_K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Draw_D);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,K);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,D);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,RSI);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,SKI);
 
return(0);
}
//------------------------------------------
int deinit()
{
 C=1;L=0;S=0;T=0;pos=0;limit=0;Bar=1;
 RSI_Length=8;
 K_Stochastic_Length=5;
 K_Slowing_Length=3;
 D_Slowing_Stochastic_Length=3;
 Price=0; 
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
 
 return(0) ;}
//------------------------------------------
//Primary StochRSI Code
//------------------------------------------
int start()                                           //Special Function Start()
{
   if (T==0)
   {
      if(Bars<=3) return(0);                               //if 3 bars or less, end program                             
      int ExtCountedBars=IndicatorCounted();               //Number of Counted Bars - At start Counted bars = 0
      if (ExtCountedBars<0) return (-1);
      limit=Bars-2;
      if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;    //limit = Index of the first uncounted bar
     } 
   else
   {
      if(Bars<=3) return(0);                               //if 3 bars or less, end program                             
      ExtCountedBars=0;               //Number of Counted Bars - At start Counted bars = 0
      if (ExtCountedBars<0) return (-1);
      limit=Bars-2;
      if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   }  
 //-------------------------------------------------
 //Calculate Initial RSI for bar array
 //-------------------------------------------------
 pos=limit;
 while(pos>=0)                                        //Loop for uncounted bars
 {
  RSI[pos]=iRSI(NULL, 0, RSI_Length, Price, pos);     //Calculate RSI for pos bar
  pos--;                                              //Calculate index of the next bar
 } 
//------------------------------------------------------------------------ 
//Calculate Initial Stochastic for the RSI
//------------------------------------------------------------------------
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Min=RSI[ArrayMinimum(RSI, K_Stochastic_Length, pos)];     //Calculate Lowest Low of RSI for Lookback period
  Max=RSI[ArrayMaximum(RSI, K_Stochastic_Length, pos)];     //Calculate Highest High of RSI for Lookback Period
  if (Min==Max)                                             //if min=max then denominator is 0, therefore
  {                                                         //Can't divide a number by 0, therefore
   SKI[pos]=100.;                                           //Stochastic = 100   
  }
  else
  {
   SKI[pos]=100.*(RSI[pos]-Min)/(Max-Min);                  //Stochastic Formula
  }
  pos--;                                                    //Calculate Stochastic of index of next bar
 }  
 //------------------------------------------------------------------------- 
//Calculate initial K Values
//-------------------------------------------------------------------------
 pos=limit;
 while(pos>=0)
 {
  K[pos]=iMAOnArray(SKI, 0, K_Slowing_Length, 0, MODE_SMA, pos);
  pos--;
 }  
 //------------------------------------------------------------------------- 
//Calculate initial D Values
//-------------------------------------------------------------------------
 pos=limit;
 while(pos>=0)
 {
 D[pos]=iMAOnArray(K, 0, D_Slowing_Stochastic_Length, 0, MODE_SMA, pos);
  pos--;
 }  
//------------------------------------------------------------------------- 
//Stochastic RSI Analysis custom function
//-------------------------------------------------------------------------
   Analyze();
//------------------------------------------------------------------------- 
//End Analysis
//-------------------------------------------------------------------------
   return (0);
}
//------------------------------------------------------------------------- 
//FUNCTIONS DECLARATIONS
//-------------------------------------------------------------------------
//------------------------------------------------------------------------- 
//Analyze
//-------------------------------------------------------------------------
int Analyze()
{
   if (C==1)  {Analyze_1st_CO();}
      else if (C==2) {Analyze_2nd_CO();}
        else  if (C==3) {Draw_Lines();;T=0;C=1;Bar=1; 
              }
           else  if (C>3)  Alert ("Error in Analyze Function. C = ",C);
   return(0);
         }
//----------------------------------------------------------------------------
//Change Settings
//----------------------------------------------------------------------------
int Change_Settings()
{if (T==0)
     { RSI_Length=8;K_Stochastic_Length=5; K_Slowing_Length=3; D_Slowing_Stochastic_Length=3;}
  else if (T==1)
     { RSI_Length=13;K_Stochastic_Length=8; K_Slowing_Length=5; D_Slowing_Stochastic_Length=5;}
         else if (T==2)
            {RSI_Length=21;K_Stochastic_Length=13; K_Slowing_Length=8; D_Slowing_Stochastic_Length=8;}
               else if (T==3)
                 { RSI_Length=34;K_Stochastic_Length=21; K_Slowing_Length=13; D_Slowing_Stochastic_Length=13;}
                    else if (T>3)
                 { RSI_Length=8;K_Stochastic_Length=5; K_Slowing_Length=3; D_Slowing_Stochastic_Length=3;
                 Draw_Lines();}
         return(0);}
 //---------------------------------------------------------------------------
 //1st CrossOver Analysis custom function
 //--------------------------------------------------------------------------

int Analyze_1st_CO()
  {                                                        
    while (K[Bar]>D[Bar])                                 //Is K greater then D?                      
     {      L=1; S=0; Bar++;    }                         //... Then we are Long , Check previous bar                   
       
           
          if (L==1)                                       //We reached our first long crossover!
             {
             if (K[Bar]<25 && D[Bar]<25)                  //Are we in the oversold area? 
             {C=2;                                        //If so, Exit this function and go to 2nd CrossOverAnalysis function
                 return(0);}                              // Via the Analyze function
             else 
               {
                  C=1; T++;Bar=1;                         //If not, Use change settings function to check the next
                  Change_Settings();                      //Lower Setting Set for our criteria
                  return(0);                              //Exit Function
                  }
              }
          else
            while (K[Bar]<D[Bar])                         //Or Is D greater then K?
               { L=0; S=1; Bar++; }                       //... Then we are Short , Check previous bar 
                     if (S==1)                            //We reached our first short crossover!
                     {         
                           if (K[Bar]>75 && D[Bar]>75)  //Are we in the overbought area? 
                              {  C=2;                   //If so, Exit this function and go to 2nd CrossOverAnalysis function
                              return(0);}               // Via the Analyze function
                           else
                                {    C=1; T++; Bar=1;   //If not, Use change settings function to check the next                                 
                                   Change_Settings();   //Lower Setting Set for our criteria
                                   return(0);}           //Exit Function
                               }
                                else
                   Alert ("There is an Error in the 1st Crossover Function.");   //Anything else is an error
                        
                     
                         return(0);                   //Exit
    }   

//----------------------------------------------------------------------------
//Analyze 2nd Cross Over custom function
//----------------------------------------------------------------------------
int Analyze_2nd_CO()
 { 
      if (L==1 && C==2)                                  //Did we have a long crossover in the oversold area?
      {
         while (K[Bar]<D[Bar])                           //If so, we are now short and checking previous bars
          {  L=0; S=1; Bar++;  }                          //for the next previous crossover in the overbought area
            if (K[Bar]>75 && D[Bar]>75)                 //We've reached the 2nd short crossover!
               {C=3;                                       //Are we in the overbought area?
                return(0);}                                 //If so, we can use the current settings and draw our lines
            else 
               {                                         //Otherwise, we need to go to the next lower settings
                  T++; C=1; Bar=1;                       //And retest
                  Change_Settings();
                  return(0);
               }
          }
      else
         if (S==1 && C==2)                             //Or did we have a short crossover in the Overbought area
         {
            while (K[Bar]>D[Bar])                        //If so, we are now long and checking previous bars
               { L=1; S=0; Bar++;}                       //for the next previous crossover in the oversold area  
               if (K[Bar]<25 && D[Bar]<25)               //We've reached the 2nd long crossover!
                  {C=3;                                  //Are we in the oversold area?
                   return(0);}                           //If so, we can use the current settings and draw our lines
               else
                  {                                      //Otherwise, we need to go to the next lower settings
                    T++;Bar=1;C=1;                       //And retest
                    Change_Settings();
                    return(0);
                  }
          }
          
                else
                   Alert ("There is an Error in the 2nd Crossover Function.");   //Anything else is an error
                   return(0);
 }
                       
//----------------------------------------------------------------------------
//Draw Lines Function
//----------------------------------------------------------------------------
int Draw_Lines()
 {if (T<=3)
      Comment ("The Settings are set at ",  RSI_Length, "," ,K_Stochastic_Length, ",", K_Slowing_Length,",", D_Slowing_Stochastic_Length);
   else Comment("Do not trade this pair at this time.  Settings are set at 8,5,3,3.");
//----------------------------------------------------------------------------
//recalculate rsi
//----------------------------------------------------------------------------
pos=limit;
while(pos>=0)                                        //Loop for uncounted bars
 {
  RSI[pos]=iRSI(NULL, 0, RSI_Length, Price, pos);     //Calculate RSI for pos bar
  pos--;                                              //Calculate index of the next bar
 } 
//------------------------------------------------------------------------ 
//recalculate stochastic
//------------------------------------------------------------------------
 double Min, Max;
 pos=limit;
 
 while(pos>=0)
 {
  Min=RSI[ArrayMinimum(RSI, K_Stochastic_Length, pos)];     //Calculate Lowest Low of RSI for Lookback period
  Max=RSI[ArrayMaximum(RSI, K_Stochastic_Length, pos)];     //Calculate Highest High of RSI for Lookback Period
  if (Min==Max)                                             //if min=max then denominator is 0, therefore
  {                                                         //Can't divide a number by 0, therefore
   SKI[pos]=100.;                                           //Stochastic = 100   
  }
  else
  {
   SKI[pos]=100.*(RSI[pos]-Min)/(Max-Min);                  //Stochastic Formula
  }
  pos--;                                                    //Calculate Stochastic of index of next bar
 }  
//------------------------------------------------------------------------- 
//recalculate K lines
//-------------------------------------------------------------------------
 pos=limit;
 while(pos>=0)
 {Draw_K[pos]=iMAOnArray(SKI, 0, K_Slowing_Length, 0, MODE_SMA, pos);
  pos--;
 }  
//------------------------------------------------------------------------- 
//Calculate D lines
//-------------------------------------------------------------------------
 pos=limit;
 while(pos>=0)
   {
      Draw_D[pos]=iMAOnArray(Draw_K, 0, D_Slowing_Stochastic_Length, 0, MODE_SMA, pos);
      pos--;
   }  
 ObjectCreate(IndicatorObjPrefix + ChartID(),"OverBought",OBJ_HLINE,1,0,75,0,0,0);
 ObjectCreate(IndicatorObjPrefix + ChartID(),"OverSold",OBJ_HLINE,1,0,25,0,0,0);
 C=1;L=0;S=0;T=0;pos=0;limit=0;Bar=1;
    return(0);
 }