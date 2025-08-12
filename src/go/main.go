package main

import (
	"embed"
	"io/fs"
	"log"
	"net/http"
	"path"
)

//go:embed static
var embedded embed.FS
var static fs.FS = embedded

func init() {
	var err error
	static, err = fs.Sub(static, "static")
	if err != nil {
		panic("Failed to create subdirectory for static files: " + err.Error())
	}
}

type StaticFS struct {
	http.Handler
	Fs fs.FS
}

func NewStaticFS(fsys fs.FS) *StaticFS {
	return &StaticFS{
		Handler: http.FileServer(http.FS(fsys)),
		Fs:      fsys,
	}
}

func (s *StaticFS) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	// Serve static files from the embedded filesystem
	log.Println("Requested URL:", r.URL.Path)

	_, err := s.resolveFile(r)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	s.Handler.ServeHTTP(w, r)
}

func (s *StaticFS) resolveFile(r *http.Request) (newPath string, err error) {
	checks := []func(string, fs.File) (string, error){s.isExact, s.isStaticHtml}

	for _, check := range checks {
		newPath, err = check(r.URL.Path, nil)
		if err == nil {
			break
		}
	}

	fsFile, err := s.Fs.Open(newPath)
	if err != nil {
		log.Println("Could not open")
		return "", err
	}

	stats, err := fsFile.Stat()
	if err != nil {
		log.Println("Could not stat")
		return "", err
	}

	if stats.IsDir() {
		log.Println("IsDir")
		r.URL.Path = path.Join(newPath, "index.html")
		return s.resolveFile(r)
	}

	return newPath, nil
}

func (s *StaticFS) isExact(path string, _ fs.File) (string, error) {
	_, err := s.Fs.Open(path)
	if err != nil {
		log.Println("Could not open in isExact", path)
		return "", err
	}
	return path, nil
}

func (s *StaticFS) isStaticHtml(path string, fsFile fs.File) (string, error) {
	log.Println("isStaticHTML", path)
	return s.isExact(path+".html", nil)
}

func main() {
	fs.WalkDir(static, ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			log.Println("Error walking directory:", err)
			return err
		}
		log.Println("Embedded file:", path)
		return nil
	})

	mux := http.NewServeMux()
	mux.Handle("/", NewStaticFS(static))
	server := &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}
	server.ListenAndServe()
}
