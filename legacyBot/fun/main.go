package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"time"
)

var (
	h   bool
	chp bool
	djt bool
)

func init() {
	flag.BoolVar(&h, "h", false, "帮助")
	flag.BoolVar(&chp, "chp", false, "彩虹屁")
	flag.BoolVar(&djt, "djt", false, "毒鸡汤")
	flag.Usage = usage
}

func usage() {
	fmt.Fprintf(os.Stderr, `osu玩家资料获取 by: Zh_Jk
Usage: fun [-h] [-chp] [-djt]

Options:
`)
	flag.PrintDefaults()
}

func get(u, k string) {
	params := url.Values{}
	URL, _ := url.Parse(u) //URL
	params.Set("k", k)     // httpget参数
	URL.RawQuery = params.Encode()
	// fmt.Println(URL.String())
	timeout := time.Duration(10 * time.Second) //超时
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
	fmt.Print(string(body))
}

func main() {
	flag.Parse()
	if h {
		flag.Usage()
	}
	if chp {
		get("https://chp.shadiao.app/api.php", "")
	}
	if djt {
		get("https://du.shadiao.app/api.php", "")
	}
}
