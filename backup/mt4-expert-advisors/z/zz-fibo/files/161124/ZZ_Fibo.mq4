//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76423
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_chart_window

input int zzDepth     = 12;    // ZigZag depth
input int zzDeviation = 5;     // ZigZag deviation
input int zzBackstep  = 3;     // ZigZag backstep

// reemplazamos/añadimos el parámetro para controlar cuántos fibos hacia atrás dibujamos
input int fibosBack = 20; // número de pares (fibos) a dibujar desde el más reciente hacia atrás

input color fiboColor    = clrDeepSkyBlue;
input int   fiboWidth    = 1;
input bool  drawOnlyLastPair = false; // si true dibuja sólo el último par

string OBJ_PREFIX = "ZZFIBO_";

void DeleteAllMyFibo()
{
   int total = ObjectsTotal();
   for(int i = total-1; i >= 0; i--)
   {
      string name = ObjectName(0,i);
      if(StringFind(name, OBJ_PREFIX) == 0)
         ObjectDelete(0, name);
   }
}

int GetZigZagPriceAt(int bar)
{
   // iCustom ZigZag: buffer 0
   double v = iCustom(NULL, 0, "ZigZag", zzDepth, zzDeviation, zzBackstep, 0, bar);
   if(v == EMPTY_VALUE) return(0);
   // devolver 1 si hay punto, pero retornamos como entero no necesario; mantendremos precio con iCustom la próxima vez
   return(0);
}

void DrawFiboObject(string name, datetime t1, double p1, datetime t2, double p2)
{
   // si existe la borramos antes
   if(ObjectFind(0, name) != -1) ObjectDelete(0, name);

   // Crear OBJ_FIBO entre (t1,p1) y (t2,p2)
   if(!ObjectCreate(0, name, OBJ_FIBO, 0, t1, p1, t2, p2))
   {
      Print("Error creando Fibo ", name, " Err=", GetLastError());
      return;
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, fiboColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, fiboWidth);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
}

void DrawAllFiboFromZigZag()
{
   // elimina previos
   DeleteAllMyFibo();

   // recopilar puntos ZigZag (de izquierda -> derecha para orden natural)
   int bars = Bars;
   int zzCount = 0;
   // arrays para indices y precios
   int idxs[];
   double prices[];
   ArrayResize(idxs, 0);
   ArrayResize(prices, 0);

   for(int b = bars-1; b >= 0; b--) // del pasado al presente (barras antiguas primero)
   {
      double zzprice = iCustom(NULL, 0, "ZigZag", zzDepth, zzDeviation, zzBackstep, 0, b);
      if(zzprice != 0.0 && zzprice != EMPTY_VALUE)
      {
         int n = ArraySize(idxs);
         ArrayResize(idxs, n+1);
         ArrayResize(prices, n+1);
         idxs[n] = b;
         prices[n] = zzprice;
         zzCount++;
      }
   }

   if(zzCount < 2) return;

   // Queremos dibujar pares de puntos consecutivos.
   // Decidir cuántos pares dibujar: desde el más reciente hacia atrás.
   int availablePairs = zzCount - 1;
   // usa el nuevo input 'fibosBack' para limitar la cantidad de fibos dibujados
   int pairsToDraw = MathMin(availablePairs, fibosBack);

   // si drawOnlyLastPair true, dibuja solo el último par (más reciente)
   int startPairIndex = 0;
   if(drawOnlyLastPair) {
      startPairIndex = availablePairs - 1; // último par (entre penúltimo y último)
      pairsToDraw = 1;
   } else {
      // queremos dibujar los pairsToDraw pares más recientes -> empezamos en availablePairs - pairsToDraw
      startPairIndex = availablePairs - pairsToDraw;
   }

   // indices en arrays están en orden de más antiguo (idxs[0]) a más reciente (idxs[zzCount-1])
   int labelIdx = 0;
   for(int pi = startPairIndex; pi <= startPairIndex + pairsToDraw - 1; pi++)
   {
      int i1 = pi;
      int i2 = pi + 1;
      datetime t1 = iTime(NULL, 0, idxs[i1]);
      datetime t2 = iTime(NULL, 0, idxs[i2]);
      double p1 = prices[i1];
      double p2 = prices[i2];

      string name = OBJ_PREFIX + IntegerToString(labelIdx) + "_" + TimeToString(t1, TIME_DATE|TIME_SECONDS);
      DrawFiboObject(name, t1, p1, t2, p2);
      labelIdx++;
   }
}

int OnInit()
{
   IndicatorShortName("ZZ-Fibo (dibujar fibo entre puntos ZigZag)");
   // crear al iniciar
   DrawAllFiboFromZigZag();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   // borrar sólo los que creó este indicador
   DeleteAllMyFibo();
}

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
   // Redibujar cuando cambien puntos del ZigZag.
   // Para simplicidad redibujamos en cada cálculo; si quieres optimizar, guarda último conteo de puntos.
   DrawAllFiboFromZigZag();
   return(rates_total);
}


//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76423
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/