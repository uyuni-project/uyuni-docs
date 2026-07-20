// docbuild generates Antora and Asciidoctor-PDF configuration files from config.yml.
//
// Usage:
//
//	docbuild gen-all                                     Generate all configs for all languages
//	docbuild gen-site  -product P -output O -lang L      Generate one site.yml
//	docbuild gen-antora -product P -lang L               Generate one antora.yml
//	docbuild gen-entities -product P -lang L             Generate one entities.adoc
//	docbuild gen-pdf-nav -book B -lang L -dir D          Generate PDF nav from Antora nav file
//	docbuild inject-lang-selector -output O              Inject language selector into header-content.hbs
//	docbuild collect-pdfs -product P -src S -dest D      Move PDFs into dest/{lang}/ structure
package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/uyuni-project/uyuni-docs/docbuild/internal/config"
	"github.com/uyuni-project/uyuni-docs/docbuild/internal/generate"
)

const defaultConfig = "config.yml"
const defaultContentDir = "modules" // Antora modules dir relative to start_path

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(1)
	}

	// Resolve repo root as the directory containing this binary's config.yml,
	// defaulting to the current working directory.
	repoRoot, err := os.Getwd()
	if err != nil {
		fatalf("getting working directory: %v", err)
	}

	subcommand := os.Args[1]
	args := os.Args[2:]

	switch subcommand {
	case "gen-all":
		runGenAll(repoRoot, args)
	case "gen-site":
		runGenSite(repoRoot, args)
	case "gen-antora":
		runGenAntora(repoRoot, args)
	case "gen-entities":
		runGenEntities(repoRoot, args)
	case "inject-lang-selector":
		runInjectLangSelector(repoRoot, args)
	case "gen-pdf-nav":
		runGenPDFNav(repoRoot, args)
	case "collect-pdfs":
		runCollectPDFs(repoRoot, args)
	case "get-pdf-prefix":
		runGetPDFPrefix(repoRoot, args)
	case "get-content-dir":
		runGetContentDir(repoRoot, args)
	case "help", "-h", "--help":
		usage()
	default:
		fatalf("unknown subcommand %q — run 'docbuild help' for usage", subcommand)
	}
}

func runGenAll(repoRoot string, args []string) {
	fs := flag.NewFlagSet("gen-all", flag.ExitOnError)
	cfgPath := fs.String("config", defaultConfig, "path to config.yml")
	contentDir := fs.String("content-dir", defaultContentDir, "Antora modules directory relative to start_path")
	_ = fs.Parse(args)

	cfg := mustLoad(filepath.Join(repoRoot, *cfgPath))
	if err := generate.All(cfg, repoRoot, *contentDir); err != nil {
		fatalf("gen-all: %v", err)
	}
	fmt.Println("docbuild: generated all configs")
}

func runGenSite(repoRoot string, args []string) {
	fs := flag.NewFlagSet("gen-site", flag.ExitOnError)
	cfgPath := fs.String("config", defaultConfig, "path to config.yml")
	product := fs.String("product", "", "product name (required)")
	output := fs.String("output", "", "output target name (required)")
	lang := fs.String("lang", "", "language code (required)")
	_ = fs.Parse(args)

	requireFlags(fs, "product", "output", "lang")
	cfg := mustLoad(filepath.Join(repoRoot, *cfgPath))
	if err := generate.SiteYML(cfg, *product, *output, *lang, repoRoot); err != nil {
		fatalf("gen-site: %v", err)
	}
}

func runGenAntora(repoRoot string, args []string) {
	fs := flag.NewFlagSet("gen-antora", flag.ExitOnError)
	cfgPath := fs.String("config", defaultConfig, "path to config.yml")
	product := fs.String("product", "", "product name (required)")
	lang := fs.String("lang", "", "language code (required)")
	contentDir := fs.String("content-dir", defaultContentDir, "Antora modules directory relative to start_path")
	_ = fs.Parse(args)

	requireFlags(fs, "product", "lang")
	cfg := mustLoad(filepath.Join(repoRoot, *cfgPath))
	if err := generate.AntoraYML(cfg, *product, *lang, repoRoot, *contentDir); err != nil {
		fatalf("gen-antora: %v", err)
	}
}

func runGenEntities(repoRoot string, args []string) {
	fs := flag.NewFlagSet("gen-entities", flag.ExitOnError)
	cfgPath := fs.String("config", defaultConfig, "path to config.yml")
	product := fs.String("product", "", "product name (required)")
	lang := fs.String("lang", "", "language code (required)")
	_ = fs.Parse(args)

	requireFlags(fs, "product", "lang")
	cfg := mustLoad(filepath.Join(repoRoot, *cfgPath))
	if err := generate.EntitiesAdoc(cfg, *product, *lang, repoRoot); err != nil {
		fatalf("gen-entities: %v", err)
	}
}

func runInjectLangSelector(repoRoot string, args []string) {
	fs := flag.NewFlagSet("inject-lang-selector", flag.ExitOnError)
	cfgPath := fs.String("config", defaultConfig, "path to config.yml")
	hbsPath := fs.String("hbs", "", "path to header-content.hbs to modify (required)")
	_ = fs.Parse(args)

	requireFlags(fs, "hbs")
	cfg := mustLoad(filepath.Join(repoRoot, *cfgPath))
	fullHBS := filepath.Join(repoRoot, *hbsPath)
	if err := generate.InjectLangSelector(cfg, fullHBS); err != nil {
		fatalf("inject-lang-selector: %v", err)
	}
}

func runGenPDFNav(repoRoot string, args []string) {
	fs := flag.NewFlagSet("gen-pdf-nav", flag.ExitOnError)
	book := fs.String("book", "", "book name, e.g. administration (required)")
	lang := fs.String("lang", "", "language code, e.g. en (required)")
	dir := fs.String("dir", "", "directory containing nav-{book}-guide.adoc (required)")
	_ = fs.Parse(args)

	requireFlags(fs, "book", "lang", "dir")
	srcDir := filepath.Join(repoRoot, *dir)
	if err := generate.PDFNav(srcDir, *book, *lang); err != nil {
		fatalf("gen-pdf-nav: %v", err)
	}
}

func runCollectPDFs(repoRoot string, args []string) {
	fs := flag.NewFlagSet("collect-pdfs", flag.ExitOnError)
	product := fs.String("product", "", "product prefix, e.g. mlm (required)")
	src := fs.String("src", "build", "source build directory (absolute or relative to repo root)")
	dest := fs.String("dest", "build/pdf", "destination directory (absolute or relative to repo root)")
	langsStr := fs.String("langs", "en ja zh_CN ko", "space-separated list of language codes")
	_ = fs.Parse(args)

	requireFlags(fs, "product")

	srcDir := *src
	if !filepath.IsAbs(srcDir) {
		srcDir = filepath.Join(repoRoot, srcDir)
	}
	destDir := *dest
	if !filepath.IsAbs(destDir) {
		destDir = filepath.Join(repoRoot, destDir)
	}

	langs := strings.Fields(*langsStr)
	if err := generate.CollectPDFs(*product, srcDir, destDir, langs); err != nil {
		fatalf("collect-pdfs: %v", err)
	}
}

func runGetPDFPrefix(repoRoot string, args []string) {
	fs := flag.NewFlagSet("get-pdf-prefix", flag.ExitOnError)
	cfgPath := fs.String("config", defaultConfig, "path to config.yml")
	product := fs.String("product", "", "product name, e.g. mlm (required)")
	_ = fs.Parse(args)

	requireFlags(fs, "product")
	cfg := mustLoad(filepath.Join(repoRoot, *cfgPath))
	p, ok := cfg.Products[*product]
	if !ok {
		fatalf("get-pdf-prefix: unknown product %q", *product)
	}
	if p.PDF.Prefix == "" {
		// Fall back to the product key name if no prefix is configured.
		fmt.Print(*product)
	} else {
		fmt.Print(p.PDF.Prefix)
	}
}

func runGetContentDir(repoRoot string, args []string) {
	fs := flag.NewFlagSet("get-content-dir", flag.ExitOnError)
	cfgPath := fs.String("config", defaultConfig, "path to config.yml")
	lang := fs.String("lang", "", "language code, e.g. zh_CN (required)")
	_ = fs.Parse(args)

	requireFlags(fs, "lang")
	cfg := mustLoad(filepath.Join(repoRoot, *cfgPath))
	l, err := cfg.LanguageByCode(*lang)
	if err != nil {
		fatalf("get-content-dir: %v", err)
	}
	fmt.Print(l.ContentPath())
}

func mustLoad(path string) *config.Config {
	cfg, err := config.Load(path)
	if err != nil {
		fatalf("loading config: %v", err)
	}
	return cfg
}

func requireFlags(fs *flag.FlagSet, names ...string) {
	for _, name := range names {
		f := fs.Lookup(name)
		if f == nil || f.Value.String() == "" {
			fatalf("-%s is required", name)
		}
	}
}

func fatalf(format string, a ...any) {
	fmt.Fprintf(os.Stderr, "docbuild: "+format+"\n", a...)
	os.Exit(1)
}

func usage() {
	fmt.Print(`docbuild — uyuni-docs build config generator

Subcommands:
  gen-all                                    Generate all configs for all languages
  gen-site  -product P -output O -lang L     Generate translations/{lang}/{output}.site.yml
  gen-antora -product P -lang L              Generate translations/{lang}/antora.yml
  gen-entities -product P -lang L            Generate branding/pdf/entities.adoc
  gen-pdf-nav -book B -lang L -dir D         Generate nav-{book}-guide.pdf.{lang}.adoc from Antora nav
  inject-lang-selector -hbs PATH             Inject language selector into header-content.hbs
  get-pdf-prefix -product P                              Print the PDF filename prefix for a product
  get-content-dir -lang L                                Print the content source directory for a language
  collect-pdfs -product P [-src S] [-dest D] [-langs L]  Move PDFs into dest/{lang}/ structure

Common flags:
  -config PATH    Path to config.yml (default: config.yml)

Run from the repository root.
`)
}
