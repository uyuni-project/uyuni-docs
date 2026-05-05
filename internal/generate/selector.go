// Package generate — language selector injection.
// Replaces the Makefile's enable-html-language-selector sed macro.
package generate

import (
	"fmt"
	"os"
	"strings"

	"github.com/uyuni-project/uyuni-docs/docbuild/internal/config"
)

const langSelectorPlaceholder = "<!-- LANGUAGESELECTOR -->"

// langSelectorEntry produces the HTML anchor to replace the placeholder for one language.
func langSelectorEntry(code, flagSVG, nation, label string) string {
	return fmt.Sprintf(
		`<a role="button" class="navbar-item" id="%s" onclick="selectLanguage(this.id)"><img src="{{uiRootPath}}/img/%s.svg" class="langIcon %s">&nbsp;%s</a>`,
		code, flagSVG, nation, label,
	)
}

// InjectLangSelector replaces the <!-- LANGUAGESELECTOR --> comment in the given
// header-content.hbs file with anchor tags for every non-English language that
// has a flag_svg defined in the config. The file is modified in place.
func InjectLangSelector(cfg *config.Config, hbsPath string) error {
	data, err := os.ReadFile(hbsPath)
	if err != nil {
		return fmt.Errorf("reading %s: %w", hbsPath, err)
	}

	var anchors []string
	for _, lang := range cfg.Languages {
		if lang.Code == "en" || lang.FlagSVG == "" {
			continue
		}
		anchors = append(anchors, langSelectorEntry(lang.Code, lang.FlagSVG, lang.Nation, lang.Label))
	}

	replacement := strings.Join(anchors, "\n")
	updated := strings.ReplaceAll(string(data), langSelectorPlaceholder, replacement)

	return os.WriteFile(hbsPath, []byte(updated), 0o644)
}
