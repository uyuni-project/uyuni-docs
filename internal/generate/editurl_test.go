package generate

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/uyuni-project/uyuni-docs/docbuild/internal/config"
)

func TestEnglishEditURL(t *testing.T) {
	cases := []struct {
		output string
		lang   string
		want   string
	}{
		{"mlm-dsc", "en", englishEditURLPattern},
		{"uyuni-website", "en", englishEditURLPattern},
		{"mlm-webui", "en", ""},
		{"uyuni-webui", "en", ""},
		{"mlm-dsc", "ja", ""},
		{"mlm-dsc", "ko", ""},
		{"mlm-dsc", "zh_CN", ""},
		{"uyuni-website", "ja", ""},
		{"uyuni-website", "ko", ""},
		{"uyuni-website", "zh_CN", ""},
	}
	for _, tc := range cases {
		got := englishEditURL(tc.output, tc.lang)
		if got != tc.want {
			t.Errorf("englishEditURL(%q, %q) = %q, want %q", tc.output, tc.lang, got, tc.want)
		}
	}
}

func TestSiteYMLEditLinkOnlyForEnglishPublicSites(t *testing.T) {
	repo := t.TempDir()
	cfg := &config.Config{
		Languages: []config.Language{
			{Code: "en"},
			{Code: "ja"},
			{Code: "ko"},
			{Code: "zh_CN"},
		},
		Products: map[string]config.Product{
			"mlm": {
				Antora: config.AntoraProduct{Name: "docs", Title: "MLM"},
				UI:     config.UIConfig{Bundle: "./branding/default-ui/mlm/ui-bundle.zip"},
				Outputs: map[string]config.Output{
					"mlm-dsc": {
						Site:              config.OutputSite{Title: "MLM", URL: "https://documentation.suse.com/multi-linux-manager/5.2/", StartPage: "docs::index.adoc"},
						SupplementalFiles: "./branding/supplemental-ui/mlm/susecom-2025",
					},
					"mlm-webui": {
						Site:              config.OutputSite{Title: "MLM", URL: "/", StartPage: "docs::index.adoc"},
						SupplementalFiles: "translations/{lang}/supplemental-ui",
					},
				},
			},
			"uyuni": {
				Antora: config.AntoraProduct{Name: "uyuni", Title: "Uyuni"},
				UI:     config.UIConfig{Bundle: "./branding/default-ui/uyuni/ui-bundle.zip"},
				Outputs: map[string]config.Output{
					"uyuni-website": {
						Site:              config.OutputSite{Title: "Uyuni", URL: "https://www.uyuni-project.org/uyuni-docs/", StartPage: "uyuni::index.adoc"},
						SupplementalFiles: "./branding/supplemental-ui/uyuni/uyuni-2023",
					},
					"uyuni-webui": {
						Site:              config.OutputSite{Title: "Uyuni", URL: "/", StartPage: "uyuni::index.adoc"},
						SupplementalFiles: "translations/{lang}/supplemental-ui",
					},
				},
			},
		},
	}

	wantsLink := map[string]bool{
		"en/mlm-dsc.site.yml":          true,
		"en/uyuni-website.site.yml":    true,
		"en/mlm-webui.site.yml":        false,
		"en/uyuni-webui.site.yml":      false,
		"ja/mlm-dsc.site.yml":          false,
		"ja/uyuni-website.site.yml":    false,
		"ko/mlm-dsc.site.yml":          false,
		"ko/uyuni-website.site.yml":    false,
		"zh_CN/mlm-dsc.site.yml":       false,
		"zh_CN/uyuni-website.site.yml": false,
	}

	for rel, want := range wantsLink {
		parts := strings.Split(rel, "/")
		lang, file := parts[0], parts[1]
		output := strings.TrimSuffix(file, ".site.yml")
		product := "mlm"
		if strings.HasPrefix(output, "uyuni") {
			product = "uyuni"
		}
		if err := SiteYML(cfg, product, output, lang, repo); err != nil {
			t.Fatalf("SiteYML %s: %v", rel, err)
		}
		body, err := os.ReadFile(filepath.Join(repo, "translations", lang, file))
		if err != nil {
			t.Fatalf("read %s: %v", rel, err)
		}
		text := string(body)
		has := strings.Contains(text, "edit_url:")
		if has != want {
			t.Errorf("%s edit_url present=%v, want %v\n%s", rel, has, want, text)
		}
		if want && !strings.Contains(text, "\n    edit_url: '"+englishEditURLPattern+"'\n") {
			t.Errorf("%s edit_url is not on its own line\n%s", rel, text)
		}
		if !strings.Contains(text, "\noutput:\n") {
			t.Errorf("%s output key was joined to the line above\n%s", rel, text)
		}
		if !want && strings.Contains(text, "translations/"+lang) == false {
			t.Errorf("%s lost its content start_path", rel)
		}
	}
}
