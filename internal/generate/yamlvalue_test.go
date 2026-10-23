package generate

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/uyuni-project/uyuni-docs/docbuild/internal/config"
)

func TestYAMLValuePreservesTrailingZero(t *testing.T) {
	cases := []struct {
		in   any
		want string
	}{
		{"2026.10", `"2026.10"`},
		{"3006.0", `"3006.0"`},
		{"5.2", "5.2"},
		{"4.3", "4.3"},
		{"true", "true"},
		{"false", "false"},
		{"Uyuni", "Uyuni"},
		{16, "16"},
	}
	for _, tc := range cases {
		got := yamlValue(tc.in)
		if got != tc.want {
			t.Errorf("yamlValue(%#v) = %q, want %q", tc.in, got, tc.want)
		}
	}
}

func TestSiteYMLQuotesProductNumber(t *testing.T) {
	repo := t.TempDir()
	cfg := &config.Config{
		Languages: []config.Language{{Code: "en"}},
		Asciidoc:  map[string]any{"saltversion": "3006.0"},
		Products: map[string]config.Product{
			"uyuni": {
				UI: config.UIConfig{Bundle: "./branding/default-ui/uyuni/ui-bundle.zip"},
				Asciidoc: config.ProductAsciidoc{Attributes: map[string]any{
					"productnumber": "2026.10",
					"productname":   "Uyuni",
				}},
				Outputs: map[string]config.Output{
					"uyuni-website": {
						Site: config.OutputSite{
							Title:     "Uyuni",
							URL:       "https://www.uyuni-project.org/uyuni-docs/",
							StartPage: "uyuni::index.adoc",
						},
						SupplementalFiles: "./branding/supplemental-ui/uyuni/uyuni-2023",
					},
				},
			},
		},
	}
	if err := SiteYML(cfg, "uyuni", "uyuni-website", "en", repo); err != nil {
		t.Fatal(err)
	}
	body, err := os.ReadFile(filepath.Join(repo, "translations", "en", "uyuni-website.site.yml"))
	if err != nil {
		t.Fatal(err)
	}
	text := string(body)
	for _, want := range []string{
		`productnumber: "2026.10"`,
		`saltversion: "3006.0"`,
		"productname: Uyuni",
	} {
		if !strings.Contains(text, want) {
			t.Errorf("site.yml missing %q\n%s", want, text)
		}
	}
}
