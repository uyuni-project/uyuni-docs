// Package config loads and validates the build configuration from config.yml.
package config

import (
	"fmt"
	"os"

	"gopkg.in/yaml.v3"
)

// Config is the top-level structure of config.yml.
type Config struct {
	Asciidoc          map[string]any       `yaml:"asciidoc"`
	Products          map[string]Product   `yaml:"products"`
	Languages         []Language           `yaml:"languages"`
	Antora            AntoraConfig         `yaml:"antora"`
	AsciidocExtensions []string            `yaml:"asciidoc_extensions"`
}

// Product describes a documentation product (mlm or uyuni).
type Product struct {
	Antora   AntoraProduct      `yaml:"antora"`
	Asciidoc ProductAsciidoc    `yaml:"asciidoc"`
	Sections []string           `yaml:"sections"`
	PDF      PDFConfig          `yaml:"pdf"`
	UI       UIConfig           `yaml:"ui"`
	Outputs  map[string]Output  `yaml:"outputs"`
}

// AntoraProduct holds the Antora component name and title for a product.
type AntoraProduct struct {
	Name  string `yaml:"name"`
	Title string `yaml:"title"`
}

// ProductAsciidoc holds product-specific AsciiDoc attributes.
type ProductAsciidoc struct {
	Attributes map[string]any `yaml:"attributes"`
}

// PDFConfig holds PDF artifact naming for a product.
type PDFConfig struct {
	TarName string `yaml:"tar_name"` // e.g. suse-multi-linux-manager-docs → _en-pdf.zip
	OBSName string `yaml:"obs_name"` // e.g. susemanager-docs → _en.tar.gz
}

// UIConfig holds the Antora UI bundle path for a product.
type UIConfig struct {
	Bundle string `yaml:"bundle"`
}

// Output describes one named HTML output target.
type Output struct {
	Site             OutputSite `yaml:"site"`
	SupplementalFiles string    `yaml:"supplemental_files"`
	LanguageSelector bool       `yaml:"language_selector"`
	OBS              bool       `yaml:"obs"`
}

// OutputSite holds the site-level metadata for an output target.
type OutputSite struct {
	Title     string `yaml:"title"`
	URL       string `yaml:"url"`
	StartPage string `yaml:"start_page"`
}

// Language describes one supported build language.
type Language struct {
	Code       string     `yaml:"code"`
	Locale     string     `yaml:"locale"`
	DateFormat string     `yaml:"date_format"`
	PDFTheme   PDFTheme   `yaml:"pdf_theme"`
	CJK        bool       `yaml:"cjk"`
	FlagSVG    string     `yaml:"flag_svg"`
	Nation     string     `yaml:"nation"`
	Label      string     `yaml:"label"`
}

// PDFTheme maps product names to PDF theme names for a language.
type PDFTheme struct {
	MLM   string `yaml:"mlm"`
	Uyuni string `yaml:"uyuni"`
}

// AntoraConfig holds global Antora extensions.
type AntoraConfig struct {
	Extensions []string `yaml:"extensions"`
}

// Load reads and parses config.yml from the given path.
func Load(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading %s: %w", path, err)
	}
	var cfg Config
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return nil, fmt.Errorf("parsing %s: %w", path, err)
	}
	if err := validate(&cfg); err != nil {
		return nil, fmt.Errorf("invalid config: %w", err)
	}
	return &cfg, nil
}

func validate(cfg *Config) error {
	if len(cfg.Products) == 0 {
		return fmt.Errorf("no products defined")
	}
	if len(cfg.Languages) == 0 {
		return fmt.Errorf("no languages defined")
	}
	for name, p := range cfg.Products {
		if p.Antora.Name == "" {
			return fmt.Errorf("product %q: antora.name is required", name)
		}
		if len(p.Sections) == 0 {
			return fmt.Errorf("product %q: sections list is empty", name)
		}
		if len(p.Outputs) == 0 {
			return fmt.Errorf("product %q: no outputs defined", name)
		}
	}
	for _, lang := range cfg.Languages {
		if lang.Code == "" {
			return fmt.Errorf("language entry missing code")
		}
	}
	return nil
}

// LanguageByCode returns the Language with the given code, or an error.
func (c *Config) LanguageByCode(code string) (Language, error) {
	for _, l := range c.Languages {
		if l.Code == code {
			return l, nil
		}
	}
	return Language{}, fmt.Errorf("language %q not found in config", code)
}
