// Id: 24812
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67187

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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"

#property description"Shows the position of Price in relation to the"
#property description"Open of the current Bar."  
#property description"."
#property description"Bid is greater than Open, Indicator shows UP."
#property description"Ask is less than Open, Indicator shows DOWN."
#property description"Ask is greater than Open and Bid is less than Open"
#property description"Indicator shows SIDEWAYS."
#property indicator_chart_window
#property strict
extern string stfs="Select --> Timeframes Below";
extern bool UseM1=true;
extern bool UseM5=true;
extern bool UseM15=true;
extern bool UseM30=true;
extern bool UseH1=true;
extern bool UseH4=true;
extern bool UseD1=true;
extern bool UseW1=true;
extern bool UseMN=true;
int iTF[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string sTF[]={"M1","M5","M15","M30","H1","H4","D1","W1","MN1"};
bool bTF[9];
extern string cnr="Select --> Corner Below";
enum entry1
{
  c0=0,//Left Top
  c1=1,//Right Top 
  c2=2,//Left Bottom
  c3=3,//Right Bottom
};
input entry1 Corner=c0;  
extern string note1="Select --> Coordinates Below";
extern int X=50;          // X Position
extern int Y=50;         // Y Position
//extern int X_Space=250;  // Horizontal Spacing
extern int Y_Space=20;  // Vertical Spacing
extern string win="Select --> Arrow or Square Below";
enum entry
{
  a1=1, //Arrow
  a2=2, //Square
};  
input entry ArroworSquare=a1;//SELECT >> Arrow or Square   

int arrowCodeUp;
int arrowCodeDown;
int arrowCodeSide;
extern bool Sort_by_ADR = false;
extern string note5="Indicator Parameters:";
extern   int EMA1_period=10;
extern   int EMA2_period=50;
extern   int EMA3_period=200;

extern   int ASSize=8;
string note8="Colors";
extern color TxtClr=Gray;          //Text Color
extern color UpClr=LimeGreen;       //Up Color
extern color DnClr=Red;       //Down Color
extern color SdClr=Orange;          //Sideway Color

int codeAO,codeAO2,codeAO3,codeAO4,codeAO5,codeAO6,codeao7,codeao8,codeao9;
color ClrAO,ClrAO2,ClrAO3,ClrAO4,ClrAO5,ClrAO6,clrao7,clrao8,clrao9;
string Pref;
int multiplier;
extern int font_size = 9;
         string   pairs[],
                  pair,
                  suffix,
                  cmt;         
         int      totPairs;
         string   curr[]={"AUD","EUR","CAD","CHF","GBP","JPY","NZD","USD"};

         double   ADR,CDR;
         double   ADR_spread_pair_idx[1][3];
        
         
         int x_col[20]={0,8,11,14,17,20,23,26,29,32,35,38,41};//,60};
         int x_col_pos=0;
         int y_space_line=0;
         double label_adj;
         
         double ema1,ema2,ema3;
         datetime TIME;
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

int init()
  {
//---- indicators
    Comment("");
    
   double temp = iCustom(NULL, 0, "MEGA_FX", false, 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'MEGA_FX' indicator");
      return INIT_FAILED;
   }
// Set 'unique' Prefix to allow multiple instances on a chart
   Pref = StringFormat("x%d:y%d_",X,Y);
   ChartSetInteger(ChartID(),CHART_FOREGROUND,false);

   IndicatorName = GenerateIndicatorName("MTF MEGA_FX");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

      totPairs=0;
      suffix=StringSubstr(Symbol(),6,StringLen(Symbol())-6);
      for(int c=0;c<ArraySize(curr);c++)
      {
         for(int p=0;p<ArraySize(curr);p++)
         {
            ArrayResize(pairs,totPairs+1);
            pair=curr[c]+curr[p]+suffix;
            if(iClose(pair,0,0)!=0)
            {
               pairs[totPairs]=pair;
               totPairs++;
            }
         }
      }
      
     int idx=0; 
     bTF[idx]=UseM1;idx++;
     bTF[idx]=UseM5;idx++;
     bTF[idx]=UseM15;idx++;
     bTF[idx]=UseM30;idx++;
     bTF[idx]=UseH1;idx++;
     bTF[idx]=UseH4;idx++;
     bTF[idx]=UseD1;idx++;
     bTF[idx]=UseW1;idx++;
     bTF[idx]=UseMN;
     
     TIME=0;
     
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  Delete_My_Obj(Pref);
   Comment("");
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
  
//----
   return(0);
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
                const int &spread[])
{

   if(Bars>0 && TIME==Time[0])return(0);
   if(ArroworSquare==a1){arrowCodeUp=233;arrowCodeDown=234;arrowCodeSide=232;}
   if(ArroworSquare==a2){arrowCodeUp=110;arrowCodeDown=110;arrowCodeSide=110;}
   
   x_col_pos=0;
   x_col_pos++;

   
   int pair_num = ArraySize(pairs)-1;
   
   ArrayResize(ADR_spread_pair_idx,pair_num);
   
   for(int p=0;p<pair_num;p++)
   {
      pair = pairs[p];
      double point = MarketInfo(pair, MODE_POINT);
      if (point == 0)
         continue;
      ADR = iATR(pair,PERIOD_D1,14,0) / point;
      CDR = (iHigh(pair,PERIOD_D1,0)-iLow(pair,PERIOD_D1,0)) / point;
 
      ADR_spread_pair_idx[p][0]=NormalizeDouble(ADR/10,0);
      ADR_spread_pair_idx[p][1]=p;
      ADR_spread_pair_idx[p][2]=NormalizeDouble(CDR/10,0);
    
   }
   
   if(Sort_by_ADR)ArraySort(ADR_spread_pair_idx,0,0);
   cmt="";
   for(int p=0;p<ArraySize(ADR_spread_pair_idx)/3;p++)
   {
      int pair_idx;
      
      pair_idx = ADR_spread_pair_idx[p][1];
      
      pair=pairs[pair_idx];
      ADR = StrToDouble(ADR_spread_pair_idx[p][0]);
      CDR = StrToDouble(ADR_spread_pair_idx[p][2]);
      
      //ADR = iATR(pair,PERIOD_D1,14,0)/MarketInfo(pair,MODE_POINT);
      
      color C;
      if(pair==Symbol())C=Red;else C=TxtClr;    
      if(Y==0)Y=1;     
      
      x_col_pos=0;
      for(int t=0;t<ArraySize(iTF);t++)
      {  
         if(bTF[t])
         {   
            x_col_pos++;
            
            double val00 = iCustom(pair, iTF[t], "MEGA_FX", false, 0, 0);
            double val01 = iCustom(pair, iTF[t], "MEGA_FX", false, 0, 1);
            double val10 = iCustom(pair, iTF[t], "MEGA_FX", false, 1, 0);
            double val11 = iCustom(pair, iTF[t], "MEGA_FX", false, 1, 1);
            double val0 = val00 == val01 ? val10 : val00;
            double val1 = val00 == val01 ? val11 : val01;
            if (val0 < val1)
            {
               codeAO = arrowCodeUp;
               ClrAO = UpClr;
            }
            else
            {
               codeAO = arrowCodeDown;
               ClrAO = DnClr;
            }
            double adj = StringLen(sTF[t])*2.5;
            DrawLabels(Pref+" "+pair+" "+sTF[t],   Corner, -adj+X+font_size*x_col[x_col_pos], Y+1*Y_Space, sTF[t],  0,TxtClr, 0, font_size);
      
            DrawLabels(Pref+"AO direction "+pair+" "+sTF[t],   Corner, X+font_size*x_col[x_col_pos], Y+2*Y_Space+p*1.5*font_size, "", codeAO,ClrAO, 0, ASSize);
         
         }
      } 
      
      
      DrawLabels("ADR "+pair,Corner,X+x_col[0],Y+2*Y_Space+p*1.5*font_size,pair,0,C,0,font_size);
      
      DrawLabels(Pref+"Header",   Corner, X+font_size*x_col[x_col_pos/2], Y+0*Y_Space,"Trend Dir",  0,TxtClr, 0, 10);

      DrawLabels("ADR",Corner,-7+X+font_size*x_col[x_col_pos+1],Y+1*Y_Space,"ADR",0,TxtClr,0,font_size);   
   
      DrawLabels("CDR",Corner,-6+X+font_size*x_col[x_col_pos+2],Y+1*Y_Space,"CDR",0,TxtClr,0,font_size);   
          
      DrawLabels("ADR_value "+ADR+pair,Corner,X+font_size*x_col[x_col_pos+1],Y+1.85*Y_Space+p*1.5*font_size,ADR,0,C,0,font_size+1);      
      
      DrawLabels("CDR_value "+ADR+pair,Corner,X+font_size*x_col[x_col_pos+2],Y+1.85*Y_Space+p*1.5*font_size,CDR,0,C,0,font_size+1);
               
      
   }

   TIME=Time[0];
   return(rates_total);
}


///-----------------------
void Delete_My_Obj(string Prefix)
   {
   for(int k=ObjectsTotal()-1; k>=0; k--)  // Ïî êîëè÷åñòâó âñåõ îáúåêòîâ 
     {
      string Obj_Name=ObjectName(k);   // Çàïðàøèâàåì èìÿ îáúåêòà
      string Head=StringSubstr(Obj_Name,0,StringLen(Prefix));// Èçâëåêàåì ïåðâûå ñèì

      if (Head==Prefix)
         {
         ObjectDelete(Obj_Name);
         } 
         
      while(StringFind(ObjectName(0,k),"ADR")>=0 ||StringFind(ObjectName(0,k),"CDR")>=0)
      {
         if(!ObjectDelete(0,ObjectName(ChartID(),k)))Alert(GetLastError());
      }               
   }
}
 
 //--------------------------------   
 
void DrawLabels(string name, int corn, int x, int y,string Text, int code=0, color Clr=Green, int Win=0, int FSize=10)
{
   int Error=ObjectFind(IndicatorObjPrefix + name);// Çàïðîñ 
   if (Error!=Win)// Åñëè îáúåêòà â óê. îêíå íåò :(
    {  
      ObjectCreate(IndicatorObjPrefix + name,OBJ_LABEL,Win, 0,0); // Ñîçäàíèå îáúåêòà
    }
     
     ObjectSet(IndicatorObjPrefix + name, OBJPROP_CORNER, corn);     // Ïðèâÿçêà ê óãëó   
     ObjectSet(IndicatorObjPrefix + name, OBJPROP_XDISTANCE, x);  // Êîîðäèíàòà Õ   
     ObjectSet(IndicatorObjPrefix + name,OBJPROP_YDISTANCE,y);// Êîîðäèíàòà Y   
     ObjectSetText(IndicatorObjPrefix + name,Text,FSize,"Arial",Clr);
     if(code==0)
     ObjectSetText(IndicatorObjPrefix + name, Text ,FSize,"Arial",Clr);
     else
     ObjectSetText(IndicatorObjPrefix + name, CharToStr(code), FSize,"Wingdings",Clr);
}
   
  
//-----------------END--------------------------   
