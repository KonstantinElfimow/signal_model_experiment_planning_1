%% 1. Оценка PO в зависимости от NP и R
clear all;

% Задание неварьируемых величин
Ts = 1/200; % Задание интервала дискретизации по времени
Ns = 200; % количество отсчетов на интервале
Hz = 200; % Частота несущей

Am = 40; % амплитуда импульса
mr = 0.5; % коэффициент различимости

repeated_seq = zeros(Ns + 1, 2);
for i = 1:Ns+1
    repeated_seq(i, 1) = (i - 1) * Ts;
    if mod(i, 2)
        repeated_seq(i, 2) = 0;
    else
        repeated_seq(i, 2) = Am;
    end
end

% Задание количества и диапазонов изменения факторов NP (уровень (мощность)
% шума на входе приемника) и R (расстояние от источника до приемника)
nf = 2; % количество факторов в плане эксперимента
minf = [0.004 2]; % минимальное значение факторов a и b
maxf = [0.1 7]; % максимальное значение факторов a и b

% Стратегическое планирование эксперимента
% Формирование дробного двухуровневого плана эксперимента для учета взаимодействий
fracfact('a b ab'); % формируем список возможных взаимодействий
% вычисление общего количества точек в плане эксперимента 
% (все возможные сочетания уровней факторов)
N = 2 ^ nf;
fracplan = ans;

% Сформируем матрицу X с добавлением столбца значений фиктивного фактора
fictfact = ones(N, 1); % ones - возвращает скалярную 1, либо матрицу этих единиц
X = [fictfact ans]'; % формируем транспонированную матрицу плана с добавлением фиктивного фактора

fraceks = zeros(N, nf); % матрица (кол-во экспериментов x кол-во факторов)
for i = 1:nf
    for j = 1:N
        % Заполняем матрицу значениями
        fraceks(j,i) = minf(i) + (fracplan(j,i) + 1) * (maxf(i) - minf(i)) / 2;
    end
end

% Тактическое планирование эксперимента
%задание доверительного интервала и уровня значимости
dp = 0.7; % доверительный интервал
alpha = 0.5; % уровень значимости
tkr_alpha = norminv(1 - alpha / 2); % t-критическое
%определение требуемого числа испытаний
NE = ceil(tkr_alpha ^ 2 / (4 * dp ^ 2));

% результаты эксперимента
Y = zeros(1, N);
for j = 1:N
    % параметры для логистического распределения
    a = fraceks(j, 1);
    b = fraceks(j, 2);
    NP = a;
    R = b;
    %цикл статистических испытаний с фиксированным объемом
    %выборки для достижения заданной точности оценки показателя
    u = zeros(NE, 1);
    for k=1:NE
        %имитация функционирования системы
        to = round(rand * 100); %инициализация генератора шума
        sl = sim('trenl', Ts * Ns);
        %вероятность успешного приема
        u(k)= mean(not(xor(sl.simout(:, 1), sl.simout1(:, 1))));
    end
    %оценка показателя (реакции) по выборке наблюдений
    P_O = mean(u);
    Y(j) = P_O; 
end

% Регрессионный анализ

% Определение коэффициентов регрессии
C = X * X';
b_ = inv(C) * X * Y';

% Формирование зависимости реакции системы на множестве реальных значений факторов
A = minf(1):0.001:maxf(1);
B = minf(2):0.001:maxf(2);
[unused, N1] = size(A);
[unused, N2] = size(B);

Yc = zeros(N2, N1);
for i = 1:N1
    for j = 1:N2
        an = 2 * (A(i) - minf(1)) / (maxf(1) - minf(1)) - 1;
        bn = 2 * (B(j) - minf(2)) / (maxf(2) - minf(2)) - 1;
        % Экспериментальная поверхность реакции (линейная регрессия)
        Yc(j, i) = b_(1) + an * b_(2) + bn * b_(3) + an * bn * b_(4);
    end
end

% Отображение зависимостей в трехмерной графике
[x, y] = meshgrid(A, B); % координата в двумерном пространстве
figure;
% Экспериментальная поверхность реакции
subplot(1, 1, 1), plot3(x, y, Yc);
xlabel('мощность шума NP');
ylabel('расстояние R');
zlabel('уверенный прием РО');
title('PO');
grid on;
%% 2. Оценка L в зависимости от R и mr при фиксированных Am и NP
clear all;
% Задание неварьируемых величин
Ts = 1/200; % Задание интервала дискретизации по времени
Ns = 200; % количество отсчетов на интервале
Hz = 200; % Частота несущей

Am = 40; % амплитуда импульса
NP = 0.9; % мощность шума


repeated_seq = zeros(Ns + 1, 2);
for i = 1:Ns+1
    repeated_seq(i, 1) = (i - 1) * Ts;
    if mod(i, 2)
        repeated_seq(i, 2) = 0;
    else
        repeated_seq(i, 2) = Am;
    end
end

% Задание количества и диапазонов изменения факторов R и mr
nf = 2; % количество факторов в плане эксперимента
minf = [4 0.01]; % минимальное значение факторов
maxf = [9 0.08]; % максимальное значение факторов

% Стратегическое планирование эксперимента
% Формирование дробного двухуровневого плана эксперимента для учета взаимодействий
fracfact('a b ab'); % формируем список возможных взаимодействий
% вычисление общего количества точек в плане эксперимента 
% (все возможные сочетания уровней факторов)
N = 2 ^ nf;
fracplan = ans;

% Сформируем матрицу X с добавлением столбца значений фиктивного фактора
fictfact = ones(N, 1); % ones - возвращает скалярную 1, либо матрицу этих единиц
X = [fictfact ans]'; % формируем транспонированную матрицу плана с добавлением фиктивного фактора

fraceks = zeros(N, nf); % матрица (кол-во экспериментов x кол-во факторов)
for i = 1:nf
    for j = 1:N
        % Заполняем матрицу значениями
        fraceks(j,i) = minf(i) + (fracplan(j,i) + 1) * (maxf(i) - minf(i)) / 2;
    end
end

%тактическое планирование эксперимента
%задание доверительного интервала и уровня значимости
dl = 0.5;
alpha = 0.3;
%определение t-критического
tkr_alpha = norminv(1 - alpha / 2);
%цикл по совокупности экспериментов стратегического плана
Yl = zeros(1, N);
for j=1:N
    a = fraceks(j, 1);
    b = fraceks(j, 2);
    R = a;
    mr = b;
    %организация цикла статистических испытаний с переменным объемом
    %выборки для достижения заданной точности оценки показателя
    NE = 1;
    l = 0;
    SQ = 0;
    D = 1;
    while NE < tkr_alpha ^ 2 * D / dl ^ 2
        %имитация функционирования системы
        to = round(rand * 100); %инициализация генератора шума
        sl = sim('trenl', Ts * Ns);
        ul = var(sl.simout1(:, 1)) / (Ts * Ns);
        %Оценка выборочной дисперсии D измеряемого параметра
        l = l + ul;
        SQ = SQ + ul ^ 2;
        if NE > 20
            D = SQ / (NE - 1) - (l ^ 2) / (NE * (NE - 1));
        end
        NE = NE + 1;
    end
    NE = NE - 1;
    %оценка показателя (реакции) по выборке наблюдений
    L = l / NE;
    Yl(j) = L;
end

% Регрессионный анализ

% Определение коэффициентов регрессии
Cl = X * X';
b_l = inv(Cl) * X * Yl';

% Формирование зависимости реакции системы на множестве реальных значений факторов
Al = minf(1):0.01:maxf(1);
Bl = minf(2):0.01:maxf(2);
[unused, N1] = size(Al);
[unused, N2] = size(Bl);

Yc = zeros(N2, N1);
for i = 1:N1
    for j = 1:N2
        anl = 2 * (Al(i) - minf(1)) / (maxf(1) - minf(1)) - 1;
        bnl = 2 * (Bl(j) - minf(2)) / (maxf(2) - minf(2)) - 1;
        % Экспериментальная поверхность реакции (линейная регрессия)
        Yc(j, i) = b_l(1) + anl * b_l(2) + bnl * b_l(3) + anl * bnl * b_l(4);
    end
end

% Отображение зависимостей в трехмерной графике
[x, y] = meshgrid(Al, Bl); % координата в двумерном пространстве
figure;
% Экспериментальная поверхность реакции
subplot(1, 1, 1), plot3(x, y, Yc);
xlabel('расстояние R');
ylabel('различимость mr');
zlabel('интенсивность ошибок L');
title('L');
grid on;