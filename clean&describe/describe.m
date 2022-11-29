% read Excel
T01 = readtable('高等教育4月.xlsx','PreserveVariableNames', true);
T02 = readtable('高等教育5月.xlsx','PreserveVariableNames', true);
T03 = readtable('高等教育6月.xlsx','PreserveVariableNames', true);

% delete unuseful variables
T01 = removevars(T01, 30:51);
T02 = removevars(T02, 30:51);
T03 = removevars(T03, 30:51);
T01 = removevars(T01, 15:17);
T02 = removevars(T02, 15:17);
T03 = removevars(T03, 15:17);
T01 = removevars(T01, 10:12);
T02 = removevars(T02, 10:12);
T03 = removevars(T03, 10:12);
T01 = removevars(T01, 8);
T02 = removevars(T02, 8);
T03 = removevars(T03, 8);
T01 = removevars(T01, 2:4);
T02 = removevars(T02, 2:4);
T03 = removevars(T03, 2:4);
T01 = removevars(T01, 'Caption');
T02 = removevars(T02, 'Caption');
T03 = removevars(T03, 'Caption');
T01 = removevars(T01, 'View');
T02 = removevars(T02, 'View');
T03 = removevars(T03, 'View');
T01 = removevars(T01, 'Reply');
T02 = removevars(T02, 'Reply');
T03 = removevars(T03, 'Reply');

% merge data
TF= [T01;T02;T03;];
save('original_data.mat','TF');

% creat index
TF.index(1:height(TF)) = [1:height(TF)];

% creat a variable to mark noises
TF.target(1:height(TF)) = 1;

% create a variable: platforms. 4=wechat, 3=weibo, 2=other websites, 1=newspaper & magazine
TF.mediatype(1:height(TF)) = 2;

TF.mediatype(contains(TF.(6), "微信")) = 4;
TF.mediatype(contains(TF.(6), "微博")) = 3;
TF.mediatype(contains(TF.(6), "报章")) = 1;
TF.mediatype(contains(TF.(6), "杂志")) = 1;

fre = cell2table(tabulate(TF.Headline));

% create data: date
TF.Date = datestr(TF.(4),'yyyy-mm-dd');
tabulate(TF.Date) 
TF.Datecat = categorical(cellstr(TF.Date)); 

% identify and mark noises, examples of the key words of noises are as follows:
TF.target(contains(TF.Headline,"熟肉")) = 0;
TF.target(contains(TF.Headline,"扣碗")) = 0;
TF.target(contains(TF.Headline,"职业打假")) = 0;

% extract non-noises and export data to xlsx
clean = TF(TF.target == 1, :); 
clean.finalindex(1:height(clean)) = [1:height(clean)]; 
writetable(clean, '2022Q2data.xlsx', 'Sheet', 1, 'Range', 'A1');

% extract data by platform
paper = clean(clean.mediatype == 1, :);
weibo = clean(clean.mediatype == 3, :);
wechat = clean(clean.mediatype == 4, :);
websites = clean(clean.(6) == "网站", :);

% tendency of numbers of articlies on WeChat over time
h = histogram(wechat.Datecat, 'BarWidth', 0.8) ; 
set(gcf,'unit','normalized','position',[0.2,0.2,0.73,0.32]); 
h.FaceColor= '#7ED194'; 
alpha(1) 
h.EdgeColor = 'none'; 
ylabel({'微','信','发','文','篇','数'},'Rotation',0); 
xticks(["2022-04-01","2022-04-11","2022-04-21","2022-05-01","2022-05-11","2022-05-21","2022-06-01","2022-06-11","2022-06-21"]); 
set(gca, 'YGrid', 'on', 'XGrid', 'off'); 
set(gca, FontSize = 15); 
box off

% tendency of numbers of articlies on Weibo over time
h1 = histogram(weibo.Datecat, 'BarWidth', 0.8) ; 
set(gcf,'unit','normalized','position',[0.2,0.2,0.73,0.32]); 
h1.FaceColor= '#7ED194'; 
alpha(1) 
h1.EdgeColor = 'none'; 
ylabel({'微','博','发','帖','计','数'},'Rotation',0); 
xticks(["2022-04-01","2022-04-11","2022-04-21","2022-05-01","2022-05-11","2022-05-21","2022-06-01","2022-06-11","2022-06-21"]); 
set(gca, 'YGrid', 'on', 'XGrid', 'off');
set(gca, FontSize = 15); 
box off 

% numbers of posts/articles by platform
histogram(categorical(cellstr(char(clean.mediatype))));

% create a variable: month
clean.month(1:height(clean)) = month(clean.(4));
tabulate(clean.month);

clean.month(strcmp(clean.Datecat, "2022-04-")== 1) = 4;
clean.month(strcmp(clean.Datecat, "2022-05-")== 1) = 5;
clean.month(strcmp(clean.Datecat, "2022-06-")== 1) = 6;

% numbers of posts/articles by platform and by month
crosstab(clean.month, clean.mediatype) 

% export texts of posts/articles on different platforms
papertxt = paper(:, 2);
weibotxt = weibo(:, 2);
wechattxt = wechat(:, 2);
websitestxt = websites(:, 2);

writetable(papertxt,'paper.txt');
writetable(weibotxt,'weibo.txt');
writetable(wechattxt,'wechat.txt');
writetable(websitestxt,'websites.txt');

% sort and indentify the abnormal days to find important events
wechatfre = cell2table(tabulate(wechat.Headline));
wechatfre = sortrows(wechatfre,'Var2','descend');
weibofre = cell2table(tabulate(weibo.Headline));
weibofre = sortrows(weibofre,'Var2','descend');
paperfre = cell2table(tabulate(paper.Headline));
paperfre = sortrows(paperfre,'Var2','descend');
websitesfre = cell2table(tabulate(web.Headline));
websitesfre = sortrows(websitesfre,'Var2','descend');

% extract relevant data of important events, examples of the key words of the events are as follows:
plagiarism = clean(contains(clean.Headline, "剽窃"), :) ;
teacherlaw = clean(contains(clean.Headline, "教师法"), :) ;
