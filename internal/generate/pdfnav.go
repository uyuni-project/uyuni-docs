package generate

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

// xrefRe matches lines like: * xref:some/file.adoc[Title]
// with any number of leading asterisks.
var xrefRe = regexp.MustCompile(`^(\*+)\s+xref:([^[]+)\.adoc\[.*\]`)

// headingRe matches plain bullet lines that are section headings (no xref).
var headingRe = regexp.MustCompile(`^(\*+)\s+(.+)`)

// headingMarker is "= " repeated per depth for plain headings
var headingPrefix = []string{"= ", "== ", "=== ", "==== ", "===== "}

// PDFNav reads nav-{book}-guide.adoc from srcDir and writes
// nav-{book}-guide.pdf.{lang}.adoc to the same directory.
//
// Transformation rules (matching Makefile pdf-book-create-index):
//   * xref:FILE.adoc[T]      -> include::modules/{book}/pages/FILE.adoc[leveloffset=+0]
//   ** xref:FILE.adoc[T]     -> include::modules/{book}/pages/FILE.adoc[leveloffset=+1]
//   *** xref:FILE.adoc[T]    -> include::modules/{book}/pages/FILE.adoc[leveloffset=+2]
//   **** xref:FILE.adoc[T]   -> include::modules/{book}/pages/FILE.adoc[leveloffset=+3]
//   ***** xref:FILE.adoc[T]  -> include::modules/{book}/pages/FILE.adoc[leveloffset=+4]
//   * TITLE (no xref)        -> = TITLE
//   ** TITLE                 -> == TITLE
//   etc.
//
// All other lines (comments, ifeval, ifdef, blank lines) are passed through unchanged.
func PDFNav(srcDir, book, lang string) error {
	inPath := filepath.Join(srcDir, fmt.Sprintf("nav-%s-guide.adoc", book))
	outPath := filepath.Join(srcDir, fmt.Sprintf("nav-%s-guide.pdf.%s.adoc", book, lang))

	in, err := os.Open(inPath)
	if err != nil {
		return fmt.Errorf("pdf-nav: open %s: %w", inPath, err)
	}
	defer in.Close()

	out, err := os.Create(outPath)
	if err != nil {
		return fmt.Errorf("pdf-nav: create %s: %w", outPath, err)
	}
	defer out.Close()

	scanner := bufio.NewScanner(in)
	for scanner.Scan() {
		line := scanner.Text()
		transformed := transformNavLine(line, book)
		fmt.Fprintln(out, transformed)
	}
	if err := scanner.Err(); err != nil {
		return fmt.Errorf("pdf-nav: read %s: %w", inPath, err)
	}
	return nil
}

func transformNavLine(line, book string) string {
	trimmed := strings.TrimSpace(line)

	// xref bullet
	if m := xrefRe.FindStringSubmatch(trimmed); m != nil {
		depth := len(m[1]) - 1 // * = 0, ** = 1, etc.
		file := m[2]           // path without .adoc
		return fmt.Sprintf("include::modules/%s/pages/%s.adoc[leveloffset=+%d]", book, file, depth)
	}

	// plain heading bullet (no xref)
	if m := headingRe.FindStringSubmatch(trimmed); m != nil {
		depth := len(m[1]) - 1
		title := m[2]
		if depth < len(headingPrefix) {
			return headingPrefix[depth] + title
		}
		return strings.Repeat("=", depth+1) + " " + title
	}

	return line
}
