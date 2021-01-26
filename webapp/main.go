package main

import (
	"fmt"
	"log"
	"net/http"

	"k8s.io/klog/v2"
)

func myhandler(w http.ResponseWriter, r *http.Request) {

	fmt.Fprintf(w, "Hello from Go!\n")
}

func main() {
	klog.InfoS("Starting pod...")

	http.HandleFunc("/", myhandler)

	log.Fatal(http.ListenAndServe(":8090", nil))
}
