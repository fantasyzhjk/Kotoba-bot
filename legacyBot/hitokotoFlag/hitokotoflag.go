package main

import (
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"math/rand"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

type res struct {
	Hitokoto string `json:"hitokoto"`
	From     string `json:"from"`
}

var (
	h      bool
	q      bool
	a      string
	s      bool
	t      string
	dbpath string
)

func init() {
	flag.BoolVar(&h, "h", false, "帮助")
	flag.BoolVar(&q, "q", false, "查询所有自定义")
	flag.BoolVar(&s, "s", false, "获取一言")
	flag.StringVar(&a, "a", "", "导入自定义一言（格式：“一言 - 作者”）")
	flag.StringVar(&t, "t", "", "指定一言类型（a~m）")
	flag.StringVar(&dbpath, "dbpath", "", "sqlite路径")
	flag.Usage = usage
	sqlInit()
}

func usage() {
	fmt.Fprintf(os.Stderr, `一言 by: Zh_Jk
Usage: hitokoto [-h] [-q] [-s -t "type"] [-add "hitokoto-author"]

Options:
`)
	flag.PrintDefaults()
}

func get(c string) {
	params := url.Values{}
	URL, _ := url.Parse("https://v1.hitokoto.cn/")
	params.Set("c", c)
	URL.RawQuery = params.Encode()
	// fmt.Println(URL.String())
	timeout := time.Duration(10 * time.Second)
	client := http.Client{
		Timeout: timeout,
	}
	hitokoto, err := client.Get(URL.String())
	if err != nil {
		fmt.Println("获取失败惹qwq...")
		return
	}
	defer hitokoto.Body.Close()
	body, _ := ioutil.ReadAll(hitokoto.Body)
	// fmt.Println(string(body))
	var result res
	_ = json.Unmarshal(body, &result)
	fmt.Printf("[%v] - %v", result.Hitokoto, result.From)
}

func sqlInit() {
	db, err := sql.Open("sqlite3", "dbpath")
	if err != nil {
		panic(err)
	}
	sqlTable := `
    CREATE TABLE IF NOT EXISTS Hitokoto(
        uid INTEGER PRIMARY KEY AUTOINCREMENT,
        hitokoto VARCHAR(64) NULL,
        author VARCHAR(64) NULL,
        created VARCHAR(64) NULL
    );
    `
	db.Exec(sqlTable)
}

func sqlInsert(hitokoto, author string) {
	created := time.Now().Format("2006-01-02")
	// fmt.Println(created)
	db, err := sql.Open("sqlite3", "dbpath")
	if err != nil {
		fmt.Println("导入失败惹qwq...")
		return
	}
	stmt, err := db.Prepare("INSERT INTO Hitokoto(hitokoto, author, created) values(?,?,?)")
	if err != nil {
		fmt.Println("导入失败惹qwq...")
		return
	}
	res, err := stmt.Exec(hitokoto, author, created)
	if err != nil {
		fmt.Println("导入失败惹qwq...")
		return
	}
	id, err := res.LastInsertId()
	if err != nil {
		fmt.Println("导入失败惹qwq...")
		return
	}
	fmt.Println("导入完成喵~ uid为：", id)
}

func sqlQuery() {
	db, err := sql.Open("sqlite3", "dbpath")
	rows, err := db.Query("SELECT * FROM Hitokoto")
	if err != nil {
		fmt.Println("获取失败惹qwq...")
		return
	}
	var uid int
	var hitokoto string
	var author string
	var created string
	fmt.Printf("所有自定义数据：")
	for rows.Next() {
		err = rows.Scan(&uid, &hitokoto, &author, &created)
		if err != nil {
			fmt.Println("获取失败惹qwq...")
			return
		}
		fmt.Printf("\n[%v] - %v (%v/%v)", hitokoto, author, created, uid)
	}
	rows.Close()

}

func sqlRead(id int) {
	db, err := sql.Open("sqlite3", "./hitokoto.db")
	var hitokoto string
	var author string
	if id == 0 {
		err = db.QueryRow("SELECT hitokoto,author FROM Hitokoto ORDER BY RANDOM() limit 1").Scan(&hitokoto, &author)
	} else {
		err = db.QueryRow("SELECT hitokoto,author FROM Hitokoto WHERE uid=?", id).Scan(&hitokoto, &author)
	}
	if err != nil {
		fmt.Println("获取失败惹qwq...")
		return
	}
	fmt.Printf("[%v] - %v", hitokoto, author)
}

func randString() string {
	rand.Seed(time.Now().UnixNano())
	return string(97 + rand.Intn(109-97))
}

func main() {
	flag.Parse()
	if h {
		flag.Usage()
	}
	if dbpath != "" {
		if s {
			if t == "" {
				t = randString()
				if t == "m" {
					sqlRead(0)
				} else {
					get("")
				}
			} else if t == "m" {
				sqlRead(0)
			} else {
				get(t)
			}
		}
		if q {
			sqlQuery()
		}
		if a != "" {
			defer func() {
				err := recover()
				if err != nil {
					fmt.Printf("格式错误：%v", err)
				}
			}()
			ret := strings.Split(a, "-")
			sqlInsert(ret[0], ret[1])
		}
	}

}
