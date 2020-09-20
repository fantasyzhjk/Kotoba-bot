package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"time"
)

type res struct {
	Username      string `json:"username"`
	Playcount     string `json:"playcount"`
	RankedScore   string `json:"ranked_score"`
	TotalScore    string `json:"total_score"`
	PPrank        string `json:"pp_rank"`
	Level         string `json:"level"`
	PPraw         string `json:"pp_raw"`
	Accuracy      string `json:"accuracy"`
	Country       string `json:"country"`
	PPcountryrank string `json:"pp_country_rank"`
}

var (
	h bool
	u string
	k string
)

func init() {
	flag.BoolVar(&h, "h", false, "帮助")
	flag.StringVar(&u, "u", "", "查询玩家数据")
	flag.StringVar(&k, "k", "", "apiKey")
	flag.Usage = usage
}

func usage() {
	fmt.Fprintf(os.Stderr, `osu玩家资料获取 by: Zh_Jk
Usage: osu_getUser [-h] [-u "Player ID"] [-k "apiKey"]

Options:
`)
	flag.PrintDefaults()
}

func get(k, u string) {
	params := url.Values{}
	URL, _ := url.Parse("https://osu.ppy.sh/api/get_user") //URL
	params.Set("k", k)                                     // httpget参数
	params.Set("u", u)
	URL.RawQuery = params.Encode()
	// fmt.Println(URL.String())
	timeout := time.Duration(20 * time.Second) //超时
	client := http.Client{
		Timeout: timeout,
	}
	userdata, err := client.Get(URL.String())
	if err != nil {
		fmt.Print("获取失败惹qwq...")
		return
	}
	defer userdata.Body.Close()
	body, _ := ioutil.ReadAll(userdata.Body) //读取response
	body = body[1 : len(body)-1]             //去除头尾中括号
	// fmt.Println(string(body))
	var result res
	err = json.Unmarshal(body, &result) //json decode
	if err != nil {
		fmt.Print("用户不存在.png")
		return
	}
	Accuracy, _ := strconv.ParseFloat(result.Accuracy, 32)
	Level, _ := strconv.ParseFloat(result.Level, 32)
	// fmt.Printf("%v - %v （Lv%.0f）\n总PP：%v\n游戏排名：#%v（#%v）\n游戏次数：%v\n准确率：%.2f%%\nRank分数：%v\n总分数：%v\n", result.Username, result.Country, Level, result.PPraw, result.PPrank, result.PPcountryrank, result.Playcount, Accuracy, result.RankedScore, result.TotalScore)
	fmt.Printf("%v - %v （Lv%.0f）\n", result.Username, result.Country, Level)
	fmt.Printf("总PP：%v\n", result.PPraw)
	fmt.Printf("游戏排名：#%v（#%v）\n", result.PPrank, result.PPcountryrank)
	fmt.Printf("游戏次数：%v\n", result.Playcount)
	fmt.Printf("准确率：%.2f%%\n", Accuracy)
	fmt.Printf("Rank分数：%v\n", result.RankedScore)
	fmt.Printf("总分数：%v", result.TotalScore)
	// fmt.Println(result)
}

func main() {
	flag.Parse()
	if h {
		flag.Usage()
	}
	if u != "" {
		if k != "" {
			get(k, u)
		} else {
			fmt.Print("请输入apiKey!")
		}
	}
}
