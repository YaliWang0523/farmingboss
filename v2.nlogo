__includes ["region.nls" "turtle.nls" "utility.nls" "plot.nls"]
globals [
  region-boundaries ; a list of regions definitions, where each region is a list of its min pxcor and max pxcor
  region-bg-color
  all-fruits
  all-sell
  total-fruits-create
  current-fruits-create
  random-normal-number
  init-energy
  銷售量
  進貨1
  進貨2
  進貨3
  銷貨1
  銷貨2
  銷貨3
  耗損
  總耗損
  耗損1
  耗損2
  耗損3
  銷貨4
]

to setup
  clear-all
  set region-bg-color 51
  Setup-regions
  Crt-wholesaler_1 20
  Crt-wholesaler_2
  Crt-wholesaler_3
  Crt-wholesaler_4
  Crt-consumer
  set init-energy 保存期限 * 2
  reset-ticks
  set random-normal-number sort (n-values (產期 * 2) [ abs(round(random-normal 0 3)) ])
  set current-fruits-create 0
  set 銷售量 0
  set 進貨1 0
  set 進貨2 0
  set 進貨3 0
  set 銷貨1 0
  set 銷貨2 0
  set 銷貨3 0
  set 耗損 0
  set 總耗損 0
  set 耗損1 0
  set 耗損2 0
  set 耗損3 0
  set 銷貨4 0
end

to go
  if (all-fruits > 0 AND count fruits = 0 AND (count patches with [torf-empty = false] ) = 0) [ stop ]
  Fruits-move
  Wholesalers-move
  Wholesales-stock-energy
  Consumers-move
  Create-fruits-by-setting

  tick
  set 總耗損 耗損 + 耗損1 + 耗損2 + 耗損3
  Update-amount-plot
  set 銷售量 進貨1 + 進貨2 + 進貨3 + 銷貨4
  set all-sell 銷貨1 + 銷貨2 + 銷貨3 + 銷貨4

end


to test
end
@#$#@#$#@
GRAPHICS-WINDOW
451
13
1269
592
-1
-1
10.0
1
10
1
1
1
0
0
0
1
-40
40
-28
28
1
1
1
ticks
30.0

BUTTON
21
196
87
229
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
111
196
193
229
go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
218
196
281
229
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
14
419
438
575
數量
時間
數量
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"fruits" 1.0 0 -16777216 true "" "plot count fruits"
"stock" 1.0 0 -10022847 true "" ""
"fruits-create" 1.0 0 -8330359 true "" ""

MONITOR
387
13
444
58
總產量
all-fruits
17
1
11

MONITOR
37
356
107
401
有效銷售量
all-sell
17
1
11

SLIDER
21
17
207
50
產期
產期
14
365
121.0
1
1
天
HORIZONTAL

SWITCH
21
60
136
93
產量常態分佈
產量常態分佈
1
1
-1000

SLIDER
20
102
206
135
估計總產量
估計總產量
1000
10000
2700.0
100
1
NIL
HORIZONTAL

MONITOR
387
70
444
115
銷售量
銷售量
17
1
11

MONITOR
1273
26
1330
71
進貨1
進貨1
17
1
11

MONITOR
1273
138
1330
183
進貨2
進貨2
17
1
11

MONITOR
1273
310
1330
355
進貨3
進貨3
17
1
11

MONITOR
1273
80
1330
125
銷貨1
銷貨1
17
1
11

MONITOR
1275
194
1332
239
銷貨2
銷貨2
17
1
11

MONITOR
1275
366
1332
411
銷貨3
銷貨3
17
1
11

MONITOR
388
140
445
185
耗損
耗損
17
1
11

MONITOR
318
13
375
58
總耗損
總耗損
17
1
11

MONITOR
1346
80
1403
125
耗損1
耗損1
17
1
11

MONITOR
1347
194
1404
239
耗損2
耗損2
17
1
11

MONITOR
1344
367
1401
412
耗損3
耗損3
17
1
11

MONITOR
1283
533
1340
578
銷貨4
銷貨4
17
1
11

SLIDER
20
146
206
179
保存期限
保存期限
7
70
28.0
7
1
NIL
HORIZONTAL

@#$#@#$#@
# 農產品銷售模擬
## WHAT IS IT?

模擬農產品市場，各個角色之間競爭關係，最終總體的有效銷售量。

## HOW IT WORKS
### 區塊
#### 1. 左邊為生產交易市場
農產品生產後銷售給中間商。
#### 2. 右邊為終端交易市場
##### 模式1. 中間商在生產交易市場中向生產者購買後，進行庫存，再銷售給終端消費者。
##### 模式2. 消費者產生購買需求，中間商才向生產者購買，直接銷售給終端消費者。 

### 角色
#### 1. 農產品
整個生態系統最主要的角色，因農產品的產出而開始整個系統運作，所有農產品完成生命週期後結束系統模擬。農產品完成生命週期有二種方式，一、銷售至終端消費者。二、農產品具有保存期限，在保存期限內若未被終端消費者購買則形成耗損，離開系統。

### 2. 中間商
中間商具有區塊中所描述的二種模式，模式一中，中間商可以有多個，每個具有自己的區塊，區塊大小代表中間商在市場所佔比例。以目前農產品交易為例，有三種主要中間商：一、行口。二、果菜拍賣市場，例：北拍。三、當地果菜市場。
而模式二中的中間商，主要代表為網路銷售管道，包含透過各個電商平台或是社群團購。與模式一最大差異在於無庫存，會在消費者有購買需求時，中間商直接在生產交易市場中交易後，銷售給終端消費者。



## HOW TO USE IT

### Step1 : 設定中間商的區塊大小，在region.nls function Setup-regions 裡。
### Step2 : 設定初始設定
#### 產期：農產品整體產期天數
#### 估計總產值：整個產期內，預估的總產量。
#### 產量常態分佈：是 - 產量依產期呈現常態分佈。否 - 產量為隨機數。
#### 保存期限：農產品的保存期限，


## THINGS TO NOTICE

### 有效銷售量 : 農產品被終端消費者購買的量。
### 總耗損量：農產品未在有效期內被終端消費者購買，而形成耗損的數量。
### 生產交易市場
#### 總產量
#### 銷售量 : 販售給中間商的數量
#### 耗損量 : 農產品於有效期內未被中間商購買而形成耗損的數量。
### 各中間商區塊
#### 進貨量 : 中間商向生產者購買的數量
#### 銷售量 : 中間商販售給終端消費者的量
#### 耗損量 : 農產品被中間商購買進庫存後，未在有效期內被販售給終端消費者。

## THINGS TO TRY

#### 產期：農產品整體產期天數
#### 估計總產值：整個產期內，預估的總產量。
#### 產量常態分佈：是 - 產量依產期呈現常態分佈。否 - 產量為隨機數。
#### 保存期限：農產品的保存期限，#### 產期：農產品整體產期天數
#### 估計總產值：整個產期內，預估的總產量。
#### 產量常態分佈：是 - 產量依產期呈現常態分佈。否 - 產量為隨機數。
#### 保存期限：農產品的保存期限，

## EXTENDING THE MODEL


## NETLOGO FEATURES

### 1. 交易市場機制下產生的價格
### 2. 中間商改變價格對其他中間商的終端消費者產生推或拉的力量。

## RELATED MODELS



## CREDITS AND REFERENCES
<https://github.com/YaliWang0523/farmingboss>
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

banana
false
0
Polygon -7500403 false true 25 78 29 86 30 95 27 103 17 122 12 151 18 181 39 211 61 234 96 247 155 259 203 257 243 245 275 229 288 205 284 192 260 188 249 187 214 187 188 188 181 189 144 189 122 183 107 175 89 158 69 126 56 95 50 83 38 68
Polygon -7500403 true true 39 69 26 77 30 88 29 103 17 124 12 152 18 179 34 205 60 233 99 249 155 260 196 259 237 248 272 230 289 205 284 194 264 190 244 188 221 188 185 191 170 191 145 190 123 186 108 178 87 157 68 126 59 103 52 88
Line -16777216 false 54 169 81 195
Line -16777216 false 75 193 82 199
Line -16777216 false 99 211 118 217
Line -16777216 false 241 211 254 210
Line -16777216 false 261 224 276 214
Polygon -16777216 true false 283 196 273 204 287 208
Polygon -16777216 true false 36 114 34 129 40 136
Polygon -16777216 true false 46 146 53 161 53 152
Line -16777216 false 65 132 82 162
Line -16777216 false 156 250 199 250
Polygon -16777216 true false 26 77 30 90 50 85 39 69

banana2
false
0
Polygon -7500403 false true 25 78 29 86 30 95 27 103 17 122 12 151 18 181 39 211 61 234 96 247 155 259 203 257 243 245 275 229 288 205 284 192 260 188 249 187 214 187 188 188 181 189 144 189 122 183 107 175 89 158 69 126 56 95 50 83 38 68
Polygon -7500403 true true 39 69 26 77 30 88 29 103 17 124 12 152 18 179 34 205 60 233 99 249 155 260 196 259 237 248 272 230 289 205 284 194 264 190 244 188 221 188 185 191 170 191 145 190 123 186 108 178 87 157 68 126 59 103 52 88
Line -16777216 false 54 169 81 195
Line -16777216 false 75 193 82 199
Line -16777216 false 99 211 118 217
Line -16777216 false 241 211 254 210
Line -16777216 false 261 224 276 214
Polygon -16777216 true false 283 196 273 204 287 208
Polygon -16777216 true false 36 114 34 129 40 136
Polygon -16777216 true false 46 146 53 161 53 152
Line -16777216 false 65 132 82 162
Line -16777216 false 156 250 199 250
Polygon -16777216 true false 26 77 30 90 50 85 39 69

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

orbit 1
true
0
Circle -7500403 true true 116 11 67
Circle -7500403 false true 41 41 218

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

strawberry
false
0
Polygon -7500403 false true 149 47 103 36 72 45 58 62 37 88 35 114 34 141 84 243 122 290 151 280 162 288 194 287 239 227 284 122 267 64 224 45 194 38
Polygon -7500403 true true 72 47 38 88 34 139 85 245 122 289 150 281 164 288 194 288 239 228 284 123 267 65 225 46 193 39 149 48 104 38
Polygon -10899396 true false 136 62 91 62 136 77 136 92 151 122 166 107 166 77 196 92 241 92 226 77 196 62 226 62 241 47 166 57 136 32
Polygon -16777216 false false 135 62 90 62 135 75 135 90 150 120 166 107 165 75 196 92 240 92 225 75 195 61 226 62 239 47 165 56 135 30
Line -16777216 false 105 120 90 135
Line -16777216 false 75 120 90 135
Line -16777216 false 75 150 60 165
Line -16777216 false 45 150 60 165
Line -16777216 false 90 180 105 195
Line -16777216 false 120 180 105 195
Line -16777216 false 120 225 105 240
Line -16777216 false 90 225 105 240
Line -16777216 false 120 255 135 270
Line -16777216 false 120 135 135 150
Line -16777216 false 135 210 150 225
Line -16777216 false 165 180 180 195

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
