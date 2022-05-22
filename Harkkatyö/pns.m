function [a_opt,R2]=pns(f,xdata,ydata,a0)
    %funktio laskee parhaat parametrit dataan sovitetulle annetulle
    %funktiolle. Funktio ottaa parametrinä funktion, muuttujan x datan, y
    %datan ja alkuarvaukset parametreille. Funktio palauttaa optimaaliset
    %parametrien arvot ja sovituksen R^{2}-luvun
    
    options = optimset('MaxFunEvals',50000);%lisätään suurimpien mahdollisten laskutoimitusten määrää, jotta iso data saadaan käsiteltyä
    S=@(a)(sum((ydata-f(a,xdata)).^2));
    a_opt=fminsearch(S,a0,options);
    R2=1-(sum((ydata-f(a_opt,xdata)).^2))/(sum((ydata-mean(ydata)).^2));
end
