import asyncio

import matplotlib.pyplot as plt
import matplotlib.tri as tri
from matplotlib.axes import Axes
from matplotlib.figure import Figure
from wordcloud import WordCloud
import re
from typing import Optional

from pyscript import display, fetch

# 匹配记录到列表
async def load(path: str = "savedrecs.txt") -> list[str]:
    # 用 pyfetch 代替 open()
    resp = await fetch(path)
    text = await resp.text()
    pattern = r"PT (.*?)(?= PT |$)"
    matches : list[str] = re.findall(pattern, text, flags=re.DOTALL)
    display(len(matches), target='output')
    return matches

# 按照值排序，reverse为True从大到小
def sort_by_value(data : dict, reverse=False):
    return dict(sorted(data.items(), key=lambda item: item[1], reverse=reverse))

# 对于单个值返回进行统计，适用于年份、出版商等情况
def get_count_single(target : list[str]) -> dict[str, int]:
    result = {}
    for key in target:
        if result.get(key):
            result[key] += 1
        else:
            result[key] = 1
    return result

# 匹配期刊名称
def match_so(entry: str) -> Optional[str]:
    # 匹配 "SO " 开头到行尾，不跨行
    m = re.search(r"(?m)^SO (.+)$", entry)
    return m.group(1).strip() if m else None

# 画词云图
def draw_word_cloud(
        data : dict,
        title : Optional[str] = '',
        width=1600,
        height=1000,
        bgc : str = 'mintcream',
        color_func=None,
        max_font_size=300,  # 最大字号更大
        relative_scaling=0.5,  # 越大差距越明显
        **kwargs
) -> Figure:
    wordcloud : WordCloud = WordCloud(
        width=width,
        height=height,
        background_color=bgc,
        margin=0,
        prefer_horizontal=1.0,
        color_func=color_func,
        max_font_size=300,  # 最大字号更大
        relative_scaling=0.3,  # 越大差距越明显
    ).generate_from_frequencies(data)

    fig = plt.figure(figsize=(width / 100, height / 100), dpi=100)
    ax : Axes = fig.gca()
    ax.imshow(wordcloud, interpolation='bilinear')
    ax.set_axis_off()
    fig.subplots_adjust(left=0, right=1, top=0.9, bottom=0)

    if title:
        ax.set_title(title)
    ax.set(**kwargs)
    return fig

async def run_wordcloud(path="main.txt"):
    records = await load(path)

    journals = [match_so(e) for e in records]
    data = get_count_single([j for j in journals if j])
    data = sort_by_value(data, reverse=True)

    fig = draw_word_cloud(data)
    display(fig, target="output")

run_wordcloud()