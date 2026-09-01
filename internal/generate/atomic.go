// Package generate — atomic file writes.
//
// The PDF matrix builds books in parallel, and several books of the same
// language regenerate identical shared files (entities.adoc in particular).
// A plain os.WriteFile truncates before it writes, so a concurrent
// asciidoctor-pdf can read a half-written file. Writing to a temporary file in
// the same directory and renaming it into place makes every write all-or-nothing:
// a reader sees either the previous complete file or the new complete one.
package generate

import (
	"fmt"
	"os"
	"path/filepath"
)

// atomicWriteFile writes data to path via a temporary file and a rename.
// The temporary file lives in the destination directory so the rename stays
// within one filesystem.
func atomicWriteFile(path string, data []byte, perm os.FileMode) error {
	dir := filepath.Dir(path)
	tmp, err := os.CreateTemp(dir, "."+filepath.Base(path)+".tmp*")
	if err != nil {
		return fmt.Errorf("create temp file in %s: %w", dir, err)
	}
	tmpName := tmp.Name()

	// Any failure from here on must not leave the temporary file behind.
	defer func() {
		tmp.Close()
		os.Remove(tmpName)
	}()

	if _, err := tmp.Write(data); err != nil {
		return fmt.Errorf("write %s: %w", tmpName, err)
	}
	if err := tmp.Close(); err != nil {
		return fmt.Errorf("close %s: %w", tmpName, err)
	}
	// CreateTemp makes the file 0600; restore the caller's mode.
	if err := os.Chmod(tmpName, perm); err != nil {
		return fmt.Errorf("chmod %s: %w", tmpName, err)
	}
	if err := os.Rename(tmpName, path); err != nil {
		return fmt.Errorf("rename %s -> %s: %w", tmpName, path, err)
	}
	return nil
}
