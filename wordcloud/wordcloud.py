"""
Created on Thu Apr  1 18:30:57 2021

@author: zhangsiqi
"""

import jieba
import jieba.analyse

import codecs

from wordcloud import WordCloud
import matplotlib.pyplot as plt

# 导入imageio库中的imread函数，并用这个函数读取本地图片，作为词云图外观形状，此处选取的是椭圆
import imageio
mk = imageio.imread("toyuan.png")

# ============================


#载入停用词
jieba.analyse.set_stop_words('stoped.txt')
#添加自定义词典
jieba.load_userdict("mydict.txt")
# 强制拆分词组(把这些词在字典里删掉
o = ['民办高校','优秀教师','教师应','高校教师','教师队伍',
     '大学教授','研究生班','研究生院','教学研究','科学研究',
     '研究成果','研究院','普通高校','重点高校','大学老师',
     '北京高校','上海高校','高校学生','高校老师','青年教师',
     '教师资格','专任教师','民办教师','教师工资','任课教师',
     '骨干教师', '教师职业', '女教师', '教师网','小学教师',
     '高级教师','教师论文','兼职教师','特级教师','资深教师',
     '家庭教师']
for oitem in o:
    jieba.del_word(oitem) 

# 强制合并 
hard = ['北京科技大学','经师','人师','文圣常','李琦','宋庚一','强国','十九届六中全会','助理教授','高等教育','课程思政','教师节','研究生','优秀','思政课','副教授','数学科学学院','100周年']
for hitem in hard:
    jieba.add_word(hitem)

# 中文分词
f = open('weibo.txt', encoding='utf-8')
txt = f.read()
txtlist = jieba.cut(txt)
string = ''
segments = []

z = open("blank3.txt", mode="w", encoding="utf-8") 
counts = {}
stopwords = [line.strip() for line in codecs.open('stoped.txt', 'r', 'utf-8').readlines()] 

for word in txtlist:
    #停用词判断，如果当前的关键词不在停用词库中才进行记录
    if len(word) > 1:
        # 记录全局分词
        if word not in stopwords:
            segments.append({'word':word, 'count':1})
            string += word + ' '
            z.write(word + "\n")
            counts[word] = counts.get(word, 0) + 1
z.close()

# 输出高频词频率至文件
q = open("weibofreq.txt", mode="w", encoding="utf-8") 

# 打印一部分高频词作初步了解
u100 = []
flist = list(counts.items())
flist.sort(key=lambda x: x[1], reverse=True)
for i in range(200):
    print(flist[i])
    u100.append(flist[i])

for j in range(200):
    x = u100[j][0]
    y = u100[j][1]
    q.write(x + ' ' + str(y) + "\n")
q.close()

# 生成词云
def create_word_cloud():
    frequencies = {}
    for line in open("weibofreq.txt"):
        arr = line.split(" ")
        frequencies[arr[0]] = float(arr[1])
    
    w = WordCloud(background_color='white',
                   font_path='SimHei.ttf',
                   mask=mk,
                   prefer_horizontal=1,
                   max_words=50,
                   min_font_size=25,
                   scale=3)
    
    word_cloud = w.generate_from_frequencies(frequencies)
    # 写词云图片
    word_cloud.to_file("weibo.jpg")
    # 显示词云文件看看
    plt.imshow(word_cloud)
    plt.axis("off")
    plt.show()

create_word_cloud()

