data latin;
input Order Day Treatment $ Y;
datalines;
1 1 E 8.21
1 2 D 5.64
1 3 A 6.52
1 4 B 8.80
1 5 C 6.18
2 1 B 8.55
2 2 E 9.12
2 3 C 5.97
2 4 D 6.63
2 5 A 6.96
3 1 D 6.06
3 2 A 7.37
3 3 E 8.58
3 4 C 6.11
3 5 B 8.95
4 1 C 6.34
4 2 B 8.82
4 3 D 6.70
4 4 A 8.65
4 5 E 8.87
5 1 A 7.89
5 2 C 6.84
5 3 B 9.03
5 4 E 9.31
5 5 D 6.85
;
run;

proc glm data=latin;
class Treatment Day Order;
model Y = Treatment Day Order;
means Treatment / tukey cldiff;
run;
