package generate

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// CollectPDFs moves PDFs for the given product from the scattered
// build/{lang}/pdf/ directories into a flat dest/{lang}/ structure suitable
// for the documentation.suse.com (susecom-2025) publish pipeline.
//
// Only files whose names start with "{product}_" and end with ".pdf" are
// moved — this ensures that, for example, an MLM collect does not pick up
// Uyuni PDFs if both happened to be built into the same build tree.
//
// After moving, the now-empty build/{lang}/pdf/ source directory is removed.
// Missing source directories (language not yet built) are silently skipped.
func CollectPDFs(product, srcBuildDir, destDir string, langs []string) error {
	prefix := product + "_"

	for _, lang := range langs {
		srcPDFDir := filepath.Join(srcBuildDir, lang, "pdf")

		entries, err := os.ReadDir(srcPDFDir)
		if os.IsNotExist(err) {
			fmt.Printf("collect-pdfs: %s: no PDFs found at %s, skipping\n", lang, srcPDFDir)
			continue
		}
		if err != nil {
			return fmt.Errorf("collect-pdfs: read %s: %w", srcPDFDir, err)
		}

		destLangDir := filepath.Join(destDir, lang)
		if err := os.MkdirAll(destLangDir, 0o755); err != nil {
			return fmt.Errorf("collect-pdfs: mkdir %s: %w", destLangDir, err)
		}

		moved := 0
		for _, entry := range entries {
			name := entry.Name()
			if entry.IsDir() || !strings.HasPrefix(name, prefix) || !strings.HasSuffix(name, ".pdf") {
				continue
			}
			src := filepath.Join(srcPDFDir, name)
			dst := filepath.Join(destLangDir, name)
			if err := os.Rename(src, dst); err != nil {
				return fmt.Errorf("collect-pdfs: move %s → %s: %w", src, dst, err)
			}
			moved++
		}

		fmt.Printf("collect-pdfs: %s: moved %d PDF(s) → %s\n", lang, moved, destLangDir)

		// Remove the source directory; only succeeds if now empty.
		_ = os.Remove(srcPDFDir)
	}

	return nil
}
